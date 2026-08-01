---Token colorscheme configuration and loading API.
---@class (exact) token.Module
---@field setup fun(opts?: token.Config) Store configuration for subsequent colorscheme loads.
---@field load fun() Load Token for the current value of `vim.o.background`.
local M = {}

---Replace the stored configuration with defaults deep-merged with `opts`.
---This does not reload an already active colorscheme.
---@param opts? token.Config Configuration options. Omit to restore defaults.
function M.setup(opts)
  require('token.config').setup(opts)
end

---Load Token for the current value of `vim.o.background`.
---Uses a matching compiled cache when available and otherwise builds the highlights dynamically.
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
