---@param p TokenPalette
---@param is_dark boolean
---@return table
local function ultra_roles(p, is_dark)
  return {
    syntax = {
      comment = { fg = p.fg2 },
      variable = { fg = p.fg0 },
      parameter = { fg = p.fg1 },
      definition = { fg = p.accent },
      call = { fg = p.accent },
      control = { fg = p.accent2 },
      literal = { fg = p.orange },
      special = { fg = p.purple },
      type = { fg = p.fg1 },
      builtin = { fg = p.fg1 },
      attribute = { fg = p.fg1 },
      operator = { fg = p.fg1 },
      punctuation = { fg = p.fg1 },
      tag = { fg = p.fg1 },
      tag_delimiter = { fg = p.fg2 },
      link = { fg = p.blue },
      quote = { fg = p.fg2 },
    },
    headings = { p.accent, p.accent2, p.blue, p.accent, p.accent2, p.blue },
    lualine = {
      normal = p.fg2,
      insert = p.green,
      visual = p.blue,
      replace = p.red,
      command = p.yellow,
      terminal = p.cyan,
      inactive = p.fg3,
    },
    terminal = {
      [0] = is_dark and p.bg1 or p.fg0,
      [1] = p.red,
      [2] = p.green,
      [3] = p.yellow,
      [4] = p.blue,
      [5] = p.purple,
      [6] = p.cyan,
      [7] = is_dark and p.fg1 or p.line_nr,
      [8] = is_dark and p.fg3 or p.fg2,
      [9] = p.accent,
      [10] = p.bright_green,
      [11] = p.accent2,
      [12] = p.bright_blue,
      [13] = p.bright_purple,
      [14] = p.bright_cyan,
      [15] = is_dark and p.fg0 or p.bg3,
    },
  }
end

return ultra_roles
