# token

Token is a warm, muted Neovim 0.12+ colorscheme with dark and light variants,
selective plugin integrations, and an optional configuration API.

Terminal themes for Ghostty, fish, delta, tmux and others are generated from the
same palette file, so everything matches without extra work.

## Features

- Dark and light variants, switching at runtime via `vim.o.background`
- Treesitter capture groups for accurate syntax highlighting
- LSP semantic token highlights
- LSP diagnostic signs, virtual text, and underlines
- Diff highlights for buffers and signs
- Legacy syntax group coverage for non-Treesitter filetypes
- Terminal color support (ANSI colors 0–15)
- Lualine theme included
- Opt-in plugin integrations and configuration-keyed bytecode compilation
- Contrib themes for external tools and apps generated from the same palette

## Showcase

| Dark                                            | Light                                            |
| ----------------------------------------------- | ------------------------------------------------ |
| ![Dark variant 1](https://rhau.se/token-d1.png) | ![Light variant 1](https://rhau.se/token-l1.png) |
| ![Dark variant 2](https://rhau.se/token-d2.png) | ![Light variant 2](https://rhau.se/token-l2.png) |

## Install

```lua
-- vim.pack (Neovim 0.12+)
vim.pack.add({ 'https://github.com/ThorstenRhau/token' })

-- lazy.nvim
{ 'ThorstenRhau/token' }
```

## Usage

```lua
local token = require('token')

---@type token.Config
local config = {
  transparent = false,
  plugins = { gitsigns = true, snacks = true },
}

token.setup(config)

vim.cmd.colorscheme('token')
```

Respects `vim.o.background`. Set `dark` or `light` before loading the
colorscheme, or change it at runtime to switch variants.

`setup()` is optional. Each call starts from the defaults and deep-merges the
provided options. It does not reload an active colorscheme automatically.

## Token v2

Token is configurable starting with v2. Call `require('token').setup()` before
loading the colorscheme to customize its appearance, semantic styles, palette,
highlights, terminal colors, and plugin integrations. Calling `setup()` is
optional, so the minimal `vim.cmd.colorscheme('token')` configuration continues
to work.

V2 also changes plugin integrations from eagerly loading every supported module
to a core-only default. Select integrations under `plugins`, or use
`plugins = { all = true }` to retain the v1 integration behavior.

## Configuration

```lua
local token = require('token')

---@type token.Config
local config = {
  -- Clear base UI surfaces while preserving semantic backgrounds.
  transparent = false,

  -- Set Neovim's ANSI terminal palette when the colorscheme loads.
  terminal_colors = true,

  -- Give inactive windows a quieter foreground and background.
  dim_inactive = false,

  -- Disable an attribute globally, including in overrides and plugin groups.
  attributes = {
    bold = true,
    italic = true,
    underline = true,
    undercurl = true,
    strikethrough = true,
  },

  -- Overlay attributes on semantic highlight categories.
  styles = {
    booleans = {},
    comments = {},
    conditionals = {},
    constants = {},
    functions = {},
    keywords = {},
    loops = {},
    numbers = {},
    operators = {},
    preprocessor = {},
    properties = {},
    strings = {},
    types = {},
    variables = {},
  },

  -- Apply shared colors first, then the active background variant.
  colors = { all = {}, dark = {}, light = {} },

  -- Replace complete highlight definitions; variant entries take precedence.
  highlights = { all = {}, dark = {}, light = {} },

  -- Integrations are opt-in. `all = true` restores v1 behavior.
  plugins = {
    all = false,
    gitsigns = true,
    snacks = true,
  },

  -- Mutate the configured palette after declarative color overrides.
  on_colors = function(colors, background) end,

  -- Mutate final highlights before global attribute gates are applied.
  on_highlights = function(highlights, colors, background) end,
}

token.setup(config)
```

Style entries accept the boolean attributes shown under `attributes`. They are
overlaid on Token's existing definitions. Broad categories run before their
more specific counterparts: `keywords` before `preprocessor`, `conditionals`,
and `loops`, `constants` before `booleans`, and `variables` before `properties`.

Color overrides apply in the order `all`, current background, then `on_colors`.
Existing palette keys and additional keys must contain `#RRGGBB` values.
Highlight entries are complete `nvim_set_hl` definitions: a variant entry
replaces an entry with the same name from `all`. `on_highlights` runs afterward
and can mutate existing definitions. Both callbacks mutate their arguments in
place and receive an explicit `dark` or `light` background.

Transparency clears Token's base surfaces while retaining cursor-line,
selection, search, diff, diagnostic, and accent backgrounds. Highlight
overrides and callbacks can restore individual backgrounds. `dim_inactive`
uses `fg1` and `bg1` for core and enabled-plugin `NormalNC` groups. Global
attribute gates run last and also apply to plugin, callback, and Lualine output.
Links to targets outside Token are preserved because Neovim links cannot combine
inherited styling with attribute overrides.

Unknown options, style categories, attributes, and plugin names are rejected
with a `token:` error.

## Compilation

Token works out of the box without compilation. For faster startup, you can
pre-compile the theme into bytecode:

```vim
:TokenCompile
```

This writes configuration-keyed dark and light variants to
`stdpath('cache')/token/`. On next load, matching cached bytecode is used instead
of the dynamic highlight path. Compiled output contains only enabled
integrations and omits terminal assignments when `terminal_colors = false`.

Rerun `:TokenCompile` after changing Token's source or any global, captured, or
external inputs read by callbacks. Static configuration and callback-body
changes use a different cache key and fall back dynamically until recompiled.
Legacy unkeyed caches are ignored. A corrupt matching cache is deleted
automatically and the dynamic path is used as fallback.

## Supported plugins

Plugin integrations are opt-in and the default is core-only. Set
`plugins = { all = true }` to restore the historical behavior of loading every
integration. An explicit boolean overrides `all`. Keys match the module
filenames below; Lualine remains available on demand and is not selected here.

`blink`, `blink_indent`, `claudecode`, `cmp`, `dap_ui`, `diffview`, `flash`,
`fugitive`, `fzf`, `gitsigns`, `hlchunk`, `ibl`, `lazy`, `markview`, `mason`,
`matchup`, `mini`, `neo_tree`, `neogit`, `noice`, `nvimtree`, `oil`,
`render_markdown`, `snacks`, `telescope`, `todo_comments`,
`treesitter_context`, `trouble`, and `whichkey`.

blink.indent defaults to rainbow scope guides. To use Token's muted guides and
single brighter neutral scope guide, configure it with Token's neutral groups:

```lua
require('blink.indent').setup({
  scope = {
    highlights = { 'BlinkIndentScope' },
    underline = {
      highlights = { 'BlinkIndentUnderline' },
    },
  },
})
```

## Contrib themes

Pre-generated themes for external tools and apps. Auto-generated from the
palette; rebuild after palette changes with `make contrib`.

| Tool                                                                                     | Files                                                     | Usage                                                                                                            |
| ---------------------------------------------------------------------------------------- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| [bat](https://github.com/sharkdp/bat)                                                    | `contrib/bat/token-{dark,light}.tmTheme`                  | Copy to bat themes dir, run `bat cache --build`                                                                  |
| [Blink Shell](https://blink.sh/)                                                         | `contrib/blink/token-{dark,light}.js`                     | Paste the raw `token-dark.js` or `token-light.js` URL in Appearance > Themes > New Theme                         |
| [Carapace](https://carapace-sh.github.io/carapace-bin/)                                  | `contrib/carapace/token-{dark,light}.json`                | Merge the selected `carapace` object into `~/.config/carapace/styles.json`                                       |
| [ChatGPT desktop](https://chatgpt.com/download/)                                         | `contrib/chatgpt/token-{dark,light}.txt`                  | Paste the share string into Settings > Appearance > Import for the matching theme variant                        |
| [delta](https://github.com/dandavison/delta)                                             | `contrib/delta/token.gitconfig`                           | Include from `~/.gitconfig`, set `features = token-dark` in `[delta]`                                            |
| [emacs](https://www.gnu.org/software/emacs/)                                             | `contrib/emacs/token-{dark,light}-theme.el`               | Copy to `~/.emacs.d/themes/`, then `(load-theme 'token-dark t)`                                                  |
| [fish](https://fishshell.com/)                                                           | `contrib/fish/token.theme`                                | Copy to `~/.config/fish/themes/`, then run `fish_config theme choose token`                                      |
| [fzf](https://github.com/junegunn/fzf)                                                   | `contrib/fzf/token-{dark,light}.{fish,zsh}`               | Source the matching Fish or Zsh file to append theme colors to `FZF_DEFAULT_OPTS`                                |
| [ghostty](https://ghostty.org/)                                                          | `contrib/ghostty/token-{dark,light}`                      | Copy to `~/.config/ghostty/themes/`, then set `theme = dark:token-dark,light:token-light`                        |
| [GtkSourceView](https://gitlab.gnome.org/GNOME/gtksourceview) (gedit, GNOME Text Editor) | `contrib/gtksourceview/token-{dark,light}.xml`            | Copy to `~/.local/share/gtksourceview-{4,5}/styles/`, then pick the scheme in the editor's preferences           |
| [iTerm2](https://iterm2.com/)                                                            | `contrib/iterm2/token-{dark,light}.itermcolors`           | Import from Profiles > Colors > Color Presets                                                                    |
| [kitty](https://sw.kovidgoyal.net/kitty/)                                                | `contrib/kitty/token-{dark,light}.conf`                   | `include /path/to/token-dark.conf` in `kitty.conf`                                                               |
| [lazygit](https://github.com/jesseduffield/lazygit)                                      | `contrib/lazygit/token-{dark,light}.yml`                  | Merge into `~/.config/lazygit/config.yml`                                                                        |
| [Obsidian](https://obsidian.md/)                                                         | `contrib/obsidian/`                                       | Copy to `<vault>/.obsidian/themes/Token`, restart Obsidian, select Token, then set the accent color to `#bc6a49` |
| [ripgrep](https://github.com/BurntSushi/ripgrep)                                         | `contrib/ripgrep/token-{dark,light}.ripgreprc`            | `RIPGREP_CONFIG_PATH=/path/to/token-dark.ripgreprc`                                                              |
| [starship](https://starship.rs/)                                                         | `contrib/starship/token-{dark,light}.toml`                | Append to `starship.toml`, set `palette = "token"`                                                               |
| [Sublime Text](https://www.sublimetext.com/)                                             | `contrib/sublime/token-{dark,light}.sublime-color-scheme` | Copy to `Packages/User/`, set `"color_scheme"` in Preferences                                                    |
| [tmux](https://github.com/tmux/tmux)                                                     | `contrib/tmux/token-{dark,light}.conf`                    | `source-file /path/to/token-dark.conf` in tmux.conf                                                              |
| [VS Code](https://code.visualstudio.com/)                                                | `contrib/vscode/`                                         | Run `scripts/install_vscode_theme.sh`, then select `Token Dark` or `Token Light`                                 |
| [Windows Terminal](https://github.com/microsoft/terminal)                                | `contrib/windows-terminal/token.json`                     | Copy schemes into settings/fragments, then set `"colorScheme": { "dark": "Token Dark", "light": "Token Light" }` |
| [Xcode](https://developer.apple.com/xcode/)                                              | `contrib/xcode/token-{dark,light}.xccolortheme`           | Copy to `~/Library/Developer/Xcode/UserData/FontAndColorThemes/`, then select Token Dark or Token Light           |
| [Zsh](https://www.zsh.org/)                                                              | `contrib/zsh/token-{dark,light}.zsh`                      | Source the selected file from `.zshrc` for matching `ls`, completion, fzf-tab, and prompt helper colors          |

## License

BSD 3-Clause
