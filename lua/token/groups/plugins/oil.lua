---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function oil(p)
  return {
    OilDir = { fg = p.blue },
    OilDirHidden = { link = 'OilDir' },
    OilFile = { fg = p.fg0 },
    OilFileHidden = { link = 'OilHidden' },
    OilLink = { fg = p.purple },
    OilLinkHidden = { link = 'OilHidden' },
    OilLinkTarget = { fg = p.purple, italic = true },
    OilLinkTargetHidden = { link = 'OilHidden' },
    OilSocket = { fg = p.accent2 },
    OilSocketHidden = { link = 'OilHidden' },
    OilOrphanLink = { fg = p.red },
    OilOrphanLinkHidden = { link = 'OilHidden' },
    OilOrphanLinkTarget = { fg = p.red, italic = true },
    OilOrphanLinkTargetHidden = { link = 'OilHidden' },
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
