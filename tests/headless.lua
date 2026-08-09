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

local function load(background)
  vim.o.background = background or 'dark'
  token.load()
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
for _, path in ipairs({
  'contrib/carapace/token-dark.json',
  'contrib/carapace/token-light.json',
  'contrib/obsidian/manifest.json',
  'contrib/vscode/package.json',
  'contrib/vscode/themes/token-dark-color-theme.json',
  'contrib/vscode/themes/token-light-color-theme.json',
  'contrib/windows-terminal/token.json',
}) do
  truthy(vim.json.decode(read_text(path)), 'invalid generated JSON: ' .. path)
end
for _, variant in ipairs({ 'dark', 'light' }) do
  local share = read_text('contrib/chatgpt/token-' .. variant .. '.txt')
  local payload = share:match('^codex%-theme%-v1:(.+)%s*$')
  truthy(payload and vim.json.decode(payload), 'invalid ChatGPT share payload for ' .. variant)

  local sublime = read_text('contrib/sublime/token-' .. variant .. '.sublime-color-scheme')
  sublime = sublime:gsub('^//[^\n]*\n', '', 1)
  truthy(vim.json.decode(sublime), 'invalid Sublime scheme for ' .. variant)
end

local git_config = vim
  .system({ 'git', 'config', '--file', root .. '/contrib/delta/token.gitconfig', '--list' }, {
    text = true,
  })
  :wait()
equal(git_config.code, 0, 'invalid delta Git config: ' .. (git_config.stderr or ''))
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
for _, variant in ipairs({ 'dark', 'light' }) do
  local decoded = vim.json.decode(read_text('contrib/carapace/token-' .. variant .. '.json'))
  equal(sorted_keys(decoded.carapace), carapace_keys, 'Carapace schema drift for ' .. variant)
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

local fish = fish_sections(read_text('contrib/fish/token.theme'))
for _, variant in ipairs({ 'dark', 'light', 'unknown' }) do
  local palette_variant = variant == 'unknown' and 'dark' or variant
  local palette = require('token.palette')(palette_variant)
  equal(fish[variant].fish_color_cwd_root, palette.red:sub(2), 'Fish root cwd color for ' .. variant)
  equal(fish[variant].fish_color_status, palette.red:sub(2), 'Fish status color for ' .. variant)
  equal(fish[variant].fish_color_history_current, palette.accent:sub(2), 'Fish history color for ' .. variant)
end

for _, variant in ipairs({ 'dark', 'light' }) do
  local palette = require('token.palette')(variant)
  local zsh = read_text('contrib/zsh/token-' .. variant .. '.zsh')
  local styles = {
    ['exec-descriptor'] = 'fg=#' .. palette.accent2:sub(2),
    ['subtle-bg'] = 'bg=#' .. palette.match:sub(2),
    ['optarg-string'] = 'fg=#' .. palette.green:sub(2),
    ['optarg-number'] = 'fg=#' .. palette.purple:sub(2),
    ['recursive-base'] = 'none',
  }
  for name, style in pairs(styles) do
    local assignment = 'FAST_HIGHLIGHT_STYLES[' .. name .. "]='" .. style .. "'"
    truthy(zsh:find(assignment, 1, true), 'missing Zsh style ' .. name .. ' for ' .. variant)
  end
end

-- Generated output helpers reject path escapes and symlinks, and publish ordinary files correctly.
local gen_lib = require('gen_lib')
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
load()
local gated = hl('TokenGated')
for _, attribute in ipairs({ 'bold', 'italic', 'underline', 'undercurl', 'strikethrough' }) do
  equal(gated[attribute], nil, 'attribute gate failed for ' .. attribute)
end
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
local callback = function(groups, colors, background)
  groups.TokenCompiled = { fg = colors.accent, bold = background == 'dark' }
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
truthy(vim.uv.fs_stat(dark_path), 'dark cache missing')
truthy(vim.uv.fs_stat(light_path), 'light cache missing')
vim.g.terminal_color_0 = 'sentinel'
load('dark')
equal(vim.g.terminal_color_0, 'sentinel', 'compiled terminal opt-out failed')
truthy(hl('TokenCompiled').bold, 'compiled dark callback missing')
truthy(hl('TokenCterm').cterm.bold, 'compiled cterm highlight missing')
load('light')
equal(hl('TokenCompiled').bold, nil, 'compiled light callback result incorrect')
equal(loaded('gitsigns'), false, 'compiled output loaded disabled integration')

token.setup({ transparent = true })
equal(compile.load('dark'), false, 'configuration change reused stale cache')

token.setup({
  terminal_colors = false,
  plugins = { gitsigns = false, snacks = false },
  highlights = { all = { TokenCterm = { fg = '#abcdef', cterm = { bold = true } } } },
  on_highlights = callback,
})
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
  for _, background in ipairs({ 'dark', 'light' }) do
    local _, groups = require('token.theme').build(background)
    expected[background] = groups
    os.remove(compile.path(background))
  end

  local dynamic = {}
  for _, background in ipairs({ 'dark', 'light' }) do
    for index = 0, 15 do
      vim.g['terminal_color_' .. index] = nil
    end
    equal(compile.load(background), false, label .. ' unexpectedly found a compiled cache')
    load(background)
    dynamic[background] = {
      groups = applied_groups(expected[background]),
      terminal = terminal_colors(),
    }
  end

  compile.compile()
  for _, background in ipairs({ 'dark', 'light' }) do
    for index = 0, 15 do
      vim.g['terminal_color_' .. index] = nil
    end
    truthy(vim.uv.fs_stat(compile.path(background)), label .. ' compiled cache is missing')
    vim.o.background = background
    truthy(compile.load(background), label .. ' compiled cache did not load')
    equal(applied_groups(expected[background]), dynamic[background].groups, label .. ' group parity for ' .. background)
    equal(terminal_colors(), dynamic[background].terminal, label .. ' terminal parity for ' .. background)
  end
end

parity({}, 'core-only')
parity({ plugins = { all = true } }, 'all-plugin')

print('token: headless tests passed')
