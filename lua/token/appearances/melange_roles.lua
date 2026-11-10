---Melange semantic roles for Token Melange: warm colors for control flow, cool colors for data.
---@param p TokenPalette
---@return table
local function melange_roles(p)
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
      exception = { fg = p.red },
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
    terminal = { [9] = p.orange },
  }
end

return melange_roles
