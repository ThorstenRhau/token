local M = {}

function M.load()
  local bg = vim.o.background

  -- Try compiled cache first
  local compile = require('token.compile')
  if compile.load(bg) then
    package.loaded['lualine.themes.token'] = nil
    return
  end

  -- Dynamic fallback
  vim.cmd('hi clear')
  vim.g.colors_name = 'token'

  -- Clear cached modules so palette/groups pick up the new background
  for key in pairs(package.loaded) do
    if key == 'token' or (key:match('^token%.') and key ~= 'token.compile') or key == 'lualine.themes.token' then
      package.loaded[key] = nil
    end
  end

  local p = require('token.palette')(bg)
  local groups = require('token.groups')(p)

  for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  local is_dark = bg == 'dark'
  require('token.terminal').set(p, is_dark)
end

return M
