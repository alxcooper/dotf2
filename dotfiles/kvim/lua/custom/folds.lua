local M = {}

-- Keep foldable files open unless a saved view says otherwise.
local function setup_open_by_default()
  vim.o.foldmethod = 'indent'
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true
end

-- Avoid saving views for help, terminals, dashboards, and unnamed buffers.
local function is_real_file_buffer(buf)
  return vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= ''
end

-- Store per-file view state outside the working tree.
local function setup_view_storage()
  vim.opt.viewoptions = { 'folds', 'cursor' }

  local viewdir = vim.fn.stdpath 'state' .. '/view'
  vim.fn.mkdir(viewdir, 'p')
  vim.o.viewdir = viewdir
end

-- Save and restore cursor/fold state for normal file buffers.
local function setup_view_autocmds()
  local fold_view_group = vim.api.nvim_create_augroup('custom-save-folds', { clear = true })
  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = fold_view_group,
    callback = function(args)
      if not is_real_file_buffer(args.buf) then return end

      vim.cmd 'silent! mkview'
    end,
  })
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = fold_view_group,
    callback = function(args)
      if not is_real_file_buffer(args.buf) then return end

      local ok = pcall(vim.cmd, 'silent loadview')
      if not ok then vim.wo.foldlevel = 99 end
      if vim.b[args.buf].custom_treesitter_folds then M.enable_treesitter(args.buf) end
    end,
  })
end

-- Use Tree-sitter fold expressions in all windows showing this buffer.
function M.enable_treesitter(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[win].foldmethod = 'expr'
  end
end

-- Apply the global fold policy and view persistence.
function M.setup()
  setup_open_by_default()
  setup_view_storage()
  setup_view_autocmds()
end

return M
