# LSP semantic tokens

Token colors LSP semantic tokens by linking them to its Treesitter groups in
[`lua/token/groups/lsp.lua`](../lua/token/groups/lsp.lua). The VS Code export
in [`scripts/gen_contrib.lua`](../scripts/gen_contrib.lua) and the Emacs
generator in [`scripts/gen_emacs.lua`](../scripts/gen_emacs.lua) give their
semantic token rules and Eglot faces the same colors. This document covers how
servers differ from the LSP specification and how to check a new server
before you add mappings for it.

## How Neovim applies semantic tokens

Neovim creates one extmark per group name, at these priorities:

| Group | Priority |
| --- | --- |
| Treesitter captures | 100 |
| `@lsp.type.{type}` | 125 |
| `@lsp.mod.{modifier}` | 126 |
| `@lsp.typemod.{type}.{modifier}` | 127 |

Each group also has a filetype form, such as `@lsp.type.variable.lua`, which
falls back to the generic group when it is undefined. `nvim_get_hl` does not
apply that fallback, so tests and probes must resolve the generic name.

Semantic tokens outrank Treesitter. When a server sends a token, its link
replaces the Treesitter capture, including Treesitter's builtin and constant
captures. A missing or wrong link usually shows up as a lost Treesitter color,
not as a missing highlight.

## Server conventions observed

Measured on 2026-11-09 with Neovim 0.12.6, pyrefly 1.4.1, emmylua_ls 0.25.1
and tombi 1.11.1, using the server set in `~/.config/nvim/lua/lsp.lua`.

| Server | Semantic tokens | Differences from the specification |
| --- | --- | --- |
| pyrefly | yes | `self` and `cls` are `parameter` with a `selfParameter` modifier. Built-in functions and classes carry `defaultLibrary`. `readonly` marks only uppercase names and `Final` names. |
| BasedPyright | yes (not measured here) | `self` and `cls` are separate `selfParameter` and `clsParameter` types. |
| emmylua_ls | yes | `readonly` marks every local and parameter that is never reassigned, about 94% of names in `scripts/gen_contrib.lua`. Built-ins carry `defaultLibrary`. Adds a `delimiter` type that also covers string quotes, and an `operator.logical` modifier. |
| tombi | yes | Custom types `table`, `key`, `boolean` and four date and time types. No modifiers. |
| bashls, ruff, rumdl, jsonls, yamlls | no | Treesitter and diagnostics only. |

The specification describes `readonly` as "readonly variables and member
fields (constants)". Servers read that differently: pyrefly sends it for
constants, emmylua_ls for any binding that is never reassigned. The same
modifier name can mean different things, so check what a server sends before
you map it.

## Current mappings

- Standard types link to the matching Treesitter group.
- `@lsp.mod.readonly` links to `@constant`, which fits pyrefly.
- `@lsp.typemod.parameter.readonly` links to `@variable.parameter`, because
  parameters are never constants.
- `@lsp.typemod.variable.readonly.lua` links to `@variable`, because
  emmylua_ls marks most Lua locals readonly. See
  [ADR-0001](decisions/0001-lsp-readonly-modifier.md).
- `@lsp.typemod.function.defaultLibrary` and
  `@lsp.typemod.class.defaultLibrary` link to `@function.builtin` and
  `@type.builtin`, so built-ins keep their Treesitter colors.
- `@lsp.typemod.parameter.selfParameter` (pyrefly) and the BasedPyright
  `@lsp.type.selfParameter.python` and `@lsp.type.clsParameter.python` link to
  `@variable.parameter.builtin`.
- Tombi's TOML types link under `.toml` names.
- `delimiter` stays unmapped. Linking it to `@punctuation.delimiter` would
  give emmylua_ls string quotes the comment color.

[`tests/headless.lua`](../tests/headless.lua) checks these links in
`provider_links` (filetype-scoped) and `modifier_links` (all filetypes).

## Emacs and Eglot

Emacs 31 Eglot has one face per type and one per modifier
(`eglot-semantic-{name}`), with modifier faces stacked above the type face.
It has no faces for a type and modifier together and no per-language faces.
The Neovim exceptions above can't be expressed in the Emacs theme.

- `eglot-semantic-readonly` uses the literal color. With emmylua_ls it would
  color most Lua names, as Neovim did before ADR-0001. The fix belongs in the
  Emacs configuration: remove `"readonly"` from
  `eglot-semantic-token-modifiers` for Lua buffers. This is not tested with
  emmylua_ls in Emacs.
- `eglot-semantic-defaultLibrary` is empty, so a built-in keeps its type
  color (function or class).
- Eglot only uses the names in `eglot-semantic-token-types` and
  `eglot-semantic-token-modifiers`. Custom names such as pyrefly's
  `selfParameter` and tombi's TOML types are ignored unless you add them
  there.

## VS Code

The VS Code export in [`scripts/gen_contrib.lua`](../scripts/gen_contrib.lua)
writes `semanticTokenColors` selectors of the form
`(*|type)(.modifier)*(:language)?`. VS Code scores each matching selector, per
style property: 10 for a language, about 100 for a type, and 100 per modifier.
A later rule wins a tie (`tokenClassificationRegistry.ts` and
`colorThemeData.ts` in the VS Code source, read 2026-11-09).

So `*.readonly` (100) ties with `parameter` (100) and wins because it comes
later. The export adds `parameter.readonly` (200) and `variable.readonly:lua`
(210, above `variable.readonly` at 200) so VS Code follows ADR-0001. The VS
Code export has no `selfParameter` or `defaultLibrary` exceptions for classic
Token. Role-profile appearances color `*.defaultLibrary` with the builtin
role.

## Check a new server

1. Attach the server in headless Neovim with the real configuration and print
   `client.server_capabilities.semanticTokensProvider.legend`. No provider
   means nothing to map.
2. Open a representative file, force a refresh with
   `vim.lsp.semantic_tokens.force_refresh`, redraw, and collect
   `vim.lsp.semantic_tokens.get_at_pos` results. Count type and modifier
   pairs, not only the legend. The legend shows what a server may send, not
   how often.
3. For each frequent pair, check which group wins with `vim.inspect_pos` (the
   highest `priority` among `semantic_tokens`) and compare its color with the
   Treesitter capture it replaced.
4. Map only pairs that change a color for the worse. Prefer a
   `@lsp.typemod.{type}.{modifier}` link when the modifier is right for one
   type and wrong for another. Use a filetype form when one server's
   convention conflicts with another's.
5. Add the link to `lsp.lua`, add a test entry, then check whether the VS
   Code export, the Emacs generator or the Emacs configuration needs the same
   change.
