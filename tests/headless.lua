local root = vim.fn.getcwd()
vim.opt.runtimepath:append(root)
package.path = root .. '/scripts/?.lua;' .. package.path

local token = require('token')

local function equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error((message or 'values differ') .. ': expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(actual), 0)
  end
end

local function truthy(value, message)
  if not value then
    error(message or 'expected truthy value', 0)
  end
end

local function fails(pattern, callback)
  local ok, err = pcall(callback)
  if ok or not tostring(err):match(pattern) then
    error('expected error matching ' .. pattern .. ', got ' .. tostring(err), 0)
  end
end

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function load(background, colorscheme)
  vim.o.background = background or 'dark'
  token.load(colorscheme)
end

local function loaded(plugin)
  return package.loaded['token.groups.plugins.' .. plugin] ~= nil
end

local function read_text(path)
  local file = assert(io.open(root .. '/' .. path, 'rb'))
  local content = assert(file:read('*a'))
  assert(file:close())
  return content
end

local function sorted_keys(value)
  local keys = vim.tbl_keys(value)
  table.sort(keys)
  return keys
end

-- Generated schemas and visible shell roles stay aligned with their supported tools.
local generated_json = { 'contrib/vscode/package.json' }
for _, appearance in ipairs(require('token.appearance').all()) do
  local obsidian_prefix = appearance.name == 'token' and 'contrib/obsidian/'
    or 'contrib/obsidian/' .. appearance.slug .. '/'
  generated_json[#generated_json + 1] = obsidian_prefix .. 'manifest.json'
  generated_json[#generated_json + 1] = 'contrib/windows-terminal/' .. appearance.slug .. '.json'

  local obsidian_css = read_text(obsidian_prefix .. 'theme.css')
  local hsl_values = 0
  for property, value in obsidian_css:gmatch('(%-%-accent%-%a): ([^;]+);') do
    hsl_values = hsl_values + 1
    local number = value:gsub('%%$', '')
    truthy(not number:match('%.%d*0$'), 'padded Obsidian HSL value for ' .. property .. ': ' .. value)
  end
  equal(hsl_values, 6, 'Obsidian HSL property count for ' .. appearance.name)
end
for _, path in ipairs(generated_json) do
  truthy(vim.json.decode(read_text(path)), 'invalid generated JSON: ' .. path)
end
for _, appearance in ipairs(require('token.appearance').all()) do
  for _, variant in ipairs({ 'dark', 'light' }) do
    for _, path in ipairs({
      'contrib/carapace/' .. appearance.slug .. '-' .. variant .. '.json',
      'contrib/vscode/themes/' .. appearance.slug .. '-' .. variant .. '-color-theme.json',
    }) do
      truthy(vim.json.decode(read_text(path)), 'invalid generated JSON: ' .. path)
    end

    local share = read_text('contrib/chatgpt/' .. appearance.slug .. '-' .. variant .. '.txt')
    local payload = share:match('^codex%-theme%-v1:(.+)%s*$')
    truthy(
      payload and vim.json.decode(payload),
      'invalid ChatGPT share payload for ' .. appearance.name .. ' ' .. variant
    )

    local sublime = read_text('contrib/sublime/' .. appearance.slug .. '-' .. variant .. '.sublime-color-scheme')
    sublime = sublime:gsub('^//[^\n]*\n', '', 1)
    truthy(vim.json.decode(sublime), 'invalid Sublime scheme for ' .. appearance.name .. ' ' .. variant)
  end
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local theme = vim.json.decode(read_text('contrib/vscode/themes/token-flint-' .. variant .. '-color-theme.json'))
  local accent = require('token.palettes.flint')(variant).accent
  for _, token_type in ipairs({ 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      equal(
        theme.semanticTokenColors[token_type .. '.' .. modifier],
        { foreground = accent, bold = true, italic = false },
        'Flint VS Code semantic type role for ' .. token_type .. '.' .. modifier .. ' ' .. variant
      )
    end
  end
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local theme = vim.json.decode(read_text('contrib/vscode/themes/token-temper-' .. variant .. '-color-theme.json'))
  local palette = require('token.palettes.temper')(variant)
  equal(
    theme.semanticTokenColors.type,
    { foreground = palette.fg1, italic = true },
    'Temper VS Code semantic type reference ' .. variant
  )
  equal(
    theme.semanticTokenColors.string,
    { foreground = palette.accent, italic = true },
    'Temper VS Code semantic literal ' .. variant
  )
  equal(theme.semanticTokenColors.keyword, palette.accent2, 'Temper VS Code semantic keyword ' .. variant)
  for _, token_type in ipairs({ 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter', 'function', 'method' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      equal(
        theme.semanticTokenColors[token_type .. '.' .. modifier],
        { foreground = palette.accent, bold = true, italic = false },
        'Temper VS Code semantic definition for ' .. token_type .. '.' .. modifier .. ' ' .. variant
      )
    end
  end
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local theme = vim.json.decode(read_text('contrib/vscode/themes/token-ultra-' .. variant .. '-color-theme.json'))
  local palette = require('token.palettes.ultra')(variant)
  equal(
    theme.semanticTokenColors.type,
    { foreground = palette.fg1, italic = true },
    'Ultra VS Code semantic type reference ' .. variant
  )
  equal(theme.semanticTokenColors.string, palette.orange, 'Ultra VS Code semantic literal ' .. variant)
  equal(theme.semanticTokenColors.keyword, palette.accent2, 'Ultra VS Code semantic keyword ' .. variant)
  equal(theme.semanticTokenColors['*.readonly'], { foreground = palette.orange }, 'Ultra VS Code readonly ' .. variant)
  for _, token_type in ipairs({ 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter', 'function', 'method' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      equal(
        theme.semanticTokenColors[token_type .. '.' .. modifier],
        { foreground = palette.accent, bold = true, italic = false },
        'Ultra VS Code semantic definition for ' .. token_type .. '.' .. modifier .. ' ' .. variant
      )
    end
  end
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local theme = vim.json.decode(read_text('contrib/vscode/themes/token-meridian-' .. variant .. '-color-theme.json'))
  local palette = require('token.palettes.meridian')(variant)
  local roles = require('token.appearance').roles('token-meridian', palette, variant == 'dark')
  equal(theme.semanticTokenColors.type.foreground, roles.syntax.type.fg, 'Meridian VS Code type color ' .. variant)
  equal(
    theme.semanticTokenColors.keyword.foreground,
    roles.syntax.control.fg,
    'Meridian VS Code keyword color ' .. variant
  )
  truthy(theme.semanticTokenColors.keyword.bold, 'Meridian VS Code keyword weight ' .. variant)
  equal(theme.semanticTokenColors.string, roles.syntax.literal.fg, 'Meridian VS Code string color ' .. variant)
  equal(theme.semanticTokenColors.number, roles.syntax.number.fg, 'Meridian VS Code number color ' .. variant)
  equal(theme.semanticTokenColors.type.italic, nil, 'Meridian VS Code type italic ' .. variant)
  equal(theme.semanticTokenColors['function.definition'].bold, nil, 'Meridian VS Code definition weight ' .. variant)
  equal(
    theme.semanticTokenColors['function.definition'].italic,
    false,
    'Meridian VS Code definition italic ' .. variant
  )
  equal(
    theme.semanticTokenColors['property.readonly'],
    roles.syntax.property.fg,
    'Meridian VS Code property color ' .. variant
  )
end

for _, appearance in ipairs(require('token.appearance').all()) do
  local git_config = vim
    .system({ 'git', 'config', '--file', root .. '/contrib/delta/' .. appearance.slug .. '.gitconfig', '--list' }, {
      text = true,
    })
    :wait()
  equal(git_config.code, 0, 'invalid delta Git config: ' .. (git_config.stderr or ''))
end
local installer_syntax = vim
  .system({ 'bash', '-n', root .. '/scripts/install_vscode_theme.sh' }, { text = true })
  :wait()
equal(installer_syntax.code, 0, 'invalid VS Code installer syntax: ' .. (installer_syntax.stderr or ''))

local carapace_keys = {
  'Description',
  'Error',
  'FlagArg',
  'FlagMultiArg',
  'FlagNoArg',
  'FlagOptArg',
  'Highlight1',
  'Highlight10',
  'Highlight11',
  'Highlight12',
  'Highlight2',
  'Highlight3',
  'Highlight4',
  'Highlight5',
  'Highlight6',
  'Highlight7',
  'Highlight8',
  'Highlight9',
  'KeywordAmbiguous',
  'KeywordNegative',
  'KeywordPositive',
  'KeywordUnknown',
  'LogLevelCritical',
  'LogLevelDebug',
  'LogLevelError',
  'LogLevelFatal',
  'LogLevelInfo',
  'LogLevelTrace',
  'LogLevelWarning',
  'Usage',
  'Value',
}
table.sort(carapace_keys)
for _, appearance in ipairs(require('token.appearance').all()) do
  for _, variant in ipairs({ 'dark', 'light' }) do
    local decoded = vim.json.decode(read_text('contrib/carapace/' .. appearance.slug .. '-' .. variant .. '.json'))
    equal(
      sorted_keys(decoded.carapace),
      carapace_keys,
      'Carapace schema drift for ' .. appearance.name .. ' ' .. variant
    )
  end
end

local function fish_sections(content)
  local sections = {}
  local current
  for line in content:gmatch('[^\r\n]+') do
    local section = line:match('^%[([^]]+)%]$')
    if section then
      current = {}
      sections[section] = current
    elseif current then
      local key, value = line:match('^(fish_%S+)%s+(.+)$')
      if key then
        current[key] = value
      end
    end
  end
  return sections
end

for _, appearance in ipairs(require('token.appearance').all()) do
  local fish = fish_sections(read_text('contrib/fish/' .. appearance.slug .. '.theme'))
  local palette_fn = require(appearance.palette)
  for _, variant in ipairs({ 'dark', 'light', 'unknown' }) do
    local palette_variant = variant == 'unknown' and 'dark' or variant
    local palette = palette_fn(palette_variant)
    equal(fish[variant].fish_color_cwd_root, palette.red:sub(2), 'Fish root cwd color for ' .. appearance.name)
    equal(fish[variant].fish_color_status, palette.red:sub(2), 'Fish status color for ' .. appearance.name)
    equal(fish[variant].fish_color_history_current, palette.accent:sub(2), 'Fish history color for ' .. appearance.name)
  end

  for _, variant in ipairs({ 'dark', 'light' }) do
    local palette = palette_fn(variant)
    local zsh = read_text('contrib/zsh/' .. appearance.slug .. '-' .. variant .. '.zsh')
    local styles = {
      ['exec-descriptor'] = 'fg=#' .. palette.accent2:sub(2),
      ['subtle-bg'] = 'bg=#' .. palette.match:sub(2),
      ['optarg-string'] = 'fg=#' .. palette.green:sub(2),
      ['optarg-number'] = 'fg=#' .. palette.purple:sub(2),
      ['recursive-base'] = 'none',
    }
    for name, style in pairs(styles) do
      local assignment = 'FAST_HIGHLIGHT_STYLES[' .. name .. "]='" .. style .. "'"
      truthy(zsh:find(assignment, 1, true), 'missing Zsh style ' .. name .. ' for ' .. appearance.name)
    end
  end
end

local vscode_package = vim.json.decode(read_text('contrib/vscode/package.json'))
equal(#vscode_package.contributes.themes, 10, 'VS Code package does not inventory ten themes')
equal(vscode_package.contributes.themes[3].label, 'Token Flint Dark', 'VS Code Flint dark label')
equal(vscode_package.contributes.themes[4].label, 'Token Flint Light', 'VS Code Flint light label')
equal(vscode_package.contributes.themes[5].label, 'Token Temper Dark', 'VS Code Temper dark label')
equal(vscode_package.contributes.themes[6].label, 'Token Temper Light', 'VS Code Temper light label')
equal(vscode_package.contributes.themes[7].label, 'Token Ultra Dark', 'VS Code Ultra dark label')
equal(vscode_package.contributes.themes[8].label, 'Token Ultra Light', 'VS Code Ultra light label')
equal(vscode_package.contributes.themes[9].label, 'Token Meridian Dark', 'VS Code Meridian dark label')
equal(vscode_package.contributes.themes[10].label, 'Token Meridian Light', 'VS Code Meridian light label')
local vscode_flint = vim.json.decode(read_text('contrib/vscode/themes/token-flint-dark-color-theme.json'))
local vscode_rules = {}
for _, rule in ipairs(vscode_flint.tokenColors) do
  vscode_rules[rule.name] = rule.settings
end
equal(vscode_rules['Function definition'].fontStyle, 'bold', 'VS Code Flint definition typography')
equal(vscode_rules['Function call'].fontStyle, nil, 'VS Code Flint call typography')
equal(vscode_rules['Type reference'].fontStyle, 'italic', 'VS Code Flint reference typography')
equal(
  vim.json.decode(read_text('contrib/obsidian/token-flint/manifest.json')).name,
  'Token Flint',
  'Obsidian Flint name'
)
local windows_flint = vim.json.decode(read_text('contrib/windows-terminal/token-flint.json')).schemes
equal(windows_flint[1].name, 'Token Flint Dark', 'Windows Terminal Flint dark name')
equal(windows_flint[2].name, 'Token Flint Light', 'Windows Terminal Flint light name')
local emacs_flint = read_text('contrib/emacs/token-flint-dark-theme.el')
truthy(
  emacs_flint:find('font-lock-function-name-face      ((,class (:foreground ,accent :weight bold)))', 1, true),
  'Emacs Flint definition typography'
)
truthy(
  emacs_flint:find('font-lock-function-call-face      ((,class (:foreground ,accent)))', 1, true),
  'Emacs Flint call typography'
)
local temper_dark = require('token.palettes.temper')('dark')
local vscode_temper = vim.json.decode(read_text('contrib/vscode/themes/token-temper-dark-color-theme.json'))
local temper_rules = {}
for _, rule in ipairs(vscode_temper.tokenColors) do
  temper_rules[rule.name] = rule.settings
end
equal(temper_rules['Function definition'].fontStyle, 'bold', 'VS Code Temper definition typography')
equal(temper_rules['Function call'].fontStyle, nil, 'VS Code Temper call typography')
equal(temper_rules['String'].fontStyle, 'italic', 'VS Code Temper literal typography')
equal(temper_rules['String'].foreground, temper_dark.accent, 'VS Code Temper literal color')
equal(temper_rules['Type reference'].fontStyle, 'italic', 'VS Code Temper reference typography')
equal(temper_rules['Type reference'].foreground, temper_dark.fg1, 'VS Code Temper type reference color')
equal(temper_rules.Exception.foreground, temper_dark.accent2, 'VS Code Temper exception color')
equal(
  vim.json.decode(read_text('contrib/obsidian/token-temper/manifest.json')).name,
  'Token Temper',
  'Obsidian Temper name'
)
local windows_temper = vim.json.decode(read_text('contrib/windows-terminal/token-temper.json')).schemes
equal(windows_temper[1].name, 'Token Temper Dark', 'Windows Terminal Temper dark name')
equal(windows_temper[2].name, 'Token Temper Light', 'Windows Terminal Temper light name')
local emacs_temper = read_text('contrib/emacs/token-temper-dark-theme.el')
truthy(
  emacs_temper:find('font-lock-function-name-face      ((,class (:foreground ,accent :weight bold)))', 1, true),
  'Emacs Temper definition typography'
)
truthy(
  emacs_temper:find('font-lock-function-call-face      ((,class (:foreground ,accent)))', 1, true),
  'Emacs Temper call typography'
)
truthy(
  emacs_temper:find('font-lock-type-face               ((,class (:foreground ,fg1 :slant italic)))', 1, true),
  'Emacs Temper type grammar'
)
truthy(
  emacs_temper:find('font-lock-string-face             ((,class (:foreground ,accent :slant italic)))', 1, true),
  'Emacs Temper literal grammar'
)
local ultra_dark = require('token.palettes.ultra')('dark')
local vscode_ultra = vim.json.decode(read_text('contrib/vscode/themes/token-ultra-dark-color-theme.json'))
local ultra_rules = {}
for _, rule in ipairs(vscode_ultra.tokenColors) do
  ultra_rules[rule.name] = rule.settings
end
equal(ultra_rules['Function definition'].fontStyle, 'bold', 'VS Code Ultra definition typography')
equal(ultra_rules['Function call'].fontStyle, nil, 'VS Code Ultra call typography')
equal(ultra_rules.String.fontStyle, nil, 'VS Code Ultra literal typography')
equal(ultra_rules.String.foreground, ultra_dark.orange, 'VS Code Ultra literal color')
equal(ultra_rules['Type reference'].fontStyle, 'italic', 'VS Code Ultra reference typography')
equal(ultra_rules['Type reference'].foreground, ultra_dark.fg1, 'VS Code Ultra type reference color')
equal(ultra_rules.Exception.foreground, ultra_dark.accent2, 'VS Code Ultra exception color')
equal(
  vim.json.decode(read_text('contrib/obsidian/token-ultra/manifest.json')).name,
  'Token Ultra',
  'Obsidian Ultra name'
)
local obsidian_ultra = read_text('contrib/obsidian/token-ultra/theme.css')
truthy(obsidian_ultra:find('%-%-code%-string: #72a59e;', 1, false), 'Obsidian Ultra literal grammar')
truthy(obsidian_ultra:find('%-%-h3%-color: #829db2;', 1, false), 'Obsidian Ultra heading cycle')
local windows_ultra = vim.json.decode(read_text('contrib/windows-terminal/token-ultra.json')).schemes
equal(windows_ultra[1].name, 'Token Ultra Dark', 'Windows Terminal Ultra dark name')
equal(windows_ultra[2].name, 'Token Ultra Light', 'Windows Terminal Ultra light name')
local emacs_ultra = read_text('contrib/emacs/token-ultra-dark-theme.el')
truthy(
  emacs_ultra:find('font-lock-function-name-face      ((,class (:foreground ,accent :weight bold)))', 1, true),
  'Emacs Ultra definition typography'
)
truthy(
  emacs_ultra:find('font-lock-type-face               ((,class (:foreground ,fg1 :slant italic)))', 1, true),
  'Emacs Ultra type grammar'
)
truthy(
  emacs_ultra:find('font-lock-string-face             ((,class (:foreground ,orange)))', 1, true),
  'Emacs Ultra literal grammar'
)
truthy(
  emacs_ultra:find('markdown-url-face                 ((,class (:foreground ,blue :underline t)))', 1, true),
  'Emacs Ultra link role'
)
local gtk_ultra = read_text('contrib/gtksourceview/token-ultra-dark.xml')
truthy(gtk_ultra:find('name="def:string" foreground="#72a59e"', 1, true), 'GtkSourceView Ultra literal grammar')
truthy(
  gtk_ultra:find('name="def:function" foreground="#d98262" bold="true"', 1, true),
  'GtkSourceView Ultra definition grammar'
)
truthy(
  gtk_ultra:find('name="def:link-text" foreground="#829db2" underline="single"', 1, true),
  'GtkSourceView Ultra link role'
)

local meridian_dark = require('token.palettes.meridian')('dark')
local vscode_meridian = vim.json.decode(read_text('contrib/vscode/themes/token-meridian-dark-color-theme.json'))
local meridian_rules = {}
for _, rule in ipairs(vscode_meridian.tokenColors) do
  meridian_rules[rule.name] = rule.settings
end
equal(meridian_rules.Keyword.foreground, meridian_dark.blue, 'VS Code Meridian keyword color')
equal(meridian_rules.Keyword.fontStyle, 'bold', 'VS Code Meridian keyword typography')
equal(meridian_rules.String.foreground, meridian_dark.green, 'VS Code Meridian string color')
equal(meridian_rules.Number.foreground, meridian_dark.yellow, 'VS Code Meridian number color')
equal(meridian_rules.Property.foreground, meridian_dark.orange, 'VS Code Meridian property color')
equal(meridian_rules['Function definition'].fontStyle, nil, 'VS Code Meridian definition typography')
equal(meridian_rules['Type definition'].fontStyle, nil, 'VS Code Meridian type definition typography')
equal(meridian_rules['Type reference'].fontStyle, nil, 'VS Code Meridian type typography')
equal(meridian_rules['Built-in function'].fontStyle, nil, 'VS Code Meridian built-in typography')
equal(
  vim.json.decode(read_text('contrib/obsidian/token-meridian/manifest.json')).name,
  'Token Meridian',
  'Obsidian Meridian name'
)
local obsidian_meridian = read_text('contrib/obsidian/token-meridian/theme.css')
truthy(obsidian_meridian:find('%-%-background%-primary: #272724;', 1, false), 'Obsidian Meridian Ultra background')
truthy(obsidian_meridian:find('%-%-h3%-color: #ea9d49;', 1, false), 'Obsidian Meridian heading color')

local function xcode_rgba(hex, alpha)
  return string.format(
    '%.6f %.6f %.6f %g',
    tonumber(hex:sub(2, 3), 16) / 255,
    tonumber(hex:sub(4, 5), 16) / 255,
    tonumber(hex:sub(6, 7), 16) / 255,
    alpha or 1
  )
end

local function xcode_value(content, key)
  return content:match('<key>' .. key .. '</key>%s*<string>([^<]+)</string>')
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local palette = require('token.palettes.ultra')(variant)
  local xcode = read_text('contrib/xcode/token-ultra-' .. variant .. '.xccolortheme')
  equal(
    xcode_value(xcode, 'DVTMarkupTextInlineCodeColor'),
    xcode_rgba(palette.orange, 0.7),
    'Xcode Ultra inline-code role for ' .. variant
  )
  equal(
    xcode_value(xcode, 'DVTMarkupTextOtherHeadingColor'),
    xcode_rgba(palette.blue),
    'Xcode Ultra heading cycle for ' .. variant
  )
end

-- Generated output helpers reject path escapes and symlinks, and publish ordinary files correctly.
local gen_lib = require('gen_lib')

-- Apple Terminal stores every colour as an archived NSColor blob, so the base64
-- encoder is pinned to the RFC 4648 vectors before the profiles are read.
equal(gen_lib.base64(''), '', 'base64 of empty input')
equal(gen_lib.base64('f'), 'Zg==', 'base64 of one byte')
equal(gen_lib.base64('fo'), 'Zm8=', 'base64 of two bytes')
equal(gen_lib.base64('foo'), 'Zm9v', 'base64 of three bytes')
equal(gen_lib.base64('foob'), 'Zm9vYg==', 'base64 of four bytes')
equal(gen_lib.base64('fooba'), 'Zm9vYmE=', 'base64 of five bytes')
equal(gen_lib.base64('foobar'), 'Zm9vYmFy', 'base64 of six bytes')

local terminal_colors = require('token.terminal').colors
for _, appearance in ipairs(require('token.appearance').all()) do
  local palette_fn = require(appearance.palette)
  for _, variant in ipairs({ 'dark', 'light' }) do
    local palette = palette_fn(variant)
    local term = terminal_colors(palette, variant == 'dark', appearance.name)
    local name = appearance.slug .. '-' .. variant
    local profile = read_text('contrib/apple-terminal/' .. name .. '.terminal')
    truthy(profile:find('<string>' .. name .. '</string>', 1, true), 'Apple Terminal profile name for ' .. name)
    truthy(profile:find('<string>Window Settings</string>', 1, true), 'Apple Terminal profile type for ' .. name)
    truthy(
      profile:find('<key>CursorType</key>\n    <integer>1</integer>', 1, true),
      'Apple Terminal cursor for ' .. name
    )
    local colors = {
      BackgroundColor = palette.bg3,
      TextColor = palette.fg0,
      TextBoldColor = palette.fg0,
      CursorColor = palette.fg0,
      SelectionColor = palette.sel,
      ANSIBlackColor = term[0],
      ANSIRedColor = term[1],
      ANSIBrightWhiteColor = term[15],
    }
    for key, hex in pairs(colors) do
      local entry = '<key>' .. key .. '</key>\n    <data>' .. gen_lib.ns_color_archive(hex) .. '</data>'
      truthy(profile:find(entry, 1, true), 'Apple Terminal ' .. key .. ' for ' .. name)
    end
  end
end
equal(
  gen_lib.unexpected_paths(
    { 'contrib/expected', 'contrib/stale', 'contrib/emacs/README.md' },
    { 'contrib/expected' },
    { 'contrib/emacs/README.md' }
  ),
  { 'contrib/stale' },
  'unexpected generated output detection'
)

local temporary = vim.fn.tempname()
assert(vim.fn.mkdir(temporary, 'p') == 1)
local previous_cwd = vim.fn.getcwd()
local helper_ok, helper_error = xpcall(function()
  vim.fn.chdir(temporary)
  gen_lib.write_if_changed('nested/output', 'first', false)
  equal(gen_lib.read_file('nested/output'), 'first', 'atomic generated output content')
  equal(vim.uv.fs_stat('nested/output').mode % 512, tonumber('644', 8), 'generated output permissions')

  assert(vim.fn.mkdir('bin', 'p') == 1)
  local failing_chmod = assert(io.open('bin/chmod', 'wb'))
  assert(failing_chmod:write('#!/bin/sh\nexit 1\n'))
  assert(failing_chmod:close())
  truthy(vim.uv.fs_chmod('bin/chmod', tonumber('755', 8)), 'failed to prepare chmod failure fixture')
  local existing = assert(io.open('failure-output', 'wb'))
  assert(existing:write('original'))
  assert(existing:close())
  local original_path = vim.env.PATH
  vim.env.PATH = temporary .. '/bin:' .. original_path
  local failure_ok, failure_error = pcall(gen_lib.write_if_changed, 'failure-output', 'changed', false)
  vim.env.PATH = original_path
  equal(failure_ok, false, 'injected publication failure unexpectedly succeeded')
  truthy(tostring(failure_error):match('failed to set permissions'), 'unexpected publication failure')
  equal(gen_lib.read_file('failure-output'), 'original', 'publication failure replaced existing output')
  equal(#vim.fn.glob('.failure-output.tmp.*', false, true), 0, 'publication failure left a temporary file')

  local sentinel = assert(io.open('sentinel', 'wb'))
  assert(sentinel:write('preserved'))
  assert(sentinel:close())
  truthy(vim.uv.fs_symlink('sentinel', 'linked-output'), 'failed to create output symlink fixture')
  fails('refusing symlinked output path', function()
    gen_lib.write_if_changed('linked-output', 'changed', false)
  end)
  equal(gen_lib.read_file('sentinel'), 'preserved', 'output symlink referent changed')

  assert(vim.fn.mkdir('outside', 'p') == 1)
  truthy(vim.uv.fs_symlink('outside', 'linked-directory'), 'failed to create directory symlink fixture')
  fails('refusing symlinked output path', function()
    gen_lib.write_if_changed('linked-directory/output', 'changed', false)
  end)
  fails('safe relative path', function()
    gen_lib.write_if_changed('/tmp/token-output', 'changed', false)
  end)
end, debug.traceback)
vim.fn.chdir(previous_cwd)
equal(vim.fn.delete(temporary, 'rf'), 0, 'failed to remove generated-output fixtures')
if not helper_ok then
  error(helper_error, 0)
end

-- All appearances expose the same complete palette contract, with approved anchors and contrast.
local function luminance(hex)
  local channels = {}
  for _, index in ipairs({ 2, 4, 6 }) do
    local channel = tonumber(hex:sub(index, index + 1), 16) / 255
    channels[#channels + 1] = channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channels[1] + 0.7152 * channels[2] + 0.0722 * channels[3]
end

local function contrast(left, right)
  local a, b = luminance(left), luminance(right)
  if a < b then
    a, b = b, a
  end
  return (a + 0.05) / (b + 0.05)
end

local flint_anchors = {
  dark = {
    bg3 = '#272C33',
    bg1 = '#1C2127',
    bg5 = '#373E47',
    fg0 = '#DCE1E6',
    fg1 = '#C2C9D0',
    fg2 = '#929BA5',
    fg3 = '#626C77',
    accent = '#D58A6F',
    accent2 = '#C6A15A',
    green = '#94A477',
    blue = '#7FA2BA',
    red = '#D47A7F',
  },
  light = {
    bg3 = '#F5F7F8',
    bg1 = '#E7EBEF',
    bg5 = '#E0E5EA',
    fg0 = '#28313A',
    fg1 = '#3D4853',
    fg2 = '#65717D',
    fg3 = '#828E9A',
    accent = '#B64E2E',
    accent2 = '#946409',
    green = '#5A772B',
    blue = '#34779D',
    red = '#BE3E50',
  },
}
for _, background in ipairs({ 'dark', 'light' }) do
  local classic = require('token.palette')(background)
  local flint = require('token.palettes.flint')(background)
  equal(sorted_keys(flint), sorted_keys(classic), 'Flint palette keys for ' .. background)
  equal(vim.tbl_count(flint), 49, 'Flint palette key count for ' .. background)
  for key, color in pairs(flint) do
    truthy(color:match('^#%x%x%x%x%x%x$'), 'invalid Flint color ' .. key .. ' for ' .. background)
  end
  for key, color in pairs(flint_anchors[background]) do
    equal(flint[key], color, 'Flint anchor ' .. key .. ' for ' .. background)
  end
  for _, key in ipairs({ 'fg0', 'fg1', 'fg2', 'accent', 'accent2', 'green', 'blue', 'red' }) do
    truthy(contrast(flint[key], flint.bg3) >= 4.5, 'insufficient Flint contrast for ' .. key .. ' ' .. background)
  end
end

local temper_anchors = {
  dark = {
    bg3 = '#272C33',
    bg1 = '#1C2127',
    fg0 = '#DCE1E6',
    fg1 = '#C2C9D0',
    fg2 = '#929BA5',
    fg3 = '#626C77',
    accent = '#56BCAE',
    accent2 = '#B184D5',
  },
  light = {
    bg3 = '#F5F7F8',
    bg1 = '#E7EBEF',
    fg0 = '#28313A',
    fg1 = '#3D4853',
    fg2 = '#65717D',
    fg3 = '#828E9A',
    accent = '#007D72',
    accent2 = '#7845A7',
  },
}
for _, background in ipairs({ 'dark', 'light' }) do
  local classic = require('token.palette')(background)
  local temper = require('token.palettes.temper')(background)
  equal(sorted_keys(temper), sorted_keys(classic), 'Temper palette keys for ' .. background)
  for key, color in pairs(temper) do
    truthy(color:match('^#%x%x%x%x%x%x$'), 'invalid Temper color ' .. key .. ' for ' .. background)
  end
  for key, color in pairs(temper_anchors[background]) do
    equal(temper[key], color, 'Temper anchor ' .. key .. ' for ' .. background)
  end
  for _, key in ipairs({ 'fg0', 'fg1', 'fg2', 'accent', 'accent2' }) do
    truthy(contrast(temper[key], temper.bg3) >= 4.5, 'insufficient Temper contrast for ' .. key .. ' ' .. background)
  end
end

local ultra_anchors = {
  dark = {
    bg0 = '#181817',
    bg3 = '#272724',
    bg4 = '#30302c',
    fg0 = '#e7e2d9',
    fg2 = '#979189',
    fg3 = '#65615c',
    accent = '#d98262',
    accent2 = '#c79b5b',
    orange = '#72a59e',
    blue = '#829db2',
    red = '#cf7778',
    yellow = '#c7a35b',
    green = '#86a17a',
    sel = '#3c3b36',
    match = '#4d4231',
  },
  light = {
    bg0 = '#e7e3dc',
    bg3 = '#fbf9f4',
    bg4 = '#f0ede6',
    fg0 = '#292a24',
    fg2 = '#6d675f',
    fg3 = '#888177',
    accent = '#a44e31',
    accent2 = '#87601b',
    orange = '#2c706a',
    blue = '#536f88',
    red = '#aa4e55',
    yellow = '#835f10',
    green = '#4f714b',
    sel = '#dedbd3',
    match = '#eadab6',
  },
}
for _, background in ipairs({ 'dark', 'light' }) do
  local classic = require('token.palette')(background)
  local ultra = require('token.palettes.ultra')(background)
  equal(sorted_keys(ultra), sorted_keys(classic), 'Ultra palette keys for ' .. background)
  equal(vim.tbl_count(ultra), 49, 'Ultra palette key count for ' .. background)
  for key, color in pairs(ultra) do
    truthy(color:match('^#%x%x%x%x%x%x$'), 'invalid Ultra color ' .. key .. ' for ' .. background)
    if not ultra_anchors[background][key] then
      equal(color, classic[key], 'Ultra copied classic key ' .. key .. ' for ' .. background)
    end
  end
  for key, color in pairs(ultra_anchors[background]) do
    equal(ultra[key], color, 'Ultra anchor ' .. key .. ' for ' .. background)
  end
  for _, key in ipairs({ 'fg0', 'fg1', 'fg2', 'accent', 'accent2', 'orange', 'blue', 'red', 'yellow', 'green' }) do
    truthy(contrast(ultra[key], ultra.bg3) >= 4.5, 'insufficient Ultra contrast for ' .. key .. ' ' .. background)
  end
  truthy(
    contrast(ultra.fg3, ultra.bg3) < 4.5,
    'Ultra structural foreground is not intentionally subdued ' .. background
  )
end

local meridian_anchors = {
  dark = {
    fg0 = '#c9c0b1',
    fg1 = '#aba195',
    fg2 = '#a69c91',
    fg3 = '#91887d',
    accent = '#e89a49',
    blue = '#66abc6',
    green = '#8cbb62',
    yellow = '#d99148',
    purple = '#b991db',
    orange = '#de88a6',
    olive = '#d9a86e',
  },
  light = {
    fg0 = '#28323a',
    fg1 = '#46535f',
    fg2 = '#524b42',
    fg3 = '#43505c',
    accent = '#0048b3',
    blue = '#0048b3',
    green = '#005f2f',
    cyan = '#095b62',
    purple = '#7a1f7a',
    orange = '#4b1fa3',
    olive = '#843900',
  },
}
for _, background in ipairs({ 'dark', 'light' }) do
  local ultra = require('token.palettes.ultra')(background)
  local meridian = require('token.palettes.meridian')(background)
  equal(sorted_keys(meridian), sorted_keys(ultra), 'Meridian palette keys for ' .. background)
  equal(vim.tbl_count(meridian), 49, 'Meridian palette key count for ' .. background)
  for index = 0, 5 do
    local key = 'bg' .. index
    equal(meridian[key], ultra[key], 'Meridian preserved Ultra ' .. key .. ' for ' .. background)
  end
  for _, key in ipairs({
    'diff_add',
    'diff_del',
    'diff_add_inline',
    'diff_del_inline',
    'diff_add_strong',
    'diff_del_strong',
    'diff_change',
    'diff_text',
    'diag_error',
    'diag_warn',
    'diag_info',
    'diag_hint',
    'sel',
    'match',
    'indent',
    'indent_active',
    'line_nr',
  }) do
    equal(meridian[key], ultra[key], 'Meridian preserved Ultra state color ' .. key .. ' for ' .. background)
  end
  for key, color in pairs(meridian_anchors[background]) do
    equal(meridian[key], color, 'Meridian anchor ' .. key .. ' for ' .. background)
  end
  local roles = require('token.appearance').roles('token-meridian', meridian, background == 'dark')
  for _, color in ipairs({
    meridian.fg0,
    meridian.fg1,
    roles.syntax.comment.fg,
    roles.syntax.control.fg,
    roles.syntax.type.fg,
    roles.syntax.definition.fg,
    roles.syntax.property.fg,
    roles.syntax.literal.fg,
    roles.syntax.number.fg,
    roles.syntax.tag.fg,
  }) do
    truthy(contrast(color, meridian.bg3) >= 4.5, 'insufficient Meridian contrast for ' .. color .. ' ' .. background)
  end
  if background == 'dark' then
    truthy(contrast(meridian.fg3, meridian.bg3) < 4.5, 'Meridian structural foreground is not subdued')
  end
end

-- Every colorscheme entry point selects its appearance while background selects the variant.
token.setup()
for _, appearance in ipairs(require('token.appearance').all()) do
  local colorscheme = appearance.name
  for _, background in ipairs({ 'dark', 'light' }) do
    vim.o.background = background
    vim.cmd.colorscheme(colorscheme)
    equal(vim.g.colors_name, colorscheme, 'colors_name for ' .. colorscheme .. ' ' .. background)
    equal(
      hl('Normal').bg,
      tonumber(require('token.theme').palette(background, colorscheme).bg3:sub(2), 16),
      'Normal background for ' .. colorscheme .. ' ' .. background
    )
  end
end
fails('unknown internal colorscheme name', function()
  token.load('unknown')
end)

-- Active Markview configuration groups resolve for every appearance and variant.
local markview_links = {
  { 'MarkviewIcon3Fg', 'MarkviewPalette3Fg' },
  { 'MarkviewSpecial', 'Special' },
  { 'MarkviewComment', 'Comment' },
}
token.setup({ plugins = { markview = true } })
for _, appearance in ipairs(require('token.appearance').all()) do
  for _, background in ipairs({ 'dark', 'light' }) do
    load(background, appearance.name)
    for _, group in ipairs(markview_links) do
      equal(
        vim.api.nvim_get_hl(0, { name = group[1], link = true }).link,
        group[2],
        'Markview link for ' .. group[1] .. ' in ' .. appearance.name .. ' ' .. background
      )
      truthy(not vim.tbl_isempty(hl(group[1])), 'empty Markview group ' .. group[1])
    end
  end
end

-- Flint's default grammar uses typography to distinguish definitions, calls, references, and built-ins.
token.setup()
load('dark', 'token-flint')
local flint = require('token.palettes.flint')('dark')
truthy(hl('@function').bold, 'Flint function definition is not bold')
equal(hl('@function').fg, tonumber(flint.accent:sub(2), 16), 'Flint function definition color')
equal(hl('@function.call').bold, nil, 'Flint function call is bold')
equal(hl('@function.call').fg, tonumber(flint.accent:sub(2), 16), 'Flint function call color')
truthy(hl('@function.method').bold, 'Flint method definition is not bold')
equal(hl('@function.method.call').bold, nil, 'Flint method call is bold')
truthy(hl('@type').italic, 'Flint type reference is not italic')
equal(hl('@type').fg, tonumber(flint.fg1:sub(2), 16), 'Flint type reference color')
truthy(hl('@type.definition').bold, 'Flint type definition is not bold')
equal(hl('@type.definition').fg, tonumber(flint.accent:sub(2), 16), 'Flint type definition color')
truthy(hl('@function.builtin').italic, 'Flint built-in is not italic')
equal(hl('@function.builtin').fg, tonumber(flint.fg1:sub(2), 16), 'Flint built-in color')
equal(hl('@lsp.type.function').bold, nil, 'Flint LSP function reference is bold')
equal(hl('@lsp.type.function').fg, tonumber(flint.accent:sub(2), 16), 'Flint LSP function reference color')
truthy(hl('@lsp.type.type').italic, 'Flint LSP type reference is not italic')
equal(hl('@lsp.type.type').fg, tonumber(flint.fg1:sub(2), 16), 'Flint LSP type reference color')
truthy(hl('@lsp.typemod.function.definition').bold, 'Flint LSP function definition is not bold')
equal(
  hl('@lsp.typemod.function.definition').fg,
  tonumber(flint.accent:sub(2), 16),
  'Flint LSP function definition color'
)
equal(hl('@keyword').fg, tonumber(flint.accent2:sub(2), 16), 'Flint keyword color')
equal(hl('@string').fg, tonumber(flint.green:sub(2), 16), 'Flint literal color')
truthy(hl('@markup.link').underline, 'Flint link is not underlined')
equal(hl('@markup.link').fg, tonumber(flint.blue:sub(2), 16), 'Flint link color')
truthy(hl('@lsp.mod.deprecated').strikethrough, 'Flint deprecated modifier is not struck through')
truthy(hl('DiagnosticUnderlineError').undercurl, 'Flint diagnostic is not undercurled')

-- Temper uses teal and purple plus typography for routine syntax roles.
token.setup()
load('dark', 'token-temper')
local temper = require('token.palettes.temper')('dark')
truthy(hl('@function').bold, 'Temper function definition is not bold')
equal(hl('@function').fg, tonumber(temper.accent:sub(2), 16), 'Temper function definition color')
equal(hl('@function.call').bold, nil, 'Temper function call is bold')
equal(hl('@function.call').fg, tonumber(temper.accent:sub(2), 16), 'Temper function call color')
truthy(hl('@function.method').bold, 'Temper method definition is not bold')
equal(hl('@function.method.call').bold, nil, 'Temper method call is bold')
truthy(hl('@type').italic, 'Temper type reference is not italic')
equal(hl('@type').fg, tonumber(temper.fg1:sub(2), 16), 'Temper type reference color')
truthy(hl('@type.definition').bold, 'Temper type definition is not bold')
equal(hl('@type.definition').fg, tonumber(temper.accent:sub(2), 16), 'Temper type definition color')
truthy(hl('@function.builtin').italic, 'Temper built-in is not italic')
equal(hl('@function.builtin').fg, tonumber(temper.fg1:sub(2), 16), 'Temper built-in color')
truthy(hl('@lsp.type.type').italic, 'Temper LSP type reference is not italic')
equal(hl('@lsp.type.type').fg, tonumber(temper.fg1:sub(2), 16), 'Temper LSP type reference color')
for _, token_type in ipairs({ 'function', 'method', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
  for _, modifier in ipairs({ 'declaration', 'definition' }) do
    local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
    truthy(hl(name).bold, 'Temper LSP definition is not bold for ' .. name)
    equal(hl(name).fg, tonumber(temper.accent:sub(2), 16), 'Temper LSP definition color for ' .. name)
  end
end
for _, name in ipairs({ '@keyword', '@keyword.exception', '@keyword.debug', '@function.macro', '@keyword.directive' }) do
  equal(hl(name).fg, tonumber(temper.accent2:sub(2), 16), 'Temper purple role color for ' .. name)
end
for _, name in ipairs({ '@string', '@number', '@boolean', '@constant' }) do
  equal(hl(name).fg, tonumber(temper.accent:sub(2), 16), 'Temper literal color for ' .. name)
  truthy(hl(name).italic, 'Temper literal is not italic for ' .. name)
end
truthy(hl('@markup.link').underline, 'Temper link is not underlined')
equal(hl('@markup.link').fg, tonumber(temper.accent:sub(2), 16), 'Temper link color')
truthy(hl('@lsp.mod.deprecated').strikethrough, 'Temper deprecated modifier is not struck through')
truthy(hl('DiagnosticUnderlineError').undercurl, 'Temper diagnostic is not undercurled')

token.setup({ plugins = { markview = true, render_markdown = true } })
load('dark', 'token-temper')
equal(hl('RenderMarkdownH3').fg, tonumber(temper.fg1:sub(2), 16), 'Temper render-markdown headings are rainbowed')
equal(hl('MarkviewHeading3').fg, tonumber(temper.fg1:sub(2), 16), 'Temper Markview headings are rainbowed')

token.setup({ plugins = { markview = true, render_markdown = true } })
load('dark', 'token-flint')
equal(hl('RenderMarkdownH3').fg, tonumber(flint.fg1:sub(2), 16), 'Flint render-markdown headings are rainbowed')
equal(hl('MarkviewHeading3').fg, tonumber(flint.fg1:sub(2), 16), 'Flint Markview headings are rainbowed')

-- Ultra uses copper definitions, ochre control flow, teal data, and neutral typography.
token.setup()
load('dark', 'token-ultra')
local ultra = require('token.palettes.ultra')('dark')
truthy(hl('@function').bold, 'Ultra function definition is not bold')
equal(hl('@function').fg, tonumber(ultra.accent:sub(2), 16), 'Ultra function definition color')
equal(hl('@function.call').bold, nil, 'Ultra function call is bold')
equal(hl('@function.call').fg, tonumber(ultra.accent:sub(2), 16), 'Ultra function call color')
truthy(hl('@type').italic, 'Ultra type reference is not italic')
equal(hl('@type').fg, tonumber(ultra.fg1:sub(2), 16), 'Ultra type reference color')
truthy(hl('@type.definition').bold, 'Ultra type definition is not bold')
equal(hl('@type.definition').fg, tonumber(ultra.accent:sub(2), 16), 'Ultra type definition color')
truthy(hl('@function.builtin').italic, 'Ultra built-in is not italic')
equal(hl('@function.builtin').fg, tonumber(ultra.fg1:sub(2), 16), 'Ultra built-in color')
for _, name in ipairs({ '@module', '@constructor', '@attribute' }) do
  truthy(hl(name).italic, 'Ultra neutral reference is not italic for ' .. name)
  equal(hl(name).fg, tonumber(ultra.fg1:sub(2), 16), 'Ultra neutral reference color for ' .. name)
end
for _, token_type in ipairs({ 'function', 'method', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
  for _, modifier in ipairs({ 'declaration', 'definition' }) do
    local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
    truthy(hl(name).bold, 'Ultra LSP definition is not bold for ' .. name)
    equal(hl(name).fg, tonumber(ultra.accent:sub(2), 16), 'Ultra LSP definition color for ' .. name)
  end
end
for _, name in ipairs({
  '@keyword',
  '@keyword.exception',
  '@keyword.debug',
  '@keyword.import',
  '@function.macro',
  '@keyword.directive',
}) do
  equal(hl(name).fg, tonumber(ultra.accent2:sub(2), 16), 'Ultra control role color for ' .. name)
end
for _, name in ipairs({ '@string', '@number', '@boolean', '@constant', '@markup.raw', '@lsp.mod.readonly' }) do
  equal(hl(name).fg, tonumber(ultra.orange:sub(2), 16), 'Ultra literal color for ' .. name)
  equal(hl(name).italic, nil, 'Ultra literal is italic for ' .. name)
end
truthy(hl('Comment').italic, 'Ultra comment is not italic')
equal(hl('Comment').fg, tonumber(ultra.fg2:sub(2), 16), 'Ultra comment color')
truthy(hl('@markup.link').underline, 'Ultra link is not underlined')
equal(hl('@markup.link').fg, tonumber(ultra.blue:sub(2), 16), 'Ultra link color')
equal(hl('@keyword.exception').fg, tonumber(ultra.accent2:sub(2), 16), 'Ultra exception borrowed diagnostic red')
equal(hl('DiagnosticError').fg, tonumber(ultra.red:sub(2), 16), 'Ultra diagnostic error color')
truthy(hl('DiagnosticUnderlineError').undercurl, 'Ultra diagnostic is not undercurled')
truthy(hl('@lsp.mod.deprecated').strikethrough, 'Ultra deprecated modifier is not struck through')

token.setup({ plugins = { markview = true, render_markdown = true } })
load('dark', 'token-ultra')
equal(hl('RenderMarkdownH3').fg, tonumber(ultra.blue:sub(2), 16), 'Ultra render-markdown heading cycle')
equal(hl('MarkviewHeading3').fg, tonumber(ultra.blue:sub(2), 16), 'Ultra Markview heading cycle')

-- Meridian uses Circadia grammar and heading colors on Ultra surfaces.
token.setup({ plugins = { markview = true, render_markdown = true } })
load('dark', 'token-meridian')
local meridian = require('token.palettes.meridian')('dark')
truthy(hl('@keyword').bold, 'Meridian keyword is not bold')
equal(hl('@keyword').fg, tonumber(meridian.blue:sub(2), 16), 'Meridian keyword color')
equal(hl('@function').fg, tonumber(meridian.purple:sub(2), 16), 'Meridian function color')
equal(hl('@type').fg, tonumber(meridian.olive:sub(2), 16), 'Meridian type color')
equal(hl('@property').fg, tonumber(meridian.orange:sub(2), 16), 'Meridian property color')
equal(hl('@string').fg, tonumber(meridian.green:sub(2), 16), 'Meridian string color')
equal(hl('@number').fg, tonumber(meridian.yellow:sub(2), 16), 'Meridian number color')
equal(hl('@tag').fg, tonumber(meridian.blue:sub(2), 16), 'Meridian tag color')
truthy(hl('Comment').italic, 'Meridian comment is not italic')
equal(hl('Comment').fg, tonumber(meridian.fg2:sub(2), 16), 'Meridian comment color')
equal(hl('RenderMarkdownH3').fg, tonumber('ea9d49', 16), 'Meridian render-markdown heading color')
equal(hl('MarkviewHeading3').fg, tonumber('ea9d49', 16), 'Meridian Markview heading color')

local flint_styles = {
  functions = { bold = false, underline = true },
  types = { bold = false, underline = true },
}
token.setup({ styles = flint_styles })
for _, background in ipairs({ 'dark', 'light' }) do
  load(background, 'token-flint')
  equal(hl('@function').bold, nil, 'user style did not remove Flint definition weight ' .. background)
  truthy(hl('@function').underline, 'user style did not augment Flint definition ' .. background)
  truthy(hl('@lsp.type.function').underline, 'user style did not reach Flint LSP function references ' .. background)
  for _, token_type in ipairs({ 'function', 'method' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
      equal(hl(name).bold, nil, 'user style did not remove Flint LSP function weight for ' .. name .. ' ' .. background)
      truthy(hl(name).underline, 'user style did not reach Flint LSP function role ' .. name .. ' ' .. background)
    end
  end
  for _, token_type in ipairs({ 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
      equal(hl(name).bold, nil, 'user style did not remove Flint LSP type weight for ' .. name .. ' ' .. background)
      truthy(hl(name).underline, 'user style did not reach Flint LSP type role ' .. name .. ' ' .. background)
    end
  end
end
for _, background in ipairs({ 'dark', 'light' }) do
  load(background, 'token-temper')
  equal(hl('@function').bold, nil, 'user style did not remove Temper definition weight ' .. background)
  truthy(hl('@function').underline, 'user style did not augment Temper definition ' .. background)
  truthy(hl('@lsp.type.function').underline, 'user style did not reach Temper LSP function references ' .. background)
  for _, token_type in ipairs({ 'function', 'method', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
      equal(
        hl(name).bold,
        nil,
        'user style did not remove Temper LSP definition weight for ' .. name .. ' ' .. background
      )
      truthy(hl(name).underline, 'user style did not reach Temper LSP definition role ' .. name .. ' ' .. background)
    end
  end
end
for _, background in ipairs({ 'dark', 'light' }) do
  load(background, 'token-ultra')
  equal(hl('@function').bold, nil, 'user style did not remove Ultra definition weight ' .. background)
  truthy(hl('@function').underline, 'user style did not augment Ultra definition ' .. background)
  truthy(hl('@lsp.type.function').underline, 'user style did not reach Ultra LSP function references ' .. background)
  for _, token_type in ipairs({ 'function', 'method', 'type', 'class', 'enum', 'interface', 'struct', 'typeParameter' }) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      local name = '@lsp.typemod.' .. token_type .. '.' .. modifier
      equal(
        hl(name).bold,
        nil,
        'user style did not remove Ultra LSP definition weight for ' .. name .. ' ' .. background
      )
      truthy(hl(name).underline, 'user style did not reach Ultra LSP definition role ' .. name .. ' ' .. background)
    end
  end
end

-- Shared user customization follows the appearance overlay and receives the active colorscheme.
local callback_colorscheme
token.setup({
  styles = { functions = { underline = true } },
  highlights = { all = { ['@function'] = { fg = '#112233' } } },
  on_colors = function(_, _, colorscheme)
    callback_colorscheme = 'colors:' .. colorscheme
  end,
  on_highlights = function(groups, _, _, colorscheme)
    callback_colorscheme = callback_colorscheme .. ',highlights:' .. colorscheme
    groups.TokenAppearanceCallback = { bold = true }
  end,
})
load('dark', 'token-flint')
equal(callback_colorscheme, 'colors:token-flint,highlights:token-flint', 'callback colorscheme arguments')
equal(hl('@function').fg, tonumber('112233', 16), 'user highlight did not replace Flint profile')
equal(hl('@function').bold, nil, 'user highlight did not completely replace Flint profile')
truthy(hl('TokenAppearanceCallback').bold, 'Flint callback highlight missing')

token.setup({
  colors = { all = { accent = '#445566' } },
  highlights = { all = { ['@function'] = { fg = '#112233' } } },
  on_colors = function(colors, _, colorscheme)
    callback_colorscheme = 'colors:' .. colorscheme
    colors.accent2 = '#665544'
  end,
  on_highlights = function(groups, colors, _, colorscheme)
    callback_colorscheme = callback_colorscheme .. ',highlights:' .. colorscheme
    groups.TokenAppearanceCallback = { fg = colors.accent2 }
  end,
})
load('dark', 'token-temper')
equal(callback_colorscheme, 'colors:token-temper,highlights:token-temper', 'Temper callback colorscheme arguments')
equal(hl('@function.call').fg, tonumber('445566', 16), 'user color did not override Temper profile')
equal(hl('@function').fg, tonumber('112233', 16), 'user highlight did not replace Temper profile')
equal(hl('@function').bold, nil, 'user highlight did not completely replace Temper profile')
equal(hl('TokenAppearanceCallback').fg, tonumber('665544', 16), 'Temper callback highlight missing')

token.setup({
  colors = { all = { accent = '#445566' } },
  highlights = { all = { ['@function'] = { fg = '#112233' } } },
  on_colors = function(colors, _, colorscheme)
    callback_colorscheme = 'colors:' .. colorscheme
    colors.orange = '#337766'
  end,
  on_highlights = function(groups, colors, _, colorscheme)
    callback_colorscheme = callback_colorscheme .. ',highlights:' .. colorscheme
    groups.TokenAppearanceCallback = { fg = colors.orange }
  end,
})
load('dark', 'token-ultra')
equal(callback_colorscheme, 'colors:token-ultra,highlights:token-ultra', 'Ultra callback colorscheme arguments')
equal(hl('@function.call').fg, tonumber('445566', 16), 'user color did not override Ultra definition role')
equal(hl('@string').fg, tonumber('337766', 16), 'on_colors did not update Ultra literal role')
equal(hl('@function').fg, tonumber('112233', 16), 'user highlight did not replace Ultra profile')
equal(hl('@function').bold, nil, 'user highlight did not completely replace Ultra profile')
equal(hl('TokenAppearanceCallback').fg, tonumber('337766', 16), 'Ultra callback highlight missing')

-- Defaults are core-only.
token.setup()
load()
equal(loaded('gitsigns'), false, 'gitsigns loaded by default')
equal(loaded('snacks'), false, 'snacks loaded by default')
equal(loaded('telescope'), false, 'telescope loaded by default')

-- Individual selection, all, explicit exclusion, and shrinking reloads.
token.setup({ plugins = { telescope = true } })
load()
truthy(loaded('telescope'), 'telescope opt-in missing')
equal(loaded('gitsigns'), false, 'unselected gitsigns integration loaded')
token.setup({ plugins = { all = true, telescope = false } })
load()
truthy(loaded('blink'), 'plugins.all did not load blink')
equal(loaded('telescope'), false, 'explicit exclusion lost')
token.setup({ plugins = { gitsigns = false, snacks = false } })
load()
equal(loaded('blink'), false, 'larger-to-smaller reload retained blink')
equal(loaded('gitsigns'), false, 'explicit default exclusion lost')

fails('unknown top%-level option', function()
  token.setup({ typo = true })
end)
fails('unknown style option', function()
  token.setup({ styles = { magic = {} } })
end)
fails('unknown plugin option', function()
  token.setup({ plugins = { gitigns = true } })
end)
fails('must be a boolean', function()
  token.setup({ transparent = 'yes' })
end)
fails('setup options must be a table', function()
  token.setup(false)
end)
fails('#RRGGBB', function()
  token.setup({ colors = { dark = { fg0 = 'red' } } })
  load()
end)
fails('palette color 1 must be a #RRGGBB value', function()
  token.setup({ colors = { all = { [1] = '#abcdef' } } })
end)

-- Variant precedence, callback order, complete highlight replacement, and reset semantics.
local order = {}
token.setup({
  colors = { all = { accent = '#111111' }, dark = { accent = '#222222' }, light = { accent = '#333333' } },
  highlights = { all = { TokenTest = { fg = '#444444', bold = true } }, dark = { TokenTest = { fg = '#555555' } } },
  on_colors = function(colors, background)
    order[#order + 1] = 'colors:' .. background .. ':' .. colors.accent
    colors.accent = '#666666'
  end,
  on_highlights = function(groups, colors, background)
    order[#order + 1] = 'highlights:' .. background .. ':' .. colors.accent
    groups.TokenCallback = { fg = colors.accent, italic = true }
  end,
})
load('dark')
equal(order, { 'colors:dark:#222222', 'highlights:dark:#666666' }, 'callback order')
equal(hl('TokenTest').bold, nil, 'variant highlight did not completely replace all highlight')
equal(hl('TokenCallback').fg, tonumber('666666', 16), 'callback highlight color')
token.setup()
equal(require('token.config').get().colors.all.accent, nil, 'setup did not reset defaults')

-- All semantic categories accept attributes; specific categories win overlap.
local styles = {}
for _, name in ipairs({
  'booleans',
  'comments',
  'conditionals',
  'constants',
  'functions',
  'keywords',
  'loops',
  'numbers',
  'operators',
  'preprocessor',
  'properties',
  'strings',
  'types',
  'variables',
}) do
  styles[name] = { underline = true }
end
styles.keywords = { italic = true, underline = true }
styles.conditionals = { italic = false, bold = true, underline = true }
styles.constants = { italic = true, underline = true }
styles.booleans = { italic = false, bold = true, underline = true }
styles.variables = { italic = true, underline = true }
styles.properties = { italic = false, bold = true, underline = true }
token.setup({ styles = styles })
load()
for _, name in ipairs({
  'Boolean',
  'Comment',
  'Conditional',
  'Constant',
  'Function',
  'Repeat',
  'Number',
  'Operator',
  'PreProc',
  '@property',
  'String',
  'Type',
  '@variable',
}) do
  truthy(hl(name).underline, 'semantic style missing for ' .. name)
end
for _, name in ipairs({
  '@comment.error',
  '@comment.todo',
  '@string.documentation',
  '@string.regexp',
  '@string.special.url',
  '@function.macro',
  '@keyword.coroutine',
  '@keyword.modifier',
  '@constructor',
}) do
  truthy(hl(name).underline, 'specialized semantic style missing for ' .. name)
end
truthy(hl('Conditional').bold and not hl('Conditional').italic, 'conditional precedence')
truthy(hl('@keyword.conditional').bold and not hl('@keyword.conditional').italic, 'capture conditional precedence')
truthy(hl('Boolean').bold and not hl('Boolean').italic, 'boolean precedence')
truthy(hl('@constant.builtin').bold and not hl('@constant.builtin').italic, 'capture boolean precedence')
truthy(hl('@property').bold and not hl('@property').italic, 'property precedence')

-- Absolute gates apply after user callbacks.
token.setup({
  attributes = { bold = false, italic = false, underline = false, undercurl = false, strikethrough = false },
  highlights = {
    all = {
      TokenGated = { bold = true, italic = true, underline = true, undercurl = true, strikethrough = true },
      TokenGatedLink = { link = 'Bold' },
      TokenCtermGated = { cterm = { bold = true } },
      TokenExternalLink = { link = 'UserDefinedTarget' },
    },
  },
  plugins = { markview = true },
})
load('dark', 'token-flint')
local gated = hl('TokenGated')
for _, attribute in ipairs({ 'bold', 'italic', 'underline', 'undercurl', 'strikethrough' }) do
  equal(gated[attribute], nil, 'attribute gate failed for ' .. attribute)
end
equal(hl('@function').bold, nil, 'bold gate did not remove Flint definition weight')
equal(hl('@type').italic, nil, 'italic gate did not remove Flint reference slant')
equal(hl('@markup.link').underline, nil, 'underline gate did not remove Flint link underline')
equal(hl('@lsp.mod.deprecated').strikethrough, nil, 'strikethrough gate did not remove Flint deprecation')
equal(hl('DiagnosticUnderlineError').undercurl, nil, 'undercurl gate did not remove Flint diagnostic')
load('dark', 'token-temper')
equal(hl('@function').bold, nil, 'bold gate did not remove Temper definition weight')
equal(hl('@type').italic, nil, 'italic gate did not remove Temper reference slant')
equal(hl('@string').italic, nil, 'italic gate did not remove Temper literal slant')
equal(hl('@markup.link').underline, nil, 'underline gate did not remove Temper link underline')
equal(hl('@lsp.mod.deprecated').strikethrough, nil, 'strikethrough gate did not remove Temper deprecation')
equal(hl('DiagnosticUnderlineError').undercurl, nil, 'undercurl gate did not remove Temper diagnostic')
load('dark', 'token-ultra')
equal(hl('@function').bold, nil, 'bold gate did not remove Ultra definition weight')
equal(hl('@type').italic, nil, 'italic gate did not remove Ultra reference slant')
equal(hl('@markup.link').underline, nil, 'underline gate did not remove Ultra link underline')
equal(hl('@lsp.mod.deprecated').strikethrough, nil, 'strikethrough gate did not remove Ultra deprecation')
equal(hl('DiagnosticUnderlineError').undercurl, nil, 'undercurl gate did not remove Ultra diagnostic')
equal(hl('TokenGatedLink').bold, nil, 'attribute gate did not resolve a user link')
equal(hl('TokenCtermGated').cterm, nil, 'attribute gate did not disable a cterm attribute')
equal(
  vim.api.nvim_get_hl(0, { name = 'TokenExternalLink', link = true }).link,
  'UserDefinedTarget',
  'attribute gate erased an external user link'
)
equal(
  vim.api.nvim_get_hl(0, { name = 'MarkviewHyperlink', link = true }).link,
  '@markup.link.label.markdown_inline',
  'attribute gate erased a Markview link'
)
equal(hl('MarkviewGradient10'), hl('MarkviewGradient9'), 'Markview gradient endpoint is missing')
equal(
  require('token.config').get().highlights.all.TokenCtermGated.cterm.bold,
  true,
  'final highlight transforms mutated stored overrides'
)

-- Dimming and transparency cover core/plugin inactive surfaces but preserve semantic backgrounds.
token.setup({ transparent = true, dim_inactive = true, plugins = { trouble = true } })
load()
equal(hl('Normal').bg, nil, 'Normal is not transparent')
equal(hl('NormalNC').bg, nil, 'NormalNC is not transparent')
equal(hl('NormalNC').fg, tonumber('d4cfc6', 16), 'NormalNC is not dimmed with fg1')
equal(hl('TroubleNormalNC').bg, nil, 'plugin NormalNC is not transparent')
truthy(hl('Visual').bg, 'Visual semantic background was cleared')
truthy(hl('DiffAdd').bg, 'Diff semantic background was cleared')
local lualine = require('lualine.themes.token')
equal(lualine.normal.b.bg, 'NONE', 'Lualine base is not transparent')
equal(lualine.inactive.a.bg, 'NONE', 'Lualine inactive section is not transparent')
equal(lualine.inactive.a.fg, require('token.theme').palette('dark').fg3, 'Lualine inactive text is not muted')
local flint_lualine = require('lualine.themes.token-flint')
equal(flint_lualine.normal.b.bg, 'NONE', 'Flint Lualine base is not transparent')
equal(
  flint_lualine.inactive.a.fg,
  require('token.theme').palette('dark', 'token-flint').fg3,
  'Flint Lualine inactive text is not muted'
)
local temper_lualine = require('lualine.themes.token-temper')
equal(temper_lualine.normal.b.bg, 'NONE', 'Temper Lualine base is not transparent')
equal(
  temper_lualine.inactive.a.fg,
  require('token.theme').palette('dark', 'token-temper').fg3,
  'Temper Lualine inactive text is not muted'
)
local ultra_lualine = require('lualine.themes.token-ultra')
local ultra_palette = require('token.theme').palette('dark', 'token-ultra')
equal(ultra_lualine.normal.b.bg, 'NONE', 'Ultra Lualine base is not transparent')
equal(ultra_lualine.normal.a.bg, ultra_palette.fg2, 'Ultra Lualine normal mode color')
equal(ultra_lualine.insert.a.bg, ultra_palette.green, 'Ultra Lualine insert mode color')
equal(ultra_lualine.visual.a.bg, ultra_palette.blue, 'Ultra Lualine visual mode color')
equal(ultra_lualine.replace.a.bg, ultra_palette.red, 'Ultra Lualine replace mode color')
equal(ultra_lualine.command.a.bg, ultra_palette.yellow, 'Ultra Lualine command mode color')
equal(ultra_lualine.terminal.a.bg, ultra_palette.cyan, 'Ultra Lualine terminal mode color')
equal(ultra_lualine.inactive.a.fg, ultra_palette.fg3, 'Ultra Lualine inactive text is not muted')

local ultra_terminal = require('token.terminal').colors(ultra_palette, true, 'token-ultra')
equal(ultra_terminal, {
  [0] = ultra_palette.bg1,
  [1] = ultra_palette.red,
  [2] = ultra_palette.green,
  [3] = ultra_palette.yellow,
  [4] = ultra_palette.blue,
  [5] = ultra_palette.purple,
  [6] = ultra_palette.cyan,
  [7] = ultra_palette.fg1,
  [8] = ultra_palette.fg3,
  [9] = ultra_palette.accent,
  [10] = ultra_palette.bright_green,
  [11] = ultra_palette.accent2,
  [12] = ultra_palette.bright_blue,
  [13] = ultra_palette.bright_purple,
  [14] = ultra_palette.bright_cyan,
  [15] = ultra_palette.fg0,
}, 'Ultra ANSI dark roles')
equal(
  require('token.terminal').colors(ultra_palette, true),
  ultra_terminal,
  'two-argument terminal compatibility changed'
)

load('light', 'token-ultra')
local ultra_light_lualine = require('lualine.themes.token-ultra')
local ultra_light_palette = require('token.theme').palette('light', 'token-ultra')
equal(ultra_light_lualine.normal.a.bg, ultra_light_palette.fg2, 'Ultra light Lualine normal mode color')
equal(ultra_light_lualine.insert.a.bg, ultra_light_palette.green, 'Ultra light Lualine insert mode color')
equal(ultra_light_lualine.visual.a.bg, ultra_light_palette.blue, 'Ultra light Lualine visual mode color')
equal(ultra_light_lualine.replace.a.bg, ultra_light_palette.red, 'Ultra light Lualine replace mode color')
equal(ultra_light_lualine.command.a.bg, ultra_light_palette.yellow, 'Ultra light Lualine command mode color')
equal(ultra_light_lualine.terminal.a.bg, ultra_light_palette.cyan, 'Ultra light Lualine terminal mode color')
equal(ultra_light_lualine.inactive.a.fg, ultra_light_palette.fg3, 'Ultra light Lualine inactive mode color')
equal(require('token.terminal').colors(ultra_light_palette, false, 'token-ultra'), {
  [0] = ultra_light_palette.fg0,
  [1] = ultra_light_palette.red,
  [2] = ultra_light_palette.green,
  [3] = ultra_light_palette.yellow,
  [4] = ultra_light_palette.blue,
  [5] = ultra_light_palette.purple,
  [6] = ultra_light_palette.cyan,
  [7] = ultra_light_palette.line_nr,
  [8] = ultra_light_palette.fg2,
  [9] = ultra_light_palette.accent,
  [10] = ultra_light_palette.bright_green,
  [11] = ultra_light_palette.accent2,
  [12] = ultra_light_palette.bright_blue,
  [13] = ultra_light_palette.bright_purple,
  [14] = ultra_light_palette.bright_cyan,
  [15] = ultra_light_palette.bg3,
}, 'Ultra ANSI light roles')

load('dark', 'token-meridian')
local meridian_lualine = require('lualine.themes.token-meridian')
local meridian_palette = require('token.theme').palette('dark', 'token-meridian')
equal(meridian_lualine.normal.a.bg, meridian_palette.fg2, 'Meridian Lualine normal mode color')
equal(meridian_lualine.insert.a.bg, meridian_palette.green, 'Meridian Lualine insert mode color')
equal(meridian_lualine.visual.a.bg, meridian_palette.blue, 'Meridian Lualine visual mode color')
equal(meridian_lualine.replace.a.bg, meridian_palette.red, 'Meridian Lualine replace mode color')
equal(meridian_lualine.command.a.bg, meridian_palette.yellow, 'Meridian Lualine command mode color')
equal(meridian_lualine.terminal.a.bg, meridian_palette.cyan, 'Meridian Lualine terminal mode color')
equal(meridian_lualine.inactive.a.fg, meridian_palette.fg3, 'Meridian Lualine inactive text is not muted')
equal(require('token.terminal').colors(meridian_palette, true, 'token-meridian'), {
  [0] = '#1d1d1c',
  [1] = '#db8935',
  [2] = '#8cbb62',
  [3] = '#d99148',
  [4] = '#66abc6',
  [5] = '#b991db',
  [6] = '#66abc6',
  [7] = '#aba195',
  [8] = '#91887d',
  [9] = '#ea9d49',
  [10] = '#8cbb62',
  [11] = '#f8c88f',
  [12] = '#66abc6',
  [13] = '#de88a6',
  [14] = '#66abc6',
  [15] = '#c9c0b1',
}, 'Meridian ANSI dark roles')

load('light', 'token-meridian')
local meridian_light_palette = require('token.theme').palette('light', 'token-meridian')
equal(require('lualine.themes.token-meridian').normal.a.bg, meridian_light_palette.fg2, 'Meridian light Lualine mode')
equal(require('token.terminal').colors(meridian_light_palette, false, 'token-meridian'), {
  [0] = '#28323a',
  [1] = '#843900',
  [2] = '#005f2f',
  [3] = '#843900',
  [4] = '#0048b3',
  [5] = '#7a1f7a',
  [6] = '#095b62',
  [7] = '#b5b2ab',
  [8] = '#524b42',
  [9] = '#843900',
  [10] = '#005f2f',
  [11] = '#843900',
  [12] = '#0048b3',
  [13] = '#4b1fa3',
  [14] = '#095b62',
  [15] = '#fbf9f4',
}, 'Meridian ANSI light roles')

token.setup({
  on_colors = function(colors, _, colorscheme)
    if colorscheme == 'token-meridian' then
      colors.blue = '#123456'
    end
  end,
})
load('dark', 'token-meridian')
equal(vim.g.terminal_color_4, '#123456', 'Meridian ANSI colors ignored on_colors override')

token.setup({ attributes = { bold = false } })
load('dark', 'token-flint')
equal(require('lualine.themes.token').normal.a.gui, nil, 'classic Lualine ignored bold gate')
equal(require('lualine.themes.token-flint').normal.a.gui, nil, 'Flint Lualine ignored bold gate')
equal(require('lualine.themes.token-temper').normal.a.gui, nil, 'Temper Lualine ignored bold gate')
equal(require('lualine.themes.token-ultra').normal.a.gui, nil, 'Ultra Lualine ignored bold gate')
equal(require('lualine.themes.token-meridian').normal.a.gui, nil, 'Meridian Lualine ignored bold gate')

-- Invalid callback output is rejected.
token.setup({
  on_highlights = function(groups)
    groups.Bad = 'invalid'
  end,
})
fails('highlight callbacks', function()
  load()
end)

-- Cache fingerprinting must not make compilation a requirement for dynamic loading.
token.setup({ on_colors = pairs })
load()
equal(vim.g.colors_name, 'token', 'non-dumpable callback blocked dynamic loading')

-- Dynamic and compiled variants, keyed misses, terminal opt-out, and corrupt fallback.
local fail_flint_compile = false
local callback = function(groups, colors, background, colorscheme)
  if fail_flint_compile and colorscheme == 'token-flint' then
    error('injected Flint compile failure')
  end
  groups.TokenCompiled = {
    fg = colors.accent,
    bold = background == 'dark',
    italic = colorscheme == 'token-flint',
    underline = colorscheme == 'token-temper',
    undercurl = colorscheme == 'token-ultra',
    strikethrough = colorscheme == 'token-meridian',
  }
end
token.setup({
  terminal_colors = false,
  plugins = { gitsigns = false, snacks = false },
  highlights = { all = { TokenCterm = { fg = '#abcdef', cterm = { bold = true } } } },
  on_highlights = callback,
})
local compile = require('token.compile')
compile.compile()
local dark_path = compile.path('dark')
local light_path = compile.path('light')
local flint_dark_path = compile.path('dark', 'token-flint')
local flint_light_path = compile.path('light', 'token-flint')
local temper_dark_path = compile.path('dark', 'token-temper')
local temper_light_path = compile.path('light', 'token-temper')
local ultra_dark_path = compile.path('dark', 'token-ultra')
local ultra_light_path = compile.path('light', 'token-ultra')
local meridian_dark_path = compile.path('dark', 'token-meridian')
local meridian_light_path = compile.path('light', 'token-meridian')
truthy(vim.uv.fs_stat(dark_path), 'dark cache missing')
truthy(vim.uv.fs_stat(light_path), 'light cache missing')
truthy(vim.uv.fs_stat(flint_dark_path), 'Flint dark cache missing')
truthy(vim.uv.fs_stat(flint_light_path), 'Flint light cache missing')
truthy(vim.uv.fs_stat(temper_dark_path), 'Temper dark cache missing')
truthy(vim.uv.fs_stat(temper_light_path), 'Temper light cache missing')
truthy(vim.uv.fs_stat(ultra_dark_path), 'Ultra dark cache missing')
truthy(vim.uv.fs_stat(ultra_light_path), 'Ultra light cache missing')
truthy(vim.uv.fs_stat(meridian_dark_path), 'Meridian dark cache missing')
truthy(vim.uv.fs_stat(meridian_light_path), 'Meridian light cache missing')
equal(
  vim.tbl_count({
    [dark_path] = true,
    [light_path] = true,
    [flint_dark_path] = true,
    [flint_light_path] = true,
    [temper_dark_path] = true,
    [temper_light_path] = true,
    [ultra_dark_path] = true,
    [ultra_light_path] = true,
    [meridian_dark_path] = true,
    [meridian_light_path] = true,
  }),
  10,
  'cache paths collide'
)
fail_flint_compile = true
local compile_ok, compile_error = pcall(compile.compile)
equal(compile_ok, false, 'injected Flint compilation unexpectedly succeeded')
truthy(tostring(compile_error):match('injected Flint compile failure'), 'unexpected Flint compilation failure')
for _, path in ipairs({
  dark_path,
  light_path,
  flint_dark_path,
  flint_light_path,
  temper_dark_path,
  temper_light_path,
  ultra_dark_path,
  ultra_light_path,
  meridian_dark_path,
  meridian_light_path,
}) do
  truthy(vim.uv.fs_stat(path), 'failed Flint rebuild removed existing cache: ' .. path)
end
equal(#vim.fn.glob(vim.fn.stdpath('cache') .. '/token/*.tmp', false, true), 0, 'failed rebuild left cache temporaries')
fail_flint_compile = false
vim.g.terminal_color_0 = 'sentinel'
load('dark')
equal(vim.g.colors_name, 'token', 'compiled classic colors_name')
equal(vim.g.terminal_color_0, 'sentinel', 'compiled terminal opt-out failed')
truthy(hl('TokenCompiled').bold, 'compiled dark callback missing')
equal(hl('TokenCompiled').italic, nil, 'classic cache used Flint callback result')
truthy(hl('TokenCterm').cterm.bold, 'compiled cterm highlight missing')
load('light')
equal(hl('TokenCompiled').bold, nil, 'compiled light callback result incorrect')
equal(loaded('gitsigns'), false, 'compiled output loaded disabled integration')
load('dark', 'token-flint')
equal(vim.g.colors_name, 'token-flint', 'compiled Flint colors_name')
truthy(hl('TokenCompiled').bold and hl('TokenCompiled').italic, 'compiled Flint callback result incorrect')
load('light', 'token-flint')
equal(vim.g.colors_name, 'token-flint', 'compiled Flint light colors_name')
truthy(hl('TokenCompiled').italic and not hl('TokenCompiled').bold, 'compiled Flint light callback result incorrect')
load('dark', 'token-temper')
equal(vim.g.colors_name, 'token-temper', 'compiled Temper colors_name')
truthy(hl('TokenCompiled').bold and hl('TokenCompiled').underline, 'compiled Temper callback result incorrect')
equal(hl('TokenCompiled').italic, nil, 'Temper cache used Flint callback result')
load('light', 'token-temper')
equal(vim.g.colors_name, 'token-temper', 'compiled Temper light colors_name')
truthy(
  hl('TokenCompiled').underline and not hl('TokenCompiled').bold,
  'compiled Temper light callback result incorrect'
)
load('dark', 'token-ultra')
equal(vim.g.colors_name, 'token-ultra', 'compiled Ultra colors_name')
truthy(hl('TokenCompiled').bold and hl('TokenCompiled').undercurl, 'compiled Ultra callback result incorrect')
equal(hl('TokenCompiled').italic, nil, 'Ultra cache used Flint callback result')
load('light', 'token-ultra')
equal(vim.g.colors_name, 'token-ultra', 'compiled Ultra light colors_name')
truthy(hl('TokenCompiled').undercurl and not hl('TokenCompiled').bold, 'compiled Ultra light callback result incorrect')
load('dark', 'token-meridian')
equal(vim.g.colors_name, 'token-meridian', 'compiled Meridian colors_name')
truthy(hl('TokenCompiled').bold and hl('TokenCompiled').strikethrough, 'compiled Meridian callback result incorrect')
load('light', 'token-meridian')
equal(vim.g.colors_name, 'token-meridian', 'compiled Meridian light colors_name')
truthy(
  hl('TokenCompiled').strikethrough and not hl('TokenCompiled').bold,
  'compiled Meridian light callback result incorrect'
)

token.setup({ transparent = true })
equal(compile.load('dark'), false, 'configuration change reused stale cache')
equal(compile.load('dark', 'token-flint'), false, 'configuration change reused stale Flint cache')
equal(compile.load('dark', 'token-temper'), false, 'configuration change reused stale Temper cache')
equal(compile.load('dark', 'token-ultra'), false, 'configuration change reused stale Ultra cache')
equal(compile.load('dark', 'token-meridian'), false, 'configuration change reused stale Meridian cache')

token.setup({
  terminal_colors = false,
  plugins = { gitsigns = false, snacks = false },
  highlights = { all = { TokenCterm = { fg = '#abcdef', cterm = { bold = true } } } },
  on_highlights = callback,
})
local meridian_file = assert(io.open(meridian_dark_path, 'wb'))
assert(meridian_file:write('corrupt'))
assert(meridian_file:close())
equal(compile.load('dark', 'token-meridian'), false, 'corrupt Meridian cache did not fall back')
equal(vim.uv.fs_stat(meridian_dark_path), nil, 'corrupt Meridian cache was not removed')
truthy(compile.load('dark'), 'corrupt Meridian cache affected classic Token')
truthy(compile.load('dark', 'token-flint'), 'corrupt Meridian cache affected Flint')
truthy(compile.load('dark', 'token-temper'), 'corrupt Meridian cache affected Temper')
truthy(compile.load('dark', 'token-ultra'), 'corrupt Meridian cache affected Ultra')

local ultra_file = assert(io.open(ultra_dark_path, 'wb'))
assert(ultra_file:write('corrupt'))
assert(ultra_file:close())
equal(compile.load('dark', 'token-ultra'), false, 'corrupt Ultra cache did not fall back')
equal(vim.uv.fs_stat(ultra_dark_path), nil, 'corrupt Ultra cache was not removed')
truthy(compile.load('dark'), 'corrupt Ultra cache affected classic Token')
truthy(compile.load('dark', 'token-flint'), 'corrupt Ultra cache affected Flint')
truthy(compile.load('dark', 'token-temper'), 'corrupt Ultra cache affected Temper')

local temper_file = assert(io.open(temper_dark_path, 'wb'))
assert(temper_file:write('corrupt'))
assert(temper_file:close())
equal(compile.load('dark', 'token-temper'), false, 'corrupt Temper cache did not fall back')
equal(vim.uv.fs_stat(temper_dark_path), nil, 'corrupt Temper cache was not removed')
truthy(compile.load('dark'), 'corrupt Temper cache affected classic Token')
truthy(compile.load('dark', 'token-flint'), 'corrupt Temper cache affected Flint')

local flint_file = assert(io.open(flint_dark_path, 'wb'))
assert(flint_file:write('corrupt'))
assert(flint_file:close())
equal(compile.load('dark', 'token-flint'), false, 'corrupt Flint cache did not fall back')
equal(vim.uv.fs_stat(flint_dark_path), nil, 'corrupt Flint cache was not removed')
truthy(compile.load('dark'), 'corrupt Flint cache affected classic Token')

local file = assert(io.open(dark_path, 'wb'))
assert(file:write('corrupt'))
assert(file:close())
equal(compile.load('dark'), false, 'corrupt cache did not fall back')
equal(vim.uv.fs_stat(dark_path), nil, 'corrupt cache was not removed')

file = assert(io.open(dark_path, 'wb'))
assert(file:write(string.dump(function()
  error({ message = 'cache execution failed' })
end)))
assert(file:close())
load('dark')
truthy(hl('TokenCompiled').bold, 'non-string cache error did not reach dynamic fallback')
equal(vim.uv.fs_stat(dark_path), nil, 'cache with a non-string error was not removed')

-- Complete dynamic and compiled maps, including ANSI colors, must match for both registry modes.
local function applied_groups(groups)
  local result = {}
  for name in pairs(groups) do
    result[name] = vim.api.nvim_get_hl(0, { name = name, link = true })
  end
  return result
end

local function terminal_colors()
  local result = {}
  for index = 0, 15 do
    result[index] = vim.g['terminal_color_' .. index]
    truthy(result[index], 'terminal color ' .. index .. ' is missing')
  end
  return result
end

local function parity(config, label)
  token.setup(config)
  local expected = {}
  for _, appearance in ipairs(require('token.appearance').all()) do
    expected[appearance.name] = {}
    for _, background in ipairs({ 'dark', 'light' }) do
      local _, groups = require('token.theme').build(background, appearance.name)
      expected[appearance.name][background] = groups
      os.remove(compile.path(background, appearance.name))
    end
  end

  local dynamic = {}
  for _, appearance in ipairs(require('token.appearance').all()) do
    dynamic[appearance.name] = {}
    for _, background in ipairs({ 'dark', 'light' }) do
      for index = 0, 15 do
        vim.g['terminal_color_' .. index] = nil
      end
      equal(
        compile.load(background, appearance.name),
        false,
        label .. ' unexpectedly found a compiled cache for ' .. appearance.name
      )
      load(background, appearance.name)
      equal(vim.g.colors_name, appearance.name, label .. ' dynamic colors_name for ' .. appearance.name)
      dynamic[appearance.name][background] = {
        groups = applied_groups(expected[appearance.name][background]),
        terminal = terminal_colors(),
      }
    end
  end

  compile.compile()
  for _, appearance in ipairs(require('token.appearance').all()) do
    for _, background in ipairs({ 'dark', 'light' }) do
      for index = 0, 15 do
        vim.g['terminal_color_' .. index] = nil
      end
      truthy(
        vim.uv.fs_stat(compile.path(background, appearance.name)),
        label .. ' compiled cache is missing for ' .. appearance.name
      )
      vim.o.background = background
      truthy(compile.load(background, appearance.name), label .. ' compiled cache did not load for ' .. appearance.name)
      equal(vim.g.colors_name, appearance.name, label .. ' compiled colors_name for ' .. appearance.name)
      equal(
        applied_groups(expected[appearance.name][background]),
        dynamic[appearance.name][background].groups,
        label .. ' group parity for ' .. appearance.name .. ' ' .. background
      )
      equal(
        terminal_colors(),
        dynamic[appearance.name][background].terminal,
        label .. ' terminal parity for ' .. appearance.name .. ' ' .. background
      )
    end
  end
end

parity({}, 'core-only')
parity({ plugins = { all = true } }, 'all-plugin')
parity({ styles = flint_styles }, 'styled')

print('token: headless tests passed')
