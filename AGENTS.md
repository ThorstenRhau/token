# AGENTS.md - token

Standalone Neovim colorscheme plugin with classic and Flint appearances, each
with dark and light variants. Requires **Neovim 0.12+**.

## Structure

```txt
token/
├── colors/
│   ├── token.lua              # Classic entry point
│   └── token-flint.lua        # Flint entry point
├── lua/
│   ├── lualine/themes/
│   │   ├── token.lua          # Classic Lualine wrapper
│   │   └── token-flint.lua    # Flint Lualine wrapper
│   └── token/
│       ├── appearance.lua      # Appearance registry and metadata
│       ├── appearances/
│       │   └── flint.lua       # Flint typography and semantic overrides
│       ├── compile.lua         # Four-variant bytecode compilation and cache loading
│       ├── config.lua          # Persistent normalized configuration
│       ├── init.lua            # Public API: setup(), load()
│       ├── lualine.lua         # Shared appearance-aware Lualine builder
│       ├── palette.lua         # Classic dark/light colors
│       ├── palettes/
│       │   └── flint.lua       # Flint dark/light colors
│       ├── theme.lua           # Shared configured appearance builder
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
│               ├── blink_indent.lua
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
│   ├── xcode/
│   └── zsh/
├── Makefile
├── selene.toml
├── neovim.yaml
├── taplo.toml
├── README.md
└── LICENSE
```

## Architecture

- `colors/token.lua` and `colors/token-flint.lua` are the Neovim entry points,
  discovered by `:colorscheme token` and `:colorscheme token-flint`
- `appearance.lua` registers classic Token and Flint, including their palette,
  optional highlight profile, generated slug, and compile-cache identity
- `init.lua` orchestrates loading: tries compiled bytecode cache first, falls
  back to the dynamic configured appearance path
- `config.lua` validates options and persists normalized configuration across
  Token's runtime module cache clearing
- `theme.lua` applies palette overrides, enabled integrations, styles, surfaces,
  user highlights, callbacks, and global attribute gates in shared order
- `compile.lua` handles `:TokenCompile` (generates classic and Flint dark/light
  bytecode under `stdpath('cache')/token/`) and configuration-fingerprinted loading
- `palette.lua` and `palettes/flint.lua` each take `'dark'|'light'` and return a
  flat table of 49 semantic hex color keys
- `appearances/flint.lua` overlays Flint's restrained color grammar and semantic
  typography before shared user styles are applied
- `groups/init.lua` loads and merges: editor, syntax, treesitter, lsp,
  diagnostics, diff, plugins
- `groups/plugins/init.lua` exposes a keyed registry and requires enabled plugin
  modules in sorted order
- Each group module exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports `{ colors, set }`: `colors(p, is_dark)` returns the
  0..15 ANSI color table (pure Lua), `set(p, is_dark)` applies it via `vim.g`
- `lualine.lua` builds all modes from the active appearance palette; the two
  files under `lua/lualine/themes/` are thin wrappers
- The registered palette modules are the source of truth for runtime highlights
  and generated contrib themes; some keys are intentionally generator-only

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add or change a classic color**: edit both dark and light tables in `palette.lua`
- **Add or change a Flint color**: edit both dark and light tables in
  `palettes/flint.lua`; preserve approved colors unless the user approves a change
- **Change Flint's semantic grammar**: edit `appearances/flint.lua`, then verify
  shared `styles` still override both base and higher-priority LSP typemod groups
- **Add plugin support**: create `groups/plugins/<name>.lua`, add its filename
  and module path to the registry in `groups/plugins/init.lua`
- **Regenerate contrib themes**: `make contrib` (run after changing
  either palette, appearance-specific generated semantics, or a generator)
- **Compile for faster loading**: `:TokenCompile` (rerun after updating the
  plugin; it writes classic and Flint dark/light caches)
- Prefer `{ link = 'GroupName' }` over duplicating color values
- Intentional same-file duplicate highlight tables are allowed when they
  preserve future per-group tuning without introducing cross-module link
  dependencies

## Validation

```bash
make check                     # Read-only formatting, lint, tests, and contrib checks
make format                    # Format with stylua
make lint                      # Lint with selene
make test                      # Run dependency-free headless runtime and generator tests
make benchmark                 # Report warm reload medians, group counts, cache sizes
make contrib                   # Regenerate contrib/ theme files
make contrib-verify            # Check contrib/ files are up to date
make all                       # Format, lint, and generate contrib
```

The pre-commit hook runs `make check`; run `make all` before committing changes
that need formatting or contrib regeneration. Enable it with
`make install-hooks`.

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
