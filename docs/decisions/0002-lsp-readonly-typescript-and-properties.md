# ADR-0002: Extend the readonly exceptions to properties and TypeScript

Status: accepted Recorded: 2026-11-10 Supersedes: none Superseded by: none
Related: `lua/token/groups/lsp.lua`, `docs/lsp-semantic-tokens.md`,
[ADR-0001](0001-lsp-readonly-modifier.md)

## Context

ADR-0001 keeps `@lsp.mod.readonly` linked to `@constant` and scopes the
exceptions. It left TypeScript and C servers unmeasured. Measured on 2026-11-10
with Neovim 0.12.6 on small sample files:

- vtsls 0.3.0 sends `readonly` for every `const` binding: 18 of 23 variable
  tokens, including locals such as `text` and `lines`.
- vtsls and Apple clangd 21.0.0 send `readonly` for fields: a TypeScript
  `readonly name` and a C `const char *label` member.
- clangd sends `readonly` for `static const` variables and enum members, which
  are constants.

Token also gained a property color in the same change, so a readonly field in
the constant color would lose the member distinction.

The same review compared Catppuccin, Tokyo Night, Kanagawa, Rosé Pine and
Nightfox. All five clear `@lsp.type.variable` so Treesitter's variable captures
show through.

## Decision

- Keep ADR-0001 as it stands.
- Link `@lsp.typemod.property.readonly` to `@property` for all filetypes.
- Link `@lsp.typemod.variable.readonly` to `@variable` for `javascript`,
  `javascriptreact`, `typescript` and `typescriptreact`.
- The VS Code export follows with `property.readonly` in the property color and
  `variable.readonly` selectors for the same four languages.
- Keep `@lsp.type.variable` linked to `@variable`.

## Consequences

- TypeScript `const` locals keep the variable color with vtsls.
- A module-level TypeScript constant such as `MAX_ITEMS` also loses the constant
  color, as a Lua constant does under ADR-0001.
- C `const` variables keep the constant color with clangd.
- Readonly fields keep the property color in every language.
- Other TypeScript servers are not measured.

## Alternatives considered

- Clear `@lsp.type.variable`, as the five compared colorschemes do. Rejected for
  now: in the Lua, Python, C, TypeScript, Swift and Go samples a plain
  `variable` token replaced a Treesitter `@variable` capture in every case but
  one, where the Swift query was wrong, so clearing it changed nothing. Rust
  could not be compared, because no Treesitter parser was installed for it.
  Revisit if a server sends plain `variable` over a more specific Treesitter
  capture.

## Verification anchors

- `lua/token/groups/lsp.lua`
- `scripts/gen_contrib.lua`: VS Code `semanticTokenColors`
- `tests/headless.lua`: `modifier_links` and `readonly_exceptions`
- `docs/lsp-semantic-tokens.md`: server conventions measured on 2026-11-10
