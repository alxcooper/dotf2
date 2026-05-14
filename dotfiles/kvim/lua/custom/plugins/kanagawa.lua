-- Kanagawa — Japanese-inspired palette. Variants:
--   wave   — cool dark blue-grey base, warm accents (default, cool-leaning)
--   dragon — darker, higher contrast, cyan/red dominant (less purple)
--   lotus  — light theme
return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        commentStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        theme = 'wave',
      }
      vim.cmd.colorscheme 'kanagawa-wave'
      -- vim.cmd.colorscheme 'kanagawa-dragon'
    end,
  },
}
