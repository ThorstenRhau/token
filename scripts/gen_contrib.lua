#!/usr/bin/env luajit

-- Generates contrib/ theme files from the canonical palette.
-- Run: luajit scripts/gen_contrib.lua [--verify]

package.path = 'lua/?.lua;lua/?/init.lua;' .. package.path

local palette_fn = require('token.palette')
local terminal = require('token.terminal')

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function strip(hex)
  return hex:gsub('^#', '')
end

local function hex_to_rgb(hex)
  local h = strip(hex)
  return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
end

local function rgb_fmt(hex)
  local r, g, b = hex_to_rgb(hex)
  return string.format('0x%02x,0x%02x,0x%02x', r, g, b)
end

local function read_file(path)
  local f = io.open(path, 'r')
  if not f then
    return nil
  end
  local content = f:read('*a')
  f:close()
  return content
end

local function mkdir_p(path)
  -- paths are all hardcoded contrib/ subdirs, no quoting needed
  os.execute('mkdir -p ' .. path)
end

local function write_if_changed(path, content, verify)
  local existing = read_file(path)
  if existing == content then
    if not verify then
      io.write('skip: ' .. path .. ' (unchanged)\n')
    end
    return true
  end
  if verify then
    if existing == nil then
      io.stderr:write('missing: ' .. path .. '\n')
    else
      io.stderr:write('outdated: ' .. path .. '\n')
    end
    return false
  end
  local dir = path:match('(.+)/[^/]+$')
  if dir then
    mkdir_p(dir)
  end
  local f = assert(io.open(path, 'w'))
  f:write(content)
  f:close()
  io.write('wrote: ' .. path .. '\n')
  return true
end

local function extend_lines(dst, src)
  for _, line in ipairs(src) do
    dst[#dst + 1] = line
  end
end

-- ---------------------------------------------------------------------------
-- bat (.tmTheme)
-- ---------------------------------------------------------------------------

local function xml_escape(s)
  return s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

local function tmtheme_entry(name, scope, fg, style)
  local lines = {
    '    <dict>',
    '      <key>name</key>',
    '      <string>' .. xml_escape(name) .. '</string>',
    '      <key>scope</key>',
    '      <string>' .. xml_escape(scope) .. '</string>',
    '      <key>settings</key>',
    '      <dict>',
  }
  if fg then
    lines[#lines + 1] = '        <key>foreground</key>'
    lines[#lines + 1] = '        <string>' .. fg .. '</string>'
  end
  if style then
    lines[#lines + 1] = '        <key>fontStyle</key>'
    lines[#lines + 1] = '        <string>' .. style .. '</string>'
  end
  lines[#lines + 1] = '      </dict>'
  lines[#lines + 1] = '    </dict>'
  return table.concat(lines, '\n')
end

local function gen_bat(p, variant, _term)
  local name = 'token-' .. variant

  local scopes = {
    tmtheme_entry('Comment', 'comment, punctuation.definition.comment', p.fg2, 'italic'),
    tmtheme_entry('Keyword', 'keyword, keyword.control, keyword.other', p.accent2, nil),
    tmtheme_entry('Storage', 'storage, storage.modifier', p.accent2, nil),
    tmtheme_entry('Operator', 'keyword.operator', p.fg1, nil),
    tmtheme_entry('Function', 'entity.name.function, support.function, meta.function-call', p.accent, nil),
    tmtheme_entry('String', 'string, punctuation.definition.string', p.green, nil),
    tmtheme_entry('String escape', 'constant.character.escape', p.purple, nil),
    tmtheme_entry('Boolean', 'constant.language.boolean', p.accent2, nil),
    tmtheme_entry('Number', 'constant.numeric', p.purple, nil),
    tmtheme_entry('Constant', 'constant, constant.language, support.constant, variable.other.constant', p.purple, nil),
    tmtheme_entry('Type', 'storage.type, support.type, entity.name.type, entity.other.inherited-class', p.blue, nil),
    tmtheme_entry('Class', 'entity.name.type.class, support.class, entity.name.class', p.blue, nil),
    tmtheme_entry('Module', 'entity.name.namespace, entity.name.type.module, support.module', p.blue, nil),
    tmtheme_entry(
      'PreProc',
      'keyword.control.import, keyword.control.export, keyword.control.directive, keyword.preprocessor',
      p.purple,
      nil
    ),
    tmtheme_entry('Include', 'keyword.other.import, keyword.other.package, keyword.other.using', p.purple, nil),
    tmtheme_entry('Macro', 'entity.name.function.preprocessor', p.purple, nil),
    tmtheme_entry('Tag', 'entity.name.tag', p.purple, nil),
    tmtheme_entry('Tag attribute', 'entity.other.attribute-name', p.accent2, 'italic'),
    tmtheme_entry('Attribute', 'meta.annotation, storage.type.annotation', p.purple, nil),
    tmtheme_entry('Label', 'entity.name.label, constant.other.label', p.accent2, nil),
    tmtheme_entry('Special', 'variable.language, constant.language.null, constant.language.undefined', p.purple, nil),
    tmtheme_entry('Debug', 'keyword.other.debugger', p.red, nil),
    tmtheme_entry('Exception', 'keyword.control.exception, keyword.control.trycatch', p.red, nil),
    tmtheme_entry('Identifier', 'variable, support.variable, meta.definition.variable', p.fg0, nil),
    tmtheme_entry(
      'Property',
      'variable.object.property, variable.other.property, variable.other.member, meta.object-literal.key',
      p.fg0,
      nil
    ),
    tmtheme_entry('Delimiter', 'punctuation, meta.brace, meta.delimiter, meta.bracket', p.fg1, nil),
    tmtheme_entry('Parameter', 'variable.parameter', p.fg1, nil),
    -- Markup
    tmtheme_entry('Heading 1', 'heading.1.markdown, markup.heading.setext.1.markdown', p.accent, 'bold'),
    tmtheme_entry('Heading 2', 'heading.2.markdown, markup.heading.setext.2.markdown', p.accent2, 'bold'),
    tmtheme_entry('Heading 3', 'heading.3.markdown', p.yellow, 'bold'),
    tmtheme_entry('Heading 4', 'heading.4.markdown', p.blue, 'bold'),
    tmtheme_entry('Heading 5', 'heading.5.markdown', p.green, 'bold'),
    tmtheme_entry('Heading 6', 'heading.6.markdown', p.purple, 'bold'),
    tmtheme_entry('Heading delimiter', 'punctuation.definition.heading.markdown', p.fg2, nil),
    tmtheme_entry('Markup link', 'markup.underline.link, string.other.link', p.blue, 'underline'),
    tmtheme_entry(
      'Markup link text',
      'string.other.link.title.markdown, constant.other.reference.link.markdown',
      p.blue,
      nil
    ),
    tmtheme_entry(
      'Markup code',
      'markup.fenced_code.block.markdown, markup.inline.raw.string.markdown, markup.raw',
      p.green,
      nil
    ),
    tmtheme_entry(
      'Markup code delimiter',
      'punctuation.definition.markdown, punctuation.definition.raw.markdown',
      p.fg2,
      nil
    ),
    tmtheme_entry('Markup list', 'punctuation.definition.list.begin.markdown, markup.list', p.accent2, nil),
    tmtheme_entry('Markup bold', 'markup.bold', nil, 'bold'),
    tmtheme_entry('Markup italic', 'markup.italic', nil, 'italic'),
    tmtheme_entry('Markup bold italic', 'markup.bold markup.italic, markup.italic markup.bold', nil, 'italic bold'),
    tmtheme_entry('Markup quote', 'markup.quote', p.fg2, 'italic'),
    -- Diff
    tmtheme_entry('Diff added', 'markup.inserted, meta.diff.header.to-file', p.green, nil),
    tmtheme_entry('Diff deleted', 'markup.deleted, meta.diff.header.from-file', p.red, nil),
    tmtheme_entry('Diff changed', 'markup.changed', p.yellow, nil),
    -- GitGutter
    tmtheme_entry('GitGutter inserted', 'markup.inserted.git_gutter', p.green, nil),
    tmtheme_entry('GitGutter deleted', 'markup.deleted.git_gutter', p.red, nil),
    tmtheme_entry('GitGutter changed', 'markup.changed.git_gutter', p.yellow, nil),
    tmtheme_entry('GitGutter untracked', 'markup.untracked.git_gutter', p.fg3, nil),
    tmtheme_entry('GitGutter ignored', 'markup.ignored.git_gutter', p.fg3, nil),
  }

  local content = table.concat({
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">',
    '<!-- Generated by token colorscheme. Do not edit manually. -->',
    '<plist version="1.0">',
    '  <dict>',
    '    <key>name</key>',
    '    <string>' .. name .. '</string>',
    '    <key>settings</key>',
    '    <array>',
    '      <dict>',
    '        <key>settings</key>',
    '        <dict>',
    '          <key>background</key>',
    '          <string>' .. p.bg3 .. '</string>',
    '          <key>foreground</key>',
    '          <string>' .. p.fg0 .. '</string>',
    '          <key>caret</key>',
    '          <string>' .. p.fg0 .. '</string>',
    '          <key>lineHighlight</key>',
    '          <string>' .. p.bg5 .. '40</string>',
    '          <key>selection</key>',
    '          <string>' .. p.sel .. 'cc</string>',
    '          <key>activeGuide</key>',
    '          <string>' .. p.fg2 .. '20</string>',
    '          <key>findHighlight</key>',
    '          <string>' .. p.match .. '</string>',
    '          <key>misspelling</key>',
    '          <string>' .. p.red .. '</string>',
    '        </dict>',
    '      </dict>',
    table.concat(scopes, '\n'),
    '    </array>',
    '  </dict>',
    '</plist>',
    '',
  }, '\n')

  return { path = 'contrib/bat/' .. name .. '.tmTheme', content = content }
end

-- ---------------------------------------------------------------------------
-- delta (.gitconfig)
-- ---------------------------------------------------------------------------

local function gen_delta(dark, light, _dark_term, _light_term)
  local function section(p, variant)
    local is_dark = variant == 'dark'
    local lines = {
      '[delta "token-' .. variant .. '"]',
      '\t' .. (is_dark and 'dark' or 'light') .. ' = true',
      '\tsyntax-theme = token-' .. variant,
      '\tblame-palette = "' .. p.bg1 .. ' ' .. p.bg2 .. ' ' .. p.bg3 .. ' ' .. p.bg4 .. ' ' .. p.bg5 .. '"',
      '\tcommit-decoration-style = "' .. p.fg3 .. '" bold box ul',
      '\tfile-style = "' .. p.fg0 .. '"',
      '\tfile-decoration-style = "' .. p.fg3 .. '"',
      '\thunk-header-style = file line-number syntax',
      '\thunk-header-decoration-style = "' .. p.fg3 .. '" box ul',
      '\thunk-header-file-style = bold',
      '\thunk-header-line-number-style = bold "' .. p.fg2 .. '"',
      '\tline-numbers-left-style = "' .. p.fg3 .. '"',
      '\tline-numbers-right-style = "' .. p.fg3 .. '"',
      '\tline-numbers-minus-style = bold "' .. p.red .. '"',
      '\tline-numbers-plus-style = bold "' .. p.green .. '"',
      '\tline-numbers-zero-style = "' .. p.fg2 .. '"',
      '\tminus-style = syntax "' .. p.diff_del .. '"',
      '\tminus-non-emph-style = syntax "' .. p.diff_del .. '"',
      '\tminus-emph-style = bold syntax "' .. p.diff_del_inline .. '"',
      '\tminus-empty-line-marker-style = syntax "' .. p.diff_del .. '"',
      '\tplus-style = syntax "' .. p.diff_add .. '"',
      '\tplus-non-emph-style = syntax "' .. p.diff_add .. '"',
      '\tplus-emph-style = bold syntax "' .. p.diff_add_inline .. '"',
      '\tplus-empty-line-marker-style = syntax "' .. p.diff_add .. '"',
    }
    return table.concat(lines, '\n')
  end

  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Include this file from ~/.gitconfig, then enable one of these named delta features:',
    '#   [delta]',
    '#     features = token-dark',
    '',
    section(dark, 'dark'),
    '',
    section(light, 'light'),
    '',
  }, '\n')

  return { path = 'contrib/delta/token.gitconfig', content = content }
end

-- ---------------------------------------------------------------------------
-- fish (.theme)
-- ---------------------------------------------------------------------------

local function fish_theme_lines(p)
  local s = strip
  return {
    'fish_color_normal ' .. s(p.fg0),
    'fish_color_command ' .. s(p.blue),
    'fish_color_keyword ' .. s(p.accent2),
    'fish_color_quote ' .. s(p.green),
    'fish_color_redirection ' .. s(p.purple),
    'fish_color_end ' .. s(p.fg2),
    'fish_color_error ' .. s(p.red),
    'fish_color_param ' .. s(p.fg1),
    'fish_color_comment ' .. s(p.fg2),
    'fish_color_selection --reverse',
    'fish_color_operator ' .. s(p.accent),
    'fish_color_escape ' .. s(p.purple),
    'fish_color_autosuggestion ' .. s(p.fg3),
    'fish_color_cwd ' .. s(p.blue),
    'fish_color_user ' .. s(p.green),
    'fish_color_host ' .. s(p.blue),
    'fish_color_host_remote ' .. s(p.accent2),
    'fish_color_cancel ' .. s(p.red),
    'fish_color_search_match --background=' .. s(p.match),
    'fish_color_valid_path --underline',
    '',
    '# Pager',
    'fish_pager_color_progress ' .. s(p.accent),
    'fish_pager_color_prefix ' .. s(p.accent) .. ' --bold',
    'fish_pager_color_completion ' .. s(p.fg0),
    'fish_pager_color_description ' .. s(p.fg2),
    'fish_pager_color_selected_background --background=' .. s(p.sel),
    'fish_pager_color_selected_prefix ' .. s(p.accent) .. ' --bold',
    'fish_pager_color_selected_completion ' .. s(p.fg0),
    'fish_pager_color_selected_description ' .. s(p.fg2),
  }
end

local function gen_fish(dark, light, _dark_term, _light_term)
  local function add_variant(lines, name, p)
    lines[#lines + 1] = '[' .. name .. ']'
    lines[#lines + 1] = '# preferred_background: ' .. strip(p.bg3)
    extend_lines(lines, fish_theme_lines(p))
    lines[#lines + 1] = ''
  end

  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    "# name: 'token'",
    '',
  }

  add_variant(lines, 'dark', dark)
  add_variant(lines, 'light', light)
  add_variant(lines, 'unknown', dark)

  return { path = 'contrib/fish/token.theme', content = table.concat(lines, '\n') }
end

-- ---------------------------------------------------------------------------
-- fzf (fish script)
-- ---------------------------------------------------------------------------

local function gen_fzf(p, variant, _term)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from config.fish to append token colors to FZF_DEFAULT_OPTS.',
    '',
    'set -gx FZF_DEFAULT_OPTS (string join " " -- \\',
    '  $FZF_DEFAULT_OPTS \\',
    '  --border \\',
    "  '--color=fg:" .. p.fg0 .. ',bg:' .. p.bg3 .. ',hl:' .. p.accent .. "' \\",
    "  '--color=fg+:" .. p.fg0 .. ',bg+:' .. p.sel .. ',hl+:' .. p.accent .. "' \\",
    "  '--color=border:" .. p.fg3 .. ',header:' .. p.blue .. ',gutter:' .. p.bg3 .. "' \\",
    "  '--color=spinner:" .. p.accent2 .. ',info:' .. p.fg2 .. "' \\",
    "  '--color=pointer:" .. p.accent .. ',marker:' .. p.green .. ',prompt:' .. p.accent .. "')",
    '',
  }, '\n')

  return { path = 'contrib/fzf/token-' .. variant .. '.fish', content = content }
end

-- ---------------------------------------------------------------------------
-- ghostty (config fragment)
-- ---------------------------------------------------------------------------

local function gen_ghostty(p, variant, term)
  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    '',
    'background = ' .. p.bg3,
    'foreground = ' .. p.fg0,
    'cursor-color = ' .. p.fg0,
    'cursor-text = ' .. p.bg3,
    'selection-background = ' .. p.sel,
    'selection-foreground = ' .. p.fg0,
    '',
  }
  for i = 0, 15 do
    lines[#lines + 1] = 'palette = ' .. i .. '=' .. term[i]
  end
  lines[#lines + 1] = ''

  return { path = 'contrib/ghostty/token-' .. variant, content = table.concat(lines, '\n') }
end

-- ---------------------------------------------------------------------------
-- lazygit (YAML)
-- ---------------------------------------------------------------------------

local function gen_lazygit(p, variant, _term)
  local content = table.concat({
    '# yaml-language-server: $schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json',
    '# Generated by token colorscheme. Do not edit manually.',
    '# Merge this into your lazygit config.yml.',
    '',
    'gui:',
    '  theme:',
    '    activeBorderColor:',
    '      - "' .. p.accent .. '"',
    '      - bold',
    '    inactiveBorderColor:',
    '      - "' .. p.fg3 .. '"',
    '    searchingActiveBorderColor:',
    '      - "' .. p.yellow .. '"',
    '      - bold',
    '    optionsTextColor:',
    '      - "' .. p.blue .. '"',
    '    selectedLineBgColor:',
    '      - "' .. p.sel .. '"',
    '    inactiveViewSelectedLineBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    cherryPickedCommitFgColor:',
    '      - "' .. p.blue .. '"',
    '    cherryPickedCommitBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    markedBaseCommitFgColor:',
    '      - "' .. p.purple .. '"',
    '    markedBaseCommitBgColor:',
    '      - "' .. p.bg4 .. '"',
    '    unstagedChangesColor:',
    '      - "' .. p.red .. '"',
    '    defaultFgColor:',
    '      - "' .. p.fg0 .. '"',
    '',
  }, '\n')

  return { path = 'contrib/lazygit/token-' .. variant .. '.yml', content = content }
end

-- ---------------------------------------------------------------------------
-- ripgrep (.ripgreprc)
-- ---------------------------------------------------------------------------

local function gen_ripgrep(p, variant, _term)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '--colors=match:none',
    '--colors=match:fg:' .. rgb_fmt(p.accent),
    '--colors=match:style:bold',
    '--colors=path:none',
    '--colors=path:fg:' .. rgb_fmt(p.blue),
    '--colors=path:style:nobold',
    '--colors=line:none',
    '--colors=line:fg:' .. rgb_fmt(p.fg2),
    '--colors=line:style:nobold',
    '--colors=column:none',
    '--colors=column:fg:' .. rgb_fmt(p.fg3),
    '--colors=column:style:nobold',
    '',
  }, '\n')

  return { path = 'contrib/ripgrep/token-' .. variant .. '.ripgreprc', content = content }
end

-- ---------------------------------------------------------------------------
-- starship (TOML palette)
-- ---------------------------------------------------------------------------

local function gen_starship(p, variant, _term)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Add palette = "token" to your starship.toml to use these colors.',
    '',
    '[palettes.token]',
    'bg      = "' .. p.bg3 .. '"',
    'fg      = "' .. p.fg0 .. '"',
    'muted   = "' .. p.fg2 .. '"',
    'subtle  = "' .. p.fg3 .. '"',
    'accent  = "' .. p.accent .. '"',
    'accent2 = "' .. p.accent2 .. '"',
    'blue    = "' .. p.blue .. '"',
    'green   = "' .. p.green .. '"',
    'red     = "' .. p.red .. '"',
    'yellow  = "' .. p.yellow .. '"',
    'purple  = "' .. p.purple .. '"',
    'cyan    = "' .. p.cyan .. '"',
    '',
  }, '\n')

  return { path = 'contrib/starship/token-' .. variant .. '.toml', content = content }
end

-- ---------------------------------------------------------------------------
-- tmux (.conf)
-- ---------------------------------------------------------------------------

local function gen_tmux(p, variant, _term)
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your tmux.conf: source-file /path/to/token-' .. variant .. '.conf',
    '',
    '# Status bar',
    'set -g status-style "bg=' .. p.bg0 .. ',fg=' .. p.fg1 .. '"',
    'set -g status-left-style "bg=' .. p.bg0 .. ',fg=' .. p.accent .. ',bold"',
    'set -g status-right-style "bg=' .. p.bg0 .. ',fg=' .. p.fg2 .. '"',
    '',
    '# Window status',
    'setw -g window-status-style "bg=' .. p.bg0 .. ',fg=' .. p.fg2 .. '"',
    'setw -g window-status-current-style "bg=' .. p.bg0 .. ',fg=' .. p.blue .. ',bold"',
    'setw -g window-status-activity-style "bg=' .. p.bg0 .. ',fg=' .. p.yellow .. '"',
    'setw -g window-status-bell-style "bg=' .. p.bg0 .. ',fg=' .. p.red .. '"',
    '',
    '# Pane borders',
    'set -g pane-border-style "fg=' .. p.fg3 .. '"',
    'set -g pane-active-border-style "fg=' .. p.blue .. '"',
    '',
    '# Messages',
    'set -g message-style "bg=' .. p.bg3 .. ',fg=' .. p.fg0 .. '"',
    'set -g message-command-style "bg=' .. p.bg3 .. ',fg=' .. p.fg0 .. '"',
    '',
    '# Copy mode',
    'setw -g mode-style "bg=' .. p.sel .. ',fg=' .. p.fg0 .. '"',
    '',
    '# Clock',
    'setw -g clock-mode-colour "' .. p.accent .. '"',
    '',
    '# Display panes',
    'set -g display-panes-active-colour "' .. p.accent .. '"',
    'set -g display-panes-colour "' .. p.fg3 .. '"',
    '',
  }, '\n')

  return { path = 'contrib/tmux/token-' .. variant .. '.conf', content = content }
end

-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

local function main()
  local verify = false
  for _, a in ipairs(arg) do
    if a == '--verify' then
      verify = true
    end
  end

  local dark = palette_fn('dark')
  local light = palette_fn('light')
  local dark_term = terminal.colors(dark, true)
  local light_term = terminal.colors(light, false)

  local files = {}

  for _, variant in ipairs({ 'dark', 'light' }) do
    local p = variant == 'dark' and dark or light
    local term = variant == 'dark' and dark_term or light_term
    files[#files + 1] = gen_bat(p, variant, term)
    files[#files + 1] = gen_fzf(p, variant, term)
    files[#files + 1] = gen_ghostty(p, variant, term)
    files[#files + 1] = gen_lazygit(p, variant)
    files[#files + 1] = gen_ripgrep(p, variant, term)
    files[#files + 1] = gen_starship(p, variant, term)
    files[#files + 1] = gen_tmux(p, variant, term)
  end

  files[#files + 1] = gen_fish(dark, light, dark_term, light_term)
  files[#files + 1] = gen_delta(dark, light, dark_term, light_term)

  local ok = true
  for _, f in ipairs(files) do
    if not write_if_changed(f.path, f.content, verify) then
      ok = false
    end
  end

  if verify and not ok then
    io.stderr:write('contrib files are out of date. Run: make contrib\n')
    os.exit(1)
  end
end

main()
