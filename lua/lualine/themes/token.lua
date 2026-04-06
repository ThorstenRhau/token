local p = require('token.palette')(vim.o.background)

return {
  normal = {
    a = { fg = p.bg3, bg = p.fg2, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  insert = {
    a = { fg = p.bg3, bg = p.green, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  visual = {
    a = { fg = p.bg3, bg = p.accent2, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  replace = {
    a = { fg = p.bg3, bg = p.red, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  command = {
    a = { fg = p.bg3, bg = p.yellow, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  terminal = {
    a = { fg = p.bg3, bg = p.blue, gui = 'bold' },
    b = { fg = p.fg1, bg = p.bg4 },
    c = { fg = p.fg1, bg = p.bg2 },
  },
  inactive = {
    a = { fg = p.fg3, bg = p.bg1, gui = 'bold' },
    b = { fg = p.fg3, bg = p.bg1 },
    c = { fg = p.fg3, bg = p.bg1 },
  },
}
