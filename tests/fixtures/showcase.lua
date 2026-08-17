---@class ThemeProfile
---@field name string
---@field enabled boolean
---@field threshold number

local ThemeProfile = {}
ThemeProfile.__index = ThemeProfile

local defaults = {
  name = 'Token Ultra',
  enabled = true,
  threshold = 0.72,
}

---@param options? ThemeProfile
---@return ThemeProfile
function ThemeProfile.new(options)
  local profile = vim.tbl_deep_extend('force', defaults, options or {})
  return setmetatable(profile, ThemeProfile)
end

---@param value number
---@return string
function ThemeProfile:classify(value)
  if not self.enabled then
    error('profile is disabled')
  elseif value >= self.threshold then
    return 'approved'
  end
  return 'review'
end

local ultra = ThemeProfile.new({ threshold = 0.81 })
print(ultra:classify(0.89))

return ThemeProfile
