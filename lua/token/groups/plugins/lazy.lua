---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function lazy(p)
  return {
    LazyNormal = { link = 'NormalFloat' },
    LazyBackdrop = { bg = p.bg0 },

    -- headings and buttons
    LazyH1 = { fg = p.bg3, bg = p.accent, bold = true },
    LazyH2 = { fg = p.accent, bold = true },
    LazyButton = { fg = p.fg1, bg = p.bg4 },
    LazyButtonActive = { fg = p.bg3, bg = p.accent },

    -- progress
    LazyProgressDone = { fg = p.accent },
    LazyProgressTodo = { fg = p.fg3 },

    -- diagnostics
    LazyError = { fg = p.red },
    LazyWarning = { fg = p.yellow },
    LazyInfo = { fg = p.blue },
    LazyTaskOutput = { link = 'MsgArea' },

    -- commit info
    LazyCommit = { fg = p.purple },
    LazyCommitIssue = { fg = p.blue },
    LazyCommitType = { fg = p.accent, bold = true },
    LazyCommitScope = { fg = p.fg1, italic = true },

    -- text elements
    LazyUrl = { fg = p.blue, underline = true },
    LazyDir = { fg = p.blue },
    LazySpecial = { fg = p.accent },
    LazyDimmed = { fg = p.fg3 },
    LazyProp = { fg = p.fg2 },
    LazyValue = { fg = p.green },
    LazyNoCond = { fg = p.fg3 },
    LazyLocal = { fg = p.green },
    LazyBold = { bold = true },
    LazyItalic = { italic = true },

    -- load reasons
    LazyReasonPlugin = { fg = p.accent },
    LazyReasonEvent = { fg = p.purple },
    LazyReasonKeys = { fg = p.accent2 },
    LazyReasonStart = { fg = p.green },
    LazyReasonCmd = { fg = p.accent },
    LazyReasonFt = { fg = p.blue },
    LazyReasonSource = { fg = p.fg2 },
    LazyReasonRequire = { fg = p.purple },
    LazyReasonRuntime = { fg = p.fg2 },
    LazyReasonImport = { fg = p.blue },
  }
end

return lazy
