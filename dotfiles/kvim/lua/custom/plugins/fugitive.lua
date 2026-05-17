-- tpope/vim-fugitive — git porcelain inside vim.
-- Main entry points:
--   :Git              -- status buffer (stage with `s`, unstage with `u`, commit with `cc`)
--   :Git commit       -- commit message editor with diff preview
--   :Git push         -- push (with branch autocomplete)
--   :Git blame        -- inline blame in a split (column-style)
--   :Gdiffsplit       -- diff current file vs index/HEAD
return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gdiffsplit', 'Gvdiffsplit', 'Gedit', 'Gread', 'Gwrite' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
      { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
    },
  },
}
