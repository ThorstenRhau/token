---
name: colorscheme-review
description:
  Performs a read-only, evidence-led audit of Token's palettes, runtime themes,
  plugin integrations, generated contrib themes, and toolchain, and returns one
  Markdown report. Use for repository-wide colorscheme audits, not for ordinary
  implementation or a narrow code review.
---

# Token Colorscheme Review

Audit the repository without modifying it or saving a report to disk, and return
one Markdown report in the conversation.

Use current code, registries, tests, and official upstream sources as the
authority. Do not preserve a finding merely because an older checklist expected
it.

## Contents

- [Establish the baseline](#establish-the-baseline)
- [Scratch space and parallel work](#scratch-space-and-parallel-work)
- [What the tests already prove](#what-the-tests-already-prove)
- [Audit coverage](#audit-coverage)
- [Evidence and findings](#evidence-and-findings)
- [Report structure](#report-structure)

## Establish the baseline

1. Read `AGENTS.md`, `README.md`, `docs/index.md`, `docs/architecture.md`,
   `Makefile`, the appearance registry, runtime entry points,
   theme/config/compile modules, typography, terminal and Lualine builders,
   group registries, generators, tests, and relevant tool configuration. Follow
   references from the current registries instead of relying on a frozen
   appearance, plugin, or contrib inventory.
2. Record `git status --short --branch`, the audited commit, Neovim and tool
   versions, and which checks are available. Run `gh issue list --state open` so
   a known item cites its issue instead of being reported as new.
3. Run `make check` and `git diff --check`, and keep their exit status: do not
   pipe them through a filter such as `tail` without `pipefail`. Run individual
   read-only targets only to isolate failures. Run `make benchmark` only when
   the request includes performance or the audit finds a performance-sensitive
   regression.
4. Run `.agents/skills/colorscheme-review/scripts/validate_contrib.sh`. It
   checks every tracked `contrib/**` file with a native parser, the schema the
   file declares, or the application that consumes it, in an environment that
   ignores the caller's configuration. It prints each failure, the passed checks
   per validator, and the files it skipped with the reason. It writes only to
   its own temporary directory and needs network access for schemas and `uv` for
   JSON Schema validation.
5. Treat a missing local tool or unavailable GUI as an unverified check, not a
   repository defect. Do not install tools or change persistent application
   settings.

Never run `make format`, `make contrib`, `make all`, an installer against user
state, or any other command that can rewrite the repository or persistent
configuration.

## Scratch space and parallel work

- Create one audit directory outside the repository with `mktemp -d` and keep
  fetched upstream sources, probes, and isolated application state in it.
- When subagents share the work, give each its own subdirectory. Never delete a
  directory another worker may still be using.
- Delete the audit directory once, at the end, as its own short command with the
  exact path.

## What the tests already prove

Once `make check` passes, treat the contracts that `tests/headless.lua` asserts
as verified and cite the test line instead of re-implementing the check.
`rg -n '^-- ' tests/headless.lua` lists its sections. These include the palette
contract, entry points, highlight precedence, plugin selection, typography,
dynamic and compiled parity, cache invalidation and fallback, terminal colors,
and parts of the generated formats.

Read an assertion before relying on it. A loop over an empty list, or a pattern
that matches nothing, passes without checking anything. An earlier VS Code test
matched none of its 160 cases. Spend independent effort where the tests cannot
see: upstream drift, native application acceptance, documentation drift,
cross-output consistency the tests do not assert, and gaps in the tests
themselves. Write your own runtime probe only for a gap you can name.

## Audit coverage

### Appearance and palette contracts

- Trace palette use through groups, appearance overlays and roles, terminal
  colors, Lualine, and generators. Before reporting an unused key, rule out
  indexed or other dynamic access and generator-only use.
- Treat documented and tested dark/light asymmetry, and any choice whose
  rationale is recorded in `README.md`, `docs/`, a test, or a code comment, as
  intentional. Do not report taste, contrast ratio alone, or an aesthetic
  preference as a defect. Put any evidence-backed palette change in a separate
  approval-required section.

### Cross-output consistency

- For each appearance and variant, a semantic role should resolve to the same
  color in Neovim and in every generated format, apart from differences with a
  recorded rationale, and font attributes should follow `typography.lua`. Cite
  the parity assertions in `tests/headless.lua` where they exist. For the
  remaining roles and formats, resolve the Neovim group and compare it with the
  generated value.
- Check runtime and generator code against the rules in `AGENTS.md` under
  "Change conventions". For example, a generator that branches on an appearance
  name or repeats an appearance's colors breaks the registry-driven rule and
  lets its output drift from Neovim.

### Runtime and configuration

- Check that the runtime tests cover every registered appearance in dark and
  light through both the dynamic and compiled paths, and probe only the gaps.
- Confirm, from a test or your own probe, that every appearance's Lualine
  wrapper provides all modes with their sections, terminal slots 0 through 15
  are set for each appearance and variant, configuration persists across
  reloads, and a reload leaves no stale groups. The tests check Lualine only
  partly, so probe the wrappers.
- Check that public configuration validation and precedence match `README.md`:
  palette callbacks, appearance overlays, shared typography, user styles,
  surfaces, highlight overrides and callbacks, and attribute gates.
- Look for values that never take effect: an attribute or color set in a source
  that a later stage of the precedence chain always replaces.
- Check the lifecycle of state Token writes, such as compiled caches: creation,
  invalidation, and cleanup across configurations, without removing state that
  another configuration still uses.
- Verify entry points and wrappers select registered appearances without
  duplicating runtime logic.

### Highlight and integration coverage

- Verify core and plugin group modules conform to the current loaders, reference
  valid palette keys, and avoid unintentional cross-module dependencies.
- Reconcile plugin files, the plugin registry, configuration keys, README
  inventory, and headless load coverage.
- Compare supported plugin highlight names with upstream source. Fetch each
  plugin at a recorded tag or commit, with a shallow clone or release tarball,
  into the audit directory. Some plugins build group names at runtime, for
  example from completion kinds or a table of modes, so read the code that
  creates highlights, not only literal group names. Do not use third-party
  material as the sole evidence for a finding.
- Check commonly visible Neovim groups against the documentation for the
  supported Neovim version. Do not report optional plugins, niche groups, or
  deliberate parallel integrations as missing features.

### Generated themes, tooling, and documentation

- Reconcile generator output, tracked `contrib/**` files, README inventory and
  usage, generated headers, appearance/background identity, deterministic
  output, and stale-file detection. Recommend changes to sources, never
  generated files.
- Report the failures from `validate_contrib.sh`, grouped by root cause: one
  broken generator source can fail many files. List its skipped files under
  manual and unverified checks, and validate a skipped format by hand only when
  a tool for it is available. Put state-changing GUI imports in the manual
  checklist.
- Review build targets, generators, installer safety, tests, hooks,
  formatting/lint configuration, `docs/`, and public documentation for current
  behavior and failure handling.

## Evidence and findings

Report only findings supported by a reproducible repository observation and,
when the claim concerns an external API or file format, an authoritative
upstream source. A grep match is a lead, not proof.

A claim that nothing differs or nothing is missing needs a named check that
covered every appearance and both variants. Without one, list the area under
manual or unverified checks instead of asserting it.

For each finding include:

- severity and ID
- exact `file:line`
- observed evidence and authoritative source when applicable
- user or maintainer impact
- smallest coherent fix, with its side effects
- a focused acceptance check

If a fix would change any rendered color in Neovim or a generated theme, even as
a side effect of a structural change, say so and put that change in the
approval-required section.

Use these severities:

- **Critical**: confirmed current breakage in supported loading, configuration,
  generation, or data-safe tooling.
- **Warning**: confirmed contract drift, deprecated or stale integration
  behavior, or a validation failure that does not establish active breakage.
- **Info**: concrete, non-urgent maintenance improvement. Omit speculative
  features and style preferences.

Number findings in report order as `C-1`, `W-1`, and `I-1`, and palette or color
proposals as `P-1`, so a follow-up request can name them.

Group findings with one root cause. Zero false positives is more important than
filling every section. If evidence remains ambiguous, list the check under
manual or unverified work instead of filing a finding.

## Report structure

Return:

1. Summary with severity counts and the highest-risk conclusion.
2. Coverage matrix showing each audited area, evidence, and status.
3. Critical, Warning, and Info findings.
4. Manual and unverified checks.
5. Approval-required palette and color proposals, if any.
6. Commands, versions, audited commit, and final repository status.

Finish by deleting the audit directory, then run `git status --short` and
confirm that the audit created no tracked or untracked files.
