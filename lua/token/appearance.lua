local appearances = {
  token = {
    name = 'token',
    display_name = 'Token',
    slug = 'token',
    cache_prefix = '',
    palette = 'token.palette',
  },
  ['token-flint'] = {
    name = 'token-flint',
    display_name = 'Token Flint',
    slug = 'token-flint',
    cache_prefix = 'flint-',
    palette = 'token.palettes.flint',
    roles = 'token.appearances.flint_roles',
  },
  ['token-temper'] = {
    name = 'token-temper',
    display_name = 'Token Temper',
    slug = 'token-temper',
    cache_prefix = 'temper-',
    palette = 'token.palettes.temper',
    roles = 'token.appearances.temper_roles',
  },
  ['token-ultra'] = {
    name = 'token-ultra',
    display_name = 'Token Ultra',
    slug = 'token-ultra',
    cache_prefix = 'ultra-',
    palette = 'token.palettes.ultra',
    roles = 'token.appearances.ultra_roles',
  },
  ['token-meridian'] = {
    name = 'token-meridian',
    display_name = 'Token Meridian',
    slug = 'token-meridian',
    cache_prefix = 'meridian-',
    palette = 'token.palettes.meridian',
    roles = 'token.appearances.meridian_roles',
  },
  ['token-melange'] = {
    name = 'token-melange',
    display_name = 'Token Melange',
    slug = 'token-melange',
    cache_prefix = 'melange-',
    palette = 'token.palettes.melange',
    roles = 'token.appearances.melange_roles',
  },
}

local order = { 'token', 'token-flint', 'token-temper', 'token-ultra', 'token-meridian', 'token-melange' }

local M = {}

---@param name? string
---@return table
function M.get(name)
  name = name or 'token'
  local appearance = appearances[name]
  if not appearance then
    error('token: unknown internal colorscheme name: ' .. tostring(name), 0)
  end
  return appearance
end

---@return table[]
function M.all()
  local result = {}
  for _, name in ipairs(order) do
    result[#result + 1] = appearances[name]
  end
  return result
end

---@param name? string
---@param p TokenPalette
---@param is_dark boolean
---@return table?
function M.roles(name, p, is_dark)
  local appearance = M.get(name)
  if not appearance.roles then
    return nil
  end
  return require(appearance.roles)(p, is_dark)
end

return M
