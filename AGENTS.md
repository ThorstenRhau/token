# AGENTS.md - token

Token is a Neovim 0.12+ colorscheme with registered dark and light
appearances. `README.md` is the public installation, configuration, plugin,
compilation, and contrib contract.

## Architecture and sources of truth

- `lua/token/appearance.lua` registers appearances and selects their palette,
  optional highlight overlay, optional role profile, generated slug, and cache
  identity.
- The registered palette modules are the canonical colors for runtime
  highlights and generated themes. Every palette exposes the same flat semantic
  key set for dark and light; some keys are consumed only by terminal, Lualine,
  appearance roles, or generators.
- `lua/token/theme.lua` owns highlight precedence: configured palette overrides
  and `on_colors`, core and enabled-plugin groups, appearance color overlays,
  shared typography, user styles, surfaces, user highlights and
  `on_highlights`, then global attribute gates.
- `lua/token/typography.lua` is the source of truth for shared semantic
  attributes in Neovim and generated themes. Appearance role profiles provide
  appearance-specific syntax, heading, Lualine, ANSI, and generator colors.
- `lua/token/groups/init.lua` merges core group modules.
  `lua/token/groups/plugins/init.lua` is the registry for opt-in plugin
  integrations.
- `scripts/gen_contrib.lua` generates tracked `contrib/**` artifacts from the
  appearance registry, palettes, typography, roles, and generator logic.

## Change conventions

- Add an appearance through the registry, dark/light palette, optional
  appearance and role modules, matching `colors/` entry point, and Lualine
  wrapper. Keep generators and tests registry-driven.
- Add plugin support with a `groups/plugins/<name>.lua` module and matching
  registry entry. Group modules export
  `(palette) -> { [group] = highlight }`.
- Put highlight groups in the appropriate core or plugin module. Prefer
  `{ link = 'GroupName' }` when groups should remain identical; same-file
  duplicate definitions are acceptable when they preserve independent future
  tuning.
- For shared semantic font attributes, change `typography.lua` and verify user
  styles still win, including higher-priority LSP type-modifier groups. For
  appearance-specific color grammar, change its appearance or role module and
  verify syntax, Lualine, ANSI, and generated outputs.
- Do not change established palette values or intentional dark/light differences
  during unrelated work. Visual palette changes require an explicit request and
  should be checked against the intended screenshots or other supplied visual
  evidence.
- Never hand-edit generated `contrib/**` theme files. Change palette,
  typography, role, or generator sources, then regenerate.

## Validation

- `make check` is the canonical read-only gate: formatting check, lint, headless
  tests, and generated-contrib verification. The pre-commit hook runs it.
- Use `make test` for a focused runtime/generator check and `make benchmark`
  only for performance-sensitive work.
- After changes that affect formatting or generated themes, run `make all` to
  format, lint, and regenerate, then run `make check`. `make format`,
  `make contrib`, and `make all` mutate tracked files and are not allowed in
  read-only tasks.
- Review the final diff and confirm unrelated worktree state is unchanged.

## Commits

Use `type(scope): description`, where type is `feat`, `fix`, `chore`,
`refactor`, `style`, or `docs`, and scope is a filename or feature area without
an extension. Add a body when the reason is not clear from the subject.

The Git guard may flag tracked generated paths under `contrib/**` because their
filenames contain `token`. A path-only match is an approved false positive only
after confirming the staged scope is exact and there are no content findings,
credentials, untracked paths, or matches outside `contrib/**`.
