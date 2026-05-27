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

      starter.setup {
        header = starter_header,
        footer = "Vim is charityware. Please read ':help Uganda'.",
        items = {
          starter.sections.recent_files(8, true, true),
          starter.sections.recent_files(8, false, true),
          { name = 'Find files', action = 'Telescope find_files', section = 'Telescope' },
          { name = 'Live grep', action = 'Telescope live_grep', section = 'Telescope' },
          { name = 'Recent files', action = 'Telescope oldfiles', section = 'Telescope' },
          { name = 'Help tags', action = 'Telescope help_tags', section = 'Telescope' },
          starter.sections.builtin_actions(),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.aligning('center', 'center'),
        },
      }

      -- ... and there is more!
      --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
