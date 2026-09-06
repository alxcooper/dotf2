---@module 'lazy'
---@type LazySpec
return {
  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
        mappings = {
          around_next = 'aa',
          inside_next = 'ii',
        },
        n_lines = 500,
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end

      -- Start screen inspired by the classic Vim startify setup.
      local starter = require 'mini.starter'
      local recent_file_skip_patterns = {
        'COMMIT_EDITMSG$',
        '/runtime/doc/',
      }
      -- Keep `q` free for the unindexed "Quit Neovim" starter action.
      local starter_index_keys = vim.split('1234567890abcdefghijklmnoprstuvwxyz', '')

      -- Build the starter header from fortune/cowsay with a static fallback.
      local starter_header = function()
        if vim.fn.executable 'fortune' == 1 and vim.fn.executable 'cowsay' == 1 then
          local lines = vim.fn.systemlist 'fortune | cowsay -f tux'
          if vim.v.shell_error == 0 and #lines > 0 then return table.concat(lines, '\n') end
        end

        return table.concat({
          ' _             _',
          '| | ____   _(_)_ __ ___',
          "| |/ /\\ \\ / / | '_ ` _ \\",
          '|   <  \\ V /| | | | | | |',
          '|_|\\_\\  \\_/ |_|_| |_| |_|',
        }, '\n')
      end

      -- Filter noisy recent-file entries before showing them on the starter.
      local should_skip_recent_file = function(path)
        for _, pattern in ipairs(recent_file_skip_patterns) do
          if path:match(pattern) then return true end
        end

        return false
      end

      local git_root_cache = {}
      -- Resolve and cache the git root for a recent-file path.
      local find_git_root = function(path)
        if vim.fn.executable 'git' ~= 1 then return end

        local dir = vim.fn.fnamemodify(path, ':p:h')
        if git_root_cache[dir] ~= nil then return git_root_cache[dir] or nil end

        local roots = vim.fn.systemlist { 'git', '-C', dir, 'rev-parse', '--show-toplevel' }
        local root = roots[1]
        if vim.v.shell_error ~= 0 or root == nil or root == '' then
          git_root_cache[dir] = false
          return
        end

        git_root_cache[dir] = root
        return root
      end

      -- Change local cwd to the file's git root so Telescope/grep start from the project.
      local change_to_git_root = function(path)
        local root = find_git_root(path)
        if root ~= nil then vim.cmd.lcd(vim.fn.fnameescape(root)) end
      end

      -- Open a recent file after moving local cwd to its project root.
      local edit_recent_file = function(path)
        change_to_git_root(path)
        vim.cmd.edit(vim.fn.fnameescape(path))
      end

      -- Shorten a long directory label while preserving the repo root and tail path.
      local compact_recent_dir = function(path, dir)
        local root = find_git_root(path)
        local root_name = root ~= nil and vim.fn.fnamemodify(root, ':t') or nil
        local compact_dir = dir

        if root ~= nil then
          local absolute_dir = vim.fn.fnamemodify(path, ':p:h')
          local root_prefix = root .. '/'
          if absolute_dir == root then
            compact_dir = ''
          elseif vim.startswith(absolute_dir, root_prefix) then
            compact_dir = absolute_dir:sub(#root_prefix + 1)
          end
        end

        local parts = vim.split(compact_dir, '/', { plain = true, trimempty = true })
        local tail = vim.list_slice(parts, math.max(#parts - 2, 1), #parts)
        local tail_path = table.concat(tail, '/')

        if root_name ~= nil and tail_path ~= '' then return root_name .. '/.../' .. tail_path end
        if root_name ~= nil then return root_name end
        return '.../' .. tail_path
      end

      -- Split a recent file into filename and optional dim path-column label.
      local recent_file_label = function(path)
        local name = vim.fn.fnamemodify(path, ':t')
        local dir = vim.fn.fnamemodify(vim.fn.fnamemodify(path, ':~:.'), ':h')
        if dir == '.' then return name, nil end

        local max_dir_width = 45
        if vim.fn.strdisplaywidth(dir) > max_dir_width then dir = compact_recent_dir(path, dir) end

        return name, dir .. '/'
      end

      -- Build one recent-files section from v:oldfiles, optionally limited to cwd.
      local recent_files_section = function(n, current_dir, section)
        return function()
          local sep = vim.uv.os_uname().sysname == 'Windows_NT' and '\\' or '/'
          local cwd = vim.fn.getcwd() .. sep
          local files = {}

          for _, file in ipairs(vim.v.oldfiles) do
            local path = vim.fn.fnamemodify(file, ':p')
            local in_current_dir = not current_dir or vim.startswith(path, cwd)
            if vim.fn.filereadable(path) == 1 and in_current_dir and not should_skip_recent_file(path) then
              table.insert(files, path)
              if #files >= n then break end
            end
          end

          if #files == 0 then
            return { { name = 'There are no recent files', action = '', section = section } }
          end

          local items = {}
          for _, path in ipairs(files) do
            local name, path_label = recent_file_label(path)
            table.insert(items, {
              name = name,
              action = function() edit_recent_file(path) end,
              section = section,
              _starter_path_label = path_label,
            })
          end

          return items
        end
      end

      -- Add Startify-style one-key indexes to actionable starter items.
      local startify_indexing = function(exclude_sections)
        local excluded = {}
        for _, section in ipairs(exclude_sections or {}) do
          excluded[section] = true
        end

        return function(content)
          local index = 0
          for _, coord in ipairs(starter.content_coords(content, 'item')) do
            local unit = content[coord.line][coord.unit]
            if unit.item.action ~= '' and not excluded[unit.item.section] then
              index = index + 1
              unit.string = ('%s. %s'):format(starter_index_keys[index] or tostring(index), unit.string)
            end
          end

          return content
        end
      end

      -- Align recent-file path labels into a separate column.
      local align_recent_file_paths = function(content)
        local coords = {}
        local name_width = 0

        for _, coord in ipairs(starter.content_coords(content, 'item')) do
          local unit = content[coord.line][coord.unit]
          if unit.item._starter_path_label ~= nil then
            table.insert(coords, coord)
            name_width = math.max(name_width, vim.fn.strdisplaywidth(unit.string))
          end
        end

        for i = #coords, 1, -1 do
          local coord = coords[i]
          local line = content[coord.line]
          local unit = line[coord.unit]
          local padding = string.rep(' ', name_width - vim.fn.strdisplaywidth(unit.string) + 4)
          table.insert(line, coord.unit + 1, {
            string = padding .. unit.item._starter_path_label,
            type = 'recent_path',
            hl = 'MiniStarterRecentPath',
          })
        end

        return content
      end

      -- Keep decorative starter elements subdued and consistent with the theme.
      local set_starter_highlights = function()
        local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })
        local special = vim.api.nvim_get_hl(0, { name = 'Special', link = false })
        vim.api.nvim_set_hl(0, 'MiniStarterHeader', {
          fg = special.fg,
          ctermfg = special.ctermfg,
          bold = false,
        })
        vim.api.nvim_set_hl(0, 'MiniStarterFooter', {
          fg = comment.fg,
          ctermfg = comment.ctermfg,
          bold = false,
          italic = false,
        })
        vim.api.nvim_set_hl(0, 'MiniStarterRecentPath', {
          fg = comment.fg,
          ctermfg = comment.ctermfg,
          italic = false,
        })
      end
      set_starter_highlights()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('custom-mini-starter-highlight', { clear = true }),
        callback = set_starter_highlights,
      })

      starter.setup {
        evaluate_single = true,
        header = starter_header,
        footer = "Vim is charityware. Please read ':help Uganda'.",
        items = {
          recent_files_section(8, true, 'LRU within this dir:'),
          recent_files_section(8, false, 'LRU:'),
          { name = 'Find files', action = 'Telescope find_files', section = 'Telescope' },
          { name = 'Live grep', action = 'Telescope live_grep', section = 'Telescope' },
          { name = 'Recent files', action = 'Telescope oldfiles', section = 'Telescope' },
          { name = 'Help tags', action = 'Telescope help_tags', section = 'Telescope' },
          starter.sections.builtin_actions(),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          startify_indexing { 'Builtin actions' },
          align_recent_file_paths,
          starter.gen_hook.padding(3, 2),
        },
        query_updaters = 'abcdefghijklmnopqrstuvwxyz0123456789_.',
      }

      -- ... and there is more!
      --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
