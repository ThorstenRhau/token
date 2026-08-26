---Circadia semantic roles for Token Meridian.
---@param p TokenPalette
---@param is_dark boolean
---@return table
local function meridian_roles(p, is_dark)
  local headings = is_dark and { p.accent2, p.bright_green, p.bright_blue, p.red, p.bright_purple, p.bright_cyan }
    or { p.bright_green, p.bright_blue, p.bright_purple, p.bright_cyan, p.red, p.yellow }

  return {
    syntax = {
      comment = { fg = p.fg2, italic = true },
      variable = { fg = p.fg0 },
      parameter = { fg = p.fg1 },
      property = { fg = p.orange },
      definition = { fg = p.purple },
      call = { fg = p.purple },
      control = { fg = p.blue, bold = true },
      literal = { fg = p.green },
      number = { fg = is_dark and p.yellow or p.cyan },
      type = { fg = is_dark and p.cyan or p.accent2 },
      builtin = { fg = is_dark and p.cyan or p.accent2 },
      attribute = { fg = is_dark and p.cyan or p.accent2 },
      operator = { fg = p.fg1 },
      punctuation = { fg = p.fg1 },
      tag = { fg = p.blue },
      tag_delimiter = { fg = p.fg1 },
      link = { fg = p.accent, underline = true },
      quote = { fg = p.fg1, italic = true },
    },
    headings = headings,
    lualine = {
      normal = p.fg2,
      insert = p.green,
      visual = p.blue,
      replace = p.red,
      command = p.yellow,
      terminal = p.cyan,
      inactive = p.fg3,
    },
    terminal = is_dark and {
      [0] = p.bg1,
      [1] = p.red,
      [2] = p.green,
      [3] = p.yellow,
      [4] = p.blue,
      [5] = p.purple,
      [6] = p.blue,
      [7] = p.fg1,
      [8] = p.fg3,
      [9] = p.bright_blue,
      [10] = p.green,
      [11] = p.accent2,
      [12] = p.blue,
      [13] = p.orange,
      [14] = p.blue,
      [15] = p.fg0,
    } or {
      [0] = p.fg0,
      [1] = p.accent2,
      [2] = p.green,
      [3] = p.accent2,
      [4] = p.blue,
      [5] = p.purple,
      [6] = p.cyan,
      [7] = p.line_nr,
      [8] = p.fg2,
      [9] = p.accent2,
      [10] = p.green,
      [11] = p.accent2,
      [12] = p.blue,
      [13] = p.orange,
      [14] = p.cyan,
      [15] = p.bg3,
    },
  }
end

return meridian_roles
