---@param p TokenPalette
---@return table<string, vim.api.keyset.highlight>
local function render_markdown(p)
  return {
    -- headings (fg matches treesitter.lua @markup.heading.*)
    RenderMarkdownH1 = { fg = p.accent, bold = true },
    RenderMarkdownH2 = { fg = p.accent2, bold = true },
    RenderMarkdownH3 = { fg = p.olive, bold = true },
    RenderMarkdownH4 = { fg = p.blue, bold = true },
    RenderMarkdownH5 = { fg = p.green, bold = true },
    RenderMarkdownH6 = { fg = p.purple, bold = true },
    RenderMarkdownH1Bg = { fg = p.accent, bg = p.bg4, bold = true },
    RenderMarkdownH2Bg = { fg = p.accent2, bg = p.bg4, bold = true },
    RenderMarkdownH3Bg = { fg = p.olive, bg = p.bg4, bold = true },
    RenderMarkdownH4Bg = { fg = p.blue, bg = p.bg4, bold = true },
    RenderMarkdownH5Bg = { fg = p.green, bg = p.bg4, bold = true },
    RenderMarkdownH6Bg = { fg = p.purple, bg = p.bg4, bold = true },

    -- code
    RenderMarkdownCode = { bg = p.bg2 },
    RenderMarkdownCodeBorder = { link = 'RenderMarkdownCode' },
    RenderMarkdownCodeInline = { fg = p.green, bg = p.bg2 },
    RenderMarkdownCodeInfo = { fg = p.fg2, bg = p.bg2 },

    -- block quotes
    RenderMarkdownQuote = { fg = p.fg2, italic = true },

    -- links
    RenderMarkdownLink = { fg = p.blue, underline = true },
    RenderMarkdownWikiLink = { link = 'RenderMarkdownLink' },

    -- checkboxes
    RenderMarkdownChecked = { fg = p.green },
    RenderMarkdownUnchecked = { fg = p.fg3 },
    RenderMarkdownTodo = { fg = p.accent2 },

    -- tables
    RenderMarkdownTableHead = { fg = p.accent, bold = true },
    RenderMarkdownTableRow = { fg = p.fg1 },
    RenderMarkdownTableFill = { fg = p.fg3 },

    -- bullets and rules
    RenderMarkdownBullet = { fg = p.accent2 },
    RenderMarkdownDash = { fg = p.fg3 },

    -- callouts
    RenderMarkdownSuccess = { fg = p.green },
    RenderMarkdownInfo = { fg = p.blue },
    RenderMarkdownHint = { fg = p.cyan },
    RenderMarkdownWarn = { fg = p.yellow },
    RenderMarkdownError = { fg = p.red },

    -- misc
    RenderMarkdownSign = { link = 'SignColumn' },
    RenderMarkdownIndent = { link = 'Whitespace' },
    RenderMarkdownMath = { fg = p.purple },
  }
end

return render_markdown
