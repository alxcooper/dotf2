-- virt-column.nvim - draw a thin text-width guide instead of a colorcolumn band.
return {
  {
    'lukas-reineke/virt-column.nvim',
    lazy = false,
    config = function(_, opts)
      local virt_column = require 'virt-column'

      virt_column.setup(opts)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('custom-python-virt-column', { clear = true }),
        pattern = 'python',
        callback = function(event)
          virt_column.setup_buffer(event.buf, { virtcolumn = '88' })
        end,
      })
    end,
    opts = {
      char = '┊',
      virtcolumn = '110',
      highlight = 'VirtColumnMuted',
    },
  },
}
