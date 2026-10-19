-- tpope/vim-fugitive — git porcelain inside vim.
-- Main entry points:
--   <leader>gs        -- full-screen status tab per repository; q returns to editing
--   :Git              -- status buffer (stage with `s`, unstage with `u`, commit with `cc`)
--   :Git commit       -- commit message editor with diff preview
--   :Git push         -- push (with branch autocomplete)
--   :Git blame        -- inline blame in a split (column-style)
--   :Gdiffsplit       -- diff current file vs index/HEAD
local function close_status()
  local target = vim.t.custom_git_return_tab
  if not vim.t.custom_git_status_dir then
    vim.cmd.close()
  elseif #vim.api.nvim_list_tabpages() == 1 then
    vim.cmd.enew()
    vim.t.custom_git_status_dir = nil
    vim.t.custom_git_status_name = nil
    vim.t.custom_git_return_tab = nil
  else
    vim.cmd.tabclose()
    if target and vim.api.nvim_tabpage_is_valid(target) then vim.api.nvim_set_current_tabpage(target) end
  end
end

local function git_status()
  local git_dir = vim.fn.FugitiveGitDir()
  if git_dir == '' then
    vim.cmd.Git()
    return
  end
  git_dir = vim.uv.fs_realpath(git_dir) or git_dir
  local origin = vim.api.nvim_get_current_tabpage()
  if vim.t[origin].custom_git_status_dir then origin = vim.t[origin].custom_git_return_tab end
  local target
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if vim.t[tab].custom_git_status_dir == git_dir then
      target = tab
      break
    end
  end

  local status = vim.fn.FugitiveFind(':', git_dir)
  if target then
    vim.api.nvim_set_current_tabpage(target)
    local win = vim.fn.bufwinid(status)
    if win ~= -1 then vim.api.nvim_set_current_win(win) end
  else
    vim.cmd.tabnew()
  end
  -- Use an explicit Fugitive URL to keep the status tied to its repository.
  if vim.api.nvim_buf_get_name(0) ~= status then vim.cmd('keepalt edit ' .. vim.fn.fnameescape(status)) end
  vim.cmd.Git()
  vim.t.custom_git_status_dir = git_dir
  local tree = vim.fn.FugitiveWorkTree(git_dir)
  vim.t.custom_git_status_name = 'Git: ' .. vim.fn.fnamemodify(tree ~= '' and tree or git_dir, ':t')
  vim.t.custom_git_return_tab = origin
  vim.keymap.set('n', 'q', close_status, { buffer = true, silent = true, desc = 'Close Git tab and return to editing' })
end

return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'Gdiffsplit', 'Gvdiffsplit', 'Gedit', 'Gread', 'Gwrite' },
    keys = {
      { '<leader>gs', git_status, desc = 'Git status' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
      { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
    },
  },
}
