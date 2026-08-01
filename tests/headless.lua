local root = vim.fn.getcwd()
vim.opt.runtimepath:append(root)

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

print('token: headless tests passed')
