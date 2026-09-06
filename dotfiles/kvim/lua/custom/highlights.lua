local M = {}

function M.setup()
  local function apply()
    for _, name in ipairs { 'VirtColumnMuted', 'WinSeparator' } do
      vim.api.nvim_set_hl(0, name, { fg = '#444444', bg = 'NONE', ctermfg = 238 })
    end
    vim.api.nvim_set_hl(0, 'VertSplit', { link = 'WinSeparator' })
    for _, name in ipairs { 'IblIndent', 'IblScope' } do
      vim.api.nvim_set_hl(0, name, { fg = '#404040', ctermfg = 238 })
    end
    for _, name in ipairs { 'Whitespace', 'IblWhitespace' } do
      vim.api.nvim_set_hl(0, name, { fg = '#303030', ctermfg = 236 })
    end
  end

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('custom-muted-guides', { clear = true }),
    callback = apply,
  })
  apply()
end

return M
