local M = {}

local function icon(glyph, fallback)
  return vim.g.have_nerd_font and glyph or fallback
end

local function escape(text)
  return (text:gsub('%%', '%%%%'))
end

-- Read the layout for this window, not buffer-local tags: the working file can
-- also be open in an ordinary editor window at the same time.
local function diff_context()
  local lib = package.loaded['diffview.lib']
  if not lib then return end
  local view = lib.get_current_view()
  if not view or not view.cur_layout then return end
  for _, win in ipairs(view.cur_layout.windows) do
    if win.id == vim.api.nvim_get_current_win() and win.file then
      local file = win.file
      local rev = file.rev
      if not rev then return { path = file.path, label = 'DIFF', accent = 'Blue' } end
      local types = require('diffview.vcs.rev').RevType
      if rev.type == types.LOCAL then
        return { path = file.path, label = 'WORKTREE', accent = 'Green' }
      elseif rev.type == types.STAGE then
        local label = ({ [0] = 'INDEX', [1] = 'BASE', [2] = 'OURS', [3] = 'THEIRS' })[rev.stage] or 'INDEX'
        return { path = file.path, label = label, accent = 'Blue' }
      elseif rev.type == types.COMMIT then
        return { path = file.path, label = (rev.commit or ''):sub(1, 8), accent = 'Purple' }
      end
      return { path = file.path, label = 'DIFF', accent = 'Blue' }
    end
  end
end

local function filename(context, width)
  local name = context and context.path or vim.api.nvim_buf_get_name(0)
  if name == '' then return '[No Name]' end
  if vim.bo.buftype == 'terminal' then return 'Terminal' end
  -- Keep one parent directory for context; the left-hand file tree has the rest.
  local tail = vim.fn.fnamemodify(name, ':t')
  local parent = vim.fn.fnamemodify(name, ':h:t')
  if width >= 65 and parent ~= '.' and parent ~= '' then return parent .. '/' .. tail end
  return tail
end

local function hl(group)
  return '%#CustomStatus' .. group .. '#'
end

local function badge(label, accent, active)
  if not active then return hl('Muted') .. ' ' .. escape(label) .. ' ' end
  return hl(accent) .. ' ' .. escape(label) .. ' ' .. hl(accent .. 'Edge') .. icon('', ' ') .. hl('Body')
end

local function mode_badge(width)
  local mode, group = require('mini.statusline').section_mode { trunc_width = width < 80 and 999 or 0 }
  local accent = ({
    MiniStatuslineModeInsert = 'Green',
    MiniStatuslineModeVisual = 'Purple',
    MiniStatuslineModeReplace = 'Red',
    MiniStatuslineModeCommand = 'Yellow',
  })[group] or 'Blue'
  return badge(mode:upper(), accent, true)
end

function M.render(active)
  local statusline = require 'mini.statusline'
  local width = vim.api.nvim_win_get_width(0)
  local base = active and 'Body' or 'Muted'
  local panel = ({ DiffviewFiles = 'FILES', DiffviewFileHistory = 'HISTORY' })[vim.bo.filetype]
  if panel then
    return badge(icon('󰙅 ', '') .. panel, 'Blue', active) .. hl(base) .. '%= %l/%L '
  end

  local context = diff_context()
  local parts = { hl(base) }
  if context then
    parts[#parts + 1] = badge(icon(' ', '') .. context.label, context.accent, active)
  elseif active then
    parts[#parts + 1] = mode_badge(width)
  end
  if active and not context and width >= 90 then
    local branch = statusline.section_git { trunc_width = 0 }
    if branch ~= '' then parts[#parts + 1] = hl('Detail') .. ' ' .. escape(branch) .. ' ' .. hl(base) end
  end

  parts[#parts + 1] = ' %<' .. icon('󰈙 ', '') .. escape(filename(context, width))
  if vim.bo.modified then parts[#parts + 1] = hl(active and 'Changed' or 'ChangedInactive') .. ' [+]' .. hl(base) end
  if vim.bo.readonly or not vim.bo.modifiable then parts[#parts + 1] = ' ' .. icon('', 'RO') end
  parts[#parts + 1] = '%='

  if active and width >= 90 then
    local diagnostics = statusline.section_diagnostics {
      trunc_width = 0,
      icon = '',
      signs = { ERROR = icon(' ', 'E'), WARN = icon(' ', 'W'), INFO = 'I', HINT = 'H' },
    }
    if diagnostics ~= '' then parts[#parts + 1] = hl('Warning') .. escape(diagnostics) .. ' ' .. hl(base) end
    local changes = vim.b.gitsigns_status
    if not context and width >= 120 and changes and changes ~= '' then
      parts[#parts + 1] = hl('Detail') .. ' ' .. escape(changes) .. ' ' .. hl(base)
    end
  end
  if active and width >= 75 and vim.bo.filetype ~= '' then
    parts[#parts + 1] = hl('Detail') .. ' ' .. escape(vim.bo.filetype) .. ' ' .. hl(base)
  end
  if active then
    parts[#parts + 1] = hl('PositionEdge') .. icon('', ' ') .. hl('Position')
  end
  parts[#parts + 1] = ' %5l:%-4c '
  return table.concat(parts)
end

local function highlights()
  local function color(group, key, fallback)
    return vim.api.nvim_get_hl(0, { name = group, link = false })[key] or fallback
  end
  local function blend(background, foreground, amount)
    local a = type(background) == 'number' and background or tonumber(background:sub(2), 16)
    local b = type(foreground) == 'number' and foreground or tonumber(foreground:sub(2), 16)
    local result = 0
    for _, shift in ipairs { 16, 8, 0 } do
      local x, y = math.floor(a / 2 ^ shift) % 256, math.floor(b / 2 ^ shift) % 256
      result = result + math.floor(x + (y - x) * amount + 0.5) * 2 ^ shift
    end
    return result
  end
  local editor_bg = color('Normal', 'bg', '#1c1c1c')
  local fg = color('Normal', 'fg', '#bcbcbc')
  local muted = color('Comment', 'fg', '#808080')
  -- Separate the bar from the editor while adapting to light and dark themes.
  local bg = blend(editor_bg, fg, 0.12)
  local inactive_bg = blend(editor_bg, fg, 0.06)
  local side = blend(editor_bg, fg, 0.20)
  local accents = {
    Blue = color('Function', 'fg', '#87afaf'),
    Green = color('String', 'fg', '#87af87'),
    Purple = color('Statement', 'fg', '#af87af'),
    Yellow = color('DiagnosticWarn', 'fg', '#d7af5f'),
    Red = color('DiagnosticError', 'fg', '#d78787'),
  }
  local function set(name, attrs) vim.api.nvim_set_hl(0, 'CustomStatus' .. name, attrs) end
  set('Body', { fg = fg, bg = bg })
  set('Detail', { fg = muted, bg = bg })
  set('Muted', { fg = muted, bg = inactive_bg })
  set('Changed', { fg = accents.Yellow, bg = bg, bold = true })
  set('ChangedInactive', { fg = accents.Yellow, bg = inactive_bg, bold = true })
  set('Warning', { fg = accents.Yellow, bg = bg })
  set('Position', { fg = fg, bg = side, bold = true })
  set('PositionEdge', { fg = side, bg = bg })
  for name, accent in pairs(accents) do
    set(name, { fg = editor_bg, bg = accent, bold = true })
    set(name .. 'Edge', { fg = accent, bg = bg })
  end
end

function M.setup()
  require('mini.statusline').setup {
    use_icons = vim.g.have_nerd_font,
    content = {
      active = function() return M.render(true) end,
      inactive = function() return M.render(false) end,
    },
  }
  highlights()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('custom-statusline', { clear = true }),
    callback = highlights,
  })
end

return M
