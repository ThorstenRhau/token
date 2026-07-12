---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function claudecode(p)
  return {
    ClaudeCodeInlineDiffAdd = { bg = p.diff_add },
    ClaudeCodeInlineDiffDelete = { bg = p.diff_del, strikethrough = true },
    ClaudeCodeInlineDiffAddSign = { fg = p.green },
    ClaudeCodeInlineDiffDeleteSign = { fg = p.red },
  }
end

return claudecode
