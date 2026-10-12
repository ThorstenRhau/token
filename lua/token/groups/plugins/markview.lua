---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function markview(p)
  return {
    -- markview.nvim palette (foundation, callouts/checkboxes link here)
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
    -- Markview draws frontmatter edges with half blocks in this foreground, so
    -- it must equal the code background to read as a soft edge.
    MarkviewCodeFg = { fg = p.bg2 },
    MarkviewInlineCode = { fg = p.green, bg = p.bg2 },

    -- markview.nvim icons and headings. Icons label code blocks on the code
    -- background, so they carry it alongside the palette foreground.
    MarkviewIcon0 = { fg = p.fg2, bg = p.bg2 },
    MarkviewIcon1 = { fg = p.accent, bg = p.bg2 },
    MarkviewIcon2 = { fg = p.accent2, bg = p.bg2 },
    MarkviewIcon3 = { fg = p.olive, bg = p.bg2 },
    MarkviewIcon3Fg = { link = 'MarkviewPalette3Fg' },
    MarkviewIcon4 = { fg = p.blue, bg = p.bg2 },
    MarkviewIcon5 = { fg = p.green, bg = p.bg2 },
    MarkviewIcon6 = { fg = p.purple, bg = p.bg2 },
    MarkviewHeading1 = { fg = p.accent, bg = p.bg4, bold = true },
    MarkviewHeading1Sign = { fg = p.accent, bold = true },
    MarkviewHeading2 = { fg = p.accent2, bg = p.bg4, bold = true },
    MarkviewHeading2Sign = { fg = p.accent2, bold = true },
    MarkviewHeading3 = { fg = p.olive, bg = p.bg4, bold = true },
    MarkviewHeading3Sign = { fg = p.olive, bold = true },
    MarkviewHeading4 = { fg = p.blue, bg = p.bg4, bold = true },
    MarkviewHeading4Sign = { fg = p.blue, bold = true },
    MarkviewHeading5 = { fg = p.green, bg = p.bg4, bold = true },
    MarkviewHeading5Sign = { fg = p.green, bold = true },
    MarkviewHeading6 = { fg = p.purple, bg = p.bg4, bold = true },
    MarkviewHeading6Sign = { fg = p.purple, bold = true },

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

    -- markview.nvim inline markup, lists, and tables
    MarkviewHyperlink = { link = '@markup.link.label.markdown_inline' },
    MarkviewImage = { link = '@markup.link.label.markdown_inline' },
    MarkviewEmail = { link = '@markup.link.url.markdown_inline' },
    MarkviewSubscript = { link = 'MarkviewPalette3Fg' },
    MarkviewSuperscript = { link = 'MarkviewPalette6Fg' },
    MarkviewSpecial = { link = 'Special' },
    MarkviewComment = { link = 'Comment' },
    MarkviewListItemMinus = { link = 'MarkviewPalette2Fg' },
    MarkviewListItemPlus = { link = 'MarkviewPalette4Fg' },
    MarkviewListItemStar = { link = 'MarkviewPalette6Fg' },
    MarkviewTableHeader = { link = '@markup.heading' },
    MarkviewTableBorder = { link = 'MarkviewPalette5Fg' },
    MarkviewTableAlignLeft = { link = '@markup.heading' },
    MarkviewTableAlignCenter = { link = '@markup.heading' },
    MarkviewTableAlignRight = { link = '@markup.heading' },

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
    -- Current presets reference Gradient10 although Markview's generator stops at 9.
    MarkviewGradient10 = { link = 'MarkviewGradient9' },
  }
end

return markview
