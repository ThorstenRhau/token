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
      accent = '#934e34',
      accent2 = '#876032',
      blue = '#496b8a',
      green = '#3F643C',
      red = '#a44e4e',
      yellow = '#6E5C20',
      purple = '#735990',
      cyan = '#2D6C6C',
      bright_green = '#4D7B49',
      bright_blue = '#6389A8',
      bright_purple = '#9075B2',
      bright_cyan = '#3D8484',
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
      gsign_del = '#C82A2A',
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
    accent = '#d07d62',
    accent2 = '#C4956A',
    blue = '#7B9EBD',
    green = '#7DA47A',
    red = '#C67777',
    yellow = '#C4A855',
    purple = '#A68BBF',
    cyan = '#6BA8A8',
    bright_green = '#98BF95',
    bright_blue = '#96B8D3',
    bright_purple = '#BEA5D4',
    bright_cyan = '#88C0C0',
    diff_add = '#23331c',
    diff_del = '#421a1e',
    diff_add_inline = '#2a5c1f',
    diff_del_inline = '#6e1c22',
    diff_change = '#2d2a25',
    diff_text = '#483e34',
    sel = '#333331',
    match = '#4a4030',
    gsign_add = '#7DA47A',
    gsign_change = '#C4A855',
    gsign_del = '#C67777',
    gsign_untracked = '#878681',
    indent = '#333330',
    indent_active = '#636360',
    line_nr = '#585855',
  }
end

return palette
