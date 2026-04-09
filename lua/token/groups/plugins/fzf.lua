---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function fzf(p)
  return {
    FzfLuaNormal = { fg = p.fg0, bg = p.bg1 },
    FzfLuaBorder = { fg = p.fg3, bg = p.bg1 },
    FzfLuaTitle = { fg = p.accent, bg = p.bg1, bold = true },
    FzfLuaPreviewNormal = { fg = p.fg0, bg = p.bg0 },
    FzfLuaPreviewBorder = { fg = p.fg3, bg = p.bg0 },
    FzfLuaPreviewTitle = { fg = p.accent2, bg = p.bg0, bold = true },
    FzfLuaCursor = { link = 'Cursor' },
    FzfLuaCursorLine = { bg = p.sel },
    FzfLuaCursorLineNr = { link = 'CursorLineNr' },
    FzfLuaSearch = { link = 'Search' },
    FzfLuaScrollBorderEmpty = { fg = p.fg3, bg = p.bg1 },
    FzfLuaScrollBorderFull = { fg = p.accent, bg = p.bg1 },
    FzfLuaScrollFloatEmpty = { bg = p.bg2 },
    FzfLuaScrollFloatFull = { bg = p.accent },
    FzfLuaHelpNormal = { fg = p.fg0, bg = p.bg0 },
    FzfLuaHelpBorder = { fg = p.fg3, bg = p.bg0 },
    FzfLuaHeaderBind = { fg = p.accent2 },
    FzfLuaHeaderText = { fg = p.blue },
    FzfLuaPathColNr = { fg = p.fg3 },
    FzfLuaPathLineNr = { fg = p.fg3 },
    FzfLuaBufName = { fg = p.fg1 },
    FzfLuaBufNr = { fg = p.fg3 },
    FzfLuaBufFlagCur = { fg = p.accent },
    FzfLuaBufFlagAlt = { fg = p.accent2 },
    FzfLuaTabTitle = { fg = p.accent, bold = true },
    FzfLuaTabMarker = { fg = p.accent2 },
    FzfLuaDirIcon = { fg = p.blue },
    FzfLuaLiveSym = { fg = p.accent2 },
    FzfLuaLivePrompt = { fg = p.accent },
    FzfLuaFzfPrompt = { fg = p.accent },
    FzfLuaFzfQuery = { fg = p.fg0 },
    FzfLuaFzfMatch = { fg = p.accent, bold = true },
    FzfLuaFzfPointer = { fg = p.accent },
    FzfLuaFzfInfo = { fg = p.fg3 },
  }
end

return fzf
