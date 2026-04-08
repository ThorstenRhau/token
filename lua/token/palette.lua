---@class TokenPalette
--- Background ramp (dark: darkest->lightest, light: lightest->darkest)
---@field bg0 string
---@field bg1 string
---@field bg2 string
---@field bg3 string  Normal background
---@field bg4 string
---@field bg5 string
--- Foreground ramp
---@field fg0 string  Normal foreground
---@field fg1 string
---@field fg2 string  Comments, muted text
---@field fg3 string  Most muted foreground
--- Accent hues
---@field accent string   Primary accent (functions, titles)
---@field accent2 string  Secondary accent (keywords, booleans)
--- Syntax hues
---@field blue string
---@field green string
---@field red string
---@field yellow string
---@field purple string
---@field cyan string
---@field orange string   Numeric literals
--- Bright variants (terminal colors 10-14 only)
---@field bright_green string
---@field bright_blue string
---@field bright_purple string
---@field bright_cyan string
--- Diff backgrounds
---@field diff_add string
---@field diff_del string
---@field diff_add_inline string
---@field diff_del_inline string
---@field diff_change string
---@field diff_text string
--- Diagnostic backgrounds
---@field diag_info string
---@field diag_hint string
--- UI elements
---@field sel string
---@field match string
---@field indent string
---@field indent_active string
---@field line_nr string
--- Git sign column
---@field gsign_add string
---@field gsign_change string
---@field gsign_del string
---@field gsign_untracked string

---@param background 'dark'|'light'
---@return TokenPalette
local function palette(background)
  if background ~= 'dark' and background ~= 'light' then
    error('palette: expected "dark" or "light", got: ' .. tostring(background))
  end

  if background == 'light' then
    return {
      -- Background ramp
      bg0 = '#edece8',
      bg1 = '#f1f0ec',
      bg2 = '#f5f4f1',
      bg3 = '#faf9f5',
      bg4 = '#f0efeb',
      bg5 = '#eae9e5',
      -- Foreground ramp
      fg0 = '#2a2920',
      fg1 = '#3d3929',
      fg2 = '#6c675f',
      fg3 = '#858179',
      -- Accent hues
      accent = '#974c30',
      accent2 = '#8b602e',
      -- Syntax hues
      blue = '#3e6b95',
      green = '#356831',
      red = '#ab4750',
      yellow = '#705d1e',
      purple = '#724c9d',
      cyan = '#287171',
      orange = '#9a5f22',
      -- Bright variants
      bright_green = '#41793c',
      bright_blue = '#5081a9',
      bright_purple = '#8762b5',
      bright_cyan = '#328080',
      -- Diff backgrounds
      diff_add = '#daf6d5',
      diff_del = '#ffdada',
      diff_add_inline = '#c0d8bc',
      diff_del_inline = '#e8c4c4',
      diff_change = '#eee4c6',
      diff_text = '#e2dac0',
      -- Diagnostic backgrounds
      diag_info = '#dae4f2',
      diag_hint = '#d6eeea',
      -- UI elements
      sel = '#dddcd6',
      match = '#e8d8b0',
      indent = '#e0ddd8',
      indent_active = '#a8a49c',
      line_nr = '#b5b2ab',
      -- Git sign column
      gsign_add = '#24831f',
      gsign_change = '#9d6600',
      gsign_del = '#c82a2a',
      gsign_untracked = '#858179',
    }
  end

  -- dark
  return {
    -- Background ramp
    bg0 = '#191918',
    bg1 = '#1d1d1c',
    bg2 = '#212120',
    bg3 = '#262624',
    bg4 = '#2f2f2d',
    bg5 = '#383835',
    -- Foreground ramp
    fg0 = '#e8e4dc',
    fg1 = '#d4cfc6',
    fg2 = '#938e87',
    fg3 = '#878681',
    -- Accent hues
    accent = '#c5826d',
    accent2 = '#be9570',
    -- Syntax hues
    blue = '#7a9ebe',
    green = '#75ae71',
    red = '#c17c82',
    yellow = '#bca45d',
    purple = '#a688c2',
    cyan = '#66adad',
    orange = '#c59159',
    -- Bright variants
    bright_green = '#8fbc8b',
    bright_blue = '#90b1cc',
    bright_purple = '#b79ece',
    bright_cyan = '#7fbcbc',
    -- Diff backgrounds
    diff_add = '#23331c',
    diff_del = '#421a1e',
    diff_add_inline = '#2a5c1f',
    diff_del_inline = '#6e1c22',
    diff_change = '#2d2a25',
    diff_text = '#483e34',
    -- Diagnostic backgrounds
    diag_info = '#1e2634',
    diag_hint = '#1c2e2e',
    -- UI elements
    sel = '#333331',
    match = '#4a4030',
    indent = '#333330',
    indent_active = '#636360',
    line_nr = '#585855',
    -- Git sign column
    gsign_add = '#75ae71',
    gsign_change = '#bca45d',
    gsign_del = '#c17c82',
    gsign_untracked = '#878681',
  }
end

return palette
