#!/usr/bin/env luajit

-- Generates contrib/ theme files from the canonical palette.
-- Run: luajit scripts/gen_contrib.lua [--verify]

local function parse_args(args)
  if #args == 0 then
    return false
  end
  if #args == 1 and args[1] == '--verify' then
    return true
  end

  io.stderr:write('Usage: luajit scripts/gen_contrib.lua [--verify]\n')
  os.exit(2)
end

local verify = parse_args(arg)

package.path = 'lua/?.lua;lua/?/init.lua;scripts/?.lua;' .. package.path

local appearance_registry = require('token.appearance')
local gen_emacs = require('gen_emacs')
local terminal = require('token.terminal')

local lib = require('gen_lib')
local strip = lib.strip
local rgb_fmt = lib.rgb_fmt
local sgr_rgb = lib.sgr_rgb
local sgr_bg_rgb = lib.sgr_bg_rgb
local write_if_changed = lib.write_if_changed
local list_files = lib.list_files
local unexpected_paths = lib.unexpected_paths
local extend_lines = lib.extend_lines

local function variant_name(appearance, variant)
  return appearance.display_name .. ' ' .. (variant == 'dark' and 'Dark' or 'Light')
end

local function json_escape(s)
  return s:gsub('[%z\1-\31\\"]', function(c)
    local escapes = {
      ['"'] = '\\"',
      ['\\'] = '\\\\',
      ['\b'] = '\\b',
      ['\f'] = '\\f',
      ['\n'] = '\\n',
      ['\r'] = '\\r',
      ['\t'] = '\\t',
    }
    return escapes[c] or string.format('\\u%04x', c:byte())
  end)
end

local function json_object(entries)
  return { __json_object = entries }
end

local function json_encode(value, indent)
  indent = indent or 0
  local t = type(value)
  if t == 'string' then
    return '"' .. json_escape(value) .. '"'
  end
  if t == 'number' or t == 'boolean' then
    return tostring(value)
  end
  if value == nil then
    return 'null'
  end

  local pad = string.rep(' ', indent)
  local child_pad = string.rep(' ', indent + 2)
  local lines = {}

  if value.__json_object then
    if #value.__json_object == 0 then
      return '{}'
    end
    lines[#lines + 1] = '{'
    for i, entry in ipairs(value.__json_object) do
      local suffix = i < #value.__json_object and ',' or ''
      lines[#lines + 1] = child_pad .. json_encode(entry[1]) .. ': ' .. json_encode(entry[2], indent + 2) .. suffix
    end
    lines[#lines + 1] = pad .. '}'
    return table.concat(lines, '\n')
  end

  if #value == 0 then
    return '[]'
  end
  lines[#lines + 1] = '['
  for i, item in ipairs(value) do
    local suffix = i < #value and ',' or ''
    lines[#lines + 1] = child_pad .. json_encode(item, indent + 2) .. suffix
  end
  lines[#lines + 1] = pad .. ']'
  return table.concat(lines, '\n')
end

-- ---------------------------------------------------------------------------
-- carapace (styles.json)
-- ---------------------------------------------------------------------------

local function gen_carapace(p, variant, _term, appearance)
  local function q(key, color)
    return '    "' .. key .. '": "' .. color .. '"'
  end

  local entries = {
    q('Description', p.fg2),
    q('Error', p.red),
    q('FlagArg', p.blue),
    q('FlagMultiArg', p.purple),
    q('FlagNoArg', p.fg1),
    q('FlagOptArg', p.cyan),
    q('Highlight1', p.blue),
    q('Highlight2', p.green),
    q('Highlight3', p.accent2),
    q('Highlight4', p.purple),
    q('Highlight5', p.cyan),
    q('Highlight6', p.yellow),
    q('Highlight7', p.accent),
    q('Highlight8', p.red),
    q('Highlight9', p.fg1),
    q('Highlight10', p.fg2),
    q('Highlight11', p.olive),
    q('Highlight12', p.orange),
    q('KeywordAmbiguous', p.yellow),
    q('KeywordNegative', p.red),
    q('KeywordPositive', p.green),
    q('KeywordUnknown', p.fg2),
    q('LogLevelCritical', p.red),
    q('LogLevelDebug', p.fg2),
    q('LogLevelError', p.red),
    q('LogLevelFatal', p.red),
    q('LogLevelInfo', p.blue),
    q('LogLevelTrace', p.fg2),
    q('LogLevelWarning', p.yellow),
    q('Usage', p.fg2),
    q('Value', p.fg1),
  }

  local content = table.concat({
    '{',
    '  "carapace": {',
    table.concat(entries, ',\n'),
    '  }',
    '}',
    '',
  }, '\n')

  return { path = 'contrib/carapace/' .. appearance.slug .. '-' .. variant .. '.json', content = content }
end

-- ---------------------------------------------------------------------------
-- ChatGPT desktop (codex-theme-v1 share string)
-- ---------------------------------------------------------------------------

local function gen_chatgpt(p, variant, appearance)
  local theme = json_object({
    { 'codeThemeId', 'codex' },
    {
      'theme',
      json_object({
        { 'accent', p.accent },
        { 'contrast', variant == 'dark' and 60 or 45 },
        { 'fonts', json_object({ { 'code', nil }, { 'ui', nil } }) },
        { 'ink', p.fg0 },
        { 'opaqueWindows', false },
        {
          'semanticColors',
          json_object({
            { 'diffAdded', p.gsign_add },
            { 'diffRemoved', p.gsign_del },
            { 'skill', p.purple },
          }),
        },
        { 'surface', p.bg3 },
      }),
    },
    { 'variant', variant },
  })
  local payload = json_encode(theme):gsub('\n%s*', '')

  return {
    path = 'contrib/chatgpt/' .. appearance.slug .. '-' .. variant .. '.txt',
    content = 'codex-theme-v1:' .. payload .. '\n',
  }
end

-- ---------------------------------------------------------------------------
-- bat (.tmTheme)
-- ---------------------------------------------------------------------------

local function xml_escape(s)
  return s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

local function tmtheme_entry(name, scope, fg, style)
  local lines = {
    '    <dict>',
    '      <key>name</key>',
    '      <string>' .. xml_escape(name) .. '</string>',
    '      <key>scope</key>',
    '      <string>' .. xml_escape(scope) .. '</string>',
    '      <key>settings</key>',
    '      <dict>',
  }
  if fg then
    lines[#lines + 1] = '        <key>foreground</key>'
    lines[#lines + 1] = '        <string>' .. fg .. '</string>'
  end
  if style then
    lines[#lines + 1] = '        <key>fontStyle</key>'
    lines[#lines + 1] = '        <string>' .. style .. '</string>'
  end
  lines[#lines + 1] = '      </dict>'
  lines[#lines + 1] = '    </dict>'
  return table.concat(lines, '\n')
end

local function textmate_scope_rules(p, appearance)
  if appearance.name == 'token-flint' then
    return {
      { 'Comment', 'comment, punctuation.definition.comment', p.fg2, 'italic' },
      { 'Keyword', 'keyword, keyword.control, keyword.other, storage.modifier', p.accent2, nil },
      { 'Operator', 'keyword.operator', p.fg1, nil },
      { 'Function definition', 'entity.name.function, meta.function.definition entity.name', p.accent, 'bold' },
      { 'Function call', 'meta.function-call, variable.function', p.accent, nil },
      { 'Built-in function', 'support.function', p.fg1, 'italic' },
      { 'String', 'string, punctuation.definition.string', p.green, nil },
      { 'Literal', 'constant, constant.language, constant.numeric, variable.other.constant', p.green, nil },
      { 'Type definition', 'entity.name.type, entity.name.class, entity.name.type.class', p.accent, 'bold' },
      { 'Type reference', 'storage.type, support.type, support.class, entity.other.inherited-class', p.blue, 'italic' },
      { 'Module', 'entity.name.namespace, entity.name.type.module, support.module', p.blue, 'italic' },
      {
        'Preprocessor',
        'keyword.control.import, keyword.control.export, keyword.control.directive, keyword.preprocessor, keyword.other.import, keyword.other.package, keyword.other.using',
        p.accent2,
        nil,
      },
      { 'Macro', 'entity.name.function.preprocessor', p.accent2, nil },
      { 'Tag', 'entity.name.tag', p.fg1, nil },
      { 'Tag attribute', 'entity.other.attribute-name', p.fg0, nil },
      { 'Attribute', 'meta.annotation, storage.type.annotation', p.fg1, 'italic' },
      { 'Label', 'entity.name.label, constant.other.label', p.accent2, nil },
      { 'Built-in symbol', 'variable.language', p.fg1, 'italic' },
      { 'Debug', 'keyword.other.debugger', p.accent2, nil },
      { 'Exception', 'keyword.control.exception, keyword.control.trycatch', p.accent2, nil },
      { 'Identifier', 'variable, support.variable, meta.definition.variable', p.fg0, nil },
      {
        'Property',
        'variable.object.property, variable.other.property, variable.other.member, meta.object-literal.key',
        p.fg0,
        nil,
      },
      { 'Delimiter', 'punctuation, meta.brace, meta.delimiter, meta.bracket', p.fg1, nil },
      { 'Parameter', 'variable.parameter', p.fg1, nil },
      { 'Heading 1', 'heading.1.markdown, markup.heading.setext.1.markdown', p.accent, 'bold' },
      { 'Heading 2', 'heading.2.markdown, markup.heading.setext.2.markdown', p.accent2, 'bold' },
      { 'Heading 3', 'heading.3.markdown', p.fg1, 'bold' },
      { 'Heading 4', 'heading.4.markdown', p.accent, 'bold' },
      { 'Heading 5', 'heading.5.markdown', p.accent2, 'bold' },
      { 'Heading 6', 'heading.6.markdown', p.fg1, 'bold' },
      { 'Heading delimiter', 'punctuation.definition.heading.markdown', p.fg2, nil },
      { 'Markup link', 'markup.underline.link, string.other.link', p.blue, 'underline' },
      {
        'Markup link text',
        'string.other.link.title.markdown, constant.other.reference.link.markdown',
        p.blue,
        'underline',
      },
      {
        'Markup code',
        'markup.fenced_code.block.markdown, markup.inline.raw.string.markdown, markup.raw',
        p.green,
        nil,
      },
      { 'Markup code delimiter', 'punctuation.definition.markdown, punctuation.definition.raw.markdown', p.fg2, nil },
      { 'Markup list', 'punctuation.definition.list.begin.markdown, markup.list', p.accent2, nil },
      { 'Markup bold', 'markup.bold', nil, 'bold' },
      { 'Markup italic', 'markup.italic', nil, 'italic' },
      { 'Markup bold italic', 'markup.bold markup.italic, markup.italic markup.bold', nil, 'italic bold' },
      { 'Markup quote', 'markup.quote', p.fg2, 'italic' },
      { 'Diff added', 'markup.inserted, meta.diff.header.to-file', p.green, nil },
      { 'Diff deleted', 'markup.deleted, meta.diff.header.from-file', p.red, nil },
      { 'Diff changed', 'markup.changed', p.yellow, nil },
      { 'GitGutter inserted', 'markup.inserted.git_gutter', p.green, nil },
      { 'GitGutter deleted', 'markup.deleted.git_gutter', p.red, nil },
      { 'GitGutter changed', 'markup.changed.git_gutter', p.yellow, nil },
      { 'GitGutter untracked', 'markup.untracked.git_gutter', p.fg3, nil },
      { 'GitGutter ignored', 'markup.ignored.git_gutter', p.fg3, nil },
    }
  end
  return {
    { 'Comment', 'comment, punctuation.definition.comment', p.fg2, 'italic' },
    { 'Keyword', 'keyword, keyword.control, keyword.other', p.accent2, nil },
    { 'Storage', 'storage, storage.modifier', p.accent2, nil },
    { 'Operator', 'keyword.operator', p.fg1, nil },
    { 'Function', 'entity.name.function, support.function, meta.function-call', p.accent, nil },
    { 'String', 'string, punctuation.definition.string', p.green, nil },
    { 'String escape', 'constant.character.escape', p.purple, nil },
    { 'Boolean', 'constant.language.boolean', p.accent2, nil },
    { 'Number', 'constant.numeric', p.purple, nil },
    { 'Constant', 'constant, constant.language, support.constant, variable.other.constant', p.purple, nil },
    { 'Type', 'storage.type, support.type, entity.name.type, entity.other.inherited-class', p.blue, nil },
    { 'Class', 'entity.name.type.class, support.class, entity.name.class', p.blue, nil },
    { 'Module', 'entity.name.namespace, entity.name.type.module, support.module', p.blue, nil },
    {
      'PreProc',
      'keyword.control.import, keyword.control.export, keyword.control.directive, keyword.preprocessor',
      p.purple,
      nil,
    },
    { 'Include', 'keyword.other.import, keyword.other.package, keyword.other.using', p.purple, nil },
    { 'Macro', 'entity.name.function.preprocessor', p.purple, nil },
    { 'Tag', 'entity.name.tag', p.purple, nil },
    { 'Tag attribute', 'entity.other.attribute-name', p.accent2, 'italic' },
    { 'Attribute', 'meta.annotation, storage.type.annotation', p.purple, nil },
    { 'Label', 'entity.name.label, constant.other.label', p.accent2, nil },
    { 'Special', 'variable.language, constant.language.null, constant.language.undefined', p.purple, nil },
    { 'Debug', 'keyword.other.debugger', p.red, nil },
    { 'Exception', 'keyword.control.exception, keyword.control.trycatch', p.red, nil },
    { 'Identifier', 'variable, support.variable, meta.definition.variable', p.fg0, nil },
    {
      'Property',
      'variable.object.property, variable.other.property, variable.other.member, meta.object-literal.key',
      p.fg0,
      nil,
    },
    { 'Delimiter', 'punctuation, meta.brace, meta.delimiter, meta.bracket', p.fg1, nil },
    { 'Parameter', 'variable.parameter', p.fg1, nil },
    { 'Heading 1', 'heading.1.markdown, markup.heading.setext.1.markdown', p.accent, 'bold' },
    { 'Heading 2', 'heading.2.markdown, markup.heading.setext.2.markdown', p.accent2, 'bold' },
    { 'Heading 3', 'heading.3.markdown', p.yellow, 'bold' },
    { 'Heading 4', 'heading.4.markdown', p.blue, 'bold' },
    { 'Heading 5', 'heading.5.markdown', p.green, 'bold' },
    { 'Heading 6', 'heading.6.markdown', p.purple, 'bold' },
    { 'Heading delimiter', 'punctuation.definition.heading.markdown', p.fg2, nil },
    { 'Markup link', 'markup.underline.link, string.other.link', p.blue, 'underline' },
    { 'Markup link text', 'string.other.link.title.markdown, constant.other.reference.link.markdown', p.blue, nil },
    { 'Markup code', 'markup.fenced_code.block.markdown, markup.inline.raw.string.markdown, markup.raw', p.green, nil },
    { 'Markup code delimiter', 'punctuation.definition.markdown, punctuation.definition.raw.markdown', p.fg2, nil },
    { 'Markup list', 'punctuation.definition.list.begin.markdown, markup.list', p.accent2, nil },
    { 'Markup bold', 'markup.bold', nil, 'bold' },
    { 'Markup italic', 'markup.italic', nil, 'italic' },
    { 'Markup bold italic', 'markup.bold markup.italic, markup.italic markup.bold', nil, 'italic bold' },
    { 'Markup quote', 'markup.quote', p.fg2, 'italic' },
    { 'Diff added', 'markup.inserted, meta.diff.header.to-file', p.green, nil },
    { 'Diff deleted', 'markup.deleted, meta.diff.header.from-file', p.red, nil },
    { 'Diff changed', 'markup.changed', p.yellow, nil },
    { 'GitGutter inserted', 'markup.inserted.git_gutter', p.green, nil },
    { 'GitGutter deleted', 'markup.deleted.git_gutter', p.red, nil },
    { 'GitGutter changed', 'markup.changed.git_gutter', p.yellow, nil },
    { 'GitGutter untracked', 'markup.untracked.git_gutter', p.fg3, nil },
    { 'GitGutter ignored', 'markup.ignored.git_gutter', p.fg3, nil },
  }
end

local function gen_bat(p, variant, _term, appearance)
  local name = appearance.slug .. '-' .. variant

  local scopes = {}
  for _, rule in ipairs(textmate_scope_rules(p, appearance)) do
    scopes[#scopes + 1] = tmtheme_entry(rule[1], rule[2], rule[3], rule[4])
  end

  local content = table.concat({
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    '<!-- Generated by token colorscheme. Do not edit manually. -->',
    '<plist version="1.0">',
    '  <dict>',
    '    <key>name</key>',
    '    <string>' .. name .. '</string>',
    '    <key>settings</key>',
    '    <array>',
    '      <dict>',
    '        <key>settings</key>',
    '        <dict>',
    '          <key>background</key>',
    '          <string>' .. p.bg3 .. '</string>',
    '          <key>foreground</key>',
    '          <string>' .. p.fg0 .. '</string>',
    '          <key>caret</key>',
    '          <string>' .. p.fg0 .. '</string>',
    '          <key>lineHighlight</key>',
    '          <string>' .. p.bg5 .. '40</string>',
    '          <key>selection</key>',
    '          <string>' .. p.sel .. 'cc</string>',
    '          <key>activeGuide</key>',
    '          <string>' .. p.fg2 .. '20</string>',
    '          <key>findHighlight</key>',
    '          <string>' .. p.match .. '</string>',
    '          <key>misspelling</key>',
    '          <string>' .. p.red .. '</string>',
    '        </dict>',
    '      </dict>',
    table.concat(scopes, '\n'),
    '    </array>',
    '  </dict>',
    '</plist>',
    '',
  }, '\n')

  return { path = 'contrib/bat/' .. name .. '.tmTheme', content = content }
end

-- ---------------------------------------------------------------------------
-- Sublime Text (.sublime-color-scheme)
-- ---------------------------------------------------------------------------

local function gen_sublime(p, variant, _term, appearance)
  local name = variant_name(appearance, variant)

  local rules = {}
  for _, rule in ipairs(textmate_scope_rules(p, appearance)) do
    local entries = {
      { 'name', rule[1] },
      { 'scope', rule[2] },
    }
    if rule[3] then
      entries[#entries + 1] = { 'foreground', rule[3] }
    end
    if rule[4] then
      entries[#entries + 1] = { 'font_style', rule[4] }
    end
    rules[#rules + 1] = json_object(entries)
  end

  local scheme = json_object({
    { 'name', name },
    { 'author', 'Generated by token colorscheme' },
    { 'variables', json_object({}) },
    {
      'globals',
      json_object({
        { 'background', p.bg3 },
        { 'foreground', p.fg0 },
        { 'caret', p.fg0 },
        { 'line_highlight', p.bg5 .. '40' },
        { 'selection', p.sel },
        { 'selection_border', p.sel },
        { 'inactive_selection', p.bg4 },
        { 'misspelling', p.red },
        { 'find_highlight', p.match },
        { 'find_highlight_foreground', p.fg0 },
        { 'gutter_foreground', p.line_nr },
        { 'guide', p.fg3 .. '40' },
        { 'active_guide', p.fg2 .. '80' },
        { 'accent', p.accent },
      }),
    },
    { 'rules', rules },
  })

  local content = table.concat({
    '// Generated by token colorscheme. Do not edit manually.',
    json_encode(scheme),
    '',
  }, '\n')

  return {
    path = 'contrib/sublime/' .. appearance.slug .. '-' .. variant .. '.sublime-color-scheme',
    content = content,
  }
end

-- ---------------------------------------------------------------------------
-- GtkSourceView (.xml) -- gedit / gnome-text-editor
-- ---------------------------------------------------------------------------

local function gtk_style(name, opts)
  local attrs = { '    <style name="' .. name .. '"' }
  if opts.fg then
    attrs[#attrs + 1] = ' foreground="' .. opts.fg .. '"'
  end
  if opts.bg then
    attrs[#attrs + 1] = ' background="' .. opts.bg .. '"'
  end
  if opts.bold then
    attrs[#attrs + 1] = ' bold="true"'
  end
  if opts.italic then
    attrs[#attrs + 1] = ' italic="true"'
  end
  if opts.underline then
    attrs[#attrs + 1] = ' underline="single"'
  end
  attrs[#attrs + 1] = '/>'
  return table.concat(attrs)
end

local function gen_gtksourceview(p, variant, _term, appearance)
  local id = appearance.slug .. '-' .. variant
  local name = variant_name(appearance, variant)
  local description = appearance.name == 'token' and 'Token ' .. variant .. ' - warm, muted theme'
    or appearance.display_name .. ' ' .. variant .. ' theme'

  -- name -> style options; ordered for readable output
  local styles = {
    -- Global editor UI
    { 'text', { fg = p.fg0, bg = p.bg3 } },
    { 'selection', { bg = p.sel } },
    { 'selection-unfocused', { bg = p.bg4 } },
    { 'cursor', { fg = p.fg0 } },
    { 'secondary-cursor', { fg = p.fg2 } },
    { 'current-line', { bg = p.bg4 } },
    { 'current-line-number', { fg = p.fg2, bg = p.bg4 } },
    { 'line-numbers', { fg = p.line_nr, bg = p.bg2 } },
    { 'line-numbers-border', { bg = p.bg5 } },
    { 'draw-spaces', { fg = p.fg3 } },
    { 'background-pattern', { bg = p.bg2 } },
    { 'right-margin', { fg = p.fg3, bg = p.fg3 } },
    { 'bracket-match', { fg = p.accent, bg = p.match, bold = true } },
    { 'bracket-mismatch', { fg = p.red, bold = true } },
    { 'search-match', { fg = p.fg0, bg = p.match } },
    -- Default syntax defs (languages map their tokens onto these)
    { 'def:comment', { fg = p.fg2, italic = true } },
    { 'def:shebang', { fg = p.fg2, italic = true } },
    { 'def:doc-comment', { fg = p.fg2, italic = true } },
    { 'def:doc-comment-element', { fg = p.fg2, italic = true } },
    { 'def:constant', { fg = p.purple } },
    { 'def:special-constant', { fg = p.purple } },
    { 'def:number', { fg = p.purple } },
    { 'def:decimal', { fg = p.purple } },
    { 'def:base-n-integer', { fg = p.purple } },
    { 'def:floating-point', { fg = p.purple } },
    { 'def:complex', { fg = p.purple } },
    { 'def:boolean', { fg = p.accent2 } },
    { 'def:character', { fg = p.green } },
    { 'def:string', { fg = p.green } },
    { 'def:special-char', { fg = p.purple } },
    { 'def:identifier', { fg = p.fg0 } },
    { 'def:function', { fg = p.accent } },
    { 'def:builtin', { fg = p.blue } },
    { 'def:keyword', { fg = p.accent2 } },
    { 'def:statement', { fg = p.accent2 } },
    { 'def:type', { fg = p.blue } },
    { 'def:operator', { fg = p.fg1 } },
    { 'def:preprocessor', { fg = p.purple } },
    { 'def:error', { fg = p.red, bold = true } },
    { 'def:warning', { fg = p.yellow } },
    { 'def:note', { fg = p.blue, bold = true } },
    { 'def:net-address', { fg = p.blue, underline = true } },
    -- Markup (Markdown, etc.)
    { 'def:heading', { fg = p.accent, bold = true } },
    { 'def:heading0', { fg = p.accent, bold = true } },
    { 'def:heading1', { fg = p.accent, bold = true } },
    { 'def:heading2', { fg = p.accent2, bold = true } },
    { 'def:heading3', { fg = p.blue, bold = true } },
    { 'def:heading4', { fg = p.green, bold = true } },
    { 'def:heading5', { fg = p.cyan, bold = true } },
    { 'def:heading6', { fg = p.purple, bold = true } },
    { 'def:thematic-break', { fg = p.fg2, bold = true } },
    { 'def:preformatted-section', { fg = p.fg0, bg = p.bg2 } },
    { 'def:link-destination', { fg = p.blue, underline = true } },
    { 'def:link-text', { fg = p.blue } },
    { 'def:link-symbol', { fg = p.accent2 } },
    { 'def:list-marker', { fg = p.accent2 } },
    { 'def:strong-emphasis', { bold = true } },
    { 'def:emphasis', { italic = true } },
    { 'def:inline-code', { fg = p.green } },
    { 'def:underlined', { underline = true } },
    { 'def:deletion', { fg = p.red } },
    { 'def:insertion', { fg = p.green } },
    -- Diff language
    { 'diff:added-line', { fg = p.green } },
    { 'diff:removed-line', { fg = p.red } },
    { 'diff:changed-line', { fg = p.yellow } },
    { 'diff:location', { fg = p.blue } },
    { 'diff:diff-file', { fg = p.accent, bold = true } },
    { 'diff:special-case', { fg = p.purple } },
  }

  if appearance.name == 'token-flint' then
    local flint_styles = {
      ['def:constant'] = { fg = p.green },
      ['def:special-constant'] = { fg = p.green },
      ['def:number'] = { fg = p.green },
      ['def:decimal'] = { fg = p.green },
      ['def:base-n-integer'] = { fg = p.green },
      ['def:floating-point'] = { fg = p.green },
      ['def:complex'] = { fg = p.green },
      ['def:boolean'] = { fg = p.green },
      ['def:special-char'] = { fg = p.green },
      ['def:function'] = { fg = p.accent, bold = true },
      ['def:builtin'] = { fg = p.fg1, italic = true },
      ['def:type'] = { fg = p.blue, italic = true },
      ['def:preprocessor'] = { fg = p.accent2 },
      ['def:heading3'] = { fg = p.fg1, bold = true },
      ['def:heading4'] = { fg = p.accent, bold = true },
      ['def:heading5'] = { fg = p.accent2, bold = true },
      ['def:heading6'] = { fg = p.fg1, bold = true },
    }
    for _, style in ipairs(styles) do
      style[2] = flint_styles[style[1]] or style[2]
    end
  end

  local lines = {
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!-- Generated by token colorscheme. Do not edit manually. -->',
    '<style-scheme id="' .. id .. '" name="' .. name .. '" version="1.0">',
    '    <author>Generated by token colorscheme</author>',
    '    <description>' .. description .. '</description>',
  }
  for _, s in ipairs(styles) do
    lines[#lines + 1] = gtk_style(s[1], s[2])
  end
  lines[#lines + 1] = '</style-scheme>'
  lines[#lines + 1] = ''

  return {
    path = 'contrib/gtksourceview/' .. appearance.slug .. '-' .. variant .. '.xml',
    content = table.concat(lines, '\n'),
  }
end

-- ---------------------------------------------------------------------------
-- Blink Shell (HTerm JavaScript theme)
-- ---------------------------------------------------------------------------

local function blink_rgba(hex, alpha)
  local h = strip(hex)
  local r = tonumber(h:sub(1, 2), 16)
  local g = tonumber(h:sub(3, 4), 16)
  local b = tonumber(h:sub(5, 6), 16)
  return string.format('rgba(%d, %d, %d, %.1f)', r, g, b, alpha)
end

local function gen_blink(p, variant, term, appearance)
  local palette = {}
  for i = 0, 15 do
    palette[#palette + 1] = "  '" .. term[i] .. "',"
  end

  local content = table.concat({
    '// Generated by token colorscheme. Do not edit manually.',
    '',
    "t.prefs_.set('color-palette-overrides', [",
    table.concat(palette, '\n'),
    ']);',
    "t.prefs_.set('foreground-color', '" .. p.fg0 .. "');",
    "t.prefs_.set('background-color', '" .. p.bg3 .. "');",
    "t.prefs_.set('cursor-color', '" .. blink_rgba(p.fg0, 0.5) .. "');",
    '',
  }, '\n')

  return { path = 'contrib/blink/' .. appearance.slug .. '-' .. variant .. '.js', content = content }
end

-- ---------------------------------------------------------------------------
-- delta (.gitconfig)
-- ---------------------------------------------------------------------------

local function gen_delta(dark, light, _dark_term, _light_term, appearance)
  local function section(p, variant)
    local is_dark = variant == 'dark'
    local base_del = is_dark and p.diff_del_inline or p.diff_del
    local base_add = is_dark and p.diff_add_inline or p.diff_add
    local emph_del = is_dark and p.diff_del_strong or p.diff_del_inline
    local emph_add = is_dark and p.diff_add_strong or p.diff_add_inline
    local lines = {
      '[delta "' .. appearance.slug .. '-' .. variant .. '"]',
      '\t' .. (is_dark and 'dark' or 'light') .. ' = true',
      '\tsyntax-theme = ' .. appearance.slug .. '-' .. variant,
      '\tblame-palette = "' .. p.bg1 .. ' ' .. p.bg2 .. ' ' .. p.bg3 .. ' ' .. p.bg4 .. ' ' .. p.bg5 .. '"',
      '\tcommit-decoration-style = "' .. p.fg3 .. '" bold box ul',
      '\tfile-style = "' .. p.fg0 .. '"',
      '\tfile-decoration-style = "' .. p.fg3 .. '"',
      '\thunk-header-style = file line-number syntax',
      '\thunk-header-decoration-style = "' .. p.fg3 .. '" box ul',
      '\thunk-header-file-style = bold',
      '\thunk-header-line-number-style = bold "' .. p.fg2 .. '"',
      '\tline-numbers-left-style = "' .. p.fg3 .. '"',
      '\tline-numbers-right-style = "' .. p.fg3 .. '"',
      '\tline-numbers-minus-style = bold "' .. p.red .. '"',
      '\tline-numbers-plus-style = bold "' .. p.green .. '"',
      '\tline-numbers-zero-style = "' .. p.fg2 .. '"',
      '\tminus-style = syntax "' .. base_del .. '"',
      '\tminus-non-emph-style = syntax "' .. base_del .. '"',
      '\tminus-emph-style = bold "' .. p.fg0 .. '" "' .. emph_del .. '"',
      '\tminus-empty-line-marker-style = syntax "' .. base_del .. '"',
      '\tplus-style = syntax "' .. base_add .. '"',
      '\tplus-non-emph-style = syntax "' .. base_add .. '"',
      '\tplus-emph-style = bold "' .. p.fg0 .. '" "' .. emph_add .. '"',
      '\tplus-empty-line-marker-style = syntax "' .. base_add .. '"',
      '\tmap-styles = "bold purple => syntax \''
        .. (is_dark and p.diff_text or p.diff_change)
        .. "', bold cyan => syntax '"
        .. (is_dark and p.diff_text or p.diff_change)
        .. '\'"',
    }
    return table.concat(lines, '\n')
  end

  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Include this file from ~/.gitconfig, then enable one of these named delta features:',
    '#   [delta]',
    '#     features = ' .. appearance.slug .. '-dark',
    '',
    section(dark, 'dark'),
    '',
    section(light, 'light'),
    '',
  }, '\n')

  return { path = 'contrib/delta/' .. appearance.slug .. '.gitconfig', content = content }
end

-- ---------------------------------------------------------------------------
-- fish (.theme)
-- ---------------------------------------------------------------------------

local function fish_theme_lines(p)
  local s = strip
  return {
    'fish_color_normal ' .. s(p.fg0),
    'fish_color_command ' .. s(p.blue),
    'fish_color_keyword ' .. s(p.accent2),
    'fish_color_quote ' .. s(p.green),
    'fish_color_redirection ' .. s(p.purple),
    'fish_color_end ' .. s(p.fg2),
    'fish_color_error ' .. s(p.red),
    'fish_color_param ' .. s(p.fg1),
    'fish_color_comment ' .. s(p.fg2),
    'fish_color_selection --reverse',
    'fish_color_operator ' .. s(p.accent),
    'fish_color_escape ' .. s(p.purple),
    'fish_color_autosuggestion ' .. s(p.line_nr),
    'fish_color_cwd ' .. s(p.blue),
    'fish_color_cwd_root ' .. s(p.red),
    'fish_color_user ' .. s(p.green),
    'fish_color_host ' .. s(p.blue),
    'fish_color_host_remote ' .. s(p.accent2),
    'fish_color_status ' .. s(p.red),
    'fish_color_cancel ' .. s(p.red),
    'fish_color_search_match --background=' .. s(p.match),
    'fish_color_history_current ' .. s(p.accent),
    'fish_color_valid_path --underline',
    '',
    '# Pager',
    'fish_pager_color_progress ' .. s(p.accent),
    'fish_pager_color_prefix ' .. s(p.accent) .. ' --bold',
    'fish_pager_color_completion ' .. s(p.fg0),
    'fish_pager_color_description ' .. s(p.fg2),
    'fish_pager_color_selected_background --background=' .. s(p.sel),
    'fish_pager_color_selected_prefix ' .. s(p.accent) .. ' --bold',
    'fish_pager_color_selected_completion ' .. s(p.fg0),
    'fish_pager_color_selected_description ' .. s(p.fg2),
  }
end

local function gen_fish(dark, light, _dark_term, _light_term, appearance)
  local function add_variant(lines, name, p)
    lines[#lines + 1] = '[' .. name .. ']'
    lines[#lines + 1] = '# preferred_background: ' .. strip(p.bg3)
    extend_lines(lines, fish_theme_lines(p))
    lines[#lines + 1] = ''
  end

  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    "# name: '" .. appearance.slug .. "'",
    '',
  }

  add_variant(lines, 'dark', dark)
  add_variant(lines, 'light', light)
  add_variant(lines, 'unknown', dark)

  return { path = 'contrib/fish/' .. appearance.slug .. '.theme', content = table.concat(lines, '\n') }
end

-- ---------------------------------------------------------------------------
-- fzf (fish script)
-- ---------------------------------------------------------------------------

local function gen_fzf(p, variant, _term, appearance)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from config.fish to append token colors to FZF_DEFAULT_OPTS.',
    '',
    'set -gx FZF_DEFAULT_OPTS (string join " " -- \\',
    '  $FZF_DEFAULT_OPTS \\',
    '  --border \\',
    "  '--color=fg:" .. p.fg0 .. ',bg:' .. p.bg3 .. ',hl:' .. p.accent .. "' \\",
    "  '--color=fg+:" .. p.fg0 .. ',bg+:' .. p.sel .. ',hl+:' .. p.accent .. "' \\",
    "  '--color=border:" .. p.fg3 .. ',header:' .. p.blue .. ',gutter:' .. p.bg3 .. "' \\",
    "  '--color=spinner:" .. p.accent2 .. ',info:' .. p.fg2 .. "' \\",
    "  '--color=pointer:" .. p.accent .. ',marker:' .. p.green .. ',prompt:' .. p.accent .. "')",
    '',
  }, '\n')

  return { path = 'contrib/fzf/' .. appearance.slug .. '-' .. variant .. '.fish', content = content }
end

local function gen_fzf_zsh(p, variant, _term, appearance)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your .zshrc to append token colors to FZF_DEFAULT_OPTS.',
    '',
    'export _FZF_THEME_OPTS="\\',
    '--border \\',
    '--color=fg:' .. p.fg0 .. ',bg:' .. p.bg3 .. ',hl:' .. p.accent .. ' \\',
    '--color=fg+:' .. p.fg0 .. ',bg+:' .. p.sel .. ',hl+:' .. p.accent .. ' \\',
    '--color=border:' .. p.fg3 .. ',header:' .. p.blue .. ',gutter:' .. p.bg3 .. ' \\',
    '--color=spinner:' .. p.accent2 .. ',info:' .. p.fg2 .. ' \\',
    '--color=pointer:' .. p.accent .. ',marker:' .. p.green .. ',prompt:' .. p.accent,
    '"',
    'export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+${FZF_DEFAULT_OPTS} }${_FZF_THEME_OPTS}"',
    '',
  }, '\n')

  return { path = 'contrib/fzf/' .. appearance.slug .. '-' .. variant .. '.zsh', content = content }
end

-- ---------------------------------------------------------------------------
-- ghostty (config fragment)
-- ---------------------------------------------------------------------------

local function gen_ghostty(p, variant, term, appearance)
  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    '',
    'background = ' .. p.bg3,
    'foreground = ' .. p.fg0,
    'cursor-color = ' .. p.fg0,
    'cursor-text = ' .. p.bg3,
    'selection-background = ' .. p.sel,
    'selection-foreground = ' .. p.fg0,
    '',
  }
  for i = 0, 15 do
    lines[#lines + 1] = 'palette = ' .. i .. '=' .. term[i]
  end
  lines[#lines + 1] = ''

  return { path = 'contrib/ghostty/' .. appearance.slug .. '-' .. variant, content = table.concat(lines, '\n') }
end

-- ---------------------------------------------------------------------------
-- kitty (.conf fragment)
-- ---------------------------------------------------------------------------

local function gen_kitty(p, variant, term, appearance)
  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    '',
    'background ' .. p.bg3,
    'foreground ' .. p.fg0,
    'cursor ' .. p.fg0,
    'cursor_text_color ' .. p.bg3,
    'selection_background ' .. p.sel,
    'selection_foreground ' .. p.fg0,
    'url_color ' .. p.blue,
    '',
  }
  for i = 0, 15 do
    lines[#lines + 1] = 'color' .. i .. ' ' .. term[i]
  end
  lines[#lines + 1] = ''

  return {
    path = 'contrib/kitty/' .. appearance.slug .. '-' .. variant .. '.conf',
    content = table.concat(lines, '\n'),
  }
end

-- ---------------------------------------------------------------------------
-- iTerm2 (.itermcolors)
-- ---------------------------------------------------------------------------

local function iterm2_component(hex, offset)
  return string.format('%.6f', tonumber(strip(hex):sub(offset, offset + 1), 16) / 255)
end

local function iterm2_color_entry(name, hex)
  return table.concat({
    '    <key>' .. xml_escape(name) .. '</key>',
    '    <dict>',
    '      <key>Alpha Component</key>',
    '      <real>1</real>',
    '      <key>Blue Component</key>',
    '      <real>' .. iterm2_component(hex, 5) .. '</real>',
    '      <key>Color Space</key>',
    '      <string>sRGB</string>',
    '      <key>Green Component</key>',
    '      <real>' .. iterm2_component(hex, 3) .. '</real>',
    '      <key>Red Component</key>',
    '      <real>' .. iterm2_component(hex, 1) .. '</real>',
    '    </dict>',
  }, '\n')
end

local function gen_iterm2(p, variant, term, appearance)
  local entries = {
    iterm2_color_entry('Background Color', p.bg3),
    iterm2_color_entry('Foreground Color', p.fg0),
    iterm2_color_entry('Bold Color', p.fg0),
    iterm2_color_entry('Cursor Color', p.fg0),
    iterm2_color_entry('Cursor Text Color', p.bg3),
    iterm2_color_entry('Selection Color', p.sel),
    iterm2_color_entry('Selected Text Color', p.fg0),
    iterm2_color_entry('Link Color', p.blue),
  }

  for i = 0, 15 do
    entries[#entries + 1] = iterm2_color_entry('Ansi ' .. i .. ' Color', term[i])
  end

  local content = table.concat({
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    '<!-- Generated by token colorscheme. Do not edit manually. -->',
    '<plist version="1.0">',
    '  <dict>',
    table.concat(entries, '\n'),
    '  </dict>',
    '</plist>',
    '',
  }, '\n')

  return { path = 'contrib/iterm2/' .. appearance.slug .. '-' .. variant .. '.itermcolors', content = content }
end

-- ---------------------------------------------------------------------------
-- Xcode (.xccolortheme)
-- ---------------------------------------------------------------------------

local function xcode_rgba(hex, alpha)
  local value = strip(hex)
  local r = tonumber(value:sub(1, 2), 16) / 255
  local g = tonumber(value:sub(3, 4), 16) / 255
  local b = tonumber(value:sub(5, 6), 16) / 255
  return string.format('%.6f %.6f %.6f %g', r, g, b, alpha or 1)
end

local function xcode_entry(lines, key, value, indent)
  indent = indent or '    '
  lines[#lines + 1] = indent .. '<key>' .. key .. '</key>'
  lines[#lines + 1] = indent .. '<string>' .. value .. '</string>'
end

local function gen_xcode(p, variant, _term, appearance)
  local lines = {
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    '<!-- Generated by token colorscheme for Xcode 26.6. Do not edit manually. -->',
    '<plist version="1.0">',
    '  <dict>',
  }

  local console_entries = {
    { 'DVTConsoleDebuggerInputTextColor', xcode_rgba(p.fg0) },
    { 'DVTConsoleDebuggerInputTextFont', 'SFMono-Regular - 12.0' },
    { 'DVTConsoleDebuggerOutputTextColor', xcode_rgba(p.fg0) },
    { 'DVTConsoleDebuggerOutputTextFont', 'SFMono-Regular - 12.0' },
    { 'DVTConsoleDebuggerPromptTextColor', xcode_rgba(p.green) },
    { 'DVTConsoleDebuggerPromptTextFont', 'SFMono-Regular - 12.0' },
    { 'DVTConsoleExectuableInputTextColor', xcode_rgba(p.fg0) },
    { 'DVTConsoleExectuableInputTextFont', 'SFMono-Regular - 12.0' },
    { 'DVTConsoleExectuableOutputTextColor', xcode_rgba(p.fg0) },
    { 'DVTConsoleExectuableOutputTextFont', 'SFMono-Regular - 12.0' },
    { 'DVTConsoleTextBackgroundColor', xcode_rgba(p.bg3) },
    { 'DVTConsoleTextInsertionPointColor', xcode_rgba(p.fg0) },
    { 'DVTConsoleTextSelectionColor', xcode_rgba(p.sel) },
  }
  for _, entry in ipairs(console_entries) do
    xcode_entry(lines, entry[1], entry[2])
  end

  lines[#lines + 1] = '    <key>DVTFontAndColorVersion</key>'
  lines[#lines + 1] = '    <integer>1</integer>'
  lines[#lines + 1] = '    <key>DVTLineSpacing</key>'
  lines[#lines + 1] = '    <real>1.100000023841858</real>'

  local markup_entries = {
    { 'DVTMarkupTextBackgroundColor', xcode_rgba(p.bg2) },
    { 'DVTMarkupTextBorderColor', xcode_rgba(p.bg4) },
    { 'DVTMarkupTextCodeFont', 'SFMono-Regular - 10.0' },
    { 'DVTMarkupTextEmphasisColor', xcode_rgba(p.fg0) },
    { 'DVTMarkupTextEmphasisFont', '.AppleSystemUIFontItalic - 10.0' },
    { 'DVTMarkupTextInlineCodeColor', xcode_rgba(p.fg1, 0.7) },
    { 'DVTMarkupTextLinkColor', xcode_rgba(p.blue) },
    { 'DVTMarkupTextLinkFont', '.AppleSystemUIFont - 10.0' },
    { 'DVTMarkupTextNormalColor', xcode_rgba(p.fg0) },
    { 'DVTMarkupTextNormalFont', '.AppleSystemUIFont - 10.0' },
    { 'DVTMarkupTextOtherHeadingColor', xcode_rgba(p.fg2) },
    { 'DVTMarkupTextOtherHeadingFont', '.AppleSystemUIFont - 14.0' },
    { 'DVTMarkupTextPrimaryHeadingColor', xcode_rgba(p.accent) },
    { 'DVTMarkupTextPrimaryHeadingFont', '.AppleSystemUIFont - 24.0' },
    { 'DVTMarkupTextSecondaryHeadingColor', xcode_rgba(p.accent2) },
    { 'DVTMarkupTextSecondaryHeadingFont', '.AppleSystemUIFont - 18.0' },
    { 'DVTMarkupTextStrongColor', xcode_rgba(p.fg0) },
    { 'DVTMarkupTextStrongFont', '.AppleSystemUIFontBold - 10.0' },
  }
  for _, entry in ipairs(markup_entries) do
    xcode_entry(lines, entry[1], entry[2])
  end

  local marker_entries = {
    { 'DVTScrollbarMarkerAnalyzerColor', p.cyan },
    { 'DVTScrollbarMarkerBreakpointColor', p.blue },
    { 'DVTScrollbarMarkerDiffColor', p.yellow },
    { 'DVTScrollbarMarkerDiffConflictColor', p.red },
    { 'DVTScrollbarMarkerErrorColor', p.red },
    { 'DVTScrollbarMarkerRuntimeIssueColor', p.purple },
    { 'DVTScrollbarMarkerWarningColor', p.yellow },
  }
  for _, entry in ipairs(marker_entries) do
    xcode_entry(lines, entry[1], xcode_rgba(entry[2]))
  end

  local source_entries = {
    { 'DVTSourceTextBackground', p.bg3 },
    { 'DVTSourceTextBlockDimBackgroundColor', p.bg2 },
    { 'DVTSourceTextCurrentLineHighlightColor', p.bg4 },
    { 'DVTSourceTextInsertionPointColor', p.fg0 },
    { 'DVTSourceTextInvisiblesColor', p.indent_active },
    { 'DVTSourceTextSelectionColor', p.sel },
  }
  for _, entry in ipairs(source_entries) do
    xcode_entry(lines, entry[1], xcode_rgba(entry[2]))
  end

  local syntax_roles = {
    { 'xcode.syntax.attribute', p.purple },
    { 'xcode.syntax.character', p.green },
    { 'xcode.syntax.comment', p.fg2 },
    { 'xcode.syntax.comment.doc', p.fg2 },
    { 'xcode.syntax.comment.doc.keyword', p.yellow },
    { 'xcode.syntax.declaration.other', p.accent },
    { 'xcode.syntax.declaration.type', p.blue },
    { 'xcode.syntax.identifier.class', p.blue },
    { 'xcode.syntax.identifier.class.system', p.purple },
    { 'xcode.syntax.identifier.constant', p.purple },
    { 'xcode.syntax.identifier.constant.system', p.purple },
    { 'xcode.syntax.identifier.function', p.accent },
    { 'xcode.syntax.identifier.function.system', p.accent },
    { 'xcode.syntax.identifier.macro', p.purple },
    { 'xcode.syntax.identifier.macro.system', p.purple },
    { 'xcode.syntax.identifier.type', p.blue },
    { 'xcode.syntax.identifier.type.system', p.blue },
    { 'xcode.syntax.identifier.variable', p.fg0 },
    { 'xcode.syntax.identifier.variable.system', p.accent2 },
    { 'xcode.syntax.keyword', p.accent2 },
    { 'xcode.syntax.mark', p.yellow },
    { 'xcode.syntax.markup.aside.kind', p.yellow },
    { 'xcode.syntax.markup.code', p.green },
    { 'xcode.syntax.number', p.orange },
    { 'xcode.syntax.plain', p.fg0 },
    { 'xcode.syntax.preprocessor', p.purple },
    { 'xcode.syntax.string', p.green },
    { 'xcode.syntax.url', p.blue },
  }

  if appearance.name == 'token-flint' then
    local flint_colors = {
      ['xcode.syntax.attribute'] = p.fg1,
      ['xcode.syntax.declaration.type'] = p.accent,
      ['xcode.syntax.identifier.class'] = p.blue,
      ['xcode.syntax.identifier.class.system'] = p.blue,
      ['xcode.syntax.identifier.constant'] = p.green,
      ['xcode.syntax.identifier.constant.system'] = p.green,
      ['xcode.syntax.identifier.function.system'] = p.fg1,
      ['xcode.syntax.identifier.macro'] = p.accent2,
      ['xcode.syntax.identifier.macro.system'] = p.accent2,
      ['xcode.syntax.identifier.type'] = p.blue,
      ['xcode.syntax.identifier.type.system'] = p.blue,
      ['xcode.syntax.identifier.variable.system'] = p.fg1,
      ['xcode.syntax.number'] = p.green,
      ['xcode.syntax.preprocessor'] = p.accent2,
    }
    for _, role in ipairs(syntax_roles) do
      role[2] = flint_colors[role[1]] or role[2]
    end
  end

  lines[#lines + 1] = '    <key>DVTSourceTextSyntaxColors</key>'
  lines[#lines + 1] = '    <dict>'
  for _, role in ipairs(syntax_roles) do
    xcode_entry(lines, role[1], xcode_rgba(role[2]), '      ')
  end
  lines[#lines + 1] = '    </dict>'

  local regular_font = variant == 'dark' and 'SFMono-Medium - 12.0' or 'SFMono-Regular - 12.0'
  local keyword_font = variant == 'dark' and 'SFMono-Bold - 12.0' or 'SFMono-Semibold - 12.0'
  local documentation_font = variant == 'dark' and 'Helvetica - 12.0' or 'HelveticaNeue - 12.0'

  lines[#lines + 1] = '    <key>DVTSourceTextSyntaxFonts</key>'
  lines[#lines + 1] = '    <dict>'
  for _, role in ipairs(syntax_roles) do
    local font = regular_font
    if role[1] == 'xcode.syntax.comment.doc' then
      font = documentation_font
    elseif role[1] == 'xcode.syntax.comment.doc.keyword' or role[1] == 'xcode.syntax.mark' then
      font = 'SFMono-Bold - 12.0'
    elseif role[1] == 'xcode.syntax.keyword' then
      font = keyword_font
    end
    if appearance.name == 'token-flint' then
      if role[1] == 'xcode.syntax.comment' or role[1] == 'xcode.syntax.comment.doc' then
        font = 'SFMono-RegularItalic - 12.0'
      elseif role[1] == 'xcode.syntax.declaration.other' or role[1] == 'xcode.syntax.declaration.type' then
        font = 'SFMono-Bold - 12.0'
      elseif
        role[1] == 'xcode.syntax.attribute'
        or role[1] == 'xcode.syntax.identifier.class'
        or role[1] == 'xcode.syntax.identifier.class.system'
        or role[1] == 'xcode.syntax.identifier.function.system'
        or role[1] == 'xcode.syntax.identifier.type'
        or role[1] == 'xcode.syntax.identifier.type.system'
        or role[1] == 'xcode.syntax.identifier.variable.system'
      then
        font = 'SFMono-RegularItalic - 12.0'
      elseif role[1] == 'xcode.syntax.keyword' then
        font = regular_font
      end
    end
    xcode_entry(lines, role[1], font, '      ')
  end
  lines[#lines + 1] = '    </dict>'
  lines[#lines + 1] = '  </dict>'
  lines[#lines + 1] = '</plist>'
  lines[#lines + 1] = ''

  return {
    path = 'contrib/xcode/' .. appearance.slug .. '-' .. variant .. '.xccolortheme',
    content = table.concat(lines, '\n'),
  }
end

-- ---------------------------------------------------------------------------
-- Windows Terminal (settings fragment)
-- ---------------------------------------------------------------------------

local function windows_terminal_scheme(p, name, term)
  local ansi_names = {
    'black',
    'red',
    'green',
    'yellow',
    'blue',
    'purple',
    'cyan',
    'white',
    'brightBlack',
    'brightRed',
    'brightGreen',
    'brightYellow',
    'brightBlue',
    'brightPurple',
    'brightCyan',
    'brightWhite',
  }
  local entries = {
    { 'name', name },
    { 'background', p.bg3 },
    { 'foreground', p.fg0 },
    { 'cursorColor', p.fg0 },
    { 'selectionBackground', p.sel },
  }
  for i, color_name in ipairs(ansi_names) do
    entries[#entries + 1] = { color_name, term[i - 1] }
  end
  return json_object(entries)
end

local function gen_windows_terminal(dark, light, dark_term, light_term, appearance)
  local content = table.concat({
    json_encode(json_object({
      {
        'schemes',
        {
          windows_terminal_scheme(dark, variant_name(appearance, 'dark'), dark_term),
          windows_terminal_scheme(light, variant_name(appearance, 'light'), light_term),
        },
      },
    })),
    '',
  }, '\n')

  return { path = 'contrib/windows-terminal/' .. appearance.slug .. '.json', content = content }
end

-- ---------------------------------------------------------------------------
-- VS Code (local color theme extension)
-- ---------------------------------------------------------------------------

local function vscode_token_colors(p, appearance)
  local rules = {}
  for _, rule in ipairs(textmate_scope_rules(p, appearance)) do
    local settings = {}
    if rule[3] then
      settings[#settings + 1] = { 'foreground', rule[3] }
    end
    if rule[4] then
      settings[#settings + 1] = { 'fontStyle', rule[4] }
    end
    rules[#rules + 1] = json_object({
      { 'name', rule[1] },
      { 'scope', rule[2] },
      { 'settings', json_object(settings) },
    })
  end
  return rules
end

local function vscode_terminal_colors(term)
  local names = {
    'terminal.ansiBlack',
    'terminal.ansiRed',
    'terminal.ansiGreen',
    'terminal.ansiYellow',
    'terminal.ansiBlue',
    'terminal.ansiMagenta',
    'terminal.ansiCyan',
    'terminal.ansiWhite',
    'terminal.ansiBrightBlack',
    'terminal.ansiBrightRed',
    'terminal.ansiBrightGreen',
    'terminal.ansiBrightYellow',
    'terminal.ansiBrightBlue',
    'terminal.ansiBrightMagenta',
    'terminal.ansiBrightCyan',
    'terminal.ansiBrightWhite',
  }
  local colors = {}
  for i, name in ipairs(names) do
    colors[#colors + 1] = { name, term[i - 1] }
  end
  return colors
end

local function gen_vscode_theme(p, variant, term, appearance)
  local is_dark = variant == 'dark'
  local colors = {
    { 'focusBorder', p.accent },
    { 'foreground', p.fg0 },
    { 'descriptionForeground', p.fg2 },
    { 'errorForeground', p.red },
    { 'textLink.foreground', p.blue },
    { 'textLink.activeForeground', p.accent },
    { 'selection.background', p.sel },
    { 'icon.foreground', p.fg1 },
    { 'sash.hoverBorder', p.accent },
    { 'editor.background', p.bg3 },
    { 'editor.foreground', p.fg0 },
    { 'editorLineNumber.foreground', p.line_nr },
    { 'editorLineNumber.activeForeground', p.fg2 },
    { 'editorCursor.foreground', p.fg0 },
    { 'editor.selectionBackground', p.sel },
    { 'editor.inactiveSelectionBackground', p.bg4 },
    { 'editor.lineHighlightBackground', p.bg5 .. '40' },
    { 'editor.findMatchBackground', p.match },
    { 'editor.findMatchHighlightBackground', p.match .. '80' },
    { 'editorWhitespace.foreground', p.fg3 .. '80' },
    { 'editorIndentGuide.background1', p.fg3 .. '40' },
    { 'editorIndentGuide.activeBackground1', p.fg2 .. '80' },
    { 'editorBracketMatch.background', p.bg5 },
    { 'editorBracketMatch.border', p.accent },
    { 'editorGutter.addedBackground', p.green },
    { 'editorGutter.modifiedBackground', p.yellow },
    { 'editorGutter.deletedBackground', p.red },
    { 'diffEditor.insertedTextBackground', p.diff_add },
    { 'diffEditor.removedTextBackground', p.diff_del },
    { 'editorError.foreground', p.red },
    { 'editorWarning.foreground', p.yellow },
    { 'editorInfo.foreground', p.blue },
    { 'editorHint.foreground', p.cyan },
    { 'activityBar.background', p.bg2 },
    { 'activityBar.foreground', p.fg0 },
    { 'activityBar.inactiveForeground', p.fg2 },
    { 'activityBarBadge.background', p.accent },
    { 'activityBarBadge.foreground', p.bg3 },
    { 'sideBar.background', p.bg2 },
    { 'sideBar.foreground', p.fg1 },
    { 'sideBarTitle.foreground', p.fg0 },
    { 'sideBarSectionHeader.background', p.bg3 },
    { 'list.activeSelectionBackground', p.sel },
    { 'list.activeSelectionForeground', p.fg0 },
    { 'list.inactiveSelectionBackground', p.bg4 },
    { 'list.hoverBackground', p.bg4 },
    { 'list.focusBackground', p.bg4 },
    { 'quickInput.background', p.bg2 },
    { 'quickInput.foreground', p.fg0 },
    { 'quickInputList.focusBackground', p.sel },
    { 'panel.background', p.bg2 },
    { 'panel.border', p.bg5 },
    { 'panelTitle.activeForeground', p.fg0 },
    { 'panelTitle.inactiveForeground', p.fg2 },
    { 'statusBar.background', p.bg2 },
    { 'statusBar.foreground', p.fg1 },
    { 'statusBar.noFolderBackground', p.bg2 },
    { 'statusBar.debuggingBackground', p.purple },
    { 'titleBar.activeBackground', p.bg2 },
    { 'titleBar.activeForeground', p.fg0 },
    { 'titleBar.inactiveBackground', p.bg1 },
    { 'titleBar.inactiveForeground', p.fg2 },
    { 'tab.activeBackground', p.bg3 },
    { 'tab.activeForeground', p.fg0 },
    { 'tab.inactiveBackground', p.bg2 },
    { 'tab.inactiveForeground', p.fg2 },
    { 'tab.border', p.bg2 },
    { 'terminal.background', p.bg3 },
    { 'terminal.foreground', p.fg0 },
    { 'terminalCursor.foreground', p.fg0 },
    { 'terminal.selectionBackground', p.sel },
  }
  extend_lines(colors, vscode_terminal_colors(term))

  local semantic_colors = {
    { 'class', p.blue },
    { 'enum', p.blue },
    { 'interface', p.blue },
    { 'struct', p.blue },
    { 'type', p.blue },
    { 'typeParameter', p.blue },
    { 'namespace', p.blue },
    { 'function', p.accent },
    { 'method', p.accent },
    { 'macro', p.purple },
    { 'keyword', p.accent2 },
    { 'string', p.green },
    { 'number', p.purple },
    { 'enumMember', p.purple },
    { 'variable.readonly', p.purple },
    { 'property.readonly', p.purple },
    { 'parameter', p.fg1 },
    { '*.deprecated', json_object({ { 'strikethrough', true } }) },
    { '*.readonly', json_object({ { 'foreground', p.purple } }) },
    { '*.async', json_object({ { 'italic', true } }) },
    { '*.static', json_object({ { 'italic', true } }) },
    { '*.abstract', json_object({ { 'italic', true } }) },
    { '*.defaultLibrary', json_object({ { 'italic', true } }) },
    { '*.declaration', json_object({ { 'bold', true } }) },
    { '*.definition', json_object({ { 'bold', true } }) },
  }
  if appearance.name == 'token-flint' then
    semantic_colors = {
      { 'class', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'enum', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'interface', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'struct', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'type', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'typeParameter', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'namespace', json_object({ { 'foreground', p.blue }, { 'italic', true } }) },
      { 'function', p.accent },
      { 'method', p.accent },
      { 'macro', p.accent2 },
      { 'keyword', p.accent2 },
      { 'string', p.green },
      { 'number', p.green },
      { 'enumMember', p.green },
      { 'variable.readonly', p.green },
      { 'property.readonly', p.green },
      { 'parameter', p.fg1 },
      { '*.deprecated', json_object({ { 'strikethrough', true } }) },
      { '*.readonly', json_object({ { 'foreground', p.green } }) },
      { '*.async', json_object({ { 'italic', true } }) },
      { '*.static', json_object({ { 'italic', true } }) },
      { '*.abstract', json_object({ { 'italic', true } }) },
      { '*.defaultLibrary', json_object({ { 'italic', true } }) },
      { '*.declaration', json_object({ { 'bold', true } }) },
      { '*.definition', json_object({ { 'bold', true } }) },
    }
    for _, token_type in ipairs({ 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
      for _, modifier in ipairs({ 'declaration', 'definition' }) do
        semantic_colors[#semantic_colors + 1] = {
          token_type .. '.' .. modifier,
          json_object({ { 'foreground', p.accent }, { 'bold', true }, { 'italic', false } }),
        }
      end
    end
  end

  local theme = json_object({
    { 'name', variant_name(appearance, variant) },
    { 'type', is_dark and 'dark' or 'light' },
    { 'colors', json_object(colors) },
    { 'tokenColors', vscode_token_colors(p, appearance) },
    { 'semanticHighlighting', true },
    {
      'semanticTokenColors',
      json_object(semantic_colors),
    },
  })

  local content = table.concat({ json_encode(theme), '' }, '\n')
  return {
    path = 'contrib/vscode/themes/' .. appearance.slug .. '-' .. variant .. '-color-theme.json',
    content = content,
  }
end

local function gen_vscode_package(appearances)
  local themes = {}
  for _, appearance in ipairs(appearances) do
    for _, variant in ipairs({ 'dark', 'light' }) do
      themes[#themes + 1] = json_object({
        { 'label', variant_name(appearance, variant) },
        { 'uiTheme', variant == 'dark' and 'vs-dark' or 'vs' },
        { 'path', './themes/' .. appearance.slug .. '-' .. variant .. '-color-theme.json' },
      })
    end
  end
  local manifest = json_object({
    { 'name', 'token-vscode-themes' },
    { 'displayName', 'Token VS Code Themes' },
    { 'description', 'Local VS Code themes generated from the Token colorscheme palette.' },
    { 'version', '0.0.0' },
    { 'publisher', 'thorstenrhau' },
    { 'author', json_object({ { 'name', 'Thorsten Rhau' } }) },
    { 'engines', json_object({ { 'vscode', '^1.80.0' } }) },
    {
      'contributes',
      json_object({
        {
          'themes',
          themes,
        },
      }),
    },
  })

  return { path = 'contrib/vscode/package.json', content = table.concat({ json_encode(manifest), '' }, '\n') }
end

-- ---------------------------------------------------------------------------
-- Obsidian (local app theme)
-- ---------------------------------------------------------------------------

local function obsidian_rgb(hex)
  local h = strip(hex)
  return table.concat({
    tonumber(h:sub(1, 2), 16),
    tonumber(h:sub(3, 4), 16),
    tonumber(h:sub(5, 6), 16),
  }, ', ')
end

local function obsidian_hsl(hex)
  local h = strip(hex)
  local r = tonumber(h:sub(1, 2), 16) / 255
  local g = tonumber(h:sub(3, 4), 16) / 255
  local b = tonumber(h:sub(5, 6), 16) / 255
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local lightness = (max + min) / 2
  local hue = 0
  local saturation = 0

  if max ~= min then
    local delta = max - min
    saturation = lightness > 0.5 and delta / (2 - max - min) or delta / (max + min)
    if max == r then
      hue = (g - b) / delta + (g < b and 6 or 0)
    elseif max == g then
      hue = (b - r) / delta + 2
    else
      hue = (r - g) / delta + 4
    end
    hue = hue / 6
  end

  return string.format('%.2f', hue * 360),
    string.format('%.2f%%', saturation * 100),
    string.format('%.2f%%', lightness * 100)
end

local function obsidian_theme_block(p, variant, appearance)
  local base = variant == 'dark'
      and {
        p.bg0,
        p.bg1,
        p.bg2,
        p.bg3,
        p.bg4,
        p.bg5,
        p.fg3,
        p.fg3,
        p.fg2,
        p.fg2,
        p.fg1,
        p.fg0,
      }
    or {
      p.bg3,
      p.bg2,
      p.bg4,
      p.bg1,
      p.bg5,
      p.bg0,
      p.line_nr,
      p.indent_active,
      p.fg3,
      p.fg2,
      p.fg1,
      p.fg0,
    }
  local base_names = { '00', '05', '10', '20', '25', '30', '35', '40', '50', '60', '70', '100' }
  local lines = { '.theme-' .. variant .. ' {' }
  local accent_h, accent_s, accent_l = obsidian_hsl(p.accent)

  for i, name in ipairs(base_names) do
    lines[#lines + 1] = '  --color-base-' .. name .. ': ' .. base[i] .. ';'
  end

  local colors = {
    { 'red', p.red },
    { 'orange', p.orange },
    { 'yellow', p.yellow },
    { 'green', p.green },
    { 'cyan', p.cyan },
    { 'blue', p.blue },
    { 'purple', p.purple },
    { 'pink', p.purple },
  }
  for _, color in ipairs(colors) do
    lines[#lines + 1] = '  --color-' .. color[1] .. ': ' .. color[2] .. ';'
    lines[#lines + 1] = '  --color-' .. color[1] .. '-rgb: ' .. obsidian_rgb(color[2]) .. ';'
  end

  extend_lines(lines, {
    '',
    '  --accent-h: ' .. accent_h .. ';',
    '  --accent-s: ' .. accent_s .. ';',
    '  --accent-l: ' .. accent_l .. ';',
    '',
    '  --background-primary: ' .. p.bg3 .. ';',
    '  --background-primary-alt: ' .. p.bg2 .. ';',
    '  --background-secondary: ' .. p.bg2 .. ';',
    '  --background-secondary-alt: ' .. p.bg1 .. ';',
    '  --background-modifier-hover: ' .. p.bg4 .. ';',
    '  --background-modifier-active-hover: ' .. p.bg5 .. ';',
    '  --background-modifier-border: ' .. p.bg5 .. ';',
    '  --background-modifier-border-hover: ' .. p.fg3 .. ';',
    '  --background-modifier-border-focus: var(--interactive-accent);',
    '  --background-modifier-form-field: ' .. p.bg2 .. ';',
    '',
    '  --interactive-normal: ' .. p.bg4 .. ';',
    '  --interactive-hover: ' .. p.bg5 .. ';',
    '',
    '  --text-normal: ' .. p.fg0 .. ';',
    '  --text-muted: ' .. p.fg2 .. ';',
    '  --text-faint: ' .. p.fg3 .. ';',
    '  --text-on-accent: ' .. p.bg3 .. ';',
    '  --text-on-accent-inverted: ' .. p.bg3 .. ';',
    '  --text-success: ' .. p.green .. ';',
    '  --text-warning: ' .. p.yellow .. ';',
    '  --text-error: ' .. p.red .. ';',
    '  --text-selection: ' .. p.sel .. ';',
    '  --text-highlight-bg: ' .. p.match .. ';',
    '  --caret-color: ' .. p.fg0 .. ';',
    '',
    '  --link-color: ' .. p.blue .. ';',
    '  --link-color-hover: ' .. p.accent .. ';',
    '  --link-external-color: ' .. p.blue .. ';',
    '  --link-external-color-hover: ' .. p.accent .. ';',
    '  --tag-color: ' .. p.accent2 .. ';',
    '  --tag-color-hover: ' .. p.accent .. ';',
    '  --tag-background: ' .. p.bg4 .. ';',
    '  --tag-background-hover: ' .. p.bg5 .. ';',
    '',
    '  --h1-color: ' .. p.accent .. ';',
    '  --h2-color: ' .. p.accent2 .. ';',
    '  --h3-color: ' .. (appearance.name == 'token-flint' and p.fg1 or p.olive) .. ';',
    '  --h4-color: ' .. (appearance.name == 'token-flint' and p.accent or p.blue) .. ';',
    '  --h5-color: ' .. (appearance.name == 'token-flint' and p.accent2 or p.green) .. ';',
    '  --h6-color: ' .. (appearance.name == 'token-flint' and p.fg1 or p.purple) .. ';',
    '',
    '  --code-normal: ' .. p.fg0 .. ';',
    '  --code-background: ' .. p.bg1 .. ';',
    '  --code-comment: ' .. p.fg2 .. ';',
    '  --code-function: ' .. p.accent .. ';',
    '  --code-important: ' .. p.red .. ';',
    '  --code-keyword: ' .. p.accent2 .. ';',
    '  --code-operator: ' .. p.fg1 .. ';',
    '  --code-property: ' .. p.fg0 .. ';',
    '  --code-punctuation: ' .. p.fg1 .. ';',
    '  --code-string: ' .. p.green .. ';',
    '  --code-tag: ' .. p.purple .. ';',
    '  --code-value: ' .. p.orange .. ';',
    '}',
  })

  return (table.concat(lines, '\n'):gsub('#%x%x%x%x%x%x', string.lower))
end

local function gen_obsidian_theme(dark, light, appearance)
  local content = table.concat({
    '/* Generated by token colorscheme. Do not edit manually. */',
    '',
    obsidian_theme_block(dark, 'dark', appearance),
    '',
    obsidian_theme_block(light, 'light', appearance),
    '',
  }, '\n')

  local prefix = appearance.name == 'token' and 'contrib/obsidian/' or 'contrib/obsidian/token-flint/'
  return { path = prefix .. 'theme.css', content = content }
end

local function gen_obsidian_manifest(appearance)
  local manifest = json_object({
    { 'name', appearance.display_name },
    { 'version', '1.0.0' },
    { 'minAppVersion', '1.0.0' },
    { 'author', 'Thorsten Rhau' },
    { 'authorUrl', 'https://github.com/ThorstenRhau' },
  })

  local prefix = appearance.name == 'token' and 'contrib/obsidian/' or 'contrib/obsidian/token-flint/'
  return { path = prefix .. 'manifest.json', content = table.concat({ json_encode(manifest), '' }, '\n') }
end

-- ---------------------------------------------------------------------------
-- lazygit (YAML)
-- ---------------------------------------------------------------------------

local function gen_lazygit(p, variant, _term, appearance)
  local content = table.concat({
    '# yaml-language-server: $schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json',
    '# Generated by token colorscheme. Do not edit manually.',
    '# Merge this into your lazygit config.yml.',
    '',
    'gui:',
    '  theme:',
    '    activeBorderColor:',
    '      - "' .. p.accent .. '"',
    '      - bold',
    '    inactiveBorderColor:',
    '      - "' .. p.fg3 .. '"',
    '    searchingActiveBorderColor:',
    '      - "' .. p.yellow .. '"',
    '      - bold',
    '    optionsTextColor:',
    '      - "' .. p.blue .. '"',
    '    selectedLineBgColor:',
    '      - "' .. p.sel .. '"',
    '    inactiveViewSelectedLineBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    cherryPickedCommitFgColor:',
    '      - "' .. p.blue .. '"',
    '    cherryPickedCommitBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    markedBaseCommitFgColor:',
    '      - "' .. p.purple .. '"',
    '    markedBaseCommitBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    unstagedChangesColor:',
    '      - "' .. p.red .. '"',
    '    defaultFgColor:',
    '      - "' .. p.fg0 .. '"',
    '',
  }, '\n')

  return { path = 'contrib/lazygit/' .. appearance.slug .. '-' .. variant .. '.yml', content = content }
end

-- ---------------------------------------------------------------------------
-- ripgrep (.ripgreprc)
-- ---------------------------------------------------------------------------

local function gen_ripgrep(p, variant, _term, appearance)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '--colors=match:none',
    '--colors=match:fg:' .. rgb_fmt(p.accent),
    '--colors=match:style:bold',
    '--colors=path:none',
    '--colors=path:fg:' .. rgb_fmt(p.blue),
    '--colors=path:style:nobold',
    '--colors=line:none',
    '--colors=line:fg:' .. rgb_fmt(p.fg2),
    '--colors=line:style:nobold',
    '--colors=column:none',
    '--colors=column:fg:' .. rgb_fmt(p.fg3),
    '--colors=column:style:nobold',
    '',
  }, '\n')

  return { path = 'contrib/ripgrep/' .. appearance.slug .. '-' .. variant .. '.ripgreprc', content = content }
end

-- ---------------------------------------------------------------------------
-- starship (TOML palette)
-- ---------------------------------------------------------------------------

local function gen_starship(p, variant, _term, appearance)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Add palette = "' .. appearance.slug .. '" to your starship.toml to use these colors.',
    '',
    '[palettes.' .. appearance.slug .. ']',
    'bg      = "' .. p.bg3 .. '"',
    'fg      = "' .. p.fg0 .. '"',
    'muted   = "' .. p.fg2 .. '"',
    'subtle  = "' .. p.fg3 .. '"',
    'accent  = "' .. p.accent .. '"',
    'accent2 = "' .. p.accent2 .. '"',
    'blue    = "' .. p.blue .. '"',
    'green   = "' .. p.green .. '"',
    'red     = "' .. p.red .. '"',
    'yellow  = "' .. p.yellow .. '"',
    'purple  = "' .. p.purple .. '"',
    'cyan    = "' .. p.cyan .. '"',
    'orange  = "' .. p.orange .. '"',
    '',
  }, '\n')

  return { path = 'contrib/starship/' .. appearance.slug .. '-' .. variant .. '.toml', content = content }
end

-- ---------------------------------------------------------------------------
-- tmux (.conf)
-- ---------------------------------------------------------------------------

local function gen_tmux(p, variant, _term, appearance)
  local status_bg = variant == 'light' and p.bg4 or p.bg0
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your tmux.conf: source-file /path/to/' .. appearance.slug .. '-' .. variant .. '.conf',
    '',
    '# Status bar',
    'set -g status-style "bg=' .. status_bg .. ',fg=' .. p.fg1 .. '"',
    'set -g status-left-style "bg=' .. status_bg .. ',fg=' .. p.accent .. ',bold"',
    'set -g status-right-style "bg=' .. status_bg .. ',fg=' .. p.fg2 .. '"',
    '',
    '# Window status',
    'setw -g window-status-style "bg=' .. status_bg .. ',fg=' .. p.fg2 .. '"',
    'setw -g window-status-current-style "bg=' .. status_bg .. ',fg=' .. p.blue .. ',bold"',
    'setw -g window-status-activity-style "bg=' .. status_bg .. ',fg=' .. p.yellow .. '"',
    'setw -g window-status-bell-style "bg=' .. status_bg .. ',fg=' .. p.red .. '"',
    '',
    '# Pane borders',
    'set -g pane-border-style "fg=' .. p.fg3 .. '"',
    'set -g pane-active-border-style "fg=' .. p.blue .. '"',
    '',
    '# Messages',
    'set -g message-style "bg=' .. p.bg3 .. ',fg=' .. p.fg0 .. '"',
    'set -g message-command-style "bg=' .. p.bg3 .. ',fg=' .. p.fg0 .. '"',
    '',
    '# Copy mode',
    'setw -g mode-style "bg=' .. p.sel .. ',fg=' .. p.fg0 .. '"',
    '',
    '# Clock',
    'setw -g clock-mode-colour "' .. p.accent .. '"',
    '',
    '# Display panes',
    'set -g display-panes-active-colour "' .. p.accent .. '"',
    'set -g display-panes-colour "' .. p.fg3 .. '"',
    '',
  }, '\n')

  return { path = 'contrib/tmux/' .. appearance.slug .. '-' .. variant .. '.conf', content = content }
end

-- ---------------------------------------------------------------------------
-- zsh (sourceable .zsh)
-- ---------------------------------------------------------------------------

local function gen_zsh(p, variant, _term, appearance)
  local s = strip
  local F = 'FAST_HIGHLIGHT_STYLES'
  local zle_selected = 'fg=#' .. s(p.fg0) .. ',bg=#' .. s(p.sel)
  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your .zshrc to apply ' .. appearance.slug .. ' ' .. variant .. ' colors.',
    '',
    '# ZLE selection and pasted text',
    'zle_highlight=(${zle_highlight:#region:*})',
    'zle_highlight=(${zle_highlight:#paste:*} "region:' .. zle_selected .. '" "paste:' .. zle_selected .. '")',
    '',
    '# fast-syntax-highlighting',
    'typeset -gA ' .. F,
    F .. "[default]='none'",
    F .. "[unknown-token]='fg=#" .. s(p.red) .. "'",
    F .. "[reserved-word]='fg=#" .. s(p.accent2) .. "'",
    F .. "[alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[suffix-alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[global-alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[builtin]='fg=#" .. s(p.blue) .. "'",
    F .. "[function]='fg=#" .. s(p.accent) .. "'",
    F .. "[command]='fg=#" .. s(p.blue) .. "'",
    F .. "[precommand]='fg=#" .. s(p.accent2) .. "'",
    F .. "[subcommand]='fg=#" .. s(p.accent2) .. "'",
    F .. "[commandseparator]='fg=#" .. s(p.fg2) .. "'",
    F .. "[hashed-command]='fg=#" .. s(p.blue) .. "'",
    F .. "[autodirectory]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path_pathseparator]='fg=#" .. s(p.fg2) .. ",underline'",
    F .. "[path_prefix]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path-to-dir]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[globbing]='fg=#" .. s(p.purple) .. "'",
    F .. "[globbing-ext]='fg=#" .. s(p.purple) .. "'",
    F .. "[history-expansion]='fg=#" .. s(p.purple) .. "'",
    F .. "[back-quoted-argument]='fg=#" .. s(p.fg2) .. "'",
    F .. "[single-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[double-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[dollar-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[single-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[double-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[dollar-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[back-or-dollar-double-quoted-argument]='fg=#" .. s(p.purple) .. "'",
    F .. "[back-dollar-quoted-argument]='fg=#" .. s(p.purple) .. "'",
    F .. "[assign]='fg=#" .. s(p.fg0) .. "'",
    F .. "[assign-array-bracket]='fg=#" .. s(p.green) .. "'",
    F .. "[redirection]='fg=#" .. s(p.purple) .. "'",
    F .. "[comment]='fg=#" .. s(p.fg2) .. ",italic'",
    F .. "[single-hyphen-option]='fg=#" .. s(p.fg1) .. "'",
    F .. "[double-hyphen-option]='fg=#" .. s(p.fg1) .. "'",
    F .. "[variable]='fg=#" .. s(p.purple) .. "'",
    F .. "[for-loop-variable]='fg=#" .. s(p.fg0) .. "'",
    F .. "[for-loop-operator]='fg=#" .. s(p.accent2) .. "'",
    F .. "[for-loop-number]='fg=#" .. s(p.purple) .. "'",
    F .. "[for-loop-separator]='fg=#" .. s(p.fg2) .. "'",
    F .. "[exec-descriptor]='fg=#" .. s(p.accent2) .. "'",
    F .. "[here-string-tri]='fg=#" .. s(p.accent2) .. "'",
    F .. "[here-string-text]='none'",
    F .. "[here-string-var]='fg=#" .. s(p.purple) .. "'",
    F .. "[mathvar]='fg=#" .. s(p.blue) .. "'",
    F .. "[mathnum]='fg=#" .. s(p.purple) .. "'",
    F .. "[matherr]='fg=#" .. s(p.red) .. "'",
    F .. "[case-input]='fg=#" .. s(p.green) .. "'",
    F .. "[case-parentheses]='fg=#" .. s(p.accent2) .. "'",
    F .. "[case-condition]='fg=#" .. s(p.blue) .. "'",
    F .. "[paired-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[bracket-level-1]='fg=#" .. s(p.green) .. "'",
    F .. "[bracket-level-2]='fg=#" .. s(p.accent2) .. "'",
    F .. "[bracket-level-3]='fg=#" .. s(p.cyan) .. "'",
    F .. "[single-sq-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[double-sq-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[double-paren]='fg=#" .. s(p.accent2) .. "'",
    F .. "[optarg-string]='fg=#" .. s(p.green) .. "'",
    F .. "[optarg-number]='fg=#" .. s(p.purple) .. "'",
    F .. "[recursive-base]='none'",
    F .. "[correct-subtle]='fg=#" .. s(p.blue) .. "'",
    F .. "[incorrect-subtle]='fg=#" .. s(p.red) .. "'",
    F .. "[subtle-separator]='fg=#" .. s(p.green) .. "'",
    F .. "[subtle-bg]='bg=#" .. s(p.match) .. "'",
    '',
    '# zsh-autosuggestions',
    "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#" .. s(p.line_nr) .. "'",
    '',
    '# LS_COLORS (GNU ls, tree, zsh completion)',
    "export LS_COLORS='"
      .. 'di=1;'
      .. sgr_rgb(p.blue)
      .. ':'
      .. 'ln='
      .. sgr_rgb(p.purple)
      .. ':'
      .. 'or='
      .. sgr_rgb(p.red)
      .. ':'
      .. 'mi=9;'
      .. sgr_rgb(p.red)
      .. ':'
      .. 'so='
      .. sgr_rgb(p.green)
      .. ':'
      .. 'pi='
      .. sgr_rgb(p.yellow)
      .. ':'
      .. 'ex='
      .. sgr_rgb(p.accent)
      .. ':'
      .. 'bd='
      .. sgr_rgb(p.cyan)
      .. ':'
      .. 'cd='
      .. sgr_rgb(p.cyan)
      .. ':'
      .. 'su=1;'
      .. sgr_rgb(p.red)
      .. ':'
      .. 'sg=1;'
      .. sgr_rgb(p.yellow)
      .. ':'
      .. 'tw=1;'
      .. sgr_rgb(p.green)
      .. ':'
      .. 'ow=4;'
      .. sgr_rgb(p.blue)
      .. ':'
      .. 'st=1;'
      .. sgr_rgb(p.blue)
      .. "'",
    '',
    '# LSCOLORS (BSD ls)',
    'export CLICOLOR=1',
    "export LSCOLORS='ExfxcxdxBxgxgxBxDxCxex'",
    '',
    '# Completion',
    'zstyle \':completion:*\' list-colors "${(s.:.)LS_COLORS}" ' .. '"ma=' .. sgr_bg_rgb(p.sel) .. ';' .. sgr_rgb(
      p.fg0
    ) .. '"',
    "zstyle ':completion:*:descriptions' format '%F{#" .. s(p.fg2) .. "}-- %d --%f'",
    "zstyle ':completion:*:messages' format '%F{#" .. s(p.fg2) .. "}-- %d --%f'",
    "zstyle ':completion:*:warnings' format '%F{#" .. s(p.red) .. "}-- no matches --%f'",
    '',
    '# fzf-tab',
    "zstyle ':fzf-tab:*' fzf-flags \\",
    "  '--color=fg:" .. p.fg0 .. ',bg:' .. p.bg3 .. ',hl:' .. p.accent .. "' \\",
    "  '--color=fg+:" .. p.fg0 .. ',bg+:' .. p.sel .. ',hl+:' .. p.accent .. "' \\",
    "  '--color=border:" .. p.fg3 .. ',header:' .. p.blue .. ',gutter:' .. p.bg3 .. "' \\",
    "  '--color=spinner:" .. p.accent2 .. ',info:' .. p.fg2 .. "' \\",
    "  '--color=pointer:" .. p.accent .. ',marker:' .. p.green .. ',prompt:' .. p.accent .. "'",
    "zstyle ':fzf-tab:*' default-color $'\\033[" .. sgr_rgb(p.fg0) .. "m'",
    "zstyle ':fzf-tab:*' group-colors " .. table.concat({
      "$'\\033[" .. sgr_rgb(p.blue) .. "m'",
      "$'\\033[" .. sgr_rgb(p.green) .. "m'",
      "$'\\033[" .. sgr_rgb(p.accent2) .. "m'",
      "$'\\033[" .. sgr_rgb(p.purple) .. "m'",
      "$'\\033[" .. sgr_rgb(p.cyan) .. "m'",
      "$'\\033[" .. sgr_rgb(p.accent) .. "m'",
      "$'\\033[" .. sgr_rgb(p.yellow) .. "m'",
      "$'\\033[" .. sgr_rgb(p.red) .. "m'",
    }, ' '),
    '',
    '# Prompt helpers',
    "export TOKEN_FG='" .. p.fg0 .. "'",
    "export TOKEN_BG='" .. p.bg3 .. "'",
    "export TOKEN_ACCENT='" .. p.accent .. "'",
    "export TOKEN_ACCENT2='" .. p.accent2 .. "'",
    "export TOKEN_BLUE='" .. p.blue .. "'",
    "export TOKEN_GREEN='" .. p.green .. "'",
    "export TOKEN_RED='" .. p.red .. "'",
    "export TOKEN_YELLOW='" .. p.yellow .. "'",
    "export TOKEN_PURPLE='" .. p.purple .. "'",
    "export TOKEN_CYAN='" .. p.cyan .. "'",
    "export TOKEN_MUTED='" .. p.fg2 .. "'",
    '',
  }

  return {
    path = 'contrib/zsh/' .. appearance.slug .. '-' .. variant .. '.zsh',
    content = table.concat(lines, '\n'),
  }
end

-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

local function main()
  local files = {}
  local appearances = appearance_registry.all()

  for _, appearance in ipairs(appearances) do
    local palette_fn = require(appearance.palette)
    local dark = palette_fn('dark')
    local light = palette_fn('light')
    local dark_term = terminal.colors(dark, true)
    local light_term = terminal.colors(light, false)

    for _, variant in ipairs({ 'dark', 'light' }) do
      local p = variant == 'dark' and dark or light
      local term = variant == 'dark' and dark_term or light_term
      files[#files + 1] = gen_bat(p, variant, term, appearance)
      files[#files + 1] = gen_sublime(p, variant, term, appearance)
      files[#files + 1] = gen_gtksourceview(p, variant, term, appearance)
      files[#files + 1] = gen_blink(p, variant, term, appearance)
      files[#files + 1] = gen_carapace(p, variant, term, appearance)
      files[#files + 1] = gen_chatgpt(p, variant, appearance)
      files[#files + 1] = gen_emacs(p, variant, appearance)
      files[#files + 1] = gen_fzf(p, variant, term, appearance)
      files[#files + 1] = gen_fzf_zsh(p, variant, term, appearance)
      files[#files + 1] = gen_ghostty(p, variant, term, appearance)
      files[#files + 1] = gen_kitty(p, variant, term, appearance)
      files[#files + 1] = gen_iterm2(p, variant, term, appearance)
      files[#files + 1] = gen_lazygit(p, variant, term, appearance)
      files[#files + 1] = gen_ripgrep(p, variant, term, appearance)
      files[#files + 1] = gen_starship(p, variant, term, appearance)
      files[#files + 1] = gen_tmux(p, variant, term, appearance)
      files[#files + 1] = gen_xcode(p, variant, term, appearance)
      files[#files + 1] = gen_zsh(p, variant, term, appearance)
      files[#files + 1] = gen_vscode_theme(p, variant, term, appearance)
    end

    files[#files + 1] = gen_fish(dark, light, dark_term, light_term, appearance)
    files[#files + 1] = gen_delta(dark, light, dark_term, light_term, appearance)
    files[#files + 1] = gen_windows_terminal(dark, light, dark_term, light_term, appearance)
    files[#files + 1] = gen_obsidian_theme(dark, light, appearance)
    files[#files + 1] = gen_obsidian_manifest(appearance)
  end

  files[#files + 1] = gen_vscode_package(appearances)

  for _, file in ipairs(files) do
    lib.validate_output_path(file.path)
  end

  local ok = true
  if verify then
    local expected = {}
    for _, file in ipairs(files) do
      expected[#expected + 1] = file.path
    end
    local actual = list_files('contrib')
    for _, path in ipairs(actual) do
      -- Refuse symlinked generated targets before comparing their contents.
      lib.validate_output_path(path)
    end
    for _, path in ipairs(unexpected_paths(actual, expected, { 'contrib/emacs/README.md' })) do
      io.stderr:write('unexpected: ' .. path .. '\n')
      ok = false
    end
  end
  for _, f in ipairs(files) do
    if not write_if_changed(f.path, f.content, verify) then
      ok = false
    end
  end

  if verify and not ok then
    io.stderr:write('contrib files are out of date. Run: make contrib\n')
    os.exit(1)
  end
end

main()
