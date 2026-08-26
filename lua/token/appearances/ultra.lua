---@param definition table
---@param extra? table
---@return table
local function copy(definition, extra)
  local result = {}
  for key, value in pairs(definition) do
    result[key] = value
  end
  for key, value in pairs(extra or {}) do
    result[key] = value
  end
  return result
end

---@param p TokenPalette
---@param roles? table
---@return table<string, vim.api.keyset.highlight>
local function ultra(p, roles)
  roles = roles or require('token.appearances.ultra_roles')(p, false)
  local r = roles.syntax
  local number = r.number or r.literal
  local property = r.property or r.variable
  local groups = {
    Comment = copy(r.comment),
    Constant = copy(r.literal),
    String = copy(r.literal),
    Character = copy(r.literal),
    Number = copy(number),
    Boolean = copy(number),
    Float = copy(number),
    Identifier = copy(r.variable),
    Function = copy(r.definition),
    Statement = copy(r.control),
    Conditional = copy(r.control),
    Repeat = copy(r.control),
    Label = copy(r.control),
    Operator = copy(r.operator),
    Keyword = copy(r.control),
    Exception = copy(r.control),
    PreProc = copy(r.control),
    Include = copy(r.control),
    Define = copy(r.control),
    Macro = copy(r.control),
    PreCondit = copy(r.control),
    Type = copy(r.type),
    StorageClass = copy(r.control),
    Structure = copy(r.type),
    Typedef = copy(r.type),
    Special = copy(r.literal),
    SpecialChar = copy(r.literal),
    Tag = copy(r.tag),
    Delimiter = copy(r.punctuation),
    SpecialComment = copy(r.comment),
    Debug = copy(r.control),
  }

  local overrides = {
    ['@variable'] = copy(r.variable),
    ['@variable.builtin'] = copy(r.builtin),
    ['@variable.parameter'] = copy(r.parameter),
    ['@variable.parameter.builtin'] = copy(r.builtin),
    ['@variable.member'] = copy(property),
    ['@constant'] = copy(r.literal),
    ['@constant.builtin'] = copy(r.literal),
    ['@constant.macro'] = copy(r.control),
    ['@module'] = copy(r.type),
    ['@module.builtin'] = copy(r.builtin),
    ['@string'] = copy(r.literal),
    ['@string.documentation'] = copy(r.literal),
    ['@string.regexp'] = copy(r.literal),
    ['@string.escape'] = copy(r.literal),
    ['@string.special'] = copy(r.literal),
    ['@string.special.symbol'] = copy(r.literal),
    ['@string.special.path'] = { fg = p.blue },
    ['@string.special.url'] = copy(r.link),
    ['@character'] = copy(r.literal),
    ['@character.special'] = copy(r.literal),
    ['@boolean'] = copy(r.literal),
    ['@number'] = copy(number),
    ['@number.float'] = copy(number),
    ['@type'] = copy(r.type),
    ['@type.builtin'] = copy(r.type),
    ['@type.definition'] = copy(r.definition),
    ['@attribute'] = copy(r.attribute),
    ['@attribute.builtin'] = copy(r.attribute),
    ['@property'] = copy(property),
    ['@function'] = copy(r.definition),
    ['@function.builtin'] = copy(r.builtin),
    ['@function.call'] = copy(r.call),
    ['@function.macro'] = copy(r.control),
    ['@function.method'] = copy(r.definition),
    ['@function.method.call'] = copy(r.call),
    ['@constructor'] = copy(r.type),
    ['@operator'] = copy(r.operator),
    ['@punctuation'] = copy(r.punctuation),
    ['@punctuation.delimiter'] = copy(r.punctuation),
    ['@punctuation.bracket'] = copy(r.punctuation),
    ['@punctuation.special'] = copy(r.punctuation),
    ['@comment'] = copy(r.comment),
    ['@comment.documentation'] = copy(r.comment),
    ['@comment.error'] = { fg = p.red, italic = true },
    ['@comment.warning'] = { fg = p.yellow, italic = true },
    ['@comment.todo'] = { fg = p.yellow, italic = true },
    ['@comment.note'] = { fg = p.blue, italic = true },
    ['@keyword'] = copy(r.control),
    ['@keyword.coroutine'] = copy(r.control),
    ['@keyword.function'] = copy(r.control),
    ['@keyword.operator'] = copy(r.control),
    ['@keyword.import'] = copy(r.control),
    ['@keyword.type'] = copy(r.control),
    ['@keyword.modifier'] = copy(r.control),
    ['@keyword.repeat'] = copy(r.control),
    ['@keyword.return'] = copy(r.control),
    ['@keyword.debug'] = copy(r.control),
    ['@keyword.exception'] = copy(r.control),
    ['@keyword.conditional'] = copy(r.control),
    ['@keyword.conditional.ternary'] = copy(r.control),
    ['@keyword.directive'] = copy(r.control),
    ['@keyword.directive.define'] = copy(r.control),
    ['@tag'] = copy(r.tag),
    ['@tag.builtin'] = copy(r.builtin),
    ['@tag.attribute'] = copy(r.attribute),
    ['@tag.delimiter'] = copy(r.tag_delimiter),
    ['@markup.heading'] = { fg = roles.headings[1], bold = true },
    ['@markup.heading.1'] = { fg = roles.headings[1], bold = true },
    ['@markup.heading.2'] = { fg = roles.headings[2], bold = true },
    ['@markup.heading.3'] = { fg = roles.headings[3], bold = true },
    ['@markup.heading.4'] = { fg = roles.headings[4], bold = true },
    ['@markup.heading.5'] = { fg = roles.headings[5], bold = true },
    ['@markup.heading.6'] = { fg = roles.headings[6], bold = true },
    ['@markup.quote'] = copy(r.quote),
    ['@markup.math'] = copy(r.type),
    ['@markup.environment'] = copy(r.type),
    ['@markup.link'] = copy(r.link),
    ['@markup.link.label'] = copy(r.link),
    ['@markup.link.url'] = copy(r.link),
    ['@markup.raw'] = copy(r.literal),
    ['@markup.raw.block'] = copy(r.literal),
    ['@markup.list'] = copy(r.control),
    ['@lsp.type.class'] = { link = '@type' },
    ['@lsp.type.decorator'] = { link = '@attribute' },
    ['@lsp.type.enum'] = { link = '@type' },
    ['@lsp.type.enumMember'] = { link = '@constant' },
    ['@lsp.type.event'] = { link = '@type' },
    ['@lsp.type.function'] = { link = '@function.call' },
    ['@lsp.type.interface'] = { link = '@type' },
    ['@lsp.type.macro'] = { link = '@function.macro' },
    ['@lsp.type.method'] = { link = '@function.method.call' },
    ['@lsp.type.namespace'] = { link = '@module' },
    ['@lsp.type.struct'] = { link = '@type' },
    ['@lsp.type.type'] = { link = '@type' },
    ['@lsp.type.typeParameter'] = { link = '@type' },
  }

  for _, token_type in ipairs({
    'class',
    'enum',
    'function',
    'interface',
    'method',
    'struct',
    'type',
    'typeParameter',
  }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      overrides['@lsp.typemod.' .. token_type .. '.' .. modifier] = copy(r.definition)
    end
  end

  for name, value in pairs(overrides) do
    groups[name] = value
  end

  for level, color in ipairs(roles.headings) do
    groups['RenderMarkdownH' .. level] = { fg = color, bold = true }
    groups['RenderMarkdownH' .. level .. 'Bg'] = { fg = color, bg = p.bg4, bold = true }
    groups['MarkviewHeading' .. level] = { fg = color, bg = p.bg4, bold = true }
    groups['MarkviewHeading' .. level .. 'Sign'] = { fg = color, bold = true }
  end

  return groups
end

return ultra
