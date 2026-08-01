---@class token.Module
local M = {}

---@param opts? token.Config
function M.setup(opts)
  require('token.config').setup(opts)
end

function M.load()
  local bg = vim.o.background

  -- Keep user configuration while ensuring disabled integrations leave package.loaded.
  for key in pairs(package.loaded) do
    if
      (key:match('^token%.') and key ~= 'token.compile' and key ~= 'token.config')
      or key == 'lualine.themes.token'
    then
      package.loaded[key] = nil
    end
  end

  -- Try compiled cache first
  local compile = require('token.compile')
  if compile.load(bg) then
    package.loaded['lualine.themes.token'] = nil
    return
  end

  -- Dynamic fallback
  vim.cmd('hi clear')
  vim.g.colors_name = 'token'

  local p, groups = require('token.theme').build(bg)

  for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  if require('token.config').get().terminal_colors then
    require('token.terminal').set(p, bg == 'dark')
  end
end

return M
