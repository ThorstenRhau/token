---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function oil(p)
  return {
    OilDir = { fg = p.blue },
    OilFile = { fg = p.fg0 },
    OilLink = { fg = p.purple },
    OilLinkTarget = { fg = p.purple, italic = true },
    OilSocket = { fg = p.accent2 },
    OilOrphanLink = { fg = p.red },
    OilOrphanLinkTarget = { fg = p.red, italic = true },
    OilEmpty = { fg = p.fg3 },
    OilCreate = { fg = p.green },
    OilDelete = { fg = p.red },
    OilMove = { fg = p.accent2 },
    OilCopy = { fg = p.yellow },
    OilChange = { fg = p.blue },
    OilDirIcon = { fg = p.blue },
    OilTrash = { fg = p.red },
    OilTrashSourcePath = { fg = p.fg3, italic = true },
    OilRestore = { fg = p.green },
    OilPurge = { fg = p.red, bold = true },
    OilHidden = { fg = p.fg3 },
  }
end

return oil
