local M = {}

local function icon(glyph, fallback)
  return vim.g.have_nerd_font and glyph or fallback
end

local function escape(text)
  return (text:gsub('%%', '%%%%'))
end

local function shorten(text, width)
  if vim.fn.strdisplaywidth(text) <= width then return text end
  local chars = vim.fn.strchars(text)
  while chars > 0 and vim.fn.strdisplaywidth(text) > width - 1 do
    text = vim.fn.strcharpart(text, 1)
    chars = chars - 1
  end
  return '…' .. text
end

local function describe(tab)
  local wins = vim.api.nvim_tabpage_list_wins(tab)
  local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
  local lib = package.loaded['diffview.lib']
  local diff = lib and lib.tabpage_to_view(tab) ~= nil or false
  local modified = false
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_config(win).relative == '' then
      local candidate = vim.api.nvim_win_get_buf(win)
      modified = modified or vim.bo[candidate].modified
      diff = diff or vim.bo[candidate].filetype == 'DiffviewFiles' or vim.bo[candidate].filetype == 'DiffviewFileHistory'
      -- Focusing a sidebar should not replace the file's tab label.
      if vim.bo[buf].buftype ~= '' and vim.bo[candidate].buftype == '' then buf = candidate end
    end
  end
  local path = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(path, ':t')
  if vim.bo[buf].filetype == 'ministarter' then
    name = 'Welcome'
  elseif vim.bo[buf].buftype == 'terminal' then
    name = 'Terminal'
  elseif name == '' then
    name = '[No Name]'
  end
  if vim.t[tab].custom_git_status_name then
    name = vim.t[tab].custom_git_status_name
    path, diff = '', false
  end
  return { path = path, name = name, modified = modified, diff = diff }
end

function M.render()
  local tabs = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()
  local items, names, selected = {}, {}, 1
  for i, tab in ipairs(tabs) do
    items[i] = describe(tab)
    names[items[i].name] = (names[items[i].name] or 0) + 1
    if tab == current then selected = i end
  end

  -- Only add parent directories when filenames collide; omit the long home path.
  for i, item in ipairs(items) do
    local label = item.name
    if names[item.name] > 1 and item.path ~= '' then
      local parts = vim.split(item.path, '/', { trimempty = true })
      local depth = 1
      while depth <= #parts do
        local suffix = table.concat(parts, '/', math.max(1, #parts - depth))
        label = suffix
        local unique = true
        for j, other in ipairs(items) do
          if i ~= j and item.path ~= other.path and item.name == other.name then
            local other_parts = vim.split(other.path, '/', { trimempty = true })
            if table.concat(other_parts, '/', math.max(1, #other_parts - depth)) == suffix then unique = false end
          end
        end
        if unique then break end
        depth = depth + 1
      end
    end
    local suffix = item.modified and ' ●' or ''
    local prefix = ' ' .. i .. ' ' .. (item.diff and 'Diff: ' or '')
    local available = math.max(1, vim.o.columns - vim.fn.strdisplaywidth(prefix .. suffix) - 9)
    item.text = prefix .. shorten(label, math.min(32, available)) .. suffix .. ' '
    item.width = vim.fn.strdisplaywidth(item.text) + 1
  end

  -- Keep the current tab visible when there are more tabs than screen columns.
  local first, last = selected, selected
  local used = items[selected].width
  local budget = math.max(1, vim.o.columns - 8)
  while first > 1 or last < #items do
    if first > 1 and used + items[first - 1].width <= budget then
      first = first - 1
      used = used + items[first].width
    elseif last < #items and used + items[last + 1].width <= budget then
      last = last + 1
      used = used + items[last].width
    else
      break
    end
  end
  local result = { '%#CustomTabFill#' }
  if first > 1 then result[#result + 1] = '%' .. (first - 1) .. 'T ‹ %T' end
  for i = first, last do
    local state = i == selected and 'Active' or 'Inactive'
    local next_state = i == last and 'Fill' or (i + 1 == selected and 'Active' or 'Inactive')
    local separator = state == 'Inactive' and next_state == 'Inactive'
      and '%#CustomTabInactive#╲'
      or ('%#CustomTab' .. state .. 'To' .. next_state .. '#' .. icon('', ' '))
    result[#result + 1] = '%' .. i .. 'T%#CustomTab' .. state .. '#' .. escape(items[i].text)
      .. separator .. '%T%#CustomTabFill#'
  end
  if last < #items then result[#result + 1] = '%' .. (last + 1) .. 'T › %T' end
  result[#result + 1] = '%#CustomTabFill#%='
  return table.concat(result)
end

function M.setup()
  -- Keep the colorscheme's native tab palette, including after theme changes.
  local function highlights()
    vim.api.nvim_set_hl(0, 'CustomTabActive', { link = 'TabLineSel' })
    vim.api.nvim_set_hl(0, 'CustomTabInactive', { link = 'TabLine' })
    vim.api.nvim_set_hl(0, 'CustomTabFill', { link = 'TabLineFill' })
    -- Each slant joins directly to the next tab, with no strip of bar background.
    for _, from in ipairs { 'Active', 'Inactive' } do
      local tab = vim.api.nvim_get_hl(0, { name = 'CustomTab' .. from, link = false })
      for _, to in ipairs { 'Active', 'Inactive', 'Fill' } do
        local next_tab = vim.api.nvim_get_hl(0, { name = 'CustomTab' .. to, link = false })
        vim.api.nvim_set_hl(0, 'CustomTab' .. from .. 'To' .. to, { fg = tab.bg, bg = next_tab.bg })
      end
    end
  end
  highlights()
  vim.o.showtabline = 1
  vim.o.tabline = "%!v:lua.require'custom.tabline'.render()"
  local group = vim.api.nvim_create_augroup('custom-tabline', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = highlights })
  vim.api.nvim_create_autocmd({ 'BufModifiedSet', 'BufFilePost', 'WinEnter', 'WinClosed' }, {
    group = group,
    callback = function() vim.cmd.redrawtabline() end,
  })
end

return M
