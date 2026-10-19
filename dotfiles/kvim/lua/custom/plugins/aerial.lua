return {
  'stevearc/aerial.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialClose' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>o', '<cmd>AerialToggle!<CR>', desc = 'Toggle [O]utline' },
  },
  opts = {
    attach_mode = 'global',
    open_automatic = function(bufnr)
      -- CodeDiff also shows real file buffers, so detect the tab's session.
      -- Keep manual opening available and preserve Aerial's default ignores.
      local codediff = package.loaded['codediff.ui.lifecycle']
      if codediff and codediff.get_session(vim.api.nvim_get_current_tabpage()) then return false end
      return not require('aerial.util').is_ignored_buf(bufnr)
    end,
    backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
    filter_kind = false, -- Include constants and other symbols supplied by the backend.
    layout = {
      default_direction = 'right',
      placement = 'edge',
      min_width = 25,
      max_width = 40,
    },
  },
}
