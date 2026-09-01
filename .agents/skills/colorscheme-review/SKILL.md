---
name: colorscheme-review
description: Perform a read-only, evidence-led audit of Token's palettes, runtime themes, integrations, generated contrib themes, and toolchain. Use for repository-wide colorscheme audits, not ordinary implementation or a narrow code review.
---

# Token Colorscheme Review

Audit the repository without modifying it or saving a report to disk. Keep any
runtime state in disposable directories outside the repository, remove it
afterward, and return one Markdown report in the conversation.

Use current code, registries, tests, and official upstream sources as the
authority. Do not preserve a finding merely because an older checklist expected
it.

## Establish the baseline

1. Read `AGENTS.md`, `README.md`, `Makefile`, the appearance registry, runtime
   entry points, theme/config/compile modules, typography, terminal and Lualine
   builders, group registries, generators, tests, and relevant tool
   configuration. Follow references from the current registries instead of
   relying on a frozen appearance, plugin, or contrib inventory.
2. Record `git status --short --branch`, the audited commit, Neovim and tool
   versions, and which checks are available.
3. Run `make check` and `git diff --check`. Run individual read-only targets
   only to isolate failures. Run `make benchmark` only when the request includes
   performance or the audit finds a performance-sensitive regression.
4. Treat a missing local tool or unavailable GUI as an unverified check, not a
   repository defect. Do not install tools or change persistent application
   settings.

Never run `make format`, `make contrib`, `make all`, an installer against user
state, or any other command that can rewrite the repository or persistent
configuration.

## Audit coverage

### Appearance and palette contracts

- Derive appearances and modules from `lua/token/appearance.lua`. Verify each
  dark/light palette is loadable, uses valid `#RRGGBB` values, and exposes the
  complete shared semantic key contract.
- Trace palette use through groups, appearance overlays and roles, terminal
  colors, Lualine, and generators. Before reporting an unused key, rule out
  indexed or other dynamic access and generator-only use.
- Treat documented and tested dark/light asymmetry as intentional. Do not report
  taste, contrast ratio alone, or an aesthetic preference as a defect. Put any
  evidence-backed palette change in a separate approval-required section.

### Runtime and configuration

- Exercise every registered appearance in dark and light through both the
  dynamic and compiled paths. Verify configuration persistence, cache
  fingerprinting and corrupt-cache fallback, terminal slots 0 through 15,
  Lualine modes, enabled-plugin loading, and clean reload behavior.
- Check that public configuration validation and precedence match `README.md`:
  palette callbacks, appearance overlays, shared typography, user styles,
  surfaces, highlight overrides and callbacks, and attribute gates.
- Verify entry points and wrappers select registered appearances without
  duplicating runtime logic.

### Highlight and integration coverage

- Verify core and plugin group modules conform to the current loaders, reference
  valid palette keys, and avoid unintentional cross-module dependencies.
- Reconcile plugin files, the plugin registry, configuration keys, README
  inventory, and headless load coverage.
- Compare supported plugin highlight names with current official upstream
  documentation or source. Context7 may help locate documentation, but do not
  use third-party material as the sole evidence for a finding.
- Check commonly visible Neovim groups against the documentation for the
  supported Neovim version. Do not report optional plugins, niche groups, or
  deliberate parallel integrations as missing features.

### Generated themes, tooling, and documentation

- Reconcile generator output, tracked `contrib/**` files, README inventory and
  usage, generated headers, appearance/background identity, deterministic
  output, and stale-file detection. Recommend changes to sources, never
  generated files.
- Validate relevant generated formats with native parsers, schemas, or isolated
  application CLIs when available. Separate state-changing GUI imports into the
  manual checklist.
- Review build targets, generators, installer safety, tests, hooks,
  formatting/lint configuration, and public documentation for current behavior
  and failure handling.

## Evidence and findings

Report only findings supported by a reproducible repository observation and,
when the claim concerns an external API or file format, an authoritative
upstream source. A grep match is a lead, not proof.

For each finding include:

- severity and stable ID
- exact `file:line`
- observed evidence and authoritative source when applicable
- user or maintainer impact
- smallest coherent fix
- a focused acceptance check

Use these severities:

- **Critical**: confirmed current breakage in supported loading, configuration,
  generation, or data-safe tooling.
- **Warning**: confirmed contract drift, deprecated or stale integration
  behavior, or a validation failure that does not establish active breakage.
- **Info**: concrete, non-urgent maintenance improvement. Omit speculative
  features and style preferences.

Group findings with one root cause. Zero false positives is more important than
filling every section. If evidence remains ambiguous, list the check under
manual or unverified work instead of filing a finding.

## Report structure

Return:

1. Summary with severity counts and the highest-risk conclusion.
2. Coverage matrix showing each audited area, evidence, and status.
3. Critical, Warning, and Info findings.
4. Manual and unverified checks.
5. Approval-required palette proposals, if any.
6. Commands, versions, audited commit, and final repository status.

Finish with `git status --short` and confirm that the audit created no tracked
or untracked files.
