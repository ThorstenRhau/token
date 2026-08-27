local M = {}

local attributes = {
  regular = { bold = false, italic = false, underline = false },
  control = { bold = true, italic = false, underline = false },
  comment = { bold = false, italic = true, underline = false },
  link = { bold = false, italic = false, underline = true },
  heading = { bold = true, italic = false, underline = false },
  strong = { bold = true },
  emphasis = { italic = true },
}

local groups = {
  regular = {
    'Constant',
    'String',
    'Character',
    'Number',
    'Boolean',
    'Float',
    'Identifier',
    'Function',
    'Type',
    'Structure',
    'Typedef',
    'Special',
    'SpecialChar',
    '@variable',
    '@variable.builtin',
    '@variable.parameter',
    '@variable.parameter.builtin',
    '@variable.member',
    '@constant',
    '@constant.builtin',
    '@module',
    '@module.builtin',
    '@string',
    '@string.regexp',
    '@string.escape',
    '@string.special',
    '@string.special.symbol',
    '@string.special.path',
    '@character',
    '@character.special',
    '@boolean',
    '@number',
    '@number.float',
    '@type',
    '@type.builtin',
    '@type.definition',
    '@attribute',
    '@attribute.builtin',
    '@property',
    '@function',
    '@function.builtin',
    '@function.call',
    '@function.method',
    '@function.method.call',
    '@constructor',
    '@tag.builtin',
    '@tag.attribute',
    '@markup.math',
    '@markup.environment',
    '@markup.raw',
    '@markup.raw.block',
    '@lsp.mod.declaration',
    '@lsp.mod.definition',
    '@lsp.mod.defaultLibrary',
    '@lsp.mod.modification',
  },
  control = {
    'Statement',
    'Conditional',
    'Repeat',
    'Label',
    'Debug',
    'Keyword',
    'Exception',
    'PreProc',
    'Include',
    'Define',
    'Macro',
    'PreCondit',
    'StorageClass',
    '@constant.macro',
    '@label',
    '@function.macro',
    '@keyword',
    '@keyword.coroutine',
    '@keyword.function',
    '@keyword.operator',
    '@keyword.import',
    '@keyword.type',
    '@keyword.modifier',
    '@keyword.repeat',
    '@keyword.return',
    '@keyword.debug',
    '@keyword.exception',
    '@keyword.conditional',
    '@keyword.conditional.ternary',
    '@keyword.directive',
    '@keyword.directive.define',
    '@markup.list',
  },
  comment = {
    'Comment',
    'SpecialComment',
    '@comment',
    '@comment.documentation',
    '@comment.error',
    '@comment.warning',
    '@comment.todo',
    '@comment.note',
    '@string.documentation',
    '@markup.quote',
  },
  link = {
    '@string.special.url',
    '@markup.link',
    '@markup.link.label',
    '@markup.link.url',
  },
  heading = {
    '@markup.heading',
    '@markup.heading.1',
    '@markup.heading.2',
    '@markup.heading.3',
    '@markup.heading.4',
    '@markup.heading.5',
    '@markup.heading.6',
  },
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
    groups.regular[#groups.regular + 1] = '@lsp.typemod.' .. token_type .. '.' .. modifier
  end
end

local group_roles = {}
for role, names in pairs(groups) do
  for _, name in ipairs(names) do
    group_roles[name] = role
  end
end

local textmate_roles = {
  Comment = 'comment',
  Keyword = 'control',
  Storage = 'control',
  PreProc = 'control',
  Preprocessor = 'control',
  Include = 'control',
  Macro = 'control',
  Label = 'control',
  Debug = 'control',
  Exception = 'control',
  ['Function definition'] = 'regular',
  ['Function call'] = 'regular',
  ['Built-in function'] = 'regular',
  ['Built-in symbol'] = 'regular',
  String = 'regular',
  Literal = 'regular',
  Number = 'regular',
  Constant = 'regular',
  ['Type definition'] = 'regular',
  ['Type reference'] = 'regular',
  Type = 'regular',
  Class = 'regular',
  Module = 'regular',
  ['Tag attribute'] = 'regular',
  Attribute = 'regular',
  ['Heading 1'] = 'heading',
  ['Heading 2'] = 'heading',
  ['Heading 3'] = 'heading',
  ['Heading 4'] = 'heading',
  ['Heading 5'] = 'heading',
  ['Heading 6'] = 'heading',
  ['Markup link'] = 'link',
  ['Markup link text'] = 'link',
  ['Markup code'] = 'regular',
  ['Markup list'] = 'control',
  ['Markup quote'] = 'comment',
  ['Markup bold'] = 'strong',
  ['Markup italic'] = 'emphasis',
  ['Markup bold italic'] = 'strong_emphasis',
}

local gtk_roles = {
  ['def:comment'] = 'comment',
  ['def:shebang'] = 'comment',
  ['def:doc-comment'] = 'comment',
  ['def:doc-comment-element'] = 'comment',
  ['def:constant'] = 'regular',
  ['def:special-constant'] = 'regular',
  ['def:number'] = 'regular',
  ['def:decimal'] = 'regular',
  ['def:base-n-integer'] = 'regular',
  ['def:floating-point'] = 'regular',
  ['def:complex'] = 'regular',
  ['def:boolean'] = 'regular',
  ['def:character'] = 'regular',
  ['def:string'] = 'regular',
  ['def:special-char'] = 'regular',
  ['def:function'] = 'regular',
  ['def:builtin'] = 'regular',
  ['def:keyword'] = 'control',
  ['def:statement'] = 'control',
  ['def:type'] = 'regular',
  ['def:preprocessor'] = 'control',
  ['def:net-address'] = 'link',
  ['def:heading'] = 'heading',
  ['def:heading0'] = 'heading',
  ['def:heading1'] = 'heading',
  ['def:heading2'] = 'heading',
  ['def:heading3'] = 'heading',
  ['def:heading4'] = 'heading',
  ['def:heading5'] = 'heading',
  ['def:heading6'] = 'heading',
  ['def:link-destination'] = 'link',
  ['def:link-text'] = 'link',
  ['def:list-marker'] = 'control',
  ['def:strong-emphasis'] = 'strong',
  ['def:emphasis'] = 'emphasis',
}

local emacs_roles = {
  ['font-lock-comment-face'] = 'comment',
  ['font-lock-comment-delimiter-face'] = 'comment',
  ['font-lock-doc-face'] = 'comment',
  ['font-lock-doc-markup-face'] = 'comment',
  ['font-lock-string-face'] = 'regular',
  ['font-lock-keyword-face'] = 'control',
  ['font-lock-builtin-face'] = 'regular',
  ['font-lock-function-name-face'] = 'regular',
  ['font-lock-function-call-face'] = 'regular',
  ['font-lock-type-face'] = 'regular',
  ['font-lock-constant-face'] = 'regular',
  ['font-lock-preprocessor-face'] = 'control',
  ['font-lock-regexp-grouping-backslash'] = 'regular',
  ['font-lock-regexp-grouping-construct'] = 'regular',
  ['font-lock-escape-face'] = 'regular',
  ['font-lock-number-face'] = 'regular',
  ['font-lock-reference-face'] = 'regular',
  link = 'link',
  ['link-visited'] = 'link',
  ['org-link'] = 'link',
  ['org-roam-link'] = 'link',
  ['markdown-link-face'] = 'link',
  ['markdown-url-face'] = 'link',
  ['markdown-plain-url-face'] = 'link',
  ['markdown-list-face'] = 'control',
  ['shr-link'] = 'link',
  ['shr-visited-link'] = 'link',
}

local vscode_roles = {
  class = 'regular',
  enum = 'regular',
  interface = 'regular',
  struct = 'regular',
  type = 'regular',
  typeParameter = 'regular',
  namespace = 'regular',
  ['function'] = 'regular',
  method = 'regular',
  macro = 'control',
  keyword = 'control',
  string = 'regular',
  number = 'regular',
  enumMember = 'regular',
  ['variable.readonly'] = 'regular',
  ['property.readonly'] = 'regular',
  parameter = 'regular',
  ['*.readonly'] = 'regular',
  ['*.declaration'] = 'regular',
  ['*.definition'] = 'regular',
  ['*.defaultLibrary'] = 'regular',
  ['*.modification'] = 'regular',
  ['*.documentation'] = 'comment',
}

local vscode_exact_selectors = {}
for _, token_type in ipairs({
  'class',
  'decorator',
  'enum',
  'enumMember',
  'event',
  'function',
  'interface',
  'macro',
  'method',
  'modifier',
  'namespace',
  'number',
  'operator',
  'parameter',
  'property',
  'regexp',
  'string',
  'struct',
  'type',
  'typeParameter',
  'variable',
}) do
  for _, modifier in ipairs({ 'declaration', 'definition' }) do
    local selector = token_type .. '.' .. modifier
    vscode_roles[selector] = 'regular'
    vscode_exact_selectors[#vscode_exact_selectors + 1] = selector
  end
end

local xcode_roles = {
  ['xcode.syntax.attribute'] = 'regular',
  ['xcode.syntax.character'] = 'regular',
  ['xcode.syntax.comment'] = 'comment',
  ['xcode.syntax.comment.doc'] = 'comment',
  ['xcode.syntax.comment.doc.keyword'] = 'control',
  ['xcode.syntax.declaration.other'] = 'regular',
  ['xcode.syntax.declaration.type'] = 'regular',
  ['xcode.syntax.identifier.class'] = 'regular',
  ['xcode.syntax.identifier.class.system'] = 'regular',
  ['xcode.syntax.identifier.constant'] = 'regular',
  ['xcode.syntax.identifier.constant.system'] = 'regular',
  ['xcode.syntax.identifier.function'] = 'regular',
  ['xcode.syntax.identifier.function.system'] = 'regular',
  ['xcode.syntax.identifier.macro'] = 'control',
  ['xcode.syntax.identifier.macro.system'] = 'control',
  ['xcode.syntax.identifier.type'] = 'regular',
  ['xcode.syntax.identifier.type.system'] = 'regular',
  ['xcode.syntax.identifier.variable.system'] = 'regular',
  ['xcode.syntax.keyword'] = 'control',
  ['xcode.syntax.mark'] = 'control',
  ['xcode.syntax.markup.aside.kind'] = 'control',
  ['xcode.syntax.markup.code'] = 'regular',
  ['xcode.syntax.number'] = 'regular',
  ['xcode.syntax.preprocessor'] = 'control',
  ['xcode.syntax.string'] = 'regular',
  ['xcode.syntax.url'] = 'link',
  DVTMarkupTextOtherHeadingFont = 'heading',
  DVTMarkupTextPrimaryHeadingFont = 'heading',
  DVTMarkupTextSecondaryHeadingFont = 'heading',
}

local mappings = {
  textmate = textmate_roles,
  gtk = gtk_roles,
  emacs = emacs_roles,
  vscode = vscode_roles,
  xcode = xcode_roles,
}

local function copy(value)
  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

function M.validate()
  local assigned = {}
  for role, names in pairs(groups) do
    for _, name in ipairs(names) do
      if assigned[name] then
        return false, name .. ' is assigned to both ' .. assigned[name] .. ' and ' .. role
      end
      assigned[name] = role
    end
  end
  return true
end

function M.attributes(role)
  if role == 'strong_emphasis' then
    return { bold = true, italic = true }
  end
  return copy(attributes[role] or attributes.regular)
end

function M.role(format, name)
  return mappings[format][name]
end

function M.vscode_exact_selectors()
  local selectors = {}
  for index, selector in ipairs(vscode_exact_selectors) do
    selectors[index] = selector
  end
  return selectors
end

function M.apply(groups_by_name, resolve)
  for role, names in pairs(groups) do
    for _, name in ipairs(names) do
      local group = groups_by_name[name]
      if group and not (group.link and group_roles[group.link] == role) then
        if group.link then
          group = resolve(name) or {}
        else
          group = copy(group)
        end
        for attribute, value in pairs(attributes[role]) do
          group[attribute] = value
        end
        groups_by_name[name] = group
      end
    end
  end
end

return M
