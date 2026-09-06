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
    open_automatic = true,
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
