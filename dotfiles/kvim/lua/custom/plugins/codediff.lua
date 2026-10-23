-- codediff.nvim — reviewing diffs and file history with VSCode-style rendering
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
      { '<leader>gd', '<cmd>CodeDiff<cr>', desc = 'CodeDiff: open' },
      { '<leader>gL', '<cmd>CodeDiff history %<cr>', desc = 'CodeDiff: current file history' },
    },
    opts = {
      diff = {
        layout = 'side-by-side', -- Toggle side-by-side/inline with t.
        -- Opt-in: detect code moved within a file (align with gm).
        compute_moves = true,
      },
      explorer = {
        focus_on_select = true, -- Enter opens the file and focuses the diff pane.
      },
      keymaps = {
        explorer = {
          -- Single click opens a file (plugin only maps double click).
          select = { '<CR>', '<LeftRelease>' },
        },
      },
    },
  },
}
