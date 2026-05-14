-- diffview.nvim — reviewing diffs and file history
-- Examples:
--   :DiffviewOpen                       -- changes in working tree vs HEAD
--   :DiffviewOpen origin/master...HEAD  -- everything on your branch vs origin/master
--   :DiffviewOpen HEAD~3                -- last 3 commits
--   :DiffviewFileHistory %              -- history of current file
return {
  {
    'dlyongemallo/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewRefresh',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diffview: open' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diffview: current file history' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Diffview: branch/repo history' },
      { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Diffview: close' },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = 'diff3_mixed',
        },
      },
      hooks = {
        diff_buf_win_enter = function(_, winid, _)
          -- Cursorline only on the line number in diff windows, to avoid the
          -- bg conflict that renders as an underline on diff-highlighted lines.
          -- Workaround from: https://github.com/sindrets/diffview.nvim/issues/113
          vim.wo[winid].cursorlineopt = 'number'
        end,
      },
    },
    init = function()
      -- Render diff fillers as diagonal hatching (matches the DiffView README screenshots),
      -- instead of the default '-' which looks like solid horizontal stripes on the empty side.
      vim.opt.fillchars:append { diff = '╱' }
    end,
  },
}
