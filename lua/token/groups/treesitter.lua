-- nvim-treesitter tags call sites with plain `@function` in these languages, so
-- the capture cannot mean "definition" there and they keep the call style.
local call_site_languages = {
  'angular',
  'awk',
  'bass',
  'cmake',
  'css',
  'd',
  'erlang',
  'forth',
  'func',
  'glimmer',
  'gotmpl',
  'gren',
  'groovy',
  'groq',
  'hcl',
  'inko',
  'kcl',
  'latex',
  'leo',
  'llvm',
  'meson',
  'mlir',
  'nu',
  'pascal',
  'prisma',
  'purescript',
  'racket',
  'rego',
  'scheme',
  'scss',
  'soql',
  'sourcepawn',
  'sparql',
  'tablegen',
  'tcl',
  'teal',
  'tiger',
  'vala',
  'vhdl',
}

---@param p table palette
---@return table
local function treesitter(p)
  local groups = {
    -- Variables
    ['@variable'] = { fg = p.fg0 },
    ['@variable.builtin'] = { fg = p.purple },
    ['@variable.parameter'] = { fg = p.fg1 },
    ['@variable.parameter.builtin'] = { fg = p.purple },
    ['@variable.member'] = { fg = p.property },

    -- Constants
    ['@constant'] = { link = 'Constant' },
    ['@constant.builtin'] = { link = 'Boolean' },
    ['@constant.macro'] = { link = 'Macro' },

    -- Modules / namespaces
    ['@module'] = { fg = p.blue },
    ['@module.builtin'] = { fg = p.blue },
    ['@label'] = { link = 'Label' },

    -- Strings
    ['@string'] = { link = 'String' },
    -- Docstrings are prose, so they read as comments.
    ['@string.documentation'] = { fg = p.comment, italic = true },
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
    ['@property'] = { fg = p.property },

    -- Functions
    ['@function'] = { link = 'Function' },
    ['@function.builtin'] = { fg = p.accent },
    ['@function.call'] = { link = 'Function' },
    ['@function.macro'] = { fg = p.purple },
    ['@function.method'] = { link = 'Function' },
    ['@function.method.call'] = { link = 'Function' },

    -- Constructors
    ['@constructor'] = { fg = p.blue },
    -- Lua's query captures the braces of every table literal as a constructor.
    ['@constructor.lua'] = { link = '@punctuation.bracket' },

    -- Operators / punctuation
    ['@operator'] = { link = 'Operator' },
    ['@punctuation'] = { fg = p.comment },
    ['@punctuation.delimiter'] = { fg = p.comment },
    ['@punctuation.bracket'] = { fg = p.comment },
    ['@punctuation.special'] = { fg = p.purple },

    -- Comments
    ['@comment'] = { link = 'Comment' },
    ['@comment.documentation'] = { fg = p.comment, italic = true },
    ['@comment.error'] = { fg = p.red, italic = true },
    ['@comment.warning'] = { fg = p.yellow, italic = true },
    ['@comment.todo'] = { fg = p.yellow },
    ['@comment.note'] = { fg = p.blue, italic = true },

    -- Keywords
    ['@keyword'] = { link = 'Keyword' },
    ['@keyword.coroutine'] = { fg = p.accent2 },
    ['@keyword.function'] = { fg = p.accent2 },
    -- Word operators such as `and` and `not` keep the operator color and the
    -- keyword weight, so they stay below `if` and `return` inside a condition.
    ['@keyword.operator'] = { fg = p.fg1 },
    ['@keyword.import'] = { link = 'Include' },
    ['@keyword.type'] = { fg = p.accent2 },
    ['@keyword.modifier'] = { fg = p.accent2 },
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
    ['@tag.attribute'] = { fg = p.accent2 },
    ['@tag.delimiter'] = { fg = p.comment },

    -- Markup (markdown etc.)
    ['@markup'] = { fg = p.fg0 },
    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.underline'] = { underline = true },
    ['@markup.heading'] = { fg = p.accent, bold = true },
    ['@markup.heading.1'] = { fg = p.accent, bold = true },
    ['@markup.heading.2'] = { fg = p.accent2, bold = true },
    ['@markup.heading.3'] = { fg = p.olive, bold = true },
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

  for _, language in ipairs(call_site_languages) do
    groups['@function.' .. language] = { link = '@function.call' }
  end

  return groups
end

return treesitter
