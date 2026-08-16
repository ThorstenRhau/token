---Token colorscheme configuration and loading API.
---@class (exact) token.Module
---@field setup fun(opts?: token.Config) Store configuration for subsequent colorscheme loads.
---@field load fun(colorscheme?: string) Load a Token colorscheme for the current value of `vim.o.background`.
local M = {}

---Replace the stored configuration with defaults deep-merged with `opts`.
---This does not reload an already active colorscheme.
---@param opts? token.Config Configuration options. Omit to restore defaults.
function M.setup(opts)
  require('token.config').setup(opts)
end

---Load a Token colorscheme for the current value of `vim.o.background`.
---Uses a matching compiled cache when available and otherwise builds the highlights dynamically.
---@param colorscheme? string Internal colorscheme name. Defaults to classic Token.
function M.load(colorscheme)
  local appearance = require('token.appearance').get(colorscheme)
  local bg = vim.o.background
  local lualine_wrappers = {}
  for _, registered in ipairs(require('token.appearance').all()) do
    lualine_wrappers['lualine.themes.' .. registered.name] = true
  end

  -- Keep user configuration while ensuring disabled integrations leave package.loaded.
  for key in pairs(package.loaded) do
    if (key:match('^token%.') and key ~= 'token.compile' and key ~= 'token.config') or lualine_wrappers[key] then
      package.loaded[key] = nil
    end
  end

  -- Try compiled cache first
  local compile = require('token.compile')
  if compile.load(bg, appearance.name) then
    for wrapper in pairs(lualine_wrappers) do
      package.loaded[wrapper] = nil
    end
    return
  end

  -- Dynamic fallback
  vim.cmd('hi clear')
  vim.g.colors_name = appearance.name

  local p, groups = require('token.theme').build(bg, appearance.name)

  for group, hl in pairs(groups) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  if require('token.config').get().terminal_colors then
    require('token.terminal').set(p, bg == 'dark')
  end
end

return M
