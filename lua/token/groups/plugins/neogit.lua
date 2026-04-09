---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function neogit(p)
  return {
    -- Graph colors
    NeogitGraphAuthor = { fg = p.accent },
    NeogitGraphRed = { fg = p.red },
    NeogitGraphWhite = { fg = p.fg0 },
    NeogitGraphYellow = { fg = p.yellow },
    NeogitGraphGreen = { fg = p.green },
    NeogitGraphCyan = { fg = p.cyan },
    NeogitGraphBlue = { fg = p.blue },
    NeogitGraphPurple = { fg = p.purple },
    NeogitGraphGray = { fg = p.fg3 },
    NeogitGraphOrange = { fg = p.accent },
    NeogitGraphBoldRed = { fg = p.red, bold = true },
    NeogitGraphBoldWhite = { fg = p.fg0, bold = true },
    NeogitGraphBoldYellow = { fg = p.yellow, bold = true },
    NeogitGraphBoldGreen = { fg = p.green, bold = true },
    NeogitGraphBoldCyan = { fg = p.cyan, bold = true },
    NeogitGraphBoldBlue = { fg = p.blue, bold = true },
    NeogitGraphBoldPurple = { fg = p.purple, bold = true },
    NeogitGraphBoldGray = { fg = p.fg3, bold = true },
    NeogitGraphBoldOrange = { fg = p.accent, bold = true },

    -- Diff file headers
    NeogitDiffHeader = { fg = p.blue, bg = p.bg4, bold = true },
    NeogitDiffHeaderHighlight = { fg = p.accent, bg = p.bg5, bold = true },

    -- Diff context
    NeogitDiffContext = { fg = p.fg1, bg = p.bg3 },
    NeogitDiffContextHighlight = { fg = p.fg0, bg = p.bg4 },
    NeogitDiffContextCursor = { fg = p.fg1, bg = p.bg3 },

    -- Diff add/delete
    NeogitDiffAdditions = { fg = p.green },
    NeogitDiffAdd = { fg = p.green, bg = p.diff_add },
    NeogitDiffAddHighlight = { fg = p.green, bg = p.diff_add, bold = true },
    NeogitDiffAddCursor = { fg = p.green, bg = p.bg3 },
    NeogitDiffDeletions = { fg = p.red },
    NeogitDiffDelete = { fg = p.red, bg = p.diff_del },
    NeogitDiffDeleteHighlight = { fg = p.red, bg = p.diff_del, bold = true },
    NeogitDiffDeleteCursor = { fg = p.red, bg = p.bg3 },
    NeogitDiffAddInline = { bg = p.diff_add_inline },
    NeogitDiffDeleteInline = { bg = p.diff_del_inline },

    -- Hunk headers
    NeogitHunkHeader = { fg = p.fg0, bg = p.bg4, bold = true },
    NeogitHunkHeaderHighlight = { fg = p.accent, bg = p.bg5, bold = true },
    NeogitHunkHeaderCursor = { fg = p.accent, bg = p.bg5, bold = true },
    NeogitHunkMergeHeader = { fg = p.fg0, bg = p.bg4, bold = true },
    NeogitHunkMergeHeaderHighlight = { fg = p.cyan, bg = p.bg5, bold = true },
    NeogitHunkMergeHeaderCursor = { fg = p.cyan, bg = p.bg5, bold = true },

    -- Branch/remote/tag
    NeogitBranch = { fg = p.accent },
    NeogitBranchHead = { fg = p.accent, bold = true, underline = true },
    NeogitRemote = { fg = p.blue },
    NeogitTagName = { fg = p.yellow },
    NeogitTagDistance = { fg = p.cyan },

    -- Status sections
    NeogitSectionHeader = { fg = p.accent, bold = true },
    NeogitObjectId = { fg = p.fg3 },
    NeogitStash = { fg = p.fg1 },
    NeogitStashEntry = { fg = p.fg0 },
    NeogitUnmergedInto = { fg = p.purple, bold = true },
    NeogitUnpushedTo = { fg = p.accent },
    NeogitUnpulledFrom = { fg = p.blue },

    -- Change type indicators
    NeogitChangeModified = { fg = p.yellow },
    NeogitChangeAdded = { fg = p.green },
    NeogitChangeDeleted = { fg = p.red },
    NeogitChangeRenamed = { fg = p.purple },
    NeogitChangeNewFile = { fg = p.green },
    NeogitChangeUpdated = { fg = p.blue },
    NeogitChangeCopied = { fg = p.accent2 },
    NeogitChangeUnmerged = { fg = p.accent },

    -- Commit view
    NeogitCommitViewHeader = { fg = p.fg0, bg = p.bg5, bold = true },
    NeogitFilePath = { fg = p.blue, italic = true },

    -- Popup keys
    NeogitPopupSwitchKey = { fg = p.purple },
    NeogitPopupOptionKey = { fg = p.purple },
    NeogitPopupConfigKey = { fg = p.purple },
    NeogitPopupActionKey = { fg = p.purple },

    -- Float headers
    NeogitFloatHeader = { fg = p.fg1, bg = p.bg0, bold = true },
    NeogitFloatHeaderHighlight = { fg = p.cyan, bg = p.bg2, bold = true },

    -- Active item (currently viewed commit in log)
    NeogitActiveItem = { bg = p.bg5, bold = true },
  }
end

return neogit
