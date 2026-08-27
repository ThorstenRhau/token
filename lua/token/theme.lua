local M = {}

local required_palette_keys

local style_groups = {
  variables = {
    'Identifier',
    '@variable',
    '@variable.builtin',
    '@variable.parameter',
    '@variable.parameter.builtin',
    '@property',
    '@variable.member',
  },
  properties = { '@property', '@variable.member' },
  constants = { 'Constant', '@constant', '@constant.builtin', '@constant.macro', 'Boolean', '@boolean' },
  booleans = { 'Boolean', '@boolean', '@constant.builtin' },
  strings = {
    'String',
    'Character',
    '@string',
    '@string.documentation',
    '@string.regexp',
    '@string.escape',
    '@string.special',
    '@string.special.symbol',
    '@string.special.path',
    '@string.special.url',
    '@character',
    '@character.special',
  },
  numbers = { 'Number', 'Float', '@number', '@number.float' },
  types = {
    'Type',
    'StorageClass',
    'Structure',
    'Typedef',
    '@type',
    '@type.builtin',
    '@type.definition',
    '@constructor',
    '@lsp.typemod.type.declaration',
    '@lsp.typemod.type.definition',
    '@lsp.typemod.class.declaration',
    '@lsp.typemod.class.definition',
    '@lsp.typemod.enum.declaration',
    '@lsp.typemod.enum.definition',
    '@lsp.typemod.interface.declaration',
    '@lsp.typemod.interface.definition',
    '@lsp.typemod.struct.declaration',
    '@lsp.typemod.struct.definition',
    '@lsp.typemod.typeParameter.declaration',
    '@lsp.typemod.typeParameter.definition',
  },
  functions = {
    'Function',
    '@function',
    '@function.builtin',
    '@function.call',
    '@function.macro',
    '@function.method',
    '@function.method.call',
    '@lsp.typemod.function.declaration',
    '@lsp.typemod.function.definition',
    '@lsp.typemod.method.declaration',
    '@lsp.typemod.method.definition',
  },
  operators = { 'Operator', '@operator' },
  comments = {
    'Comment',
    'SpecialComment',
    '@comment',
    '@comment.documentation',
    '@comment.error',
    '@comment.warning',
    '@comment.todo',
    '@comment.note',
  },
  preprocessor = {
    'PreProc',
    'Include',
    'Define',
    'Macro',
    'PreCondit',
    '@function.macro',
    '@keyword.import',
    '@keyword.directive',
    '@keyword.directive.define',
  },
  keywords = {
    'Statement',
    'Conditional',
    'Repeat',
    'Keyword',
    'Exception',
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
  },
  conditionals = { 'Conditional', '@keyword.conditional', '@keyword.conditional.ternary' },
  loops = { 'Repeat', '@keyword.repeat' },
}

local style_order = {
  'variables',
  'properties',
  'constants',
  'booleans',
  'strings',
  'numbers',
  'types',
  'functions',
  'operators',
  'comments',
  'keywords',
  'preprocessor',
  'conditionals',
  'loops',
}

local protected_backgrounds = {
  '^Cursor',
  '^Visual',
  'Search$',
  '^Substitute$',
  '^Diff',
  '^Added$',
  '^Changed$',
  '^Removed$',
  '^Diagnostic',
  '^GitSigns.*Inline$',
  '^GitSigns.*Ln$',
  '^RenderMarkdownH%dBg$',
  '^RenderMarkdownCode',
  'Selection$',
  '^FlashLabel$',
  '^TodoBg',
}

local function fail(message)
  error('token: ' .. message, 0)
end

local function validate_palette(p)
  for key in pairs(required_palette_keys) do
    if type(p[key]) ~= 'string' or not p[key]:match('^#%x%x%x%x%x%x$') then
      fail('palette color ' .. key .. ' must be a #RRGGBB value')
    end
  end
  for key, value in pairs(p) do
    if type(key) ~= 'string' or type(value) ~= 'string' or not value:match('^#%x%x%x%x%x%x$') then
      fail('palette color ' .. tostring(key) .. ' must be a #RRGGBB value')
    end
  end
end

local function resolved(groups, name, seen)
  local hl = groups[name]
  if not hl then
    return nil
  end
  if not hl.link then
    return vim.deepcopy(hl)
  end
  seen = seen or {}
  if seen[name] then
    return nil
  end
  seen[name] = true
  return resolved(groups, hl.link, seen)
end

local function apply_styles(groups, styles)
  for _, category in ipairs(style_order) do
    local style = styles[category]
    if next(style) then
      for _, name in ipairs(style_groups[category]) do
        if groups[name] then
          groups[name] = vim.tbl_extend('force', resolved(groups, name) or {}, style)
        end
      end
    end
  end
end

local function is_protected(name)
  for _, pattern in ipairs(protected_backgrounds) do
    if name:match(pattern) then
      return true
    end
  end
  return false
end

local function apply_surfaces(groups, p, config)
  if config.dim_inactive then
    for name in pairs(groups) do
      if name == 'NormalNC' or name:match('NormalNC$') then
        groups[name] = { fg = p.fg1, bg = config.transparent and 'NONE' or p.bg1 }
      end
    end
  end
  if config.transparent then
    local surfaces = { [p.bg0] = true, [p.bg1] = true, [p.bg2] = true, [p.bg3] = true }
    for name, hl in pairs(groups) do
      if hl.bg and surfaces[hl.bg] and not is_protected(name) then
        hl.bg = 'NONE'
      end
    end
  end
end

local function apply_attribute_gates(groups, attributes)
  local disabled = false
  for _, enabled in pairs(attributes) do
    disabled = disabled or not enabled
  end
  for group, hl in pairs(groups) do
    local can_gate = true
    if disabled and hl.link then
      local concrete = resolved(groups, group)
      if concrete then
        hl = concrete
        groups[group] = hl
      else
        can_gate = false
      end
    end
    for name, enabled in pairs(attributes) do
      if can_gate and not enabled then
        hl[name] = false
        if hl.cterm then
          hl.cterm[name] = false
        end
      end
    end
  end
end

---@param background 'dark'|'light'
---@param colorscheme? string
function M.palette(background, colorscheme)
  local config = require('token.config').get()
  local appearance = require('token.appearance').get(colorscheme)
  local stock = require(appearance.palette)(background)
  required_palette_keys = required_palette_keys or vim.deepcopy(require('token.palette')(background))
  local p = vim.tbl_extend('force', stock, config.colors.all, config.colors[background])
  if config.on_colors then
    config.on_colors(p, background, appearance.name)
  end
  validate_palette(p)
  return p
end

---@param background 'dark'|'light'
---@param colorscheme? string
function M.build(background, colorscheme)
  local config = require('token.config').get()
  local appearance = require('token.appearance').get(colorscheme)
  local p = M.palette(background, appearance.name)
  local groups = require('token.groups')(p, config.plugins)
  if appearance.highlights then
    local roles = require('token.appearance').roles(appearance.name, p, background == 'dark')
    for name, hl in pairs(require(appearance.highlights)(p, roles)) do
      if groups[name] or name:match('^@lsp%.typemod%.') then
        groups[name] = hl
      end
    end
  end
  require('token.typography').apply(groups, function(name)
    return resolved(groups, name)
  end)
  apply_styles(groups, config.styles)
  apply_surfaces(groups, p, config)
  groups =
    vim.tbl_extend('force', groups, vim.deepcopy(config.highlights.all), vim.deepcopy(config.highlights[background]))
  if config.on_highlights then
    config.on_highlights(groups, p, background, appearance.name)
  end
  for name, hl in pairs(groups) do
    if type(name) ~= 'string' or type(hl) ~= 'table' then
      fail('highlight callbacks must leave a name-to-table mapping')
    end
  end
  apply_attribute_gates(groups, config.attributes)
  return p, groups
end

return M
