# CLAUDE.md - token

Standalone Neovim colorscheme plugin with dark and light variants. Requires **Neovim 0.12+**.

## Structure

```txt
token/
├── colors/
│   └── token.lua              # Entry point
├── lua/
│   ├── lualine/themes/
│   │   └── token.lua          # Lualine theme
│   └── token/
│       ├── init.lua            # Public API: load()
│       ├── palette.lua         # Color definitions for dark/light
│       ├── terminal.lua        # ANSI terminal colors 0..15
│       └── groups/
│           ├── init.lua        # Group loader (merges all modules)
│           ├── editor.lua      # Core editor UI, LSP refs, spell, misc
│           ├── syntax.lua      # Legacy :h group-name syntax groups
│           ├── treesitter.lua  # Treesitter capture groups
│           ├── lsp.lua         # LSP semantic tokens
│           ├── diagnostics.lua # Diagnostic signs, virtual text, underlines
│           ├── diff.lua        # Diff and Added/Changed/Removed
│           └── plugins/
│               ├── init.lua    # Plugin loader (merges all plugin modules)
│               ├── blink.lua
│               ├── claudecode.lua
│               ├── diffview.lua
│               ├── fugitive.lua
│               ├── fzf.lua
│               ├── gitsigns.lua
│               ├── hlchunk.lua
│               ├── ibl.lua
│               ├── markview.lua
│               ├── mason.lua
│               ├── matchup.lua
│               ├── mini.lua
│               ├── neogit.lua
│               ├── nvimtree.lua
│               ├── oil.lua
│               ├── snacks.lua
│               ├── treesitter_context.lua
│               └── trouble.lua
├── scripts/
│   └── gen_contrib.lua
├── contrib/
│   ├── bat/
│   ├── delta/
│   ├── emacs/
│   ├── fish/
│   ├── fzf/
│   ├── ghostty/
│   ├── lazygit/
│   ├── ripgrep/
│   ├── starship/
│   └── tmux/
├── Makefile
├── selene.toml
├── neovim.yaml
├── taplo.toml
├── README.md
└── LICENSE
```

## Architecture

- `colors/token.lua` is the Neovim entry point, discovered by `:colorscheme token`
- `init.lua` orchestrates: hi clear, set colors_name, bust module cache (including `lualine.themes.token`), load palette, merge groups, apply via `nvim_set_hl`, set terminal colors
- `palette.lua` returns a function that takes `'dark'|'light'` and returns a flat table of 41 semantic hex color keys
- `groups/init.lua` loads and merges: editor, syntax, treesitter, lsp, diagnostics, diff, plugins
- `groups/plugins/init.lua` loads individual plugin files from an explicit sorted list
- Each group module exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports `{ colors, set }`: `colors(p, is_dark)` returns the 0..15 ANSI color table (pure Lua), `set(p, is_dark)` applies it via `vim.g`

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add a palette color**: add it to both dark and light tables in `palette.lua`
- **Add plugin support**: create `groups/plugins/<name>.lua`, add the module path to the list in `groups/plugins/init.lua`
- **Regenerate contrib themes**: `make contrib` (run after changing `palette.lua`)
- Prefer `{ link = 'GroupName' }` over duplicating color values

## Validation

```bash
make format                    # Format with stylua
make lint                      # Lint with selene
make contrib                   # Regenerate contrib/ theme files
make contrib-verify            # Check contrib/ files are up to date
make all                       # Format, lint, and generate contrib
```

No test suite. Run `make all` before committing.

## Style

- **StyLua**: 2-space indent, 120 line width, single quotes, trailing commas
- **Selene**: `neovim` std (neovim.yaml defines vim global)
- Sparse comments, only where non-obvious

## Commits

```txt
type(scope): description

Body text that explains the change
```

- Types: `feat`, `fix`, `chore`, `refactor`, `style`, `docs`
- Scope: filename or feature area (no extension)
