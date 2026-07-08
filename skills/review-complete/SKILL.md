---
name: review-complete
description: After all four openwashdata review issues are closed and merged to dev, create the final PR from dev to main. Reports precisely what blocks completion if the state does not reconcile.
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

## Step 3: Create the final PR

Title: `Complete package review for [package-name]`. Base: `main`, head:
`dev`. Body:

```
## Summary

This PR completes the review of the [package-name] R data package
following openwashdata standards.

Review standard version: [stamp from the metadata issue body]

## Completed Review Issues

- #[N]: Data Package Review: General Information & Metadata
- #[N]: Data Package Review: Data Content & Processing
- #[N]: Data Package Review: Documentation
- #[N]: Data Package Review: Tests & CI/CD

## Final Checks

- [ ] Package passes devtools::check() with no errors or warnings
- [ ] Documentation and website build successfully
- [ ] Ready for publication

## Next Steps

After merging: create a release with /create-release [version]
```

## Step 4: Report and stop

Give the user the PR URL and the next steps (review, merge, then
`/create-release [version]`). **Stop; do not merge the PR yourself and do
not start a release.**
