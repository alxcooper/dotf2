-- diffview.nvim — reviewing diffs and file history
-- Examples:
--   :DiffviewOpen                       -- changes in working tree vs HEAD
--   :DiffviewOpen origin/master...HEAD  -- everything on your branch vs origin/master
--   :DiffviewOpen HEAD~3                -- last 3 commits
--   :DiffviewFileHistory %              -- history of current file
local function stage_and_focus()
  local view = require('diffview.lib').get_current_view()
  if not view then
    return
  end

  -- Diffview already advances to the next entry after staging/unstaging.
  require('diffview.actions').toggle_stage_entry()
  if view.cur_layout then
    view.cur_layout:get_main_win():focus()
  end
end

local function focus_entry()
  require('diffview.actions').focus_entry()
end

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
      keymaps = {
        view = {
          { 'n', '-', stage_and_focus, { desc = 'Stage / unstage and focus the next file' } },
        },
        file_panel = {
          { 'n', '-', stage_and_focus, { desc = 'Stage / unstage and focus the next file' } },
          { 'n', '<cr>', focus_entry, { desc = 'Open file and focus its contents' } },
        },
        file_history_panel = {
          { 'n', '<cr>', focus_entry, { desc = 'Open file and focus its contents' } },
        },
      },
      view = {
        cycle_layouts = {
          -- g<C-x>: side by side -> unified inline -> top/bottom.
          default = { 'diff2_horizontal', 'diff1_inline', 'diff2_vertical' },
        },
        merge_tool = {
          layout = 'diff3_mixed',
        },
      },
      hooks = {
        diff_buf_win_enter = function(_, winid, _)
          vim.wo[winid].wrap = false
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
