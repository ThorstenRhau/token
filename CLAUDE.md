# CLAUDE.md - token

Standalone Neovim colorscheme plugin with dark and light variants. Requires **Neovim 0.12+**.

## Structure

```txt
token/
├── colors/
│   └── token.lua              # Entry point (calls require('token').load())
├── lua/
│   └── token/
│       ├── init.lua            # Public API: load()
│       ├── palette.lua         # Returns color table for 'dark' or 'light' background
│       ├── terminal.lua        # Sets g:terminal_color_0..15
│       └── groups/             # Highlight group definitions (each returns fn(palette))
│           ├── base.lua        # Core editor, diff, diagnostics, LSP refs, legacy syntax
│           ├── treesitter.lua  # Treesitter capture groups
│           ├── lsp.lua         # LSP semantic tokens (@lsp.type.*, @lsp.mod.*)
│           └── plugins.lua     # Plugin-specific highlights (~15 plugins)
├── scripts/
│   └── gen_contrib.lua        # Generates contrib/ theme files (plain LuaJIT)
├── contrib/                   # Auto-generated theme files for external tools
├── README.md
└── LICENSE
```

## Architecture

- `colors/token.lua` is the Neovim entry point, discovered by `:colorscheme token`
- `init.lua` orchestrates: hi clear, set colors_name, bust module cache, load palette, merge groups, apply via `nvim_set_hl`, set terminal colors
- `palette.lua` returns a function that takes `'dark'|'light'` and returns a flat table of 28 semantic hex color keys
- Each file in `groups/` exports a function `(palette) -> { [group] = hl_opts }`
- `terminal.lua` exports a function `(palette, is_dark)` that sets 16 ANSI terminal colors
- Groups merge order matters: base, treesitter, lsp, plugins (later overrides earlier via `tbl_extend('force', ...)`)

## Common tasks

- **Add a highlight group**: add it to the appropriate `groups/*.lua` file
- **Add a palette color**: add it to both dark and light tables in `palette.lua`
- **Add plugin support**: add groups to `groups/plugins.lua` under a new comment section
- **Regenerate contrib themes**: `make contrib` (after changing `palette.lua`)
- Prefer `{ link = 'GroupName' }` over duplicating color values

## Validation

```bash
stylua --check lua/ colors/    # Formatting
selene lua/                    # Linting
```

No test suite. Validate with both commands before committing.

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
