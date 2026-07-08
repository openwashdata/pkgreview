# Review state: known failure modes and recovery paths

Review state is derived entirely from GitHub labels (`pkgreview-metadata`,
`pkgreview-data`, `pkgreview-docs`, `pkgreview-tests`), issue open/closed
state, and branch name prefixes. There is no session state file. These are the
known ways that state gets corrupted, and how to recover. When a skill hits
one of these, it must name the failure mode and the recovery path instead of
refusing opaquely or guessing.

## 1. Duplicate review issues (label edited or issue recreated)

Symptom: two or more issues carry the same `pkgreview-*` label, usually
because someone tidied labels and `/create-next-issue` then created a
duplicate.

Recovery: keep the older issue (it holds the review record and the version
stamp), copy any unchecked items from the newer issue into it, close the newer
issue with a comment pointing at the original, and remove the `pkgreview-*`
label from the closed duplicate.

Prevention: `/create-next-issue` checks for existing issues with the target
label in ANY state (open or closed) before creating, and aborts with a clear
message if one exists.

## 2. Issue closed manually without a merged PR

Symptom: a review issue is closed but no merged PR references it, so
`/review-complete` cannot verify the work landed on `dev`.

Recovery: check whether the changes are actually on `dev`
(`git log dev --oneline` and inspect the relevant files against the issue
checklist). If the work is there, note the merged commit range in an issue
comment and proceed. If it is not, reopen the issue and finish it through the
normal flow.

## 3. Feature branch named without the issue-number prefix

Symptom: a branch like `metadata-fixes` instead of `issue-42-metadata` breaks
issue detection.

Recovery: rename the branch (`git branch -m issue-[number]-[slug]`), or if the
PR is already open, edit the PR body to include `Closes #[number]` so the link
exists regardless of the branch name. Branch naming is a convenience; the
issue-PR link is the record that matters.

## 4. A hotfix landed directly on main mid-review

Symptom: `dev` is behind `main`, and the final dev-to-main PR will conflict or
silently revert the hotfix.

Recovery: merge `main` into `dev` (`git checkout dev && git merge main`),
resolve conflicts, push, then continue. `/review-status` and
`/review-complete` check `git rev-list --count dev..main` and surface this
before it bites.

## 5. Version stamp mismatch (standard changed mid-review)

Symptom: the version stamp in the first review issue body differs from the
installed pkgreview version. Checklists or templates changed while this
review was in flight.

Recovery: in-flight reviews finish on the version they started with. Fetch
the checklist pinned to the stamped version:
`https://raw.githubusercontent.com/openwashdata/pkgreview/[stamp]/skills/pkgreview-core/references/checklists/[area].md`.
Warn the user, and never mix two standard versions within one review.

## 6. No version stamp found (review predates stamping)

Symptom: the first review issue body has no "Review standard version" line.

Recovery: treat the review as pinned to the oldest available standard, tell
the user, and continue with the installed version only after they confirm.
