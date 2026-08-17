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

  return {
    normal = {
      a = { fg = p.bg3, bg = mode.normal, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    insert = {
      a = { fg = p.bg3, bg = mode.insert, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    visual = {
      a = { fg = p.bg3, bg = mode.visual, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    replace = {
      a = { fg = p.bg3, bg = mode.replace, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    command = {
      a = { fg = p.bg3, bg = mode.command, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    terminal = {
      a = { fg = p.bg3, bg = mode.terminal, gui = gui('bold') },
      b = { fg = p.fg1, bg = surface(p.bg4) },
      c = { fg = p.fg1, bg = surface(p.bg2) },
    },
    inactive = {
      a = { fg = mode.inactive, bg = surface(p.bg1), gui = gui('bold') },
      b = { fg = mode.inactive, bg = surface(p.bg1) },
      c = { fg = mode.inactive, bg = surface(p.bg1) },
    },
  }
end

return build
