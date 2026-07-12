---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function noice(p)
  return {
    -- cmdline
    NoiceCmdline = { fg = p.fg0, bg = p.bg1 },
    NoiceCmdlineIcon = { fg = p.accent },
    NoiceCmdlineIconSearch = { fg = p.yellow },
    NoiceCmdlinePopup = { fg = p.fg0, bg = p.bg1 },
    NoiceCmdlinePopupBorder = { fg = p.fg3, bg = p.bg1 },
    NoiceCmdlinePopupBorderSearch = { fg = p.yellow, bg = p.bg1 },
    NoiceCmdlinePopupTitle = { fg = p.accent, bg = p.bg1, bold = true },
    NoiceCmdlinePrompt = { link = 'MsgArea' },

    -- popup and message windows
    NoicePopup = { fg = p.fg0, bg = p.bg0 },
    NoicePopupBorder = { fg = p.fg3, bg = p.bg0 },
    NoiceMini = { link = 'MsgArea' },
    NoiceSplit = { link = 'Normal' },
    NoiceSplitBorder = { link = 'FloatBorder' },

    -- confirm dialog
    NoiceConfirm = { link = 'NormalFloat' },
    NoiceConfirmBorder = { link = 'FloatBorder' },
    NoiceCursor = { link = 'Cursor' },
    NoiceHiddenCursor = { blend = 100, nocombine = true },

    -- popupmenu
    NoicePopupmenu = { link = 'Pmenu' },
    NoicePopupmenuBorder = { link = 'FloatBorder' },
    NoicePopupmenuMatch = { fg = p.accent, bold = true },
    NoicePopupmenuSelected = { link = 'PmenuSel' },
    NoiceScrollbar = { link = 'PmenuSbar' },
    NoiceScrollbarThumb = { link = 'PmenuThumb' },

    -- format elements
    NoiceFormatProgressDone = { fg = p.bg3, bg = p.accent },
    NoiceFormatProgressTodo = { fg = p.fg3, bg = p.bg4 },
    NoiceFormatTitle = { fg = p.accent, bold = true },
    NoiceFormatEvent = { fg = p.fg2 },
    NoiceFormatKind = { fg = p.blue },
    NoiceFormatDate = { fg = p.fg2 },
    NoiceFormatConfirm = { fg = p.accent },
    NoiceFormatConfirmDefault = { fg = p.accent, bold = true },
    NoiceFormatLevelError = { fg = p.red },
    NoiceFormatLevelWarn = { fg = p.yellow },
    NoiceFormatLevelInfo = { fg = p.blue },
    NoiceFormatLevelDebug = { fg = p.fg2 },
    NoiceFormatLevelTrace = { fg = p.fg3 },
    NoiceFormatLevelOff = { fg = p.fg3 },

    -- LSP progress
    NoiceLspProgressTitle = { fg = p.accent, bold = true },
    NoiceLspProgressClient = { fg = p.fg2 },
    NoiceLspProgressSpinner = { fg = p.accent },

    -- virtual text
    NoiceVirtualText = { fg = p.fg2, italic = true },

    -- completion item kinds (matches blink.lua mapping)
    NoiceCompletionItemKindDefault = { fg = p.fg2 },
    NoiceCompletionItemMenu = { fg = p.fg2 },
    NoiceCompletionItemWord = { fg = p.fg0 },
    NoiceCompletionItemKindText = { fg = p.fg1 },
    NoiceCompletionItemKindMethod = { fg = p.accent },
    NoiceCompletionItemKindFunction = { fg = p.accent },
    NoiceCompletionItemKindConstructor = { fg = p.blue },
    NoiceCompletionItemKindField = { fg = p.fg0 },
    NoiceCompletionItemKindVariable = { fg = p.fg0 },
    NoiceCompletionItemKindClass = { fg = p.blue },
    NoiceCompletionItemKindInterface = { fg = p.blue },
    NoiceCompletionItemKindModule = { fg = p.blue },
    NoiceCompletionItemKindProperty = { fg = p.fg0 },
    NoiceCompletionItemKindUnit = { fg = p.purple },
    NoiceCompletionItemKindValue = { fg = p.purple },
    NoiceCompletionItemKindEnum = { fg = p.blue },
    NoiceCompletionItemKindKeyword = { fg = p.accent2 },
    NoiceCompletionItemKindSnippet = { fg = p.green },
    NoiceCompletionItemKindColor = { fg = p.purple },
    NoiceCompletionItemKindFile = { fg = p.blue },
    NoiceCompletionItemKindFolder = { fg = p.blue },
    NoiceCompletionItemKindEnumMember = { fg = p.purple },
    NoiceCompletionItemKindConstant = { fg = p.purple },
    NoiceCompletionItemKindStruct = { fg = p.blue },
  }
end

return noice
