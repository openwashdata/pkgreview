---
name: create-next-issue
description: Create the next openwashdata review issue in sequence (data, docs, or tests) after the previous review issue's PR has been merged to dev. Includes a duplicate guard and version-stamp check.
disable-model-invocation: true
---

# create-next-issue

Create the next review issue in the sequence metadata, data, docs, tests for
the package in the current directory. This skill creates exactly one issue
and stops; it never starts working on the issue it creates.

## Step 1: Sync dev and gather state (dedupe guard)

Sync `dev` first; the previous PR was merged on GitHub and the local
branch is stale:

```bash
git checkout dev && git pull
```

Check ALL states, not just open; a closed or relabeled issue still counts as
existing (recovery.md failure mode 1):

```bash
gh issue list --label "pkgreview-metadata" --state all --json number,state,title
gh issue list --label "pkgreview-data" --state all --json number,state,title
gh issue list --label "pkgreview-docs" --state all --json number,state,title
gh issue list --label "pkgreview-tests" --state all --json number,state,title
```

Rules:

- If an issue for the would-be-next area ALREADY EXISTS (any state), abort
  with the issue number and state, and point at `/review-status`. Never
  create a duplicate.
- If the previous area's issue is still OPEN, check for a merged PR
  referencing it:
  ```bash
  gh pr list --state merged --search "[issue-number]" --json number,title
  ```
  An open issue with a merged PR is the NORMAL post-merge state, not an
  error: `Closes #N` only fires on merges into the default branch, and
  review PRs merge into `dev` (recovery.md failure mode 7). Close it now
  and continue:
  ```bash
  gh issue close [issue-number] --comment "Completed via PR #[pr-number], merged into dev."
  ```
  Abort only if the previous issue is open and NO merged PR references it:
  its work has not landed on dev. Name the open issue.
- If more than one issue carries the same label, abort and follow failure
  mode 1 in
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/recovery.md`.
- If all four areas have issues, say so and suggest `/review-status` or
  `/review-complete`.

## Step 2: Version stamp check

Read the `Review standard version` line from the metadata issue body and
compare with `${CLAUDE_SKILL_DIR}/../pkgreview-core/VERSION`.

On mismatch: warn the user, and use the checklist pinned to the STAMPED
version, fetched from
`https://raw.githubusercontent.com/openwashdata/pkgreview/v[stamp]/skills/pkgreview-core/references/checklists/[area].md`
(failure mode 5 in recovery.md: in-flight reviews finish on the version they
started with). If the stamped version cannot be fetched, ask the user before
falling back to the installed checklists.

## Step 3: Create the issue

Next area: `data` if only metadata exists and is closed; `docs` if data is
the latest and closed; `tests` if docs is the latest and closed.

Build the body from the canonical sources; insert checklist content
verbatim:

- Template: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/templates/issue-body.md`
  (title and label mapping are in its table)
- Checklist: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/checklists/[area].md`
  (or the stamped-version copy from Step 2)

Fill the Prerequisites section with the actual issue numbers of the
completed earlier areas, and carry the same
`Review standard version: [stamp]` line forward.

Capture the new issue number from the `gh issue create` output.

## Step 4: Report and stop

Tell the user:

1. The created issue number and URL
2. Whether the previous area's issue was closed by this skill (name the
   issue and the merged PR)
3. Run `/review-issue [new-number]` to start working on it (`dev` is
   already synced from Step 1)

**Stop here. Do not start working on the issue.**
