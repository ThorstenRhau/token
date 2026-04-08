local M = {}

---@param p TokenPalette
---@param is_dark boolean
---@return table<integer,string> colors 0..15 ANSI terminal colors
function M.colors(p, is_dark)
  return {
    [0] = is_dark and p.bg1 or p.fg0,
    [1] = p.red,
    [2] = p.green,
    [3] = p.yellow,
    [4] = p.blue,
    [5] = p.purple,
    [6] = p.cyan,
    [7] = is_dark and p.fg1 or p.bg1,
    [8] = is_dark and p.fg3 or p.fg2,
    [9] = p.accent,
    [10] = p.bright_green,
    [11] = p.accent2,
    [12] = p.bright_blue,
    [13] = p.bright_purple,
    [14] = p.bright_cyan,
    [15] = is_dark and p.fg0 or p.bg3,
  }
end

---@param p TokenPalette
---@param is_dark boolean
function M.set(p, is_dark)
  local c = M.colors(p, is_dark)
  for i = 0, 15 do
    vim.g['terminal_color_' .. i] = c[i]
  end
end

return M
