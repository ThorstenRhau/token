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
    highlights = 'token.appearances.flint',
  },
  ['token-temper'] = {
    name = 'token-temper',
    display_name = 'Token Temper',
    slug = 'token-temper',
    cache_prefix = 'temper-',
    palette = 'token.palettes.temper',
    highlights = 'token.appearances.temper',
  },
  ['token-ultra'] = {
    name = 'token-ultra',
    display_name = 'Token Ultra',
    slug = 'token-ultra',
    cache_prefix = 'ultra-',
    palette = 'token.palettes.ultra',
    highlights = 'token.appearances.ultra',
    roles = 'token.appearances.ultra_roles',
  },
}

local order = { 'token', 'token-flint', 'token-temper', 'token-ultra' }

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
