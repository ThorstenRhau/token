---@param colorscheme? string
---@return table
local function build(colorscheme)
  local background = vim.o.background
  local config = require('token.config').get()
  local p = require('token.theme').palette(background, colorscheme)
  local roles = require('token.appearance').roles(colorscheme, p, background == 'dark')
  local mode = roles and roles.lualine
    or {
      normal = p.fg2,
      insert = p.green,
      visual = p.accent2,
      replace = p.red,
      command = p.yellow,
      terminal = p.blue,
      inactive = p.fg3,
    }

  local function surface(bg)
    return config.transparent and 'NONE' or bg
  end

  local function gui(value)
    return config.attributes.bold and value or nil
  end

  local theme = {
    inactive = {
      a = { fg = mode.inactive, bg = surface(p.bg1), gui = gui('bold') },
      b = { fg = mode.inactive, bg = surface(p.bg1) },
      c = { fg = mode.inactive, bg = surface(p.bg1) },
    },
  }
  for _, name in ipairs({ 'normal', 'insert', 'visual', 'replace', 'command', 'terminal' }) do
    theme[name] = {
      a = { fg = p.bg3, bg = mode[name], gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    }
  end
  return theme
end

return build
