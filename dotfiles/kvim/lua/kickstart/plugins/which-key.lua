-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `opts` key (recommended), the configuration runs
-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

-- Last key pressed, to tell a mouse selection apart from an explicit `v`
local last_key = ''

---@module 'lazy'
---@type LazySpec
return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter',
    init = function()
      vim.on_key(function(key) last_key = vim.fn.keytrans(key) end)
    end,
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      -- Don't pop up on entering Visual mode with V/<C-V> (which-key default) or
      -- with the mouse (double-click, drag), only once a key is pressed in it.
      -- An explicit `v` still shows it right away.
      defer = function(ctx)
        if ctx.mode == 'v' then return last_key:find 'Mouse>$' ~= nil or last_key:find 'Drag>$' ~= nil end
        return ctx.mode == 'V' or ctx.mode == '<C-V>'
      end,
      icons = { mappings = vim.g.have_nerd_font },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk' },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
