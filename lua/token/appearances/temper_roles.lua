---Focused teal-and-purple semantic roles for Token Temper.
---@param p TokenPalette
---@return table
local function temper_roles(p)
  return {
    syntax = {
      comment = { fg = p.comment },
      note = { fg = p.fg1 },
      variable = { fg = p.fg0 },
      parameter = { fg = p.fg1 },
      property = { fg = p.property },
      definition = { fg = p.accent },
      call = { fg = p.accent },
      control = { fg = p.accent2 },
      literal = { fg = p.accent },
      path = { fg = p.accent },
      special = { fg = p.purple },
      type = { fg = p.fg1 },
      builtin = { fg = p.fg1 },
      attribute = { fg = p.fg1 },
      operator = { fg = p.fg1 },
      punctuation = { fg = p.comment },
      tag = { fg = p.fg1 },
      tag_attribute = { fg = p.fg0 },
      tag_delimiter = { fg = p.comment },
      link = { fg = p.accent },
      quote = { fg = p.fg2 },
    },
    headings = { p.accent, p.accent2, p.fg1, p.accent, p.accent2, p.fg1 },
  }
end

return temper_roles
