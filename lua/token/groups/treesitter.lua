---@param p table palette
---@return table
local function treesitter(p)
  return {
    -- Variables
    ['@variable'] = { fg = p.fg0 },
    ['@variable.builtin'] = { fg = p.accent2, italic = true },
    ['@variable.parameter'] = { fg = p.fg1 },
    ['@variable.parameter.builtin'] = { fg = p.accent2, italic = true },
    ['@variable.member'] = { fg = p.fg0 },

    -- Constants
    ['@constant'] = { link = 'Constant' },
    ['@constant.builtin'] = { fg = p.purple },
    ['@constant.macro'] = { link = 'Macro' },

    -- Modules / namespaces
    ['@module'] = { fg = p.blue },
    ['@module.builtin'] = { fg = p.blue },
    ['@label'] = { link = 'Label' },

    -- Strings
    ['@string'] = { link = 'String' },
    ['@string.documentation'] = { fg = p.green, italic = true },
    ['@string.regexp'] = { fg = p.purple },
    ['@string.escape'] = { fg = p.purple },
    ['@string.special'] = { link = 'SpecialChar' },
    ['@string.special.symbol'] = { fg = p.purple },
    ['@string.special.path'] = { fg = p.blue },
    ['@string.special.url'] = { fg = p.blue, underline = true },

    -- Characters / numbers
    ['@character'] = { link = 'Character' },
    ['@character.special'] = { link = 'SpecialChar' },
    ['@boolean'] = { link = 'Boolean' },
    ['@number'] = { link = 'Number' },
    ['@number.float'] = { link = 'Float' },

    -- Types
    ['@type'] = { link = 'Type' },
    ['@type.builtin'] = { fg = p.blue },
    ['@type.definition'] = { link = 'Type' },

    -- Attributes / decorators
    ['@attribute'] = { fg = p.purple },
    ['@attribute.builtin'] = { fg = p.purple },
    ['@property'] = { fg = p.fg0 },

    -- Functions
    ['@function'] = { link = 'Function' },
    ['@function.builtin'] = { fg = p.accent },
    ['@function.call'] = { link = 'Function' },
    ['@function.macro'] = { fg = p.purple },
    ['@function.method'] = { link = 'Function' },
    ['@function.method.call'] = { link = 'Function' },

    -- Constructors
    ['@constructor'] = { fg = p.blue },

    -- Operators / punctuation
    ['@operator'] = { link = 'Operator' },
    ['@punctuation'] = { fg = p.fg1 },
    ['@punctuation.delimiter'] = { fg = p.fg1 },
    ['@punctuation.bracket'] = { fg = p.fg1 },
    ['@punctuation.special'] = { fg = p.purple },

    -- Comments
    ['@comment'] = { link = 'Comment' },
    ['@comment.documentation'] = { fg = p.fg2, italic = true },
    ['@comment.error'] = { fg = p.red, italic = true },
    ['@comment.warning'] = { fg = p.yellow, italic = true },
    ['@comment.todo'] = { fg = p.yellow, bold = true },
    ['@comment.note'] = { fg = p.blue, italic = true },

    -- Keywords
    ['@keyword'] = { link = 'Keyword' },
    ['@keyword.coroutine'] = { fg = p.accent2 },
    ['@keyword.function'] = { fg = p.accent2 },
    ['@keyword.operator'] = { fg = p.accent2 },
    ['@keyword.import'] = { link = 'Include' },
    ['@keyword.type'] = { fg = p.accent2 },
    ['@keyword.modifier'] = { fg = p.accent2, italic = true },
    ['@keyword.repeat'] = { link = 'Repeat' },
    ['@keyword.return'] = { fg = p.accent2 },
    ['@keyword.debug'] = { fg = p.red },
    ['@keyword.exception'] = { link = 'Exception' },
    ['@keyword.conditional'] = { link = 'Conditional' },
    ['@keyword.conditional.ternary'] = { fg = p.fg1 },
    ['@keyword.directive'] = { link = 'Define' },
    ['@keyword.directive.define'] = { link = 'Define' },

    -- HTML / JSX / XML tags
    ['@tag'] = { fg = p.purple },
    ['@tag.builtin'] = { fg = p.purple },
    ['@tag.attribute'] = { fg = p.accent2, italic = true },
    ['@tag.delimiter'] = { fg = p.fg2 },

    -- Markup (markdown etc.)
    ['@markup'] = { fg = p.fg0 },
    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.underline'] = { underline = true },
    ['@markup.heading'] = { fg = p.accent, bold = true },
    ['@markup.heading.1'] = { fg = p.accent, bold = true },
    ['@markup.heading.2'] = { fg = p.accent2, bold = true },
    ['@markup.heading.3'] = { fg = p.yellow, bold = true },
    ['@markup.heading.4'] = { fg = p.blue, bold = true },
    ['@markup.heading.5'] = { fg = p.green, bold = true },
    ['@markup.heading.6'] = { fg = p.purple, bold = true },
    ['@markup.quote'] = { fg = p.fg2, italic = true },
    ['@markup.math'] = { fg = p.blue },
    ['@markup.environment'] = { fg = p.purple },
    ['@markup.link'] = { fg = p.blue, underline = true },
    ['@markup.link.label'] = { fg = p.blue },
    ['@markup.link.url'] = { fg = p.blue, underline = true },
    ['@markup.raw'] = { fg = p.green },
    ['@markup.raw.block'] = { fg = p.green },
    ['@markup.list'] = { fg = p.accent2 },
    ['@markup.list.checked'] = { fg = p.green },
    ['@markup.list.unchecked'] = { fg = p.fg3 },

    -- Diff
    ['@diff.plus'] = { link = 'DiffAdd' },
    ['@diff.minus'] = { link = 'DiffDelete' },
    ['@diff.delta'] = { link = 'DiffChange' },

    -- None / error
    ['@none'] = {},
    ['@error'] = { fg = p.red },

    -- Conceal
    ['@conceal'] = { link = 'Conceal' },

    -- Spell
    ['@spell'] = {},
    ['@nospell'] = {},
  }
end

return treesitter
