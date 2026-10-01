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
- `references/orgs/` - registered organization profiles, one file per
  org; the single source of org-specific values (pages domain, analytics,
  citation tooling, keywords, brand, Zenodo community).
- `references/standards.md` - the package-resident standards file that
  `/review-package` writes into each reviewed package (as its CLAUDE.md),
  stamped with the standard version and the organization profile.
- `references/recovery.md` - known review-state failure modes and their
  recovery paths.
- `check/pkgreview-check.R` - the deterministic check script for the
  mechanical subset of the checklists (run by `/review-package` and
  `/review-issue`). Its metadata, docs, and tests lines come from
  `washr::check_publication_readiness()` (issues #66 and #87), so it needs
  washr at or above `WASHR_FLOOR`; the data-quality lines, the PII signal
  scan, and the git-history scan are its own.

## Versioning rule

Checklist and template changes get a version bump (git tag on this repo).
In-flight reviews finish on the version stamped into their first review
issue. After any significant change to checklists or skills, run the review
against `fixtures/pkgreviewtest/` and confirm every planted defect in
`fixtures/SCORECARD.md` is still caught before merging.
