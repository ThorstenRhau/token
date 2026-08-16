# Token Flint implementation plan

Status: approved for implementation

This document is the handoff brief for adding Token Flint as a second first-class
appearance to the Token Neovim colorscheme and its generated contrib themes.

Before editing, read the repository `AGENTS.md`, inspect the current worktree, and
preserve unrelated changes. Do not create commits, branches, tags, pushes, or
releases unless the user separately requests them.

## Objective

Implement a cool-gray Token appearance with restrained warm accents and purposeful
typography while preserving the existing Token appearance as the unchanged default.

- `:colorscheme token` remains the classic Token appearance.
- `:colorscheme token-flint` loads Token Flint.
- `vim.o.background` continues to select dark or light within either colorscheme.
- Existing setup options and integrations work with both colorschemes.
- Do not add an `appearance` option to `require('token').setup()`.
- Do not add a production dependency.

The scheme name selects the appearance. The Neovim background option selects its
dark or light variant. This avoids two competing selectors for the same concept.

## Approved palette anchors

The following values are approved and must not be retuned during implementation.

| Semantic role | Palette key | Flint dark | Flint light |
| --- | --- | --- | --- |
| Editor base | `bg3` | `#272C33` | `#F5F7F8` |
| Panel | `bg1` | `#1C2127` | `#E7EBEF` |
| Border or raised surface | `bg5` | `#373E47` | `#E0E5EA` |
| Primary text | `fg0` | `#DCE1E6` | `#28313A` |
| Secondary text | `fg1` | `#C2C9D0` | `#3D4853` |
| Muted text | `fg2` | `#929BA5` | `#65717D` |
| Subdued UI | `fg3` | `#626C77` | `#828E9A` |
| Definition, copper | `accent` | `#D58A6F` | `#B64E2E` |
| Control, brass | `accent2` | `#C6A15A` | `#946409` |
| Literal, sage | `green` | `#94A477` | `#5A772B` |
| Link, steel blue | `blue` | `#7FA2BA` | `#34779D` |
| Error, dusty red | `red` | `#D47A7F` | `#BE3E50` |

The approved text-bearing foregrounds and semantic accents meet a contrast ratio of
at least 4.5:1 against their matching editor base. `fg3` is for borders, line
numbers, inactive details, and other nonessential UI rather than ordinary text.

### Complete the semantic palette without adding a rainbow

The Flint palette must expose exactly the same 49 keys as the existing
`TokenPalette`. Keep the approved anchors exact and derive the remaining keys from
them.

- Use `accent` and `purple` for the copper family.
- Use `accent2` and `yellow` for the brass family.
- Use `green`, `orange`, and `olive` for the sage family.
- Use `blue` and `cyan` for the steel-blue family.
- Use `red` for error, deletion, and destructive states.
- Adjust only luminance for bright ANSI variants. Do not make them neon.
- Derive diff and diagnostic backgrounds as low-chroma mixtures of the appropriate
  semantic color and cool-gray base.
- Keep selection, indentation, line-number, and ordinary UI colors in the cool-gray
  ramp. A restrained brass tint may be used for search matches.
- Do not introduce another syntax hue to recreate the classic palette's rainbow.

## Approved typography grammar

Flint uses typography to reduce how many tokens need a distinct hue.

| Role | Color | Typography |
| --- | --- | --- |
| Function and type definitions | Copper | Bold |
| Function calls | Copper | Regular |
| Function and type references | Neutral | Italic where the scope allows |
| Built-ins and default-library symbols | Neutral or semantic role | Italic |
| Keywords and control flow | Brass | Regular |
| Strings, numbers, booleans, and constants | Sage | Regular |
| Variables, properties, operators, punctuation | Neutral | Regular |
| Comments and documentation | Muted | Italic |
| Links | Steel blue | Underline |
| Deprecated symbols | Inherited color | Strikethrough |
| Diagnostics | Status color | Undercurl |
| Markup strong and emphasis | Inherited color | Bold or italic |

Use bold for definition-bearing captures such as `@function`,
`@function.method`, and `@type.definition`. Keep `@function.call` and
`@function.method.call` non-bold. Legacy `Function` may be bold because legacy
syntax cannot reliably separate definitions from calls.

Flatten rainbow-like markup heading colors. Headings may use copper, brass, and
neutral foregrounds with bold weight, but should not assign a different hue to
every heading level.

## Target architecture

Keep the classic implementation intact and add a narrow appearance layer:

```text
colors/
  token.lua                         explicit classic entry point
  token-flint.lua                   new Flint entry point

lua/token/
  appearance.lua                    fixed internal appearance registry
  palette.lua                       existing classic palette, unchanged
  palettes/flint.lua                new 49-key Flint palette
  appearances/flint.lua             Flint highlight overlay
  init.lua                          appearance-aware loader
  theme.lua                         appearance-aware palette and group builder
  compile.lua                       four cache variants
  lualine.lua                       shared Lualine builder

lua/lualine/themes/
  token.lua                         thin classic wrapper
  token-flint.lua                   thin Flint wrapper
```

The internal registry should contain two fixed descriptors keyed by the exact
colorscheme names `token` and `token-flint`. Each descriptor owns its display
name, generated-file slug, palette module, and optional highlight-profile module.
Keep this as data shared by runtime and generators, not as a public extension API.
It must remain compatible with plain LuaJIT because `make contrib` does not run
inside Neovim.

## Highlight construction order

Apply the appearance profile before user customization:

```text
shared editor, syntax, Treesitter, LSP, diagnostic, diff, and plugin groups
-> Flint appearance overlay, or no-op for classic Token
-> setup().styles
-> transparent and dim-inactive surface handling
-> setup().highlights
-> on_highlights callback
-> global attribute gates
```

This order makes Flint's typography the default while preserving all existing
configuration precedence. Avoid adding appearance branches throughout every
group and plugin module. Use the Flint overlay and semantic palette, adding a
targeted override only when a plugin otherwise creates an unnecessary rainbow.

## Implementation sequence

### 1. Establish a clean baseline

Before changing files:

```bash
git status --short --branch
make check
make benchmark
```

Retain the benchmark output for the final comparison. Confirm that generated
contrib output is initially current.

### 2. Add the appearance registry and Flint palette

1. Add the two fixed appearance descriptors.
2. Leave `lua/token/palette.lua` unchanged so it remains the classic source of
   truth.
3. Add the complete Flint dark and light palette.
4. Validate that classic and Flint return identical key sets.
5. Validate every palette entry as a six-digit `#RRGGBB` color.
6. Add focused contrast checks for the approved text-bearing anchors.

### 3. Add the Flint highlight overlay

1. Start with the normal shared highlight map.
2. Replace the relevant legacy syntax, Treesitter, LSP semantic token, and markup
   groups with the approved Flint color and typography roles.
3. Preserve diagnostics, diffs, search, Git signs, and other purposeful status
   colors.
4. Ensure `attributes.bold = false`, and the other global gates, still remove
   Flint's default attributes because gates run last.
5. Verify that user styles and complete highlight overrides take precedence over
   the Flint profile.

### 4. Make runtime loading appearance-aware

1. Add `colors/token-flint.lua`.
2. Make `colors/token.lua` request classic Token explicitly.
3. Extend `require('token').load()` with an optional internal colorscheme name,
   defaulting to `token` for backward compatibility.
4. Resolve and validate the appearance before clearing modules or loading cache.
5. Set `vim.g.colors_name` to `token` or `token-flint` in both dynamic and
   compiled paths.
6. Clear both Lualine wrapper modules when reloading.
7. Return a clear `token:` error for an unknown internal colorscheme name.

Keep `require('token').setup()` shared. Add the active colorscheme as a trailing,
backward-compatible callback argument:

```lua
on_colors(colors, background, colorscheme)
on_highlights(highlights, colors, background, colorscheme)
```

Lua callers using the existing callback arities remain compatible because extra
arguments are ignored.

### 5. Compile and load four cache variants

Update `lua/token/compile.lua` so `:TokenCompile` produces dark and light caches
for both appearances.

Preserve the classic cache names when practical:

```text
dark-<fingerprint>.lua
light-<fingerprint>.lua
flint-dark-<fingerprint>.lua
flint-light-<fingerprint>.lua
```

Requirements:

- Cache lookup includes both appearance and background.
- Compiled source assigns the correct `vim.g.colors_name`.
- Configuration fingerprinting remains unchanged in purpose.
- Atomic cache publication remains intact.
- A corrupt cache is deleted and falls back dynamically.
- A failure or corrupt cache for Flint does not affect classic Token, and vice
  versa.
- `:TokenCompile` reports that both appearances and both backgrounds were built.

### 6. Add Token Flint for Lualine

Move the existing Lualine table construction into a shared builder that accepts an
appearance name. Keep `lua/lualine/themes/token.lua` as a thin classic wrapper and
add `lua/lualine/themes/token-flint.lua`.

Both themes must honor transparency, inactive-window dimming, the active palette,
and the global bold gate exactly as the current Lualine theme does.

### 7. Expand runtime and cache tests

Cover the complete matrix in `tests/headless.lua`:

```text
token, token-flint
x dark, light
x dynamic, compiled
x core-only, all-plugin
```

Add focused assertions for:

- Both `:colorscheme` entry points and their `vim.g.colors_name` values.
- Exact approved Flint anchors.
- Equal palette key sets and valid color formats.
- Contrast of text-bearing Flint colors against the editor base.
- Copper bold definitions and non-bold calls.
- Neutral italic references and built-ins.
- Sage literal data and brass control flow.
- Steel-blue underlined links.
- Deprecated strikethrough and diagnostic undercurl.
- Global attribute gates removing Flint defaults.
- User styles, highlights, and callbacks overriding Flint defaults.
- The callback colorscheme argument.
- Four distinct cache paths.
- Isolated cache misses, configuration-key misses, corruption, and fallback.
- Dynamic and compiled highlight-map parity.
- Dynamic and compiled ANSI 0 through 15 parity.
- Both Lualine wrappers.

Extend `tests/benchmark.lua` to report classic and Flint warm reload medians,
group counts, and all four cache sizes. A material regression in classic Token is
a defect and should be investigated before completion.

### 8. Generate contrib themes for both appearances

Refactor `scripts/gen_contrib.lua` to iterate over the same appearance descriptors
instead of hardcoding one palette and one display name. Pass the descriptor to
`scripts/gen_emacs.lua` and to syntax-rule builders where typography differs.

Do not edit generated files by hand.

#### Compatibility and naming

- Keep every existing classic path and visible name.
- Keep existing classic theme content byte-for-byte where the file is not an
  aggregate manifest that must enumerate the new Flint themes.
- Use `Token Flint Dark` and `Token Flint Light` as visible names.
- Use `token-flint-{dark,light}.*` for ordinary paired outputs.
- Generate `contrib/fish/token-flint.theme`.
- Generate `contrib/delta/token-flint.gitconfig` with Flint-specific feature
  names.
- Generate `contrib/windows-terminal/token-flint.json` rather than changing the
  existing classic fragment.
- Add two Flint JSON themes to the existing VS Code package and add their entries
  to its aggregate `package.json`.
- Generate an independently installable Obsidian theme at
  `contrib/obsidian/token-flint/{manifest.json,theme.css}` while preserving the
  current classic Obsidian paths.
- Generate `token-flint-dark-theme.el` and `token-flint-light-theme.el` for
  Emacs.

For TextMate, bat, Sublime, GtkSourceView, VS Code, Emacs, and Xcode, carry the
Flint typography grammar where the format and available scopes support it.
Separate function or class definitions from calls when the format can express the
difference. Palette-only terminal and shell formats receive the Flint palette
without pretending to support syntax typography.

Expand generated-format and inventory tests to include both appearances. Preserve
the generator's stale-output detection, path validation, symlink refusal, atomic
publication, and failure cleanup.

### 9. Update documentation

Update the main README usage section:

```lua
vim.cmd.colorscheme('token')       -- classic and default
vim.cmd.colorscheme('token-flint') -- cool-gray Flint appearance
```

Document that:

- The colorscheme name selects classic or Flint.
- `vim.o.background` selects dark or light.
- `setup()` is shared by both appearances.
- Callbacks receive the colorscheme name as their trailing argument.
- `:TokenCompile` creates four configuration-keyed variants.
- Contrib themes include classic and Flint filenames and display names.

Update `contrib/emacs/README.md` with the two Flint theme names and installation
examples. Update the contrib table and usage examples for combined outputs,
VS Code, Windows Terminal, Obsidian, and any tool whose selection name changes.

## Validation

Run the narrow checks while implementing, then complete the full repository gates:

```bash
make all
make check
make contrib-verify
make benchmark
git diff --check
make -C /Users/thorre/github/token check
```

Review the final diff for:

- Accidental changes to the classic palette.
- Classic generated files that changed without a compatibility reason.
- Hand-edited generated output.
- Unnecessary appearance branches or duplicated group modules.
- Cache collisions or a compiled `colors_name` mismatch.
- Missing documentation or generated-file inventory entries.
- Unrelated worktree changes.

## Manual visual QA

Exercise real Neovim 0.12 rendering for all four combinations:

```text
Token dark
Token light
Token Flint dark
Token Flint light
```

Use representative source and Markdown buffers containing:

- A class or type definition and reference.
- A function definition, method definition, function call, and built-in call.
- Variables, properties, operators, and punctuation.
- Strings, numbers, booleans, and constants.
- Keywords and control flow.
- Normal, documentation, TODO, warning, and error comments.
- Links, headings, strong, emphasis, underline, and strikethrough markup.
- LSP definition, readonly, default-library, and deprecated modifiers.
- Errors, warnings, information, hints, diffs, Git signs, and search matches.
- Lualine and an ANSI 0 through 15 terminal sample.

Confirm that:

- Classic Token has no visual regression.
- Flint colors are clear without appearing neon.
- Definitions are visibly bold in both Flint variants.
- Calls remain visually subordinate to definitions.
- Typography is doing enough work that syntax does not look rainbow-colored.
- Muted and subdued text remains legible for its intended purpose.
- Background switching selects the correct variant without changing appearance
  family.

The approved anchors, `Token Flint` name, and typography grammar are closed design
decisions. If completing the remaining palette requires a genuinely new hue or an
exception to the contrast target, stop and request review. Ordinary derived ramps
within the approved families do not require another design round.

## Acceptance criteria

The implementation is complete when all of the following are true:

- `:colorscheme token` remains the default and renders the existing palette.
- `:colorscheme token-flint` works for dark and light backgrounds.
- Flint uses the approved colors and typography grammar.
- Existing setup behavior remains backward compatible.
- Dynamic and compiled output match for both appearances.
- Lualine and ANSI colors follow the active appearance.
- Every supported contrib target has a Flint equivalent or Flint entries in its
  aggregate package.
- Existing contrib paths remain valid.
- Generator verification inventories all new files and rejects stale output.
- `make check`, `make contrib-verify`, `git diff --check`, and the external-cwd
  check pass.
- The final report identifies anything that was not manually verified in Neovim
  or an external application.

## Out of scope

- Renaming or replacing the existing `token` colorscheme.
- Implementing the discarded Cinder or Temper concepts.
- Adding a public appearance-selection option.
- Creating a general third-party appearance API.
- Redesigning unrelated plugin integrations.
- Adding dependencies.
- Committing, pushing, tagging, publishing, or releasing.
