---Semantic color palette exposed to configuration callbacks.
---@alias token.Palette TokenPalette

---Highlight name-to-definition mapping accepted by Neovim's highlight API.
---@alias token.HighlightMap table<string, vim.api.keyset.highlight>

---Callback invoked after declarative palette overrides.
---@alias token.OnColors fun(colors: token.Palette, background: 'dark'|'light', colorscheme: 'token'|'token-flint'|'token-temper')

---Callback invoked after highlight overrides and before global attribute gates.
---@alias token.OnHighlights fun(highlights: token.HighlightMap, colors: token.Palette, background: 'dark'|'light', colorscheme: 'token'|'token-flint'|'token-temper')

---Text attributes accepted by global gates and semantic style overlays.
---@class (exact) token.HighlightAttributes
---@field bold? boolean Set bold text. Global gate default: true; style overlay default: unset.
---@field italic? boolean Set italic text. Global gate default: true; style overlay default: unset.
---@field underline? boolean Set underlined text. Global gate default: true; style overlay default: unset.
---@field undercurl? boolean Set undercurled text. Global gate default: true; style overlay default: unset.
---@field strikethrough? boolean Set struck-through text. Global gate default: true; style overlay default: unset.

---Attribute overlays for semantic syntax categories. Defaults to no overlays.
---More-specific categories are applied after overlapping broader categories.
---@class (exact) token.Styles
---@field booleans? token.HighlightAttributes Style booleans and built-in constants after `constants`.
---@field comments? token.HighlightAttributes Style comments, documentation comments, and comment annotations.
---@field conditionals? token.HighlightAttributes Style conditional keywords after `keywords`.
---@field constants? token.HighlightAttributes Style constants, macros, and booleans.
---@field functions? token.HighlightAttributes Style functions, methods, calls, and constructors.
---@field keywords? token.HighlightAttributes Style statements and all keyword captures.
---@field loops? token.HighlightAttributes Style loop and repeat keywords after `keywords`.
---@field numbers? token.HighlightAttributes Style integer and floating-point literals.
---@field operators? token.HighlightAttributes Style operators.
---@field preprocessor? token.HighlightAttributes Style imports, directives, and macros after `keywords`.
---@field properties? token.HighlightAttributes Style properties and members after `variables`.
---@field strings? token.HighlightAttributes Style strings, characters, paths, URLs, regular expressions, and escapes.
---@field types? token.HighlightAttributes Style types, definitions, storage classes, structures, and constructors.
---@field variables? token.HighlightAttributes Style identifiers, variables, parameters, properties, and members.

---Palette overrides. Keys may replace built-in colors or add colors for callbacks; values must be `#RRGGBB` strings.
---@class (exact) token.Colors
---@field all? table<string, string> Colors shared by both variants. Defaults to an empty table.
---@field dark? table<string, string> Dark overrides applied after `all`. Defaults to an empty table.
---@field light? table<string, string> Light overrides applied after `all`. Defaults to an empty table.

---Complete highlight definitions applied after semantic styles and surface options.
---@class (exact) token.Highlights
---@field all? token.HighlightMap Definitions shared by both variants. Defaults to an empty table.
---@field dark? token.HighlightMap Dark definitions replacing entries from `all`. Defaults to an empty table.
---@field light? token.HighlightMap Light definitions replacing entries from `all`. Defaults to an empty table.

---Optional plugin highlight integrations. Omitted keys inherit `all`; `all` defaults to false.
---@class (exact) token.Plugins
---@field all? boolean Enable every integration unless explicitly overridden. Default: false.
---@field blink? boolean Enable highlights for blink.cmp.
---@field blink_indent? boolean Enable highlights for blink.indent.
---@field claudecode? boolean Enable highlights for claudecode.nvim.
---@field cmp? boolean Enable highlights for nvim-cmp.
---@field dap_ui? boolean Enable highlights for nvim-dap-ui.
---@field diffview? boolean Enable highlights for diffview.nvim.
---@field flash? boolean Enable highlights for flash.nvim.
---@field fugitive? boolean Enable highlights for vim-fugitive.
---@field fzf? boolean Enable highlights for fzf-lua.
---@field gitsigns? boolean Enable highlights for gitsigns.nvim.
---@field hlchunk? boolean Enable highlights for hlchunk.nvim.
---@field ibl? boolean Enable highlights for indent-blankline.nvim.
---@field lazy? boolean Enable highlights for lazy.nvim.
---@field markview? boolean Enable highlights for markview.nvim.
---@field mason? boolean Enable highlights for mason.nvim.
---@field matchup? boolean Enable highlights for vim-matchup.
---@field mini? boolean Enable highlights for supported mini.nvim modules.
---@field neo_tree? boolean Enable highlights for neo-tree.nvim.
---@field neogit? boolean Enable highlights for neogit.
---@field noice? boolean Enable highlights for noice.nvim.
---@field nvimtree? boolean Enable highlights for nvim-tree.lua.
---@field oil? boolean Enable highlights for oil.nvim.
---@field render_markdown? boolean Enable highlights for render-markdown.nvim.
---@field snacks? boolean Enable highlights for snacks.nvim.
---@field telescope? boolean Enable highlights for telescope.nvim.
---@field todo_comments? boolean Enable highlights for todo-comments.nvim.
---@field treesitter_context? boolean Enable highlights for nvim-treesitter-context.
---@field trouble? boolean Enable highlights for trouble.nvim.
---@field whichkey? boolean Enable highlights for which-key.nvim.

---Configuration for `require('token').setup()`. Each call starts from defaults and deep-merges these options.
---@class (exact) token.Config
---@field transparent? boolean Clear ordinary UI surfaces while preserving semantic backgrounds. Default: false.
---@field terminal_colors? boolean Set Neovim terminal colors 0 through 15 when loading. Default: true.
---@field dim_inactive? boolean Use quieter colors for inactive windows. Default: false.
---@field attributes? token.HighlightAttributes Global attribute gates applied last. Defaults to all enabled.
---@field styles? token.Styles Semantic attribute overlays applied to Token's built-in groups.
---@field colors? token.Colors Declarative palette overrides applied before `on_colors`.
---@field highlights? token.Highlights Complete highlight definitions applied before `on_highlights`.
---@field plugins? token.Plugins Opt-in plugin integrations. Defaults to `{ all = false }`.
---@field on_colors? token.OnColors Edit the palette after declarative overrides.
---@field on_highlights? token.OnHighlights Edit final highlights before global attribute gates.

local M = {}

local attributes = { 'bold', 'italic', 'underline', 'undercurl', 'strikethrough' }
local style_names = {
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
}

local function set(values)
  local result = {}
  for _, value in ipairs(values) do
    result[value] = true
  end
  return result
end

local attribute_set = set(attributes)
local style_set = set(style_names)

local defaults = {
  transparent = false,
  terminal_colors = true,
  dim_inactive = false,
  attributes = { bold = true, italic = true, underline = true, undercurl = true, strikethrough = true },
  styles = {},
  colors = { all = {}, dark = {}, light = {} },
  highlights = { all = {}, dark = {}, light = {} },
  plugins = { all = false },
}

for _, name in ipairs(style_names) do
  defaults.styles[name] = {}
end

local current = vim.deepcopy(defaults)

local function fail(message)
  error('token: ' .. message, 0)
end

local function expect_table(value, path)
  if type(value) ~= 'table' then
    fail(path .. ' must be a table')
  end
end

local function validate_keys(value, allowed, path)
  for key in pairs(value) do
    if not allowed[key] then
      fail('unknown ' .. path .. ' option: ' .. tostring(key))
    end
  end
end

local function validate_boolean(value, path)
  if type(value) ~= 'boolean' then
    fail(path .. ' must be a boolean')
  end
end

local function validate_highlights(value, path)
  expect_table(value, path)
  for group, definition in pairs(value) do
    if type(group) ~= 'string' or type(definition) ~= 'table' then
      fail(path .. ' must map highlight names to tables')
    end
  end
end

local function validate_colors(value, path)
  expect_table(value, path)
  for key, color in pairs(value) do
    if type(key) ~= 'string' or type(color) ~= 'string' or not color:match('^#%x%x%x%x%x%x$') then
      fail('palette color ' .. tostring(key) .. ' must be a #RRGGBB value')
    end
  end
end

---@param opts? token.Config
function M.setup(opts)
  if opts == nil then
    opts = {}
  end
  expect_table(opts, 'setup options')
  validate_keys(
    opts,
    set({
      'transparent',
      'terminal_colors',
      'dim_inactive',
      'attributes',
      'styles',
      'colors',
      'highlights',
      'plugins',
      'on_colors',
      'on_highlights',
    }),
    'top-level'
  )

  local config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts)
  for _, name in ipairs({ 'transparent', 'terminal_colors', 'dim_inactive' }) do
    validate_boolean(config[name], name)
  end

  expect_table(config.attributes, 'attributes')
  validate_keys(config.attributes, attribute_set, 'attribute')
  for name, value in pairs(config.attributes) do
    validate_boolean(value, 'attributes.' .. name)
  end

  expect_table(config.styles, 'styles')
  validate_keys(config.styles, style_set, 'style')
  for name, style in pairs(config.styles) do
    expect_table(style, 'styles.' .. name)
    validate_keys(style, attribute_set, 'styles.' .. name)
    for attribute, value in pairs(style) do
      validate_boolean(value, 'styles.' .. name .. '.' .. attribute)
    end
  end

  for _, section in ipairs({ 'colors', 'highlights' }) do
    expect_table(config[section], section)
    validate_keys(config[section], set({ 'all', 'dark', 'light' }), section)
  end
  for _, variant in ipairs({ 'all', 'dark', 'light' }) do
    validate_colors(config.colors[variant], 'colors.' .. variant)
    validate_highlights(config.highlights[variant], 'highlights.' .. variant)
  end

  expect_table(config.plugins, 'plugins')
  local registry = require('token.groups.plugins').registry
  local plugin_names = { all = true }
  for name in pairs(registry) do
    plugin_names[name] = true
  end
  validate_keys(config.plugins, plugin_names, 'plugin')
  for name, value in pairs(config.plugins) do
    validate_boolean(value, 'plugins.' .. name)
  end

  for _, callback in ipairs({ 'on_colors', 'on_highlights' }) do
    if config[callback] ~= nil and type(config[callback]) ~= 'function' then
      fail(callback .. ' must be a function')
    end
  end

  current = config
end

function M.get()
  return current
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
