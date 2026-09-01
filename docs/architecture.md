# Architecture

Token turns one registered appearance and one Neovim background variant into
runtime highlights, terminal colors, Lualine colors, and generated themes for
external tools. The same canonical palettes and semantic typography feed those
outputs so they can be verified together.

## Appearance model

[`lua/token/appearance.lua`](../lua/token/appearance.lua) is the registry and
ordering authority for appearances. Each entry selects a palette module and
identifiers used by runtime caches and generated files. An appearance may also
select a highlight overlay and a semantic role profile. Every `colors/*.lua`
entry point delegates its registered name to
[`require('token').load()`](../lua/token/init.lua).

The selected appearance chooses the color grammar. `vim.o.background` chooses
its `dark` or `light` variant. Both axes are explicit throughout runtime tests
and contrib generation.

## Runtime assembly

[`lua/token/config.lua`](../lua/token/config.lua) owns defaults, validation, and
the stored configuration shared by all appearances. A colorscheme load follows
this flow:

1. [`lua/token/init.lua`](../lua/token/init.lua) resolves the appearance and
   attempts its configuration-keyed compiled cache.
2. On a cache miss, [`lua/token/theme.lua`](../lua/token/theme.lua) loads and
   validates the active palette, then builds the highlight map.
3. [`lua/token/groups/init.lua`](../lua/token/groups/init.lua) merges core
   editor, syntax, Treesitter, LSP, diagnostic, diff, and enabled plugin groups.
4. The theme applies the appearance overlay, shared typography, user styles,
   surface options, user highlight overrides and callbacks, then global
   attribute gates in that order.
5. Neovim receives the completed highlight map and, when enabled, terminal
   colors from [`lua/token/terminal.lua`](../lua/token/terminal.lua).

Plugin integrations are opt-in. Their registry in
[`lua/token/groups/plugins/init.lua`](../lua/token/groups/plugins/init.lua)
maps configuration keys to independent group modules and implements the
`plugins.all` fallback.

## Semantic sources

Registered palette modules are the canonical color inputs. Classic Token uses
[`lua/token/palette.lua`](../lua/token/palette.lua); the other appearances use
modules under [`lua/token/palettes/`](../lua/token/palettes/). The runtime
validates that every required semantic key exists and every palette value is a
`#RRGGBB` string.

[`lua/token/typography.lua`](../lua/token/typography.lua) owns shared semantic
attributes and format-specific role mappings. Optional appearance role modules
under [`lua/token/appearances/`](../lua/token/appearances/) refine semantic
colors used by appearance overlays, terminal and Lualine output, and generators.
User styles are applied after shared and appearance typography, so supported
customization can override those defaults before the final global gates.

## Compiled runtime path

[`lua/token/compile.lua`](../lua/token/compile.lua) serializes the completed
highlight maps and optional terminal colors for every registered appearance and
both background variants. Cache paths include a deterministic configuration
fingerprint. Cache payloads also carry a source identity based on the detached
Git revision or, for mutable trees, metadata for `lua/token/**/*.lua`.

Missing, stale, legacy, corrupt, or failing caches are discarded or ignored and
the loader falls back to dynamic assembly. Compilation writes temporary files
for the complete appearance set before promoting them to their final paths, so
a failed build does not replace only part of the cache set.

## Generated contrib themes

[`scripts/gen_contrib.lua`](../scripts/gen_contrib.lua) iterates the appearance
registry and both variants, then derives tracked `contrib/**` themes from the
registered palettes, terminal mappings, semantic role profiles, typography,
and format-specific generator logic. Its `--verify` mode compares expected
content and paths without rewriting them, including detection of stale files.

Generated contrib files are outputs, not independent authorities. Changes to
their colors or typography originate in the palette, role, typography, or
generator sources and are regenerated as one coherent set.

## Verification boundaries

[`tests/headless.lua`](../tests/headless.lua) exercises configuration
validation, every registered appearance and variant, highlight precedence,
plugin selection, typography propagation, generated formats, terminal colors,
and compiled-cache invalidation and fallback. [`tests/benchmark.lua`](../tests/benchmark.lua)
measures dynamic and compiled reload paths without defining correctness.

The canonical gate is `make check`, defined by [`Makefile`](../Makefile). It
combines formatting verification, lint, headless tests, and generated-contrib
verification. Visual palette acceptance remains separate because deterministic
checks can establish structural consistency but not visual intent.
