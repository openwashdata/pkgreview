# pkgreview-core

This directory is not a skill (it has no SKILL.md). It holds the reference
files shared by all pkgreview skills, which load them with relative paths
(`../pkgreview-core/references/...`).

## Contents

- `references/checklists/` - the canonical review checklists, one per review
  area (metadata, data, docs, tests). Single source of truth; issue bodies
  are built from these. Consolidation record:
  `docs/checklist-reconciliation.md` in the repo root.
- `references/templates/` - canonical issue body template, PR body template,
  and the standard `_pkgdown.yml`.
- `references/standards.md` - the package-resident standards file that
  `/review-package` writes into each reviewed package (as its CLAUDE.md),
  stamped with the standard version.
- `references/recovery.md` - known review-state failure modes and their
  recovery paths.

## Versioning rule

Checklist and template changes get a version bump (git tag on this repo).
In-flight reviews finish on the version stamped into their first review
issue. After any significant change to checklists or skills, run the review
against `fixtures/pkgreviewtest/` and confirm every planted defect in
`fixtures/SCORECARD.md` is still caught before merging.
