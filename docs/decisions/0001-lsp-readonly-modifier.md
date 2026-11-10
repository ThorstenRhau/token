# ADR-0001: Keep readonly as constant and scope the exceptions

Status: accepted
Recorded: 2026-11-09
Supersedes: none
Superseded by: none
Related: `lua/token/groups/lsp.lua`, `docs/lsp-semantic-tokens.md`

## Context

Token links `@lsp.mod.readonly` to `@constant`. Modifier groups outrank type
groups and Treesitter, so a readonly token takes the constant color.

Servers send `readonly` with different meanings. pyrefly 1.4.1 sends it only
for uppercase and `Final` names. emmylua_ls 0.25.1 sends it for every local
and parameter that is never reassigned. Measured on 2026-11-09:

| File                      | Readonly share of variables and parameters |
| ------------------------- | ------------------------------------------ |
| `lua/token/theme.lua`     | 69% (152 of 221)                           |
| `scripts/gen_contrib.lua` | 94% (2400 of 2558)                         |
| Python sample             | 3 of 13, all constants                     |

With emmylua_ls attached, most Lua names took the literal color.

## Decision

- Keep `@lsp.mod.readonly → @constant` for all filetypes.
- Link `@lsp.typemod.parameter.readonly` to `@variable.parameter` for all
  filetypes, because a parameter is never a constant.
- Link `@lsp.typemod.variable.readonly.lua` to `@variable`, because the only
  measured Lua server uses readonly for any binding that is never reassigned.
- The VS Code export follows the same rule with the `parameter.readonly` and
  `variable.readonly:lua` selectors.

## Consequences

- Python constants keep their constant color with pyrefly.
- Lua locals and all parameters keep their normal colors.
- A Lua `local x <const>` also loses the constant color. emmylua_ls sent such
  a binding as a plain `variable` in the sample, so nothing visible was lost
  with that server.
- The `.lua` exception also applies to LuaLS (`lua_ls`), which was not
  measured. If LuaLS sends readonly only for `<const>` locals, its users lose
  that constant color.
- Other servers that send readonly for every `const` binding, possibly
  TypeScript and C/C++ servers, are not measured. Count their tokens before
  you add a filetype exception for them.
- Eglot has no faces for a type and modifier together and no per-language
  faces, so the Emacs theme can't follow this. See
  `docs/lsp-semantic-tokens.md`.

## Alternatives considered

- Remove the `@lsp.mod.readonly` link. Rejected because pyrefly sends `MAX`
  as `variable`, which outranks Treesitter's uppercase constant capture, so
  Python constants would lose their color.
- Define an empty `@lsp.mod.readonly.lua`. Rejected because it was unclear
  whether Neovim treats an empty group as defined or falls back to the generic
  link. The type-and-modifier link does not depend on that.

## Verification anchors

- `lua/token/groups/lsp.lua`
- `scripts/gen_contrib.lua`: VS Code `semanticTokenColors`
- `tests/headless.lua`: `provider_links`, `modifier_links` and
  `readonly_exceptions`
- Live check on 2026-11-09: with the user's Neovim configuration, emmylua_ls
  and pyrefly, the new groups win and resolve to their targets' colors.
