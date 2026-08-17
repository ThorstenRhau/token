---@class Signal
---@field hue string
---@field energy number
---@field visible boolean

local SignalGarden = {}
local constellations = {
  ember = { hue = 'coral', energy = 0.82, visible = true },
  moss = { hue = 'olive', energy = 0.64, visible = true },
  aurora = { hue = 'violet', energy = 0.91, visible = true },
  midnight = { hue = 'indigo', energy = 0.28, visible = false },
}
---@param signal Signal
---@param phase number
---@return number
local function shimmer(signal, phase)
  local pulse = math.sin(phase) * 0.18
  return math.max(0, math.min(1, signal.energy + pulse))
end
---@param phase number
---@return string[]
function SignalGarden.compose(phase)
  local frame = {}
  for name, signal in pairs(constellations) do
    if signal.visible and shimmer(signal, phase) > 0.55 then
      frame[#frame + 1] = string.format('%-8s  %s', name, signal.hue)
    end
  end
  table.sort(frame)
  return frame
end
-- NOTE: every signal keeps its character in light and dark.
local preview = SignalGarden.compose(0.72)
vim.notify(table.concat(preview, '  •  '), vim.log.levels.INFO)
return SignalGarden
