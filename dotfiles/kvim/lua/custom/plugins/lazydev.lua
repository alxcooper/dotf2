-- Dynamically populate lua_ls library only with what's actually required.
-- Replaces kickstart's blanket runtime scan which loaded ~2.5k .lua files.
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
