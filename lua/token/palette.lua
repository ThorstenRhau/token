---Token's semantic color palette for one background variant.
---All values are six-digit hexadecimal colors and may be mutated by `token.Config.on_colors`.
---@class TokenPalette
-- Background ramp
---@field bg0 string Recessed background used by floating windows and shadows.
---@field bg1 string Secondary background used by menus, status lines, and plugin panels.
---@field bg2 string Inactive background used by gutters, folded text, and inactive windows.
---@field bg3 string Primary editor background used by `Normal`.
---@field bg4 string Raised background used by cursor lines, separators, and inactive UI details.
---@field bg5 string Strong raised background used by references, active snippets, and quickfix selections.
-- Foreground ramp
---@field fg0 string Primary foreground used by normal text and identifiers.
---@field fg1 string Secondary foreground used by operators, delimiters, and emphasized UI text.
---@field fg2 string Muted foreground used by comments, concealed text, and secondary UI text.
---@field fg3 string Most subdued foreground used by borders, inactive UI, and nonessential text.
-- Accent hues
---@field accent string Primary accent used by functions, titles, active search, and focused UI.
---@field accent2 string Secondary accent used by keywords, control flow, and alternate active UI.
-- Syntax and status hues
---@field blue string Blue semantic hue used by types, paths, informational messages, and directories.
---@field green string Green semantic hue used by strings, additions, success states, and positive messages.
---@field red string Red semantic hue used by errors, deletions, exceptions, and destructive states.
---@field yellow string Yellow semantic hue used by warnings, changes, and pending states.
---@field purple string Purple semantic hue used by constants, preprocessor groups, and special syntax.
---@field cyan string Cyan semantic hue used by hints and auxiliary information.
---@field orange string Orange semantic hue used by numeric and boolean literals.
---@field olive string Warm olive hue used by the current line number and tertiary headings.
-- Bright terminal variants
---@field bright_green string Bright ANSI green used for terminal color 10.
---@field bright_blue string Bright ANSI blue used for terminal color 12.
---@field bright_purple string Bright ANSI purple used for terminal color 13.
---@field bright_cyan string Bright ANSI cyan used for terminal color 14.
-- Diff backgrounds
---@field diff_add string Background for added lines and addition previews.
---@field diff_del string Background for deleted lines and deletion previews.
---@field diff_add_inline string Stronger background for inline added text.
---@field diff_del_inline string Stronger background for inline deleted text.
---@field diff_add_strong string Strongest background for emphasized additions.
---@field diff_del_strong string Strongest background for emphasized deletions.
---@field diff_change string Background for changed lines.
---@field diff_text string Background for changed text within changed lines.
-- Diagnostic backgrounds
---@field diag_error string Background for virtual-text and diagnostic error emphasis.
---@field diag_warn string Background for virtual-text and diagnostic warning emphasis.
---@field diag_info string Background for virtual-text and diagnostic information emphasis.
---@field diag_hint string Background for virtual-text and diagnostic hint emphasis.
-- UI elements
---@field sel string Background for visual selections, selected menu items, and focused rows.
---@field match string Background for search matches and active snippet placeholders.
---@field indent string Foreground for ordinary indentation guides and whitespace markers.
---@field indent_active string Foreground for active indentation scopes.
---@field line_nr string Foreground for ordinary line numbers.
-- Git signs
---@field gsign_add string Foreground for unstaged added-line signs.
---@field gsign_change string Foreground for unstaged changed-line signs.
---@field gsign_del string Foreground for unstaged deleted-line signs.
---@field gsign_untracked string Foreground for untracked-line signs.
---@field gsign_add_staged string Foreground for staged added-line signs.
---@field gsign_change_staged string Foreground for staged changed-line signs.
---@field gsign_del_staged string Foreground for staged deleted-line signs.
---@field gsign_untracked_staged string Foreground for staged untracked-line signs.

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
      fg0 = '#323128',
      fg1 = '#565141',
      fg2 = '#504b44',
      fg3 = '#524e46',
      -- Accent hues
      accent = '#863716',
      accent2 = '#6d4717',
      -- Syntax hues
      blue = '#315270',
      green = '#365a33',
      red = '#ad5253',
      yellow = '#857238',
      purple = '#573c72',
      cyan = '#185b5b',
      orange = '#613500',
      olive = '#465509',
      -- Bright variants
      bright_green = '#274b24',
      bright_blue = '#335471',
      bright_purple = '#6b5488',
      bright_cyan = '#387272',
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
      diag_error = '#ffdada',
      diag_warn = '#e2dac0',
      diag_info = '#dae4f2',
      diag_hint = '#d6eeea',
      -- UI elements
      sel = '#dddcd6',
      match = '#e8d8b0',
      indent = '#e0ddd8',
      indent_active = '#a8a49c',
      line_nr = '#b4b2ab',
      -- Git sign column
      gsign_add = '#23831e',
      gsign_change = '#9d6600',
      gsign_del = '#c82a2a',
      gsign_untracked = '#a5a29b',
      gsign_add_staged = '#5ea059',
      gsign_change_staged = '#b28c42',
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
    fg0 = '#c3c0b8',
    fg1 = '#a6a198',
    fg2 = '#a19c94',
    fg3 = '#8a8884',
    -- Accent hues
    accent = '#f4906f',
    accent2 = '#f7c699',
    -- Syntax hues
    blue = '#81a5c4',
    green = '#8fb78c',
    red = '#d68585',
    yellow = '#b99d4a',
    purple = '#b195ca',
    cyan = '#7dbbba',
    orange = '#d6924c',
    olive = '#a9b76c',
    -- Bright variants
    bright_green = '#a0c89d',
    bright_blue = '#8fb1cb',
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
    diag_error = '#3c2024',
    diag_warn = '#444039',
    diag_info = '#1e2634',
    diag_hint = '#1c2e2e',
    -- UI elements
    sel = '#3a3a37',
    match = '#4a4030',
    indent = '#323230',
    indent_active = '#626260',
    line_nr = '#575755',
    -- Git sign column
    gsign_add = '#7ca379',
    gsign_change = '#c3a753',
    gsign_del = '#c57677',
    gsign_untracked = '#797570',
    gsign_add_staged = '#5e795c',
    gsign_change_staged = '#87743f',
    gsign_del_staged = '#995e5f',
    gsign_untracked_staged = '#595855',
  }
end

return palette
