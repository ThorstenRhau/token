#!/usr/bin/env luajit

-- Generates contrib/ theme files from the canonical palette.
-- Run: luajit scripts/gen_contrib.lua [--verify]

package.path = 'lua/?.lua;lua/?/init.lua;scripts/?.lua;' .. package.path

local gen_emacs = require('gen_emacs')
local palette_fn = require('token.palette')
local terminal = require('token.terminal')

local lib = require('gen_lib')
local strip = lib.strip
local rgb_fmt = lib.rgb_fmt
local write_if_changed = lib.write_if_changed
local extend_lines = lib.extend_lines

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
    local base_del = is_dark and p.diff_del_inline or p.diff_del
    local base_add = is_dark and p.diff_add_inline or p.diff_add
    local emph_del = is_dark and p.diff_del_strong or p.diff_del_inline
    local emph_add = is_dark and p.diff_add_strong or p.diff_add_inline
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
      '\tminus-style = syntax "' .. base_del .. '"',
      '\tminus-non-emph-style = syntax "' .. base_del .. '"',
      '\tminus-emph-style = bold "' .. p.fg0 .. '" "' .. emph_del .. '"',
      '\tminus-empty-line-marker-style = syntax "' .. base_del .. '"',
      '\tplus-style = syntax "' .. base_add .. '"',
      '\tplus-non-emph-style = syntax "' .. base_add .. '"',
      '\tplus-emph-style = bold "' .. p.fg0 .. '" "' .. emph_add .. '"',
      '\tplus-empty-line-marker-style = syntax "' .. base_add .. '"',
      '\tmap-styles = "bold purple => syntax \''
        .. (is_dark and p.diff_text or p.diff_change)
        .. "', bold cyan => syntax '"
        .. (is_dark and p.diff_text or p.diff_change)
        .. '\'"',
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
    'fish_color_autosuggestion ' .. s(p.line_nr),
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
    'orange  = "' .. p.orange .. '"',
    '',
  }, '\n')

  return { path = 'contrib/starship/token-' .. variant .. '.toml', content = content }
end

-- ---------------------------------------------------------------------------
-- tmux (.conf)
-- ---------------------------------------------------------------------------

local function gen_tmux(p, variant, _term)
  local status_bg = variant == 'light' and p.bg4 or p.bg0
  local content = table.concat({
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your tmux.conf: source-file /path/to/token-' .. variant .. '.conf',
    '',
    '# Status bar',
    'set -g status-style "bg=' .. status_bg .. ',fg=' .. p.fg1 .. '"',
    'set -g status-left-style "bg=' .. status_bg .. ',fg=' .. p.accent .. ',bold"',
    'set -g status-right-style "bg=' .. status_bg .. ',fg=' .. p.fg2 .. '"',
    '',
    '# Window status',
    'setw -g window-status-style "bg=' .. status_bg .. ',fg=' .. p.fg2 .. '"',
    'setw -g window-status-current-style "bg=' .. status_bg .. ',fg=' .. p.blue .. ',bold"',
    'setw -g window-status-activity-style "bg=' .. status_bg .. ',fg=' .. p.yellow .. '"',
    'setw -g window-status-bell-style "bg=' .. status_bg .. ',fg=' .. p.red .. '"',
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
-- zsh (sourceable .zsh)
-- ---------------------------------------------------------------------------

local function gen_zsh(p, variant, _term)
  local s = strip
  local F = 'FAST_HIGHLIGHT_STYLES'
  local lines = {
    '# Generated by token colorscheme. Do not edit manually.',
    '# Source this file from your .zshrc to apply token ' .. variant .. ' colors.',
    '',
    '# fast-syntax-highlighting',
    'typeset -gA ' .. F,
    F .. "[default]='none'",
    F .. "[unknown-token]='fg=#" .. s(p.red) .. "'",
    F .. "[reserved-word]='fg=#" .. s(p.accent2) .. "'",
    F .. "[alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[suffix-alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[global-alias]='fg=#" .. s(p.blue) .. "'",
    F .. "[builtin]='fg=#" .. s(p.blue) .. "'",
    F .. "[function]='fg=#" .. s(p.accent) .. "'",
    F .. "[command]='fg=#" .. s(p.blue) .. "'",
    F .. "[precommand]='fg=#" .. s(p.accent2) .. "'",
    F .. "[subcommand]='fg=#" .. s(p.accent2) .. "'",
    F .. "[commandseparator]='fg=#" .. s(p.fg2) .. "'",
    F .. "[hashed-command]='fg=#" .. s(p.blue) .. "'",
    F .. "[autodirectory]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path_pathseparator]='fg=#" .. s(p.fg2) .. ",underline'",
    F .. "[path_prefix]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[path-to-dir]='fg=#" .. s(p.fg1) .. ",underline'",
    F .. "[globbing]='fg=#" .. s(p.purple) .. "'",
    F .. "[globbing-ext]='fg=#" .. s(p.purple) .. "'",
    F .. "[history-expansion]='fg=#" .. s(p.purple) .. "'",
    F .. "[back-quoted-argument]='fg=#" .. s(p.fg2) .. "'",
    F .. "[single-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[double-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[dollar-quoted-argument]='fg=#" .. s(p.green) .. "'",
    F .. "[single-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[double-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[dollar-quoted-argument-unclosed]='fg=#" .. s(p.red) .. ",underline'",
    F .. "[back-or-dollar-double-quoted-argument]='fg=#" .. s(p.purple) .. "'",
    F .. "[back-dollar-quoted-argument]='fg=#" .. s(p.purple) .. "'",
    F .. "[assign]='fg=#" .. s(p.fg0) .. "'",
    F .. "[assign-array-bracket]='fg=#" .. s(p.green) .. "'",
    F .. "[redirection]='fg=#" .. s(p.purple) .. "'",
    F .. "[comment]='fg=#" .. s(p.fg2) .. ",italic'",
    F .. "[single-hyphen-option]='fg=#" .. s(p.fg1) .. "'",
    F .. "[double-hyphen-option]='fg=#" .. s(p.fg1) .. "'",
    F .. "[variable]='fg=#" .. s(p.purple) .. "'",
    F .. "[for-loop-variable]='fg=#" .. s(p.fg0) .. "'",
    F .. "[for-loop-operator]='fg=#" .. s(p.accent2) .. "'",
    F .. "[for-loop-number]='fg=#" .. s(p.purple) .. "'",
    F .. "[for-loop-separator]='fg=#" .. s(p.fg2) .. "'",
    F .. "[here-string-tri]='fg=#" .. s(p.accent2) .. "'",
    F .. "[here-string-text]='none'",
    F .. "[here-string-var]='fg=#" .. s(p.purple) .. "'",
    F .. "[mathvar]='fg=#" .. s(p.blue) .. "'",
    F .. "[mathnum]='fg=#" .. s(p.purple) .. "'",
    F .. "[matherr]='fg=#" .. s(p.red) .. "'",
    F .. "[case-input]='fg=#" .. s(p.green) .. "'",
    F .. "[case-parentheses]='fg=#" .. s(p.accent2) .. "'",
    F .. "[case-condition]='fg=#" .. s(p.blue) .. "'",
    F .. "[paired-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[bracket-level-1]='fg=#" .. s(p.green) .. "'",
    F .. "[bracket-level-2]='fg=#" .. s(p.accent2) .. "'",
    F .. "[bracket-level-3]='fg=#" .. s(p.cyan) .. "'",
    F .. "[single-sq-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[double-sq-bracket]='fg=#" .. s(p.blue) .. "'",
    F .. "[double-paren]='fg=#" .. s(p.accent2) .. "'",
    F .. "[correct-subtle]='fg=#" .. s(p.blue) .. "'",
    F .. "[incorrect-subtle]='fg=#" .. s(p.red) .. "'",
    F .. "[subtle-separator]='fg=#" .. s(p.green) .. "'",
    '',
    '# Completion',
    "zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'pi=33' 'ex=31' 'bd=34;46' 'cd=34;43'",
    "zstyle ':completion:*:descriptions' format '%F{#" .. s(p.fg2) .. "}-- %d --%f'",
    "zstyle ':completion:*:messages' format '%F{#" .. s(p.fg2) .. "}-- %d --%f'",
    "zstyle ':completion:*:warnings' format '%F{#" .. s(p.red) .. "}-- no matches --%f'",
    '',
    '# Prompt helpers',
    "export TOKEN_FG='" .. p.fg0 .. "'",
    "export TOKEN_BG='" .. p.bg3 .. "'",
    "export TOKEN_ACCENT='" .. p.accent .. "'",
    "export TOKEN_ACCENT2='" .. p.accent2 .. "'",
    "export TOKEN_BLUE='" .. p.blue .. "'",
    "export TOKEN_GREEN='" .. p.green .. "'",
    "export TOKEN_RED='" .. p.red .. "'",
    "export TOKEN_YELLOW='" .. p.yellow .. "'",
    "export TOKEN_PURPLE='" .. p.purple .. "'",
    "export TOKEN_CYAN='" .. p.cyan .. "'",
    "export TOKEN_MUTED='" .. p.fg2 .. "'",
    '',
  }

  return { path = 'contrib/zsh/token-' .. variant .. '.zsh', content = table.concat(lines, '\n') }
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
    files[#files + 1] = gen_emacs(p, variant)
    files[#files + 1] = gen_fzf(p, variant, term)
    files[#files + 1] = gen_ghostty(p, variant, term)
    files[#files + 1] = gen_lazygit(p, variant)
    files[#files + 1] = gen_ripgrep(p, variant, term)
    files[#files + 1] = gen_starship(p, variant, term)
    files[#files + 1] = gen_tmux(p, variant, term)
    files[#files + 1] = gen_zsh(p, variant, term)
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
