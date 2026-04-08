---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function diff(p)
  return {
    DiffAdd = { bg = p.diff_add },
    DiffDelete = { bg = p.diff_del },
    DiffChange = { bg = p.diff_change },
    DiffText = { bg = p.diff_text },
    DiffTextAdd = { link = 'DiffAdd' },
    Added = { fg = p.green },
    Changed = { fg = p.yellow },
    Removed = { fg = p.red },
  }
end

return diff
