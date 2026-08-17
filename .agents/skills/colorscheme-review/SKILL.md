---
name: colorscheme-review
description: Read-only audit of the token colorscheme for palette integrity, module conformance, and toolchain health
user-invocable: true
---

Perform a **read-only** structured audit of this Neovim colorscheme. Do not create or modify repository files, and do not save the report to disk. Temporary state outside the repository is allowed only for isolated runtime checks and must be removed afterward. Produce a single markdown report in the conversation.

## Setup

Before starting, read these files to understand the project:

1. `AGENTS.md` (project conventions)
2. `README.md` (public API, integrations, contrib inventory, and installation)
3. All `colors/token*.lua` entry points, `plugin/token.lua`, `lua/token/init.lua`, `lua/token/config.lua`, `lua/token/theme.lua`, and `lua/token/compile.lua`
4. `lua/token/appearance.lua`, every registered palette and appearance-profile module, `lua/token/terminal.lua`, `lua/token/lualine.lua`, and all matching `lua/lualine/themes/token*.lua` wrappers
5. `lua/token/groups/init.lua` and `lua/token/groups/plugins/init.lua`
6. `Makefile`, `.stylua.toml`, `selene.toml`, `neovim.yaml`, `taplo.toml`, `.editorconfig`, and `.prettierrc.toml`
7. `scripts/*.lua` and `scripts/install_vscode_theme.sh`
8. `tests/*.lua`, `.githooks/*`, and both copies of this skill
9. Every file under `contrib/`, including `contrib/emacs/README.md`

## Tool Usage

Use the available tools to **verify findings before reporting**. A finding based only on grep without verification is not production-grade.

### Context7 MCP and official upstream sources

Prefer `resolve-library-id` then `query-docs` when the plugin is discoverable. Otherwise use current official documentation, tagged source, types, parsers, or default themes. Record the exact source revision or release and access date.

- Verify current highlight group names for every plugin in `lua/token/groups/plugins/*.lua` (Phase 5).
- Confirm a group has been renamed, added, removed, or meaningfully omitted before flagging it.
- Do not treat missing Context7 coverage as a reason to skip an integration when official source is available.

Never establish a finding from third-party documentation alone.

### LSP tool and runtime fallback

When available, use LSP operations (hover, go-to-definition, find-references, document-symbols) to:

- Confirm a grep match is an actual code reference, not a comment or string (Phase 2, 3)
- Verify `p.<key>` references resolve to real fields on the palette table (Phase 3)
- Check that group modules return a function with the expected signature (Phase 3).

If LSP is unavailable, use source inspection plus isolated headless Neovim assertions. State that fallback in the report.

### Bash (read-only targets only)

The following repository commands are read-only and safe to run:

- `make check`
- `stylua --check --config-path .stylua.toml .`
- `selene --config selene.toml lua/ colors/ plugin/`
- `make test`
- `make benchmark`
- `make contrib-verify`
- `git diff --check`

Native syntax validators and installed application CLIs may be used with isolated temporary configuration and cache directories. Do not install missing applications or alter persistent application settings. Remove temporary state when finished.

Do NOT run any command that mutates the working tree. `make format`, `make contrib`, and `make all` all rewrite files and are forbidden in this audit.

## Audit Phases

Execute all 10 phases in order. For each finding, record a severity, an ID tag, the `file:line` reference, upstream evidence, impact, the smallest suggested fix, and an acceptance test.

### Phase 1: Toolchain & Static Analysis

1. Run `make check` and capture the output. Run individual components when needed to isolate a failure.
2. Run `stylua --check --config-path .stylua.toml .` and capture the output.
   - Format drift → Warning (list the files).
   - Missing `stylua` binary → Critical.
3. Run `selene --config selene.toml lua/ colors/ plugin/` and capture the output.
   - Lint errors → Critical.
   - Missing `selene` binary → Critical.
4. Run `make test`, `make contrib-verify`, and `git diff --check`. Any failure → Critical, naming the exact failing contract.
5. Grep Lua sources under `lua/`, `colors/`, `plugin/` for deprecated Neovim APIs. Confirm each match with LSP when available, otherwise inspect its call site before reporting:
   - `vim.cmd('hi ` / `vim.cmd("hi ` / `vim.cmd('highlight ` / `vim.cmd("highlight ` (use `vim.api.nvim_set_hl`)
   - `vim.tbl_flatten` (use `vim.iter(t):flatten():totable()`)
   - `vim.tbl_islist` (use `vim.islist`)
   - `vim.loop` (use `vim.uv`)
   - `vim.api.nvim_set_option` / `nvim_buf_set_option` / `nvim_win_set_option` (use `vim.o` / `vim.bo` / `vim.wo`)

### Phase 2: Palette Integrity

1. Parse `lua/token/appearance.lua`, then parse every registered palette module. Extract the key sets of each module's dark and light tables.
   - Asymmetric key sets within any appearance → Critical (list missing/extra keys on each side).
   - Registered palette module missing or unparseable → Critical.
2. Verify every value in every registered dark and light table matches `^#[0-9a-fA-F]{6}$`.
   - Malformed hex → Critical.
3. Grep for the pattern `#[0-9a-fA-F]{6}` under `lua/`, `colors/`, `plugin/`. Any hit outside the registered palette modules and `lua/token/terminal.lua` → Warning (colors should flow through an appearance palette).
   - Guard: `scripts/` and `contrib/` are allowed to embed hex — they generate external theme files. Do not scan those directories.
4. **Unused palette keys**: for each key in every registered palette, grep `p\.<key>\b` across group modules, appearance profiles, `lua/token/terminal.lua`, `lua/token/lualine.lua`, and generator scripts.
   - Zero references anywhere → Info.
   - Guard: verify with LSP that the grep has searched every file that consumes the palette. Do not flag keys that appear only in indexed form (e.g., `palette[name]`) — check for dynamic access before flagging.

### Phase 3: Group Module Conformance

1. For every `.lua` file in `lua/token/groups/` and `lua/token/groups/plugins/` (excluding the two `init.lua` files): verify it returns a function with signature `(palette) -> table<string, vim.api.keyset.highlight>`.
   - Non-conforming (returns a table directly, returns nothing, wrong arity) → Critical.
2. For every `p.<key>` reference in a group module, verify the key exists in the palette. Use LSP go-to-definition or field-completion to confirm.
   - Unresolved reference → Critical.
3. **Link preference**: within a single group module, if two or more groups share the exact same options table (same keys, same values), suggest linking later ones to the first → Info.
   - Guard: do not flag across modules (cross-module links introduce load-order dependencies). Only flag duplicates in the same file.

### Phase 4: Plugin List Coherence

1. List filenames under `lua/token/groups/plugins/` (excluding `init.lua`). Compare against the hardcoded module list in `lua/token/groups/plugins/init.lua`.
   - File on disk not in list → Critical (module is never loaded; its groups are dead code).
   - Entry in list without a corresponding file → Critical (`require` will fail at startup).
2. Verify the list in `init.lua` is alphabetically sorted.
   - Out of order → Info.

### Phase 5: Plugin API Verification

For each plugin group module in `lua/token/groups/plugins/`, use Context7 when available or inspect the current official source and documentation. Compare the upstream highlight inventory with the groups the module defines, and headlessly load every integration.

- Module sets a group that no longer appears in upstream docs (may be stale) → Info.
- Upstream documents a highlight group that the module does not define or link → Info.
- Upstream documents a renamed group (e.g., old name removed, new name added) → Warning.

Do not report every optional group as missing. Report only renamed, removed, stale, or visibly meaningful omissions established by authoritative evidence.

### Phase 6: Load Path & Compile Cache

1. Every `colors/token*.lua` entry point must be thin and call `require('token').load()` with its registered appearance name; the classic entry may omit its default name. A missing entry for a registered appearance, an unregistered entry, or additional entry-point behavior → Warning.
2. `plugin/token.lua`: must register the `:TokenCompile` user command and wire it to `require('token.compile').compile()`. Missing → Warning.
3. `lua/token/init.lua` dynamic-fallback path must:
   (a) call `vim.cmd('hi clear')` (or equivalent),
   (b) preserve configured state while busting reloadable `token.*` modules and every Token Lualine wrapper from `package.loaded`,
   (c) resolve the selected appearance and load its palette for the current `vim.o.background`,
   (d) merge groups via `require('token.groups')(p)`,
   (e) apply via `vim.api.nvim_set_hl`,
   (f) resolve an optional appearance role profile after configured palette callbacks,
   (g) set terminal colors via `require('token.terminal').set(p, is_dark, appearance)`.
   - Any missing step → Critical (colorscheme won't reload cleanly after `:TokenCompile`).
4. `lua/token/compile.lua`: compilation must produce distinct configuration-keyed caches for every registered appearance in dark and light. `load(bg, appearance)` must recover from a missing or corrupt bytecode cache (delete the stale file, fall back to dynamic load). Missing coverage or recovery → Warning.

### Phase 7: Terminal & Lualine Coverage

1. `lua/token/terminal.lua`: verify `colors(p, is_dark, appearance?)` returns all 16 indices (0–15) for both backgrounds and every registered appearance. Verify two-argument calls retain the shared fallback. Any nil slot → Critical.
2. For every registered appearance, load its `lua/lualine/themes/<appearance>.lua` wrapper through `lua/token/lualine.lua`. Verify all 7 modes are present: `normal`, `insert`, `visual`, `replace`, `command`, `terminal`, `inactive`. Each must have `a`, `b`, `c` sections.
   - Missing mode → Warning.
   - Missing section within a mode → Warning.
3. Verify the shared Lualine builder resolves colors and any optional role profile through the appearance-aware APIs after configured palette callbacks, and each wrapper selects the correct registered appearance. Hardcoded hex or a classic-only palette path → Warning.

### Phase 8: Standard Neovim Group Coverage

Cross-reference defined highlight groups against a curated list of commonly user-visible standard Neovim groups (from `:h highlight-groups` and `:h group-name`). For each standard group that is neither defined nor linked in any module, report as Info.

**Curated list of groups to check** (this is a small, stable set — do not expand it speculatively):

`ColorColumn`, `Conceal`, `CurSearch`, `Cursor`, `CursorColumn`, `CursorLine`, `CursorLineNr`, `Directory`, `DiffAdd`, `DiffChange`, `DiffDelete`, `DiffText`, `EndOfBuffer`, `ErrorMsg`, `FloatBorder`, `FloatTitle`, `FoldColumn`, `Folded`, `IncSearch`, `LineNr`, `MatchParen`, `ModeMsg`, `MoreMsg`, `NonText`, `Normal`, `NormalFloat`, `NormalNC`, `Pmenu`, `PmenuSbar`, `PmenuSel`, `PmenuThumb`, `Question`, `QuickFixLine`, `Search`, `SignColumn`, `SpecialKey`, `SpellBad`, `SpellCap`, `SpellLocal`, `SpellRare`, `StatusLine`, `StatusLineNC`, `Substitute`, `TabLine`, `TabLineFill`, `TabLineSel`, `Title`, `Visual`, `VisualNOS`, `WarningMsg`, `Whitespace`, `WinSeparator`.

Guard: only flag a group if it is absent **and** not targeted via `link = '<Group>'` elsewhere. Apply the zero-false-positive rule harder here than anywhere else — bias toward silence.

### Phase 9: Contributions

1. Reconcile all contribution directories, generated files, generator functions, README rows, generated headers, variants, and install instructions.
2. For every contribution, record the current official documentation, schema, release, or source revision and access date.
3. Validate every available JSON, XML/plist, CSS, TOML, YAML, Git config, and shell format with a native parser or published schema.
4. Exercise installed CLI applications with temporary profiles. Put unavailable or state-changing GUI imports into a separate manual dark/light checklist.
5. Trace rendered colors to the matching registered appearance palette, terminal slots, or documented format encodings. Do not report intentional low contrast or aesthetics as defects.
6. Verify generator parity, deterministic output, appearance and dark/light identity, and stale-file detection. Recommend generator-source changes, not edits to generated files.

The live contribution families are: bat, Blink Shell, Carapace, ChatGPT desktop, delta, Emacs, fish, fzf, Ghostty, GtkSourceView, iTerm2, Kitty, lazygit, Obsidian, ripgrep, Starship, Sublime Text, tmux, VS Code, Windows Terminal, Xcode, and Zsh.

### Phase 10: Repository Tooling

1. Verify Make dependencies, `.PHONY`, help, working-directory independence, read-only versus mutating targets, and exit propagation.
2. Review all generators for deterministic ordering, escaping, safe relative paths, symlink handling, atomic publication, stale outputs, partial failures, and verify-mode non-mutation.
3. Review `scripts/install_vscode_theme.sh` with `bash -n`, ShellCheck, and isolated install/replacement/rollback fixtures.
4. Review tests for public contracts, both variants, dynamic/compiled parity, registry coverage, generator safety, cleanup, and failure paths.
5. Confirm the benchmark is isolated, informational, and accurately labels what it measures.
6. Reconcile StyLua, Selene, Neovim globals, Taplo, EditorConfig, Prettier, ignore rules, hooks, repository documentation, and both audit-skill copies.

## Output Format

Produce a single markdown report printed to the conversation. Include a coverage matrix for every Neovim subsystem, plugin integration, contribution family, documentation surface, and tooling component before the severity sections:

```markdown
# Token Colorscheme Audit Report

## Summary

| Severity | Count |
|----------|-------|
| Critical | X     |
| Warning  | X     |
| Info     | X     |

## Coverage

## Critical

### [C-01] Title
- **File**: `path/to/file.lua:42`
- **Issue**: Description of the problem
- **Fix**: Suggested resolution

## Warnings

### [W-01] Title
- **File**: `path/to/file.lua:10`
- **Issue**: Description
- **Fix**: Suggested resolution

## Info

### [I-01] Title
- **File**: `path/to/file.lua:5`
- **Issue**: Description
- **Suggestion**: Optional improvement

## Manual and Unverified Checks

## Approval-Required Palette Proposals

## Commands, Versions, and Repository State
```

## Severity Definitions

- **Critical**: broken functionality right now. `make check` or `make contrib-verify` failures. Palette asymmetry. Unresolved `p.<key>` references. Plugin file/list mismatch. Missing load-path step. Gaps in terminal colors 0–15.
- **Warning**: convention violations from AGENTS.md. Deprecated APIs (still functional but should be updated). Hardcoded hex outside the allowed files. Missing lualine mode or section. Contrib drift. Renamed upstream highlight groups.
- **Info**: consistency improvements, unused palette keys, missing standard Neovim groups, minor stylistic opportunities. Not wrong, just could be better.

## Rules

1. Do not create or modify repository files. This is a read-only audit.
2. Keep temporary runtime state outside the repository, remove it afterward, and print the report to the conversation only.
3. Prefer Context7 for plugin documentation when it is available; otherwise use official source and record the fallback.
4. Prefer LSP for code references when it is available; otherwise require source inspection plus headless runtime evidence.
5. Be specific: always include `file:line` references.
6. Do not flag intentional design choices:
   - `scripts/` and `contrib/` may contain hex literals (they generate external theme files).
   - Some registered palette keys exist primarily for terminal colors, Lualine, appearance profiles, or generators and may look unused from a narrow grep.
   - `ibl.lua` and `hlchunk.lua` coexist by design (different indentation plugins supported in parallel).
   - Both `neo_tree.lua` and `nvimtree.lua` coexist by design (two file tree plugins supported in parallel).
   - README's Obsidian accent `#bc6a49` is an intentional light/dark compromise so automatic macOS appearance changes do not require a user-setting change.
7. Group related findings under the same ID if they share a root cause (e.g., ten unused keys from one naming family = one finding).
8. **Zero false positives is more important than coverage.** If a check might flag correct code, skip the finding rather than report it. The user can request deeper investigation.
9. **Do not report the absence of optional features.** Missing support for a plugin not in the current list is not a finding. Missing a niche highlight group outside the Phase 8 curated list is not a finding.
10. Do not report intentional low contrast, aesthetic preference, or a contrast ratio alone as a defect.
11. Preserve established colors. Put any justified palette change in a separate approval-required section with authoritative semantics, a reproducible mapping problem, and dark/light impact.
12. Finish by running `git status --short` and confirming the audit created no tracked or untracked files.
