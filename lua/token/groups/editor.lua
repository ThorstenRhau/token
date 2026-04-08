---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function editor(p)
  return {
    -- Editor UI
    Normal = { fg = p.fg0, bg = p.bg3 },
    NormalNC = { fg = p.fg0, bg = p.bg2 },
    NormalFloat = { fg = p.fg0, bg = p.bg0 },
    FloatBorder = { fg = p.fg3, bg = p.bg0 },
    FloatTitle = { fg = p.accent, bg = p.bg0, bold = true },
    FloatFooter = { fg = p.fg2, bg = p.bg0 },

    Cursor = { fg = p.bg3, bg = p.fg0 },
    lCursor = { link = 'Cursor' },
    CursorIM = { link = 'Cursor' },
    CursorLine = { bg = p.bg4 },
    CursorColumn = { bg = p.bg4 },
    TermCursor = { link = 'Cursor' },
    CursorLineFold = { fg = p.fg3, bg = p.bg4 },
    CursorLineSign = { fg = p.fg3, bg = p.bg4 },
    CursorLineNr = { fg = p.accent2, bold = true },

    LineNr = { fg = p.line_nr, bg = p.bg2 },
    LineNrAbove = { link = 'LineNr' },
    LineNrBelow = { link = 'LineNr' },
    SignColumn = { fg = p.fg3, bg = p.bg2 },
    FoldColumn = { fg = p.fg3, bg = p.bg2 },
    Folded = { fg = p.fg2, bg = p.bg2 },

    ColorColumn = { bg = p.bg4 },
    VertSplit = { fg = p.bg4 },
    WinSeparator = { fg = p.bg4 },

    StatusLine = { fg = p.fg1, bg = p.bg1 },
    StatusLineNC = { fg = p.fg3, bg = p.bg1 },
    StatusLineTerm = { fg = p.fg1, bg = p.bg1 },
    StatusLineTermNC = { fg = p.fg3, bg = p.bg1 },
    WinBar = { fg = p.fg1, bg = p.bg3 },
    WinBarNC = { fg = p.fg3, bg = p.bg2 },

    TabLine = { fg = p.fg2, bg = p.bg1 },
    TabLineFill = { fg = p.fg3, bg = p.bg1 },
    TabLineSel = { fg = p.fg0, bg = p.bg3, bold = true },

    Pmenu = { fg = p.fg0, bg = p.bg1 },
    PmenuSel = { fg = p.fg0, bg = p.sel, bold = true },
    PmenuSbar = { bg = p.bg2 },
    PmenuThumb = { bg = p.fg3 },
    PmenuKind = { fg = p.blue, bg = p.bg1 },
    PmenuKindSel = { fg = p.blue, bg = p.sel },
    PmenuExtra = { fg = p.fg2, bg = p.bg1 },
    PmenuExtraSel = { fg = p.fg2, bg = p.sel },
    PmenuMatch = { fg = p.accent, bg = p.bg1, bold = true },
    PmenuMatchSel = { fg = p.accent, bg = p.sel, bold = true },
    PmenuBorder = { fg = p.fg3, bg = p.bg1 },
    PmenuShadow = { link = 'FloatShadow' },
    PmenuShadowThrough = { link = 'FloatShadowThrough' },

    Visual = { bg = p.sel },
    VisualNOS = { bg = p.sel },

    Search = { fg = p.fg0, bg = p.match },
    IncSearch = { fg = p.bg3, bg = p.accent2 },
    CurSearch = { fg = p.bg3, bg = p.accent },
    Substitute = { fg = p.bg3, bg = p.red },

    MatchParen = { fg = p.accent, bold = true, underline = true },
    SnippetTabstop = { bg = p.bg5 },
    SnippetTabstopActive = { bg = p.match },

    WildMenu = { fg = p.bg3, bg = p.accent2 },
    QuickFixLine = { bg = p.bg5 },

    Directory = { fg = p.blue },
    Title = { fg = p.accent, bold = true },
    Question = { fg = p.green },
    MoreMsg = { fg = p.green },
    ModeMsg = { fg = p.fg1, bold = true },
    WarningMsg = { fg = p.yellow },
    ErrorMsg = { fg = p.red },
    MsgArea = { fg = p.fg0 },
    OkMsg = { fg = p.green },
    StderrMsg = { fg = p.red },
    StdoutMsg = { fg = p.fg0 },
    MsgSeparator = { fg = p.fg3, bg = p.bg4 },

    NonText = { fg = p.indent },
    Whitespace = { fg = p.indent },
    SpecialKey = { fg = p.fg3 },
    EndOfBuffer = { fg = p.bg4 },
    Conceal = { fg = p.fg2 },

    SpellBad = { undercurl = true, sp = p.red },
    SpellCap = { undercurl = true, sp = p.yellow },
    SpellLocal = { undercurl = true, sp = p.blue },
    SpellRare = { undercurl = true, sp = p.purple },

    -- LSP references
    LspReferenceText = { bg = p.bg5 },
    LspReferenceRead = { bg = p.bg5 },
    LspReferenceWrite = { bg = p.bg5, bold = true },
    LspReferenceTarget = { bg = p.bg5 },
    LspInlayHint = { fg = p.fg3, bg = p.bg4, italic = true },
    LspCodeLens = { fg = p.fg2 },
    LspCodeLensSeparator = { fg = p.fg3 },
    LspSignatureActiveParameter = { fg = p.accent, bold = true },

    -- Misc UI
    ComplMatchIns = { fg = p.accent, bold = true },
    PreInsert = { fg = p.green },
    ComplHint = { fg = p.fg3 },
    ComplHintMore = { fg = p.fg2 },
    FloatShadow = { bg = p.bg0, blend = 50 },
    FloatShadowThrough = { bg = p.bg0, blend = 80 },

    -- Quickfix / Location list
    qfLineNr = { fg = p.fg2 },
    qfFileName = { fg = p.blue },
  }
end

return editor
