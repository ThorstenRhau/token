# Project knowledge

## Purpose and authority

This index maps Token's durable, checked-in project knowledge. The sources are
authoritative by concern:

- [`README.md`](../README.md) defines the public installation, configuration,
  compilation, plugin, and contrib contract.
- [`AGENTS.md`](../AGENTS.md) defines repository-specific contributor rules,
  source-of-truth boundaries, validation, and commit conventions.
- [`architecture.md`](architecture.md) describes the current implementation
  and the relationships between its runtime and generated outputs.
- Code, tests, and deterministic checks named by those documents anchor claims
  about implemented behavior.

## Current-state documentation

- [Architecture](architecture.md): appearance registration, runtime theme
  assembly, compiled caches, generated contrib themes, and validation coverage.

## Decision history

No decision records are currently retained. Add a numbered record under
`docs/decisions/` only for accepted, non-obvious rationale that cannot be
represented as current architecture, a project rule, or an enforced invariant.

## Active work

Active and proposed work belongs in the
[GitHub issue tracker](https://github.com/ThorstenRhau/token/issues), not in this
index or local TODO documents.

## Release and operational evidence

- [`README.md`](../README.md) documents supported user workflows, including
  installation and `:TokenCompile`.
- [`Makefile`](../Makefile) defines the canonical formatting, lint, test,
  benchmark, generation, and verification targets.
- [GitHub releases](https://github.com/ThorstenRhau/token/releases) retain
  published release evidence.

## Maintenance

Update current-state documents with the implementation they describe. Preserve
accepted decision records and supersede them with a linked newer record instead
of rewriting their history. Do not retain active work, speculative plans,
session summaries, or facts that are obvious from a single code lookup.
