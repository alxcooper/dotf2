-- Add indentation guides even on blank lines

---@module 'lazy'
---@type LazySpec
return {
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  ---@module 'ibl'
  ---@type ibl.config
  opts = {
    indent = { char = '▏' },
    scope = {
      char = '▏',
      show_start = false,
      show_end = false,
    },
  },
}
