local M = {}

function M.trim_trailing_whitespace(buf)
  -- Trailing whitespace is meaningful in Markdown hard breaks and patch files.
  local ft = vim.bo[buf].filetype
  if vim.bo[buf].buftype ~= '' or not vim.bo[buf].modifiable or vim.bo[buf].binary or ft == 'markdown' or ft == 'diff' then return end
  vim.api.nvim_buf_call(buf, function()
    local view = vim.fn.winsaveview()
    vim.cmd [[silent keepjumps keeppatterns %s/[ \t]\+$//e]]
    vim.fn.winrestview(view)
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('custom-trim-whitespace', { clear = true }),
    desc = 'Remove trailing spaces and tabs before saving',
    callback = function(args) M.trim_trailing_whitespace(args.buf) end,
  })
end

return M
