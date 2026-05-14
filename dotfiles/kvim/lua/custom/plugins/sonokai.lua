return {
  -- Disable kickstart's default tokyonight
  { 'folke/tokyonight.nvim', enabled = false },

  -- Sonokai — modern molokai successor.
  -- Variants: default, atlantis, andromeda, shusia, maia, espresso.
  -- Change `vim.g.sonokai_style` below to try different ones.
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_style = 'default'
      vim.g.sonokai_better_performance = 1
      vim.g.sonokai_enable_italic = true
      -- vim.cmd.colorscheme 'sonokai'  -- left installed; another plugin sets the active colorscheme
    end,
  },
}
