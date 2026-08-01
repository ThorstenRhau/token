---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function blink_indent(p)
  return {
    BlinkIndent = { link = 'Whitespace' },
    BlinkIndentScope = { fg = p.indent_active },
    BlinkIndentUnderline = { sp = p.indent_active, underline = true },

    BlinkIndentRed = { fg = p.red },
    BlinkIndentOrange = { fg = p.orange },
    BlinkIndentYellow = { fg = p.yellow },
    BlinkIndentGreen = { fg = p.green },
    BlinkIndentCyan = { fg = p.cyan },
    BlinkIndentBlue = { fg = p.blue },
    BlinkIndentViolet = { fg = p.purple },

    BlinkIndentRedUnderline = { sp = p.red, underline = true },
    BlinkIndentOrangeUnderline = { sp = p.orange, underline = true },
    BlinkIndentYellowUnderline = { sp = p.yellow, underline = true },
    BlinkIndentGreenUnderline = { sp = p.green, underline = true },
    BlinkIndentCyanUnderline = { sp = p.cyan, underline = true },
    BlinkIndentBlueUnderline = { sp = p.blue, underline = true },
    BlinkIndentVioletUnderline = { sp = p.purple, underline = true },
  }
end

return blink_indent
