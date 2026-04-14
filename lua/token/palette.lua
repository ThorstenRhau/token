---@class TokenPalette
--- Background ramp
--- Dark:  bg0 (darkest) -> bg5 (lightest), bg3 = Normal
--- Light: bg3 (lightest) -> bg0 (darkest), bg4/bg5 also darker than bg3
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
---@field olive string    Warm yellow-green (numbers)
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
---@field diff_add_strong string
---@field diff_del_strong string
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
---@field gsign_add_staged string
---@field gsign_change_staged string
---@field gsign_del_staged string
---@field gsign_untracked_staged string

---@param background 'dark'|'light'
---@return TokenPalette
local function palette(background)
  if background ~= 'dark' and background ~= 'light' then
    error('palette: expected "dark" or "light", got: ' .. tostring(background))
  end

  if background == 'light' then
    return {
      -- Background ramp
      bg0 = '#e6e5e1',
      bg1 = '#ecebe7',
      bg2 = '#f6f5f1',
      bg3 = '#faf9f5',
      bg4 = '#f0efeb',
      bg5 = '#eae9e5',
      -- Foreground ramp
      fg0 = '#2a2920',
      fg1 = '#3d3929',
      fg2 = '#6c675f',
      fg3 = '#858179',
      -- Accent hues
      accent = '#9a4929',
      accent2 = '#876032',
      -- Syntax hues
      blue = '#527594',
      green = '#3f643c',
      red = '#b05555',
      yellow = '#6e5c20',
      purple = '#7c619a',
      cyan = '#2d6c6c',
      orange = '#9a5f22',
      olive = '#63742f',
      -- Bright variants
      bright_green = '#3a5e37',
      bright_blue = '#486a88',
      bright_purple = '#6f578c',
      bright_cyan = '#286363',
      -- Diff backgrounds
      diff_add = '#daf6d5',
      diff_del = '#ffdada',
      diff_add_inline = '#c0d8bc',
      diff_del_inline = '#e8c4c4',
      diff_add_strong = '#a8c8a2',
      diff_del_strong = '#d8aaaa',
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
      gsign_untracked = '#a5a29b',
      gsign_add_staged = '#5ea059',
      gsign_change_staged = '#b28c43',
      gsign_del_staged = '#d17473',
      gsign_untracked_staged = '#858179',
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
    fg3 = '#5a5955',
    -- Accent hues
    accent = '#d97757',
    accent2 = '#c4956a',
    -- Syntax hues
    blue = '#7b9ebd',
    green = '#7da47a',
    red = '#c67777',
    yellow = '#c4a855',
    purple = '#a68bbf',
    cyan = '#6ba8a8',
    orange = '#d4914a',
    olive = '#a8b56b',
    -- Bright variants
    bright_green = '#98bf95',
    bright_blue = '#96b8d3',
    bright_purple = '#bea5d4',
    bright_cyan = '#88c0c0',
    -- Diff backgrounds
    diff_add = '#1e3524',
    diff_del = '#3c2024',
    diff_add_inline = '#2e5232',
    diff_del_inline = '#5a2529',
    diff_add_strong = '#3a6e3e',
    diff_del_strong = '#7a2e34',
    diff_change = '#2b2b29',
    diff_text = '#444039',
    -- Diagnostic backgrounds
    diag_info = '#1e2634',
    diag_hint = '#1c2e2e',
    -- UI elements
    sel = '#3a3a37',
    match = '#4a4030',
    indent = '#333330',
    indent_active = '#636360',
    line_nr = '#585855',
    -- Git sign column
    gsign_add = '#7da47a',
    gsign_change = '#c4a855',
    gsign_del = '#c67777',
    gsign_untracked = '#7a7670',
    gsign_add_staged = '#5e7a5c',
    gsign_change_staged = '#88753f',
    gsign_del_staged = '#9a5f5f',
    gsign_untracked_staged = '#5a5955',
  }
end

return palette
