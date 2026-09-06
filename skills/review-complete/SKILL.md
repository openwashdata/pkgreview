---
name: review-complete
description: After all four review issues are closed and merged to dev, create the final PR from dev to main. Reports precisely what blocks completion if the state does not reconcile.
disable-model-invocation: true
---

# review-complete

Create the final PR from `dev` to `main` for the package in the current
directory. This is the ONLY point in the entire review workflow where a PR
against `main` is correct.

## Step 1: Verify all four review issues are complete

```bash
gh issue list --label "pkgreview-metadata" --state all --json number,state,title
gh issue list --label "pkgreview-data" --state all --json number,state,title
gh issue list --label "pkgreview-docs" --state all --json number,state,title
gh issue list --label "pkgreview-tests" --state all --json number,state,title
```

All four must exist and be CLOSED, with one reconcilable exception: an
OPEN issue whose PR is already merged into dev is the normal post-merge
state (`Closes #N` only fires on default-branch merges; recovery.md
failure mode 7). Check with
`gh pr list --state merged --search "[issue-number]"`, close the issue,
and continue:

```bash
gh issue close [issue-number] --comment "Completed via PR #[pr-number], merged into dev."
```

For anything else, do not create the PR. Report precisely what blocks
completion, per area:

- missing issue: "[Area]: no issue with label pkgreview-[area] exists"
- open issue without a merged PR: "[Area]: issue #[N] is still open and no
  merged PR references it"
- duplicate labels: name both issue numbers

Do not refuse opaquely; for each problem name the matching failure mode and
recovery path from
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/recovery.md`.

Upgrade path: when a `pkgreview-upgrade` issue exists
(`gh issue list --label "pkgreview-upgrade" --state all --json number,state,title`),
the four area issues belong to the original review and are closed; the
upgrade issue must be CLOSED with a merged PR, or OPEN with a merged PR
(the same post-merge state as above: close it and continue). An open
upgrade issue without a merged PR blocks completion; name it. The final
PR then carries the new stamp and an `Upgraded from:` line.

Also verify each closed issue has a merged PR referencing it
(`gh pr list --state merged --search "[issue-number]"` or the issue's
timeline). A closed issue without a merged PR is failure mode 2: check
whether the work is actually on dev before proceeding, and tell the user
what you found.

## Step 2: Check branch state

```bash
git checkout dev && git pull origin dev
git fetch origin main
git rev-list --count dev..main
```

If `dev` is behind `main` (count above 0), check whether the missing
commits actually change content:

```bash
git diff --stat dev origin/main
```

- Empty diff: the trees are identical, so the behind-ness is bookkeeping
  only (for example the merge commit of a previous dev-to-main PR). Tell
  the user, resolve it directly
  (`git merge origin/main && git push origin dev`), and continue.
- Non-empty diff: stop: failure mode 4 in recovery.md. Merge `main` into
  `dev` first (with the user's approval), resolve conflicts, then re-run
  this skill.

## Step 3: Check the site deployment state

The docs area's required Website item means: the pkgdown workflow exists,
`docs/` is not tracked, and the workflow builds green. Verify on `dev`:

```bash
test -f .github/workflows/pkgdown.yaml && echo "workflow present"
git ls-files docs | head -1        # must print nothing
gh run list --workflow=pkgdown.yaml --limit 1 --json status,conclusion,url,headBranch
```

The workflow runs on every pull request, so the latest run is normally
the one from the last per-issue PR into `dev`; it deploys only on the
push to `main` that merging the final PR produces. If the workflow is
missing or `docs/` is tracked, the docs item is not met: stop, name the
docs issue, and let the user decide whether to reopen it or fix it on
`dev` first. If the latest run failed, stop and show its output.

## Step 4: Create the final PR

Title: `Complete package review for [package-name]`. Base: `main`, head:
`dev`. Body:

```
## Summary

This PR completes the review of the [package-name] R data package
following the pkgreview standards with the [org] organization profile.

Review standard version: [stamp from the metadata issue body, or from the upgrade issue when this PR completes an upgrade]

Organization profile: [org stamp from the metadata issue body]

[Upgrade only:] Upgraded from: [previous stamp] (issue #[upgrade issue])

## Completed Review Issues

- #[N]: Data Package Review: General Information & Metadata
- #[N]: Data Package Review: Data Content & Processing
- #[N]: Data Package Review: Documentation
- #[N]: Data Package Review: Tests & CI/CD

## Final Checks

- [ ] Package passes devtools::check() with no errors or warnings
- [ ] pkgdown workflow builds green (latest run: [URL from Step 3])
- [ ] `.github/workflows/pkgdown.yaml` present and `docs/` untracked
- [ ] Ready for publication

## Maintainer action

GitHub Pages must deploy from the `gh-pages` branch (repository
Settings, Pages, Source: Deploy from a branch, Branch: gh-pages, /root).
`usethis::use_pkgdown_github_pages()` sets this during the docs issue;
confirm it, because the workflow deploys the site on the merge of this
PR. The site then lives at [Pages URL from the org profile pattern].

## Next Steps

After merging: create a release with /create-release [version]
```

## Step 5: Report and stop

Give the user the PR URL and the next steps (review, merge, confirm the
Pages setting, then `/create-release [version]`). **Stop; do not merge
the PR yourself and do not start a release.**
