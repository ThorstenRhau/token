---@param colorscheme? string
---@return table
local function build(colorscheme)
  local background = vim.o.background
  local config = require('token.config').get()
  local p = require('token.theme').palette(background, colorscheme)

  local function surface(bg)
    return config.transparent and 'NONE' or bg
  end

  local function gui(value)
    return config.attributes.bold and value or nil
  end

  return {
    normal = {
      a = { fg = p.bg3, bg = p.fg2, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    insert = {
      a = { fg = p.bg3, bg = p.green, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    visual = {
      a = { fg = p.bg3, bg = p.accent2, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    replace = {
      a = { fg = p.bg3, bg = p.red, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    command = {
      a = { fg = p.bg3, bg = p.yellow, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    terminal = {
      a = { fg = p.bg3, bg = p.blue, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    inactive = {
      a = { fg = p.fg3, bg = surface(p.bg1), gui = gui('bold') },
      b = { fg = p.fg3, bg = surface(p.bg1) },
      c = { fg = p.fg3, bg = surface(p.bg1) },
    },
  }
end

return build
