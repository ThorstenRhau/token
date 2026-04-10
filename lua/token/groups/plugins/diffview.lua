---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function diffview(p)
  return {
    DiffviewFilePanelRootPath = { fg = p.fg3 },
    DiffviewFilePanelTitle = { fg = p.accent, bold = true },
    DiffviewFilePanelCounter = { fg = p.fg2 },
    DiffviewFilePanelFileName = { fg = p.fg0 },
    DiffviewFilePanelInsertions = { fg = p.green },
    DiffviewFilePanelDeletions = { fg = p.red },
    DiffviewFilePanelConflicts = { fg = p.yellow },
    DiffviewFolderName = { fg = p.blue },
    DiffviewFolderSign = { fg = p.fg3 },
    DiffviewStatusAdded = { fg = p.green },
    DiffviewStatusUntracked = { fg = p.fg3 },
    DiffviewStatusModified = { fg = p.yellow },
    DiffviewStatusRenamed = { fg = p.purple },
    DiffviewStatusCopied = { fg = p.accent2 },
    DiffviewStatusTypeChange = { fg = p.blue },
    DiffviewStatusUnmerged = { fg = p.accent },
    DiffviewStatusUnknown = { fg = p.red },
    DiffviewStatusDeleted = { fg = p.red },
    DiffviewStatusBroken = { fg = p.red, bold = true },
    DiffviewStatusIgnored = { fg = p.fg3 },
    DiffviewDim1 = { fg = p.fg3 },
    DiffviewPrimary = { fg = p.accent },
    DiffviewSecondary = { fg = p.accent2 },
    DiffviewHash = { fg = p.purple },
    DiffviewReference = { fg = p.accent },
    DiffviewFilePanelPath = { fg = p.fg3 },
  }
end

return diffview
