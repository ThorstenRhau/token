---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function neo_tree(p)
  return {
    -- window
    NeoTreeNormal = { fg = p.fg0, bg = p.bg1 },
    NeoTreeNormalNC = { fg = p.fg0, bg = p.bg1 },
    NeoTreeEndOfBuffer = { fg = p.bg1 },
    NeoTreeWinSeparator = { fg = p.bg4, bg = p.bg1 },
    NeoTreeCursorLine = { bg = p.bg4 },
    NeoTreeBufferNumber = { fg = p.fg3 },
    NeoTreeFadeText1 = { fg = p.fg2 },
    NeoTreeFadeText2 = { fg = p.fg3 },
    NeoTreeSignColumn = { link = 'NeoTreeNormal' },
    NeoTreeStatusLine = { link = 'StatusLineNC' },
    NeoTreeStatusLineNC = { link = 'StatusLineNC' },
    NeoTreeVertSplit = { link = 'WinSeparator' },

    -- files and directories
    NeoTreeRootName = { fg = p.accent, bold = true },
    NeoTreeDirectoryName = { fg = p.blue },
    NeoTreeDirectoryIcon = { fg = p.blue },
    NeoTreeFileName = { fg = p.fg0 },
    NeoTreeFileNameOpened = { fg = p.fg0, bold = true },
    NeoTreeFileIcon = { fg = p.fg0 },
    NeoTreeFileStats = { fg = p.fg3 },
    NeoTreeFileStatsHeader = { fg = p.fg2, bold = true },
    NeoTreeSymbolicLinkTarget = { fg = p.purple, italic = true },
    NeoTreeIndentMarker = { fg = p.fg3 },
    NeoTreeExpander = { fg = p.fg3 },
    NeoTreeDotfile = { fg = p.fg3 },
    NeoTreeHiddenByName = { fg = p.fg3 },
    NeoTreeIgnored = { fg = p.fg3 },
    NeoTreeDimText = { fg = p.fg3 },
    NeoTreeMessage = { fg = p.fg2, italic = true },
    NeoTreeSelected = { bg = p.sel },
    NeoTreeFilterTerm = { fg = p.accent, bold = true },

    -- float window
    NeoTreeFloatBorder = { fg = p.fg3, bg = p.bg0 },
    NeoTreeFloatNormal = { link = 'NormalFloat' },
    NeoTreeFloatTitle = { fg = p.accent, bg = p.bg0, bold = true },
    NeoTreeTitleBar = { fg = p.bg3, bg = p.accent, bold = true },

    -- git status
    NeoTreeGitAdded = { fg = p.green },
    NeoTreeGitConflict = { fg = p.accent },
    NeoTreeGitDeleted = { fg = p.red },
    NeoTreeGitIgnored = { fg = p.fg3 },
    NeoTreeGitModified = { fg = p.yellow },
    NeoTreeGitRenamed = { fg = p.purple },
    NeoTreeGitStaged = { fg = p.green },
    NeoTreeGitUnstaged = { fg = p.yellow },
    NeoTreeGitUntracked = { fg = p.fg3 },

    -- modified indicator
    NeoTreeModified = { fg = p.yellow },

    -- tabs, previews, and hidden-window indicator
    NeoTreeTabActive = { fg = p.fg0, bg = p.bg3, bold = true },
    NeoTreeTabInactive = { fg = p.fg2, bg = p.bg1 },
    NeoTreeTabSeparatorActive = { fg = p.bg3, bg = p.bg3 },
    NeoTreeTabSeparatorInactive = { fg = p.bg1, bg = p.bg1 },
    NeoTreeWindowsHidden = { fg = p.fg3 },
    NeoTreePreview = { bg = p.bg5 },
  }
end

return neo_tree
