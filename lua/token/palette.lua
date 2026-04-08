---@param background 'dark'|'light'
---@return table
local function palette(background)
  if background ~= 'dark' and background ~= 'light' then
    error('palette: expected "dark" or "light", got: ' .. tostring(background))
  end

  if background == 'light' then
    return {
      bg0 = '#edece8',
      bg1 = '#f1f0ec',
      bg2 = '#f5f4f1',
      bg3 = '#faf9f5',
      bg4 = '#f0efeb',
      bg5 = '#eae9e5',
      fg0 = '#2a2920',
      fg1 = '#3d3929',
      fg2 = '#6c675f',
      fg3 = '#858179',
      accent = '#974c30',
      accent2 = '#8b602e',
      blue = '#3e6b95',
      green = '#356831',
      red = '#ab4750',
      yellow = '#705d1e',
      purple = '#724c9d',
      cyan = '#287171',
      bright_green = '#41793c',
      bright_blue = '#5081a9',
      bright_purple = '#8762b5',
      bright_cyan = '#328080',
      diff_add = '#daf6d5',
      diff_del = '#ffdada',
      diff_add_inline = '#c0d8bc',
      diff_del_inline = '#e8c4c4',
      diff_change = '#eee4c6',
      diff_text = '#e2dac0',
      sel = '#dddcd6',
      match = '#e8d8b0',
      gsign_add = '#24831f',
      gsign_change = '#9d6600',
      gsign_del = '#c82a2a',
      gsign_untracked = '#6e6e95',
      indent = '#e0ddd8',
      indent_active = '#a8a49c',
      line_nr = '#b5b2ab',
    }
  end

  -- dark
  return {
    bg0 = '#191918',
    bg1 = '#1d1d1c',
    bg2 = '#212120',
    bg3 = '#262624',
    bg4 = '#2f2f2d',
    bg5 = '#383835',
    fg0 = '#e8e4dc',
    fg1 = '#d4cfc6',
    fg2 = '#938e87',
    fg3 = '#878681',
    accent = '#d17c61',
    accent2 = '#c99565',
    blue = '#719fc7',
    green = '#70b36b',
    red = '#cb727a',
    yellow = '#c9ab50',
    purple = '#a681c9',
    cyan = '#5eb5b5',
    bright_green = '#93c58f',
    bright_blue = '#92b8d7',
    bright_purple = '#bea1d8',
    bright_cyan = '#81c7c7',
    diff_add = '#23331c',
    diff_del = '#421a1e',
    diff_add_inline = '#2a5c1f',
    diff_del_inline = '#6e1c22',
    diff_change = '#2d2a25',
    diff_text = '#483e34',
    sel = '#333331',
    match = '#4a4030',
    gsign_add = '#70b36b',
    gsign_change = '#c9ab50',
    gsign_del = '#cb727a',
    gsign_untracked = '#878681',
    indent = '#333330',
    indent_active = '#636360',
    line_nr = '#585855',
  }
end

return palette
