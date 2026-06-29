-- File tree, NerdTree-style.
-- `-` in normal mode: if current buffer is a real file, open tree and reveal it;
-- otherwise, toggle the tree.
return {
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      {
        '-',
        function()
          local api = require 'nvim-tree.api'
          local current_buf = vim.api.nvim_buf_get_name(0)
          local is_tree = vim.bo.filetype == 'NvimTree'
          local is_starter = vim.bo.filetype == 'ministarter'
          local is_special = current_buf == '' or is_tree or is_starter or vim.bo.buftype ~= ''
          if is_special then
            api.tree.toggle()
          else
            api.tree.find_file { open = true, focus = true }
          end
        end,
        desc = 'File tree (NerdTree-style)',
      },
    },
    opts = {
      -- NerdTree-style keymaps inside the tree
      on_attach = function(bufnr)
        local api = require 'nvim-tree.api'
        api.map.on_attach.default(bufnr)

        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = 'nvim-tree: ' .. desc, noremap = true, silent = true, nowait = true })
        end

        -- Remove default '-' (dir_up). Global '-' will close the tree via smart toggle.
        vim.keymap.del('n', '-', { buffer = bufnr })

        map('u', api.tree.change_root_to_parent, 'Up to parent dir')
        map('i', api.node.open.horizontal, 'Open: horizontal split')
        map('s', api.node.open.vertical, 'Open: vertical split')
        map('t', api.node.open.tab, 'Open: new tab')
        map('?', api.tree.toggle_help, 'Help')
      end,
      filters = {
        dotfiles = false, -- NERDTreeShowHidden = 1
        git_ignored = true,
        exclude = {
          '%.env%.local$',
        },
        custom = {
          '^\\.git$',
          '^node_modules$',
          '^coverage$',
          '^log$',
          '^tmp$',
          '\\.tags$',
          'tags\\.lock$',
          '\\.DS_Store$',
          '\\~$',
        },
      },
      actions = {
        open_file = {
          quit_on_open = true, -- NERDTreeQuitOnOpen = 1
        },
        remove_file = {
          close_window = true, -- NERDTreeAutoDeleteBuffer = 1
        },
      },
      git = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
      },
      renderer = {
        highlight_git = 'all', -- colour both filename and icon by git status
        icons = {
          git_placement = 'after', -- git glyph after filename, neo-tree style
          show = { git = true },
          glyphs = {
            git = {
              unstaged = '○',
              staged = '✓',
              unmerged = '',
              renamed = '➜',
              untracked = '?',
              deleted = '✗',
              ignored = '◌',
            },
          },
        },
      },
      view = {
        width = 35,
      },
    },
  },
}
