---@param p TokenPalette
---@return table
local function ultra_roles(p)
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
    -- Ultra uses the default ANSI mapping from token.terminal.
  }
end

return ultra_roles
