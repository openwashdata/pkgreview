# review-status

**Description**: Shows current review progress and pending tasks for the openwashdata package review workflow.

**Usage**: `/review-status`

**Parameters**: None

---

When the user types `/review-status`, execute the following:

First, determine the package name and check review issues:

```bash
PACKAGE_NAME=$(basename "$PWD")

# Get all review issues with their status (open and closed)
gh issue list --label "pkgreview-metadata" --state all --json number,state,title
gh issue list --label "pkgreview-data" --state all --json number,state,title
gh issue list --label "pkgreview-docs" --state all --json number,state,title
gh issue list --label "pkgreview-tests" --state all --json number,state,title
```

## Reporting the status

Build the report from the command output above. Do not invent progress; report only what the GitHub state shows.

Present a status report with this structure:

```
## Review Status for [package-name]

**Issues Completed**: [N]/4

### Issue Status

[For each of the four review areas, in order
(Metadata, Data, Documentation, Tests), report one line:]
- Issue #[number]: [title] (completed)   [if the issue exists and is CLOSED]
- Issue #[number]: [title] (open)        [if the issue exists and is OPEN]
- [Area] Review: Not yet created         [if no issue with that label exists]

### Next Action

[Exactly one of the following, based on the state:]
- No issues exist yet: suggest `/review-package` to start the review.
- An issue is open: suggest `/review-issue [number]` to work on it.
- The most recent issue is closed and later ones are not yet
  created: suggest `/create-next-issue`.
- All four issues exist and are closed: suggest `/review-complete`
  to create the final PR from dev to main.
```

Also check for and report anomalies rather than only counting progress:

- More than one issue carries the same `pkgreview-*` label (duplicate issues)
- An issue is closed but no merged PR references it
- The `dev` branch is behind `main` (`git rev-list --count dev..main` greater than 0)

---

## Error Handling

If no review is in progress (no `pkgreview-*` labeled issues exist):

> No package review is currently in progress.
> Start a new review with: `/review-package [package-name]`
