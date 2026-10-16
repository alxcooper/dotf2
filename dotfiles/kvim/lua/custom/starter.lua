local M = {}

function M.setup()
  local active, pending = false, false
  local group = vim.api.nvim_create_augroup('custom-starter-lifecycle', { clear = true })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'MiniStarterOpened',
    callback = function() active = true end,
  })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'TabNewEntered' }, {
    group = group,
    desc = 'Dismiss Welcome after opening another buffer or window',
    callback = function()
      if not active or pending then return end
      pending = true
      -- Plugins may create several windows before their final layout is ready.
      vim.schedule(function()
        local welcome, other = {}, false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative == '' then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'ministarter' then
              welcome[#welcome + 1] = win
            else
              other = true
            end
          end
        end

        if not other and #welcome > 1 then
          -- :tab split / :split can duplicate Welcome instead of opening a buffer.
          local current = vim.api.nvim_get_current_win()
          if vim.tbl_contains(welcome, current) then
            vim.api.nvim_win_set_buf(current, vim.api.nvim_create_buf(true, false))
            other = true
          end
        end
        if other then
          for _, win in ipairs(welcome) do
            if vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'ministarter' then
              vim.api.nvim_win_close(win, false)
            end
          end
        end
        active = not other and #welcome > 0
        pending = false
      end)
    end,
  })
end

return M
