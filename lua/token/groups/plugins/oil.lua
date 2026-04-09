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
    OilCreate = { fg = p.green },
    OilDelete = { fg = p.red },
    OilMove = { fg = p.accent2 },
    OilCopy = { fg = p.yellow },
    OilChange = { fg = p.blue },
    OilPermissionNone = { fg = p.fg3 },
    OilPermissionRead = { fg = p.yellow },
    OilPermissionWrite = { fg = p.red },
    OilPermissionExecute = { fg = p.green },
    OilTypeDir = { fg = p.blue },
    OilTypeFile = { fg = p.fg2 },
    OilTypeLink = { fg = p.purple },
    OilTypeSocket = { fg = p.accent2 },
    OilTrash = { fg = p.red },
    OilRestore = { fg = p.green },
    OilPurge = { fg = p.red, bold = true },
    OilHidden = { fg = p.fg3 },
  }
end

return oil
