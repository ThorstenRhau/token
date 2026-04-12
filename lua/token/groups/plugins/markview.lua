---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function markview(p)
  return {
    -- markview.nvim palette (foundation, headings/callouts/checkboxes link here)
    MarkviewPalette0 = { fg = p.fg2, bg = p.bg4 },
    MarkviewPalette0Sign = { fg = p.fg2 },
    MarkviewPalette0Fg = { fg = p.fg2 },
    MarkviewPalette0Bg = { bg = p.bg4 },

    MarkviewPalette1 = { fg = p.accent, bg = p.bg4 },
    MarkviewPalette1Sign = { fg = p.accent },
    MarkviewPalette1Fg = { fg = p.accent },
    MarkviewPalette1Bg = { bg = p.bg4 },

    MarkviewPalette2 = { fg = p.accent2, bg = p.bg4 },
    MarkviewPalette2Sign = { fg = p.accent2 },
    MarkviewPalette2Fg = { fg = p.accent2 },
    MarkviewPalette2Bg = { bg = p.bg4 },

    MarkviewPalette3 = { fg = p.olive, bg = p.bg4 },
    MarkviewPalette3Sign = { fg = p.olive },
    MarkviewPalette3Fg = { fg = p.olive },
    MarkviewPalette3Bg = { bg = p.bg4 },

    MarkviewPalette4 = { fg = p.blue, bg = p.bg4 },
    MarkviewPalette4Sign = { fg = p.blue },
    MarkviewPalette4Fg = { fg = p.blue },
    MarkviewPalette4Bg = { bg = p.bg4 },

    MarkviewPalette5 = { fg = p.green, bg = p.bg4 },
    MarkviewPalette5Sign = { fg = p.green },
    MarkviewPalette5Fg = { fg = p.green },
    MarkviewPalette5Bg = { bg = p.bg4 },

    MarkviewPalette6 = { fg = p.purple, bg = p.bg4 },
    MarkviewPalette6Sign = { fg = p.purple },
    MarkviewPalette6Fg = { fg = p.purple },
    MarkviewPalette6Bg = { bg = p.bg4 },

    MarkviewPalette7 = { fg = p.cyan, bg = p.bg4 },
    MarkviewPalette7Sign = { fg = p.cyan },
    MarkviewPalette7Fg = { fg = p.cyan },
    MarkviewPalette7Bg = { bg = p.bg4 },

    -- markview.nvim code blocks
    MarkviewCode = { bg = p.bg2 },
    MarkviewCodeInfo = { fg = p.fg2, bg = p.bg2 },
    MarkviewCodeFg = { fg = p.fg3 },
    MarkviewInlineCode = { fg = p.green, bg = p.bg2 },

    -- markview.nvim block quotes (override palette links for semantic colors)
    MarkviewBlockQuoteDefault = { fg = p.fg2 },
    MarkviewBlockQuoteError = { fg = p.red },
    MarkviewBlockQuoteWarn = { fg = p.yellow },
    MarkviewBlockQuoteSpecial = { fg = p.accent2 },
    MarkviewBlockQuoteOk = { fg = p.green },
    MarkviewBlockQuoteNote = { fg = p.blue },

    -- markview.nvim checkboxes (override palette links for semantic colors)
    MarkviewCheckboxChecked = { fg = p.green },
    MarkviewCheckboxUnchecked = { fg = p.fg3 },
    MarkviewCheckboxPending = { fg = p.accent2 },
    MarkviewCheckboxProgress = { fg = p.blue },
    MarkviewCheckboxCancelled = { fg = p.fg2 },
    MarkviewCheckboxStriked = { fg = p.fg2, strikethrough = true },

    -- markview.nvim horizontal rule gradient
    MarkviewGradient0 = { fg = p.bg5 },
    MarkviewGradient1 = { fg = p.fg3 },
    MarkviewGradient2 = { fg = p.fg3 },
    MarkviewGradient3 = { fg = p.fg2 },
    MarkviewGradient4 = { fg = p.fg2 },
    MarkviewGradient5 = { fg = p.fg2 },
    MarkviewGradient6 = { fg = p.fg1 },
    MarkviewGradient7 = { fg = p.fg1 },
    MarkviewGradient8 = { fg = p.accent2 },
    MarkviewGradient9 = { fg = p.accent },
  }
end

return markview
