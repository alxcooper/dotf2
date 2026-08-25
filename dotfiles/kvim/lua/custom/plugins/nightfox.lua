-- Nightfox — a highly customizable dark colorscheme.
return {
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nightfox').setup {
        options = {
          terminal_colors = true,
        },
      }
      vim.cmd.colorscheme 'nightfox'
    end,
  },
}
