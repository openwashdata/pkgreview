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
- `fixtures/` - `pkgreviewtest`, a deliberately defective package (17
  planted defects D1-D17), plus `SCORECARD.md` listing every planted
  defect and the checklist item that must catch it. The git-history
  defect D18 (issue #52) cannot live in `pkgreviewtest` (it is a subdir
  of this repo with no history of its own); `make_history_fixture.sh`
  builds a throwaway repo with a planted add-then-remove history for the
  scan to catch.
- `docs/checklist-reconciliation.md` - the record of how the previously
  diverging checklist copies were merged (issue #5) and, per release
  section keyed by version, every checklist item reworded since;
  `/review-upgrade` reads those sections to build a package's delta
- `NEWS.md` - release notes for everything that is not a checklist item
- `scripts/` - `release.sh` (release tail), `verify_release.sh`,
  `news_section.sh`, `lint.sh`, `washr_drift.R`
- `.github/workflows/` - `gate.yaml` (fixture gate, case suite, lint),
  `washr-drift.yaml`, `release.yaml`
- `.claude-plugin/` - plugin manifests; the version there mirrors
  `skills/pkgreview-core/VERSION` (lint checks they agree)

## Rules for changing the review standard

1. Checklist or template changes get a version bump: update
   `skills/pkgreview-core/VERSION` (and the matching version in
   `.claude-plugin/`), then release with `scripts/release.sh [version]`
   after the dev-to-main PR merges (it tags, verifies the pinned raw
   URLs, creates the GitHub release from NEWS.md, and syncs `dev`).
   In-flight reviews finish on the version stamped into their first
   review issue; skills fetch stamped-version checklists and org
   profiles from raw.githubusercontent.com when they detect a mismatch.
2. The mechanical fixture gate runs in CI (`.github/workflows/gate.yaml`:
   the check script against `fixtures/pkgreviewtest/` and the history
   fixture diffed against `fixtures/expected/`, plus the case suite in
   `fixtures/cases/`). A change that alters a FAIL, FLAG, or NOT RUN
   line must update the expected report in the same PR, with the
   scorecard mapping re-checked. A missed defect means the change
   weakened the standard and must not merge. The interactive run
   through the skills is issue #17 (#80 decides its future).
3. If a checklist item is added, dropped, or reworded, record the decision
   in `docs/checklist-reconciliation.md`, one row per item. Everything
   else (skills, scripts, templates, fixtures, process) is recorded in
   `NEWS.md` under the release version.
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
- Changes are proposed with `.github/ISSUE_TEMPLATE/proposal.md`: an
  objection window decides unless the choice is open; the release issue
  carries one decision table
- The release PR body lists `Closes #N` for every issue it lands (PRs
  here target `main`, so the keyword fires); no per-issue status or
  closing comments
- After the merge: `scripts/release.sh [version]` from `main`
- No emojis and no em dashes in anything committed to this repo;
  `scripts/lint.sh` enforces this and the skill path references
