# CLAUDE.md - openwashdata/pkgreview

This file guides Claude Code sessions working ON this repository (the review
tooling itself). It is no longer the artifact downloaded into packages under
review; that role moved to the package-resident standards file (see below).

## What this repository is

The review tooling for R data packages in registered GitHub organizations
(openwashdata and Global-Health-Engineering; profiles under
`skills/pkgreview-core/references/orgs/`). A review runs issue-per-area
(metadata, data, docs, tests) on the package's `dev` branch, one PR per
issue into `dev`, and one final PR from `dev` to `main`. The workflow
ships as Claude Code skills.

## Architecture

- `skills/` - one skill per entry point (`review-package`, `review-issue`,
  `create-next-issue`, `review-status`, `review-complete`,
  `create-release`, `add-doi`), all with `disable-model-invocation: true`. The
  behavioral guardrails (STOP after each PR, check-ins before commits, PRs
  only against `dev`) live in the SKILL.md bodies at the point of action;
  never move them into reference files.
- `skills/pkgreview-core/` - shared reference files, loaded by the skills
  with `${CLAUDE_SKILL_DIR}` paths:
  - `references/checklists/` - the canonical checklists, the single source
    of truth for the review standard
  - `references/templates/` - issue body, PR body, standard `_pkgdown.yml`
  - `references/orgs/` - registered organization profiles, one file per
    org; the single source of org-specific values (pages domain,
    analytics, citation tooling, keywords, Zenodo community). Reviewing a
    package in an unregistered org is a hard stop.
  - `references/standards.md` - the package-resident standards file;
    `/review-package` writes it into each reviewed package as its CLAUDE.md,
    with the version and organization profile stamped in
  - `references/recovery.md` - review-state failure modes and recovery paths
  - `VERSION` - the review standard version
- `fixtures/` - `pkgreviewtest`, a deliberately defective package, plus
  `SCORECARD.md` listing every planted defect and the checklist item that
  must catch it
- `docs/checklist-reconciliation.md` - the record of how the previously
  diverging checklist copies were merged (issue #5)
- `commands/` - deprecated slash-command stubs, kept only as pointers

## Rules for changing the review standard

1. Checklist or template changes get a version bump: update
   `skills/pkgreview-core/VERSION` and tag the release commit
   (`v[version]`). In-flight reviews finish on the version stamped into
   their first review issue; skills fetch stamped-version checklists and
   org profiles from raw.githubusercontent.com when they detect a
   mismatch.
2. After any significant change to checklists or skills, run the review
   workflow against `fixtures/pkgreviewtest/` and confirm every planted
   defect in `fixtures/SCORECARD.md` is caught. A missed defect means the
   change weakened the standard and must not merge.
3. If a checklist item is added, dropped, or reworded, record the decision
   in `docs/checklist-reconciliation.md`.
4. Never let checklist content be duplicated again: issue bodies quote the
   canonical files verbatim; commands, docs, and skills reference them by
   path.
5. Do not delete the package-resident standards artifact
   (`references/standards.md`) or the step that writes it: it is what
   guides future Claude sessions inside reviewed packages and records the
   standard version a package was reviewed against.

## Git workflow for this repo

- Work happens on `dev` (create off `main` if missing); PRs go from `dev`
  into `main`
- No emojis and no em dashes in anything committed to this repo
