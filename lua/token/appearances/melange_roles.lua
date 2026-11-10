---Melange semantic roles for Token Melange: warm colors for control flow, cool colors for data.
---@param p TokenPalette
---@param is_dark boolean
---@return table
local function melange_roles(p, is_dark)
  return {
    syntax = {
      comment = { fg = p.comment },
      variable = { fg = p.fg0 },
      parameter = { fg = p.fg1 },
      property = { fg = p.property },
      -- Warm: Melange's orange keywords, gold functions and coral operators.
      -- `olive` holds Melange's orange at the contrast Token gives keywords.
      definition = { fg = p.accent },
      call = { fg = p.accent },
      control = { fg = p.olive },
      operator = { fg = p.orange },
      tag = { fg = p.accent },
      -- Cool: Melange's blue strings, magenta numbers and cyan types.
      literal = { fg = p.blue },
      number = { fg = p.purple },
      special = { fg = p.purple },
      type = { fg = p.cyan },
      builtin = { fg = p.cyan },
      tag_attribute = { fg = p.cyan },
      -- Melange colors preprocessor items and directories green.
      attribute = { fg = p.green },
      path = { fg = p.green },
      punctuation = { fg = p.comment },
      tag_delimiter = { fg = p.comment },
      link = { fg = p.blue },
      quote = { fg = p.fg2 },
    },
    headings = { p.olive, p.accent, p.green, p.olive, p.accent, p.green },
    lualine = {
      normal = p.fg2,
      insert = p.accent,
      visual = p.purple,
      replace = p.orange,
      command = p.cyan,
      terminal = p.green,
      inactive = p.fg3,
    },
    -- Token's default ANSI table, except that bright red takes Melange's coral.
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
      [9] = p.orange,
      [10] = p.bright_green,
      [11] = p.accent2,
      [12] = p.bright_blue,
      [13] = p.bright_purple,
      [14] = p.bright_cyan,
      [15] = is_dark and p.fg0 or p.bg3,
    },
  }
end

return melange_roles
