---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function nvimtree(p)
  return {
    NvimTreeNormal = { fg = p.fg0, bg = p.bg1 },
    NvimTreeNormalNC = { fg = p.fg0, bg = p.bg1 },
    NvimTreeWinSeparator = { fg = p.bg4, bg = p.bg1 },
    NvimTreeEndOfBuffer = { fg = p.bg1 },
    NvimTreeCursorLine = { bg = p.bg4 },
    NvimTreeRootFolder = { fg = p.accent, bold = true },
    NvimTreeFolderName = { fg = p.blue },
    NvimTreeFolderIcon = { fg = p.blue },
    NvimTreeOpenedFolderName = { fg = p.blue, bold = true },
    NvimTreeEmptyFolderName = { fg = p.fg3 },
    NvimTreeSymlinkFolderName = { fg = p.purple },
    NvimTreeSpecialFile = { fg = p.accent2 },
    NvimTreeSymlink = { fg = p.purple },
    NvimTreeIndentMarker = { fg = p.fg3 },
    NvimTreeImageFile = { fg = p.purple },
    -- Git icon groups (current canonical names)
    NvimTreeGitDirtyIcon = { fg = p.yellow },
    NvimTreeGitStagedIcon = { fg = p.green },
    NvimTreeGitMergeIcon = { fg = p.accent },
    NvimTreeGitRenamedIcon = { fg = p.purple },
    NvimTreeGitNewIcon = { fg = p.green },
    NvimTreeGitDeletedIcon = { fg = p.red },
    NvimTreeGitIgnoredIcon = { fg = p.fg3 },
    NvimTreeDiagnosticErrorIcon = { fg = p.red },
    NvimTreeDiagnosticWarnIcon = { fg = p.yellow },
    NvimTreeDiagnosticInfoIcon = { fg = p.blue },
    NvimTreeDiagnosticHintIcon = { fg = p.cyan },
    -- Modified/opened icons
    NvimTreeModifiedIcon = { fg = p.yellow },
    NvimTreeOpenedHL = { fg = p.fg0, bold = true },
    -- *HL variants: activated by renderer.highlight_git = 'name'
    NvimTreeGitFileDirtyHL = { link = 'NvimTreeGitDirtyIcon' },
    NvimTreeGitFileStagedHL = { link = 'NvimTreeGitStagedIcon' },
    NvimTreeGitFileMergeHL = { link = 'NvimTreeGitMergeIcon' },
    NvimTreeGitFileRenamedHL = { link = 'NvimTreeGitRenamedIcon' },
    NvimTreeGitFileNewHL = { link = 'NvimTreeGitNewIcon' },
    NvimTreeGitFileDeletedHL = { link = 'NvimTreeGitDeletedIcon' },
    NvimTreeGitFileIgnoredHL = { link = 'NvimTreeGitIgnoredIcon' },
    NvimTreeGitFolderDirtyHL = { link = 'NvimTreeGitFileDirtyHL' },
    NvimTreeGitFolderStagedHL = { link = 'NvimTreeGitFileStagedHL' },
    NvimTreeGitFolderMergeHL = { link = 'NvimTreeGitFileMergeHL' },
    NvimTreeGitFolderRenamedHL = { link = 'NvimTreeGitFileRenamedHL' },
    NvimTreeGitFolderNewHL = { link = 'NvimTreeGitFileNewHL' },
    NvimTreeGitFolderDeletedHL = { link = 'NvimTreeGitFileDeletedHL' },
    NvimTreeGitFolderIgnoredHL = { link = 'NvimTreeGitFileIgnoredHL' },
    -- *HL variants: activated by renderer.highlight_modified / highlight_opened_files = 'name'
    NvimTreeModifiedFileHL = { link = 'NvimTreeModifiedIcon' },
    NvimTreeModifiedFolderHL = { link = 'NvimTreeModifiedIcon' },
    -- *HL variants: activated by renderer.highlight_diagnostics = 'name'
    NvimTreeDiagnosticErrorFileHL = { link = 'DiagnosticError' },
    NvimTreeDiagnosticWarnFileHL = { link = 'DiagnosticWarn' },
    NvimTreeDiagnosticInfoFileHL = { link = 'DiagnosticInfo' },
    NvimTreeDiagnosticHintFileHL = { link = 'DiagnosticHint' },
    NvimTreeDiagnosticErrorFolderHL = { link = 'NvimTreeDiagnosticErrorFileHL' },
    NvimTreeDiagnosticWarnFolderHL = { link = 'NvimTreeDiagnosticWarnFileHL' },
    NvimTreeDiagnosticInfoFolderHL = { link = 'NvimTreeDiagnosticInfoFileHL' },
    NvimTreeDiagnosticHintFolderHL = { link = 'NvimTreeDiagnosticHintFileHL' },
  }
end

return nvimtree
