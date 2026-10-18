-- codediff.nvim — VSCode-style diffs, trial alongside diffview.nvim
-- The native diff library is downloaded from GitHub releases on first use
-- (`:CodeDiff install!` to re-download).
-- Examples:
--   :CodeDiff                       -- explorer with working tree changes
--   :CodeDiff origin/master...      -- everything on your branch vs merge base
--   :CodeDiff pr 123                -- review a PR without checking it out
--   :CodeDiff history %             -- history of current file
-- In the diff tab: q close, t toggle side-by-side/inline, gc compact mode,
-- gm align moved blocks, - stage file, <leader>hs/hu/hr stage/unstage/discard hunk, g? help.
return {
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    keys = {
      { '<leader>gD', '<cmd>CodeDiff<cr>', desc = 'CodeDiff: open' },
      { '<leader>gL', '<cmd>CodeDiff history %<cr>', desc = 'CodeDiff: current file history' },
    },
    opts = {
      diff = {
        -- Opt-in: detect code moved within a file (align with gm).
        compute_moves = true,
      },
    },
  },
}
