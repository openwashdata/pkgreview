---
name: review-status
description: Show package review progress for the R data package in the current directory, derived from the pkgreview-* labeled GitHub issues, and surface state anomalies. Read-only.
disable-model-invocation: true
---

# review-status

Report the state of a package review. This skill is read-only:
it inspects GitHub issues, PRs, and git state, and reports. It never creates,
edits, closes, commits, or pushes anything.

Run from the root of the package under review (the repo whose issues carry
the `pkgreview-*` labels).

## Step 1: Gather state

```bash
PACKAGE_NAME=$(basename "$PWD")

# All four review areas, open AND closed
gh issue list --label "pkgreview-metadata" --state all --json number,state,title
gh issue list --label "pkgreview-data" --state all --json number,state,title
gh issue list --label "pkgreview-docs" --state all --json number,state,title
gh issue list --label "pkgreview-tests" --state all --json number,state,title

# Open PRs and branch state
gh pr list --state open
git fetch --quiet origin
git rev-list --count dev..main 2>/dev/null || echo "no dev branch"
```

Fallback when ALL FOUR label queries return empty: the review may predate
the labeling convention (failure mode 8 in recovery.md). Search titles
before concluding no review exists:

```bash
gh issue list --state all --search "Data Package Review: in:title" --json number,state,title
```

If this finds issues, treat them as the review record for the report
below and add the retro-labeling recommendation from recovery.md to the
Next Action section. Only when both the label queries and the title
search are empty does "no review exists" hold.

Also read the version stamp: view the first (metadata) issue body with
`gh issue view [number]` and find the "Review standard version" line, if
present. The installed tooling version is in
`${CLAUDE_SKILL_DIR}/../pkgreview-core/VERSION`, and the newest released
version comes from the tags:

```bash
git ls-remote --tags https://github.com/openwashdata/pkgreview.git | sed 's|.*refs/tags/v||; /\^{}$/d' | sort -V | tail -1
```

(offline: report "not checked"). Also list a standard upgrade issue, if
any: `gh issue list --label "pkgreview-upgrade" --state all --json number,state,title`.

## Step 2: Report

Build the report only from the command output above; do not invent progress.

```
## Review Status for [package-name]

**Issues Completed**: [N]/4
**Review standard version**: [stamp from issue 1, or "not stamped"]
**Installed tooling version**: [VERSION] (newest release: [latest], or "not checked")
**Standard upgrade**: [none, or issue #[number] ([state]) from [stamp] to [version]]

### Issue Status

[One line per review area, in order (Metadata, Data, Documentation, Tests):]
- Issue #[number]: [title] (completed)   [exists and CLOSED]
- Issue #[number]: [title] (open)        [exists and OPEN]
- [Area] Review: Not yet created         [no issue with that label]

### Next Action

[Exactly one, based on state:]
- No issues exist: suggest /review-package to start the review
- An issue is open: suggest /review-issue [number]
- Latest issue closed, later ones not created: suggest /create-next-issue
- All four exist and are closed: suggest /review-complete
- An upgrade issue is open: suggest /review-issue [number]; closed with a merged PR and no open review issue: suggest /review-complete
```

## Step 3: Anomaly checks

Surface these rather than only counting progress. For each hit, name the
failure mode and the recovery path from
[recovery.md](../pkgreview-core/references/recovery.md):

- More than one issue with the same `pkgreview-*` label (duplicates)
- An issue closed without a merged PR referencing it
- `dev` behind `main` (`git rev-list --count dev..main` greater than 0)
- Version stamp in issue 1 differs from the installed tooling version
- Installed tooling version older than the newest release (not a review-state failure; the install is stale, update before the next review)
- A package CLAUDE.md whose last `Standard version:` line differs from the stamp in issue 1 without an `Upgraded from:` line (failure mode 11)
- An open PR whose base branch is `main` while review issues are still open

If no review is in progress (no `pkgreview-*` issues AND no
title-matched issues from the Step 1 fallback), say so and suggest
`/review-package [package-name]`. If title-matched issues exist without
labels, report the review from them and recommend the retro-labeling
commands from failure mode 8 in recovery.md instead of suggesting a
fresh review.
