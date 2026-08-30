# AGENTS.md - token

Standalone Neovim colorscheme plugin with classic, Flint, Temper, Ultra, and Meridian
appearances, each with dark and light variants. Requires **Neovim 0.12+**.

## Structure

```txt
token/
├── colors/
│   ├── token.lua              # Classic entry point
│   ├── token-flint.lua        # Flint entry point
│   ├── token-meridian.lua     # Meridian entry point
│   ├── token-temper.lua       # Temper entry point
│   └── token-ultra.lua        # Ultra entry point
├── lua/
│   ├── lualine/themes/
│   │   ├── token.lua          # Classic Lualine wrapper
│   │   ├── token-flint.lua    # Flint Lualine wrapper
│   │   ├── token-meridian.lua # Meridian Lualine wrapper
│   │   ├── token-temper.lua   # Temper Lualine wrapper
│   │   └── token-ultra.lua    # Ultra Lualine wrapper
│   └── token/
│       ├── appearance.lua      # Appearance registry and metadata
│       ├── appearances/
│       │   ├── flint.lua       # Flint semantic color overrides
│       │   ├── meridian.lua    # Meridian semantic overrides
│       │   ├── meridian_roles.lua # Meridian syntax, Lualine, ANSI, and generator roles
│       │   ├── temper.lua      # Temper semantic color overrides
│       │   ├── ultra.lua       # Ultra semantic color overrides
│       │   └── ultra_roles.lua # Ultra syntax, Lualine, ANSI, and generator roles
│       ├── compile.lua         # Ten-variant bytecode compilation and cache loading
│       ├── config.lua          # Persistent normalized configuration
│       ├── init.lua            # Public API: setup(), load()
│       ├── lualine.lua         # Shared appearance-aware Lualine builder
│       ├── palette.lua         # Classic dark/light colors
│       ├── palettes/
│       │   ├── flint.lua       # Flint dark/light colors
│       │   ├── meridian.lua    # Meridian dark/light colors
│       │   ├── temper.lua      # Temper dark/light colors
│       │   └── ultra.lua       # Ultra dark/light colors
│       ├── theme.lua           # Shared configured appearance builder
│       ├── terminal.lua        # ANSI terminal colors 0..15
│       ├── typography.lua      # Shared semantic font attributes and generated-theme mappings
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

- `colors/token.lua`, `colors/token-flint.lua`, `colors/token-meridian.lua`,
  `colors/token-temper.lua`, and `colors/token-ultra.lua` are the Neovim entry
  points discovered by their matching `:colorscheme` names
- `appearance.lua` registers classic Token, Flint, Temper, Ultra, and Meridian, including
  their palette, optional highlight and role profiles, generated slug, and
  compile-cache identity
- `init.lua` orchestrates loading: tries compiled bytecode cache first, falls
  back to the dynamic configured appearance path
- `config.lua` validates options and persists normalized configuration across
  Token's runtime module cache clearing
- `theme.lua` applies palette overrides, enabled integrations, appearance color
  overlays, shared typography, styles, surfaces, user highlights, callbacks,
  and global attribute gates in shared order
- `compile.lua` handles `:TokenCompile` (generates classic, Flint, Temper, Ultra,
  and Meridian dark/light bytecode under `stdpath('cache')/token/`) and
  configuration-fingerprinted loading
- `palette.lua`, `palettes/flint.lua`, `palettes/meridian.lua`,
  `palettes/temper.lua`, and `palettes/ultra.lua` each take `'dark'|'light'`
  and return the same flat semantic hex color key set
- `typography.lua` is the source of truth for shared semantic attributes across
  runtime highlights and role-aware generated themes. Appearance modules overlay
  color grammar before it is applied, then shared user styles take precedence
- An optional appearance role profile may define syntax adapter, heading,
  Lualine, and ANSI roles after configured palette callbacks run. Ultra and
  Meridian use `appearances/ultra_roles.lua` and `appearances/meridian_roles.lua`;
  existing appearances retain their fallbacks
- `groups/init.lua` loads and merges: editor, syntax, treesitter, lsp,
  diagnostics, diff, plugins
- `groups/plugins/init.lua` exposes a keyed registry and requires enabled plugin
  modules in sorted order
- Each group module exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports `{ colors, set }`: `colors(p, is_dark, appearance?)`
  returns the 0..15 ANSI color table (pure Lua), and
  `set(p, is_dark, appearance?)` applies it via `vim.g`; two-argument calls
  retain the shared fallback
- `lualine.lua` builds all modes from the active appearance palette; the five
  files under `lua/lualine/themes/` are thin wrappers
- The registered palette modules are the source of truth for runtime highlights
  and generated contrib themes; some keys are intentionally generator-only

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add or change a classic color**: edit both dark and light tables in `palette.lua`
- **Add or change a Flint color**: edit both dark and light tables in
  `palettes/flint.lua`; preserve approved colors unless the user approves a change
- **Add or change a Meridian color**: edit both dark and light tables in
  `palettes/meridian.lua`; preserve approved colors unless the user approves a change
- **Add or change a Temper color**: edit both dark and light tables in
  `palettes/temper.lua`; preserve approved anchors unless the user approves a change
- **Add or change an Ultra color**: edit both dark and light tables in
  `palettes/ultra.lua`; preserve approved anchors unless the user approves a change
- **Change shared semantic typography**: edit `typography.lua`, then verify shared
  `styles` still override base and higher-priority LSP typemod groups
- **Change Flint, Temper, Ultra, or Meridian color grammar**: edit the matching
  appearance and optional role profile, then verify styles, Lualine, Terminal,
  and syntax-sensitive generators retain their configured colors
- **Add plugin support**: create `groups/plugins/<name>.lua`, add its filename
  and module path to the registry in `groups/plugins/init.lua`
- **Regenerate contrib themes**: `make contrib` (run after changing
  either palette, appearance-specific generated semantics, or a generator)
- **Compile for faster loading**: `:TokenCompile` (rerun after updating the
  plugin; it writes classic, Flint, Temper, Ultra, and Meridian dark/light caches)
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

## Durable project knowledge

- Use the global `$project-knowledge` workflow when explicitly asked to capture,
  audit, or promote durable knowledge for this repository.
- Keep always-applicable architecture and operating rules in `AGENTS.md`. Keep
  the public feature and configuration contract in `README.md`, and keep the
  repeatable colorscheme audit and screenshot procedures in
  `.agents/skills/colorscheme-review/` and
  `.agents/skills/create-theme-screenshots/`.
- Record accepted, non-obvious rationale under `docs/decisions/` only when it
  meets the workflow's capture threshold. Add `docs/index.md` only when the
  repository has multiple durable knowledge sources that need routing.
- Update current-state documentation with the implementation change that makes
  it stale. Treat implementation plans as active work, not accepted decisions,
  and do not store session summaries or temporary branch state as project
  knowledge.

## Commits

- Tracked `contrib/**/token*` files generated by `scripts/gen_contrib.lua` are
  expected theme artifacts. A Git guard finding caused only by their `token`
  filename component is an approved false positive and may be overridden after
  confirming the staged scope is exact and the staged content has no secret or
  credential findings. This exception does not apply to content findings,
  untracked paths, or files outside `contrib/**`.

```txt
type(scope): description

Body text that explains the change
```

- Types: `feat`, `fix`, `chore`, `refactor`, `style`, `docs`
- Scope: filename or feature area (no extension)
