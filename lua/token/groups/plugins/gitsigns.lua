---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function gitsigns(p)
  return {
    GitSignsAdd = { fg = p.gsign_add },
    GitSignsChange = { fg = p.gsign_change },
    GitSignsDelete = { fg = p.gsign_del },
    GitSignsTopdelete = { fg = p.gsign_del },
    GitSignsChangedelete = { fg = p.gsign_change },
    GitSignsUntracked = { fg = p.gsign_untracked },
    GitSignsAddNr = { link = 'GitSignsAdd' },
    GitSignsChangeNr = { link = 'GitSignsChange' },
    GitSignsDeleteNr = { link = 'GitSignsDelete' },
    GitSignsAddLn = { bg = p.diff_add },
    GitSignsChangeLn = { bg = p.diff_change },
    GitSignsAddPreview = { bg = p.diff_add },
    GitSignsDeletePreview = { bg = p.diff_del },
    GitSignsCurrentLineBlame = { fg = p.fg3, italic = true },
  }
end

return gitsigns
