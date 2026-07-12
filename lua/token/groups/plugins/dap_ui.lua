---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function dap_ui(p)
  return {
    -- window
    DapUINormal = { fg = p.fg0, bg = p.bg1 },
    DapUINormalNC = { link = 'DapUINormal' },
    DapUIEndofBuffer = { fg = p.bg1 },
    DapUIFloatNormal = { link = 'NormalFloat' },
    DapUIFloatBorder = { link = 'FloatBorder' },

    -- variables and scoping
    DapUIVariable = { fg = p.fg0 },
    DapUIType = { fg = p.blue },
    DapUIValue = { fg = p.purple },
    DapUIModifiedValue = { fg = p.accent, bold = true },
    DapUIScope = { fg = p.accent, bold = true },
    DapUIDecoration = { fg = p.fg3 },

    -- threads and frames
    DapUIThread = { fg = p.green },
    DapUIStoppedThread = { fg = p.accent, bold = true },
    DapUIFrameName = { fg = p.fg0 },
    DapUISource = { fg = p.blue, italic = true },
    DapUILineNumber = { link = 'LineNr' },
    DapUICurrentFrameName = { link = 'DapUIBreakpointsCurrentLine' },

    -- breakpoints
    DapUIBreakpointsPath = { fg = p.blue },
    DapUIBreakpointsInfo = { fg = p.blue },
    DapUIBreakpointsCurrentLine = { fg = p.accent, bold = true },
    DapUIBreakpointsLine = { link = 'DapUILineNumber' },
    DapUIBreakpointsDisabledLine = { fg = p.fg3 },

    -- watches
    DapUIWatchesEmpty = { fg = p.fg3 },
    DapUIWatchesValue = { fg = p.purple },
    DapUIWatchesError = { fg = p.red },

    -- controls
    DapUIPlayPause = { fg = p.green },
    DapUIPlayPauseNC = { link = 'DapUIPlayPause' },
    DapUIRestart = { fg = p.green },
    DapUIRestartNC = { link = 'DapUIRestart' },
    DapUIStepOver = { fg = p.blue },
    DapUIStepOverNC = { link = 'DapUIStepOver' },
    DapUIStepInto = { fg = p.blue },
    DapUIStepIntoNC = { link = 'DapUIStepInto' },
    DapUIStepBack = { fg = p.blue },
    DapUIStepBackNC = { link = 'DapUIStepBack' },
    DapUIStepOut = { fg = p.blue },
    DapUIStepOutNC = { link = 'DapUIStepOut' },
    DapUIStop = { fg = p.red },
    DapUIStopNC = { link = 'DapUIStop' },
    DapUIUnavailable = { fg = p.fg3 },
    DapUIUnavailableNC = { link = 'DapUIUnavailable' },
    DapUIWinSelect = { fg = p.accent, bold = true },
  }
end

return dap_ui
