---Token Melange maps the Melange colorscheme onto Token's semantic keys. Surfaces, selection,
---diff and diagnostic tints come from Melange directly. Foregrounds keep Melange's hue and
---chroma with lightness fitted to Token's contrast tiers: warm orange, gold and coral carry
---control flow, functions and operators, and cool blue, magenta and cyan carry data.
---
---Melange palette: https://github.com/savq/melange-nvim
---
---MIT License
---
---Copyright (c) 2021 Sergio Alejandro Vargas
---
---Permission is hereby granted, free of charge, to any person obtaining a copy
---of this software and associated documentation files (the "Software"), to deal
---in the Software without restriction, including without limitation the rights
---to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
---copies of the Software, and to permit persons to whom the Software is
---furnished to do so, subject to the following conditions:
---
---The above copyright notice and this permission notice shall be included in all
---copies or substantial portions of the Software.
---
---THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
---IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
---FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
---AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
---LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
---OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
---SOFTWARE.

---@param background 'dark'|'light'
---@return TokenPalette
local function palette(background)
  if background ~= 'dark' and background ~= 'light' then
    error('palette: expected "dark" or "light", got: ' .. tostring(background))
  end

  if background == 'light' then
    return {
      bg0 = '#e3dbd4',
      bg1 = '#e8e4e0',
      bg2 = '#eeedeb',
      bg3 = '#f1f1f1',
      bg4 = '#e9e1db',
      bg5 = '#e3ddd8',
      fg0 = '#39281f',
      fg1 = '#594a41',
      fg2 = '#594334',
      fg3 = '#5f4436',
      comment = '#735c4c',
      accent = '#674400',
      accent2 = '#773a03',
      blue = '#3b5198',
      green = '#2a563c',
      red = '#9c5364',
      yellow = '#976502',
      purple = '#843476',
      cyan = '#355b60',
      orange = '#ac0a1f',
      olive = '#773a03',
      property = '#655066',
      bright_green = '#164729',
      bright_blue = '#384792',
      bright_purple = '#954986',
      bright_cyan = '#436b70',
      diff_add = '#d0e9d1',
      diff_del = '#f1dedf',
      diff_add_inline = '#b5d9b7',
      diff_del_inline = '#e5c3c5',
      diff_add_strong = '#9cc79f',
      diff_del_strong = '#d6a5a8',
      diff_change = '#e8e0e8',
      diff_text = '#dccbdc',
      diag_error = '#f1dedf',
      diag_warn = '#eedfc6',
      diag_info = '#e0e2e8',
      diag_hint = '#cde8e7',
      sel = '#d9d3ce',
      match = '#e0c6a2',
      match_current = '#a9d6d4',
      indent = '#ded4d1',
      indent_active = '#ad9b91',
      whitespace = '#c2b8b3',
      line_nr = '#a1806e',
      faded = '#8b7262',
      gsign_add = '#4b774d',
      gsign_change = '#995492',
      gsign_del = '#964e61',
      gsign_untracked = '#ab998e',
      gsign_add_staged = '#69966f',
      gsign_change_staged = '#b776b4',
      gsign_del_staged = '#be7483',
      gsign_untracked_staged = '#8d786e',
    }
  end

  return {
    bg0 = '#1e1b18',
    bg1 = '#221f1c',
    bg2 = '#25221f',
    bg3 = '#292522',
    bg4 = '#34302c',
    bg5 = '#3b3632',
    fg0 = '#c9beb2',
    fg1 = '#b5ada3',
    fg2 = '#af997d',
    fg3 = '#988573',
    comment = '#af997d',
    accent = '#cda44f',
    accent2 = '#fcc493',
    blue = '#a2a9d0',
    green = '#84b894',
    red = '#c88b8f',
    yellow = '#c19a47',
    purple = '#d59ec6',
    cyan = '#86aeb1',
    orange = '#ee907c',
    olive = '#ea9f63',
    property = '#b298b0',
    bright_green = '#95c9a8',
    bright_blue = '#b3bae1',
    bright_purple = '#dfadd3',
    bright_cyan = '#98c4c7',
    diff_add = '#233524',
    diff_del = '#3a2224',
    diff_add_inline = '#2f4a31',
    diff_del_inline = '#56282c',
    diff_add_strong = '#3d633f',
    diff_del_strong = '#7d2a2f',
    diff_change = '#352833',
    diff_text = '#422741',
    diag_error = '#3a2224',
    diag_warn = '#3d3424',
    diag_info = '#273142',
    diag_hint = '#253333',
    sel = '#403a36',
    match = '#554631',
    match_current = '#2f4a60',
    indent = '#3a3028',
    indent_active = '#6c6053',
    whitespace = '#53483e',
    line_nr = '#786754',
    faded = '#967e65',
    gsign_add = '#82a180',
    gsign_change = '#ce98c8',
    gsign_del = '#ba7b7d',
    gsign_untracked = '#837360',
    gsign_add_staged = '#5c795e',
    gsign_change_staged = '#986496',
    gsign_del_staged = '#985e63',
    gsign_untracked_staged = '#665546',
  }
end

return palette
