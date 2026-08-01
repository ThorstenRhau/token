# AGENTS.md - token

Standalone Neovim colorscheme plugin with dark and light variants. Requires
**Neovim 0.12+**.

## Structure

```txt
token/
├── colors/
│   └── token.lua              # Entry point
├── lua/
│   ├── lualine/themes/
│   │   └── token.lua          # Lualine theme
│   └── token/
│       ├── init.lua            # Public API: setup(), load()
│       ├── config.lua          # Persistent normalized configuration
│       ├── compile.lua         # Bytecode compilation and cache loading
│       ├── palette.lua         # Color definitions for dark/light
│       ├── theme.lua           # Shared configured variant builder
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
│   ├── gen_lib.lua
│   └── install_vscode_theme.sh
├── contrib/
│   ├── bat/
│   ├── blink/
│   ├── carapace/
│   ├── chatgpt/
│   ├── delta/
│   ├── emacs/
│   ├── fish/
│   ├── fzf/
│   ├── ghostty/
│   ├── gtksourceview/
│   ├── iterm2/
│   ├── kitty/
│   ├── lazygit/
│   ├── obsidian/
│   ├── ripgrep/
│   ├── starship/
│   ├── sublime/
│   ├── tmux/
│   ├── vscode/
│   ├── windows-terminal/
│   └── zsh/
├── Makefile
├── selene.toml
├── neovim.yaml
├── taplo.toml
├── README.md
└── LICENSE
```

## Architecture

- `colors/token.lua` is the Neovim entry point, discovered by
  `:colorscheme token`
- `init.lua` orchestrates loading: tries compiled bytecode cache first, falls
  back to the dynamic configured variant path
- `config.lua` validates options and persists normalized configuration across
  Token's runtime module cache clearing
- `theme.lua` applies palette overrides, enabled integrations, styles, surfaces,
  user highlights, callbacks, and global attribute gates in shared order
- `compile.lua` handles `:TokenCompile` (generates bytecode cache to
  `stdpath('cache')/token/`) and configuration-fingerprinted cache loading
- `palette.lua` returns a function that takes `'dark'|'light'` and returns a
  flat table of 49 semantic hex color keys
- `groups/init.lua` loads and merges: editor, syntax, treesitter, lsp,
  diagnostics, diff, plugins
- `groups/plugins/init.lua` exposes a keyed registry and requires enabled plugin
  modules in sorted order
- Each group module exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports `{ colors, set }`: `colors(p, is_dark)` returns the
  0..15 ANSI color table (pure Lua), `set(p, is_dark)` applies it via `vim.g`
- `palette.lua` is the single source of truth for both runtime highlights and
  generated contrib themes; some palette keys are intentionally consumed only by
  generator scripts under `scripts/`

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add a palette color**: add it to both dark and light tables in `palette.lua`
- **Add plugin support**: create `groups/plugins/<name>.lua`, add its filename
  and module path to the registry in `groups/plugins/init.lua`
- **Regenerate contrib themes**: `make contrib` (run after changing
  `palette.lua`)
- **Compile for faster loading**: `:TokenCompile` (rerun after updating the
  plugin)
- Prefer `{ link = 'GroupName' }` over duplicating color values
- Intentional same-file duplicate highlight tables are allowed when they
  preserve future per-group tuning without introducing cross-module link
  dependencies

## Validation

```bash
make check                     # Read-only formatting, lint, and contrib checks
make format                    # Format with stylua
make lint                      # Lint with selene
make test                      # Run dependency-free headless Neovim tests
make benchmark                 # Report load medians, group counts, cache sizes
make contrib                   # Regenerate contrib/ theme files
make contrib-verify            # Check contrib/ files are up to date
make all                       # Format, lint, and generate contrib
```

The pre-commit hook runs `make check`; run `make all` before committing changes
that need formatting or contrib regeneration.

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
