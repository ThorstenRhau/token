---@alias token.Palette TokenPalette

---@class token.HighlightAttributes
---@field bold? boolean Enable bold text.
---@field italic? boolean Enable italic text.
---@field underline? boolean Enable underlined text.
---@field undercurl? boolean Enable undercurled text.
---@field strikethrough? boolean Enable struck-through text.

---@class token.Styles
---@field booleans? token.HighlightAttributes
---@field comments? token.HighlightAttributes
---@field conditionals? token.HighlightAttributes Applied after `keywords`.
---@field constants? token.HighlightAttributes
---@field functions? token.HighlightAttributes
---@field keywords? token.HighlightAttributes
---@field loops? token.HighlightAttributes Applied after `keywords`.
---@field numbers? token.HighlightAttributes
---@field operators? token.HighlightAttributes
---@field preprocessor? token.HighlightAttributes
---@field properties? token.HighlightAttributes Applied after `variables`.
---@field strings? token.HighlightAttributes
---@field types? token.HighlightAttributes
---@field variables? token.HighlightAttributes

---@class token.Colors
---@field all? table<string, string> Colors shared by both variants.
---@field dark? table<string, string> Dark overrides applied after `all`.
---@field light? table<string, string> Light overrides applied after `all`.

---@class token.Highlights
---@field all? table<string, vim.api.keyset.highlight> Complete definitions shared by both variants.
---@field dark? table<string, vim.api.keyset.highlight> Complete dark definitions applied after `all`.
---@field light? table<string, vim.api.keyset.highlight> Complete light definitions applied after `all`.

---@class token.Plugins
---@field all? boolean Enable every integration unless explicitly overridden.
---@field blink? boolean
---@field blink_indent? boolean
---@field claudecode? boolean
---@field cmp? boolean
---@field dap_ui? boolean
---@field diffview? boolean
---@field flash? boolean
---@field fugitive? boolean
---@field fzf? boolean
---@field gitsigns? boolean
---@field hlchunk? boolean
---@field ibl? boolean
---@field lazy? boolean
---@field markview? boolean
---@field mason? boolean
---@field matchup? boolean
---@field mini? boolean
---@field neo_tree? boolean
---@field neogit? boolean
---@field noice? boolean
---@field nvimtree? boolean
---@field oil? boolean
---@field render_markdown? boolean
---@field snacks? boolean
---@field telescope? boolean
---@field todo_comments? boolean
---@field treesitter_context? boolean
---@field trouble? boolean
---@field whichkey? boolean

---@class token.Config
---@field transparent? boolean Clear base surfaces while preserving semantic backgrounds.
---@field terminal_colors? boolean Set Neovim's ANSI terminal palette. Defaults to true.
---@field dim_inactive? boolean Use quieter colors for inactive windows.
---@field attributes? token.HighlightAttributes Global attribute gates applied last.
---@field styles? token.Styles Semantic attribute overlays.
---@field colors? token.Colors Declarative palette overrides.
---@field highlights? token.Highlights Declarative complete highlight definitions.
---@field plugins? token.Plugins Opt-in plugin integrations.
---@field on_colors? fun(colors: token.Palette, background: 'dark'|'light') Mutate the configured palette in place.
---@field on_highlights? fun(highlights: table<string, vim.api.keyset.highlight>, colors: token.Palette, background: 'dark'|'light') Mutate final highlights in place.

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
  opts = opts or {}
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
