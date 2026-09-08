-- File, buffer and help pickers. LSP mappings live in kickstart.plugins.lspconfig.
local function grep_open_files()
  local files = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buflisted and vim.bo[buf].buftype == '' and vim.fn.filereadable(name) == 1 then table.insert(files, name) end
  end
  if #files == 0 then
    vim.notify('No open files to search', vim.log.levels.INFO)
    return
  end
  require('fzf-lua').live_grep { search_paths = files, prompt = 'Grep Open Files> ' }
end

---@module 'lazy'
---@type LazySpec
return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    event = 'VimEnter', -- Register vim.ui.select before it is first used.
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>sh', function() require('fzf-lua').helptags() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('fzf-lua').keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>ss', function() require('fzf-lua').builtin() end, desc = '[S]earch [S]elect Picker' },
      { '<leader>sd', function() require('fzf-lua').diagnostics_workspace() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>s.', function() require('fzf-lua').oldfiles() end, desc = '[S]earch Recent Files' },
      { '<leader>sc', function() require('fzf-lua').commands() end, desc = '[S]earch [C]ommands' },
      { '<leader><leader>', function() require('fzf-lua').buffers() end, desc = '[ ] Find existing buffers' },
      { ',.', function() require('fzf-lua').buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('fzf-lua').blines { previewer = false } end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', grep_open_files, desc = '[S]earch [/] in Open Files' },
      { ',,', function() require('fzf-lua').files() end, desc = '[S]earch [F]iles' },
      { '<leader>sf', function() require('fzf-lua').files() end, desc = '[S]earch [F]iles' },
      {
        '<leader>sF',
        function() require('fzf-lua').files { no_ignore = true, file_ignore_patterns = false } end,
        desc = '[S]earch [F]iles (all)',
      },
      { '<leader>sg', function() require('fzf-lua').live_grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sw', function() require('fzf-lua').grep_cword() end, desc = '[S]earch current [W]ord' },
      { ',g', function() require('fzf-lua').grep_cword() end, desc = 'Search current word' },
      { '<leader>sw', function() require('fzf-lua').grep_visual() end, mode = 'x', desc = '[S]earch selection' },
      { ',g', function() require('fzf-lua').grep_visual() end, mode = 'x', desc = 'Search selection' },
      { '<leader>sr', function() require('fzf-lua').resume() end, desc = '[S]earch [R]esume fzf-lua' },
      { '<leader>sn', function() require('fzf-lua').files { cwd = vim.fn.stdpath 'config' } end, desc = '[S]earch [N]eovim files' },
    },
    opts = {
      ui_select = {},
      fzf_opts = { ['--layout'] = 'reverse' },
      keymap = { fzf = { ['esc'] = 'abort' } },
      previewers = { builtin = { limit_b = 1024 * 1024 } },
      files = {
        hidden = true,
        -- Keep binary assets out of code searches; SVG remains searchable.
        -- <leader>sF disables these filters as well as project ignore files.
        file_ignore_patterns = {
          '%.avif$',
          '%.bmp$',
          '%.gif$',
          '%.heic$',
          '%.ico$',
          '%.jpe?g$',
          '%.png$',
          '%.tiff?$',
          '%.webp$',
          '%.pdf$',
          '%.avi$',
          '%.mkv$',
          '%.mov$',
          '%.mp4$',
          '%.webm$',
          '%.7z$',
          '%.bz2$',
          '%.gz$',
          '%.jar$',
          '%.rar$',
          '%.tar$',
          '%.tgz$',
          '%.xz$',
          '%.zip$',
          '%.eot$',
          '%.otf$',
          '%.ttf$',
          '%.woff2?$',
        },
      },
      -- Respect ignore files and skip hidden files when searching text.
      grep = { hidden = false },
    },
  },
}
