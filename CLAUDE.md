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
│       ├── compile.lua         # Bytecode compilation and cache loading
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
│               ├── cmp.lua
│               ├── dap_ui.lua
│               ├── diffview.lua
│               ├── flash.lua
│               ├── fugitive.lua
│               ├── fzf.lua
│               ├── gitsigns.lua
│               ├── hlchunk.lua
│               ├── ibl.lua
│               ├── lazy.lua
│               ├── markview.lua
│               ├── mason.lua
│               ├── matchup.lua
│               ├── mini.lua
│               ├── neo_tree.lua
│               ├── neogit.lua
│               ├── noice.lua
│               ├── nvimtree.lua
│               ├── oil.lua
│               ├── render_markdown.lua
│               ├── snacks.lua
│               ├── telescope.lua
│               ├── todo_comments.lua
│               ├── treesitter_context.lua
│               ├── trouble.lua
│               └── whichkey.lua
├── plugin/
│   └── token.lua              # :TokenCompile command registration
├── scripts/
│   ├── gen_contrib.lua
│   ├── gen_emacs.lua
│   └── gen_lib.lua
├── contrib/
│   ├── bat/
│   ├── carapace/
│   ├── delta/
│   ├── emacs/
│   ├── fish/
│   ├── fzf/
│   ├── ghostty/
│   ├── lazygit/
│   ├── ripgrep/
│   ├── starship/
│   ├── tmux/
│   └── zsh/
├── Makefile
├── selene.toml
├── neovim.yaml
├── taplo.toml
├── README.md
└── LICENSE
```

## Architecture

- `colors/token.lua` is the Neovim entry point, discovered by `:colorscheme token`
- `init.lua` orchestrates loading: tries compiled bytecode cache first, falls back to dynamic path (hi clear, bust module cache, load palette, merge groups, apply via `nvim_set_hl`, set terminal colors)
- `compile.lua` handles `:TokenCompile` (generates bytecode cache to `stdpath('cache')/token/`) and cache loading
- `palette.lua` returns a function that takes `'dark'|'light'` and returns a flat table of 47 semantic hex color keys
- `groups/init.lua` loads and merges: editor, syntax, treesitter, lsp, diagnostics, diff, plugins
- `groups/plugins/init.lua` loads individual plugin files from an explicit sorted list
- Each group module exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports `{ colors, set }`: `colors(p, is_dark)` returns the 0..15 ANSI color table (pure Lua), `set(p, is_dark)` applies it via `vim.g`

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add a palette color**: add it to both dark and light tables in `palette.lua`
- **Add plugin support**: create `groups/plugins/<name>.lua`, add the module path to the list in `groups/plugins/init.lua`
- **Regenerate contrib themes**: `make contrib` (run after changing `palette.lua`)
- **Compile for faster loading**: `:TokenCompile` (rerun after updating the plugin)
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
