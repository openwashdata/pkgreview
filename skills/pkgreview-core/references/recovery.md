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
PR is already open, edit the PR body so `Addresses #[number]` names the right
issue; that reference is what the skills search for when matching merged PRs
to issues. Branch naming is a convenience; the issue-PR link is the record
that matters.

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
`https://raw.githubusercontent.com/openwashdata/pkgreview/[stamp]/skills/pkgreview-core/references/checklists/[area].md`,
and the organization profile pinned the same way:
`.../[stamp]/skills/pkgreview-core/references/orgs/[org].md`.
Warn the user, and never mix two standard versions within one review.

Note: an installed tooling version older than the newest release is not a
review-state failure. `/review-package` compares the two before a review
exists and stops; `/review-status` reports it. Update the install and
rerun.

## 6. No version stamp found (review predates stamping)

Symptom: the first review issue body has no "Review standard version" line.

Recovery: treat the review as pinned to the oldest available standard, tell
the user, and continue with the installed version only after they confirm.

## 7. Issue still open after its PR merged into dev (expected state)

Symptom: a review issue remains open although its PR was merged.

This is not corruption. `Closes #N` only fires on merges into the default
branch (`main`); per-issue review PRs merge into `dev`, so GitHub never
auto-closes review issues. `/create-next-issue` and `/review-complete`
detect this state, close the issue with a comment referencing the merged
PR, and continue.

Manual recovery, if needed:
`gh issue close [number] --comment "Completed via PR #[pr-number], merged into dev."`

## 8. Pre-label review invisible to label queries

Symptom: all four `pkgreview-*` label queries return empty, yet the repo
was reviewed. Reviews created before the labeling convention (the older
CLAUDE.md-driven workflow) used title conventions only, so their issues
carry no labels. Observed on openwashdata/artesianwells: four closed
"Data Package Review: ..." issues and a merged dev-to-main PR, reported
as 0/4 with a suggestion to start a fresh review.

Recovery: search titles before concluding no review exists:
`gh issue list --state all --search "Data Package Review: in:title" --json number,state,title`.
If title-matched issues are found, report them as the review record and
recommend retro-labeling so subsequent runs use the label path:
`gh label create pkgreview-[area]` (if missing) plus
`gh issue edit [number] --add-label pkgreview-[area]` for each of the
four areas. Retro-labeling is a write action: /review-status only
recommends the commands, it never runs them.

## 9. No organization stamp found (review predates org profiles)

Symptom: the first review issue body has a "Review standard version" line
but no "Organization profile" line. The review started before v1.3.0
introduced organization profiles.

Recovery: the review is an openwashdata review by definition; openwashdata
was the only organization before profiles existed. Tell the user and
continue with the openwashdata profile
(`skills/pkgreview-core/references/orgs/openwashdata.md`).

## 10. Identifying data found in the git history

Symptom: the intake screen's history scan (review-package Step 2, or the
check script's history FLAG) surfaces identifiers in an earlier revision:
a data file that was added and later removed, an identifier column present
in a historical `.rda`, or a commit message naming identifying data being
added or removed. The current working tree can be completely clean and the
package still fails the publication floor, because anyone who clones the
repository can recover the removed data. Observed on
Global-Health-Engineering/malawihcf (facility GPS coordinates in three
historical commits; documented in
Global-Health-Engineering/malawihcf#6).

Recovery: publication (making the repository public, or archiving it
together with its history) stays blocked until the history is clean. This
is a write action on the reviewed package and its clones; the review skill
recommends the path and stops, it never rewrites history on its own.

1. Rewrite the history to drop the identifying blobs: `git filter-repo`
   (preferred) over the affected paths, or restart the history from a
   clean root commit when the identifiers are spread across many commits.
2. Force-push the rewritten branches and re-apply branch protection.
3. Ask GitHub support to purge unreachable objects and cached views;
   until they do, the old blobs remain reachable by SHA.
4. Have every collaborator delete their old clones and clone again; a
   rewritten remote does not clean local copies.
5. Treat the data as disclosed to everyone who had access to the
   repository for the window it was present, and decide with the data
   owner whether that needs follow-up.

Only after the history scan comes back clean does the package clear the
PII floor. Record the remediation and the clean re-scan on the review
issue.

## 11. Two standard stamps in one package (upgraded package)

Symptom: the package CLAUDE.md carries a `Standard version:` line that
differs from the stamp in the first review issue. Since v1.6.0,
`/review-upgrade` brings a published package to a newer standard through
one `pkgreview-upgrade` issue and rewrites the standards file with the
new version; the first review issue keeps its original stamp as history.

Recovery: this is the expected state when an `Upgraded from: [stamp] on
[date]` line sits under the stamps in CLAUDE.md and a closed
`pkgreview-upgrade` issue with a merged PR exists. The current standard
of the package is the last `Standard version:` line in CLAUDE.md, and
that is the version later skills pin to. Without the `Upgraded from:`
line or without the upgrade issue, someone edited the stamp by hand:
restore the stamp from the first review issue and run `/review-upgrade`
properly.
