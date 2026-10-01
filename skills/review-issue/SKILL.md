---
name: review-issue
description: Work on one review issue (by actual GitHub issue number) with a single plan-approval check-in, atomic commits, and a hard stop after the PR to dev is created. With --unattended the plan is posted on the issue and the PR is merged into dev on green checks.
disable-model-invocation: true
argument-hint: "[issue-number] [--unattended]"
---

# review-issue

Work on one review issue for the package in the current directory.

Arguments: `$ARGUMENTS`. The first token is the issue number, written
`[issue-number]` in the commands below. `--unattended` after it selects
unattended mode (Step 1b); the flag is never passed on to `git` or `gh`.
Without the flag the skill runs attended.

**Core discipline, non-negotiable: pause at CHECK-IN #1 and wait for the
user's reply. Once the plan is approved, implement, test, update the
issue, and create the PR without further prompts; the only reason to
pause again is a failure or work outside the approved plan. After
creating the PR, STOP COMPLETELY. One invocation of this skill handles
exactly one issue and ends at its PR; never continue to another issue or
another review area.**

**Unattended mode changes two things and nothing else: the plan is posted
on the issue instead of being approved at CHECK-IN #1, and this skill
merges the PR into `dev` once its checks are green and every required
item is checked. Every other stop holds in both modes, and the skill
still ends at this one issue.**

## Step 1: Verify the issue

```bash
gh issue view [issue-number] --json title,labels,body,state
```

- The issue must carry exactly one of: `pkgreview-metadata`,
  `pkgreview-data`, `pkgreview-docs`, `pkgreview-tests`, or
  `pkgreview-upgrade` (a standard upgrade issue created by
  `/review-upgrade`; its body is the whole work list, its items name the
  version that introduced them, and its "Intake re-screen" section must
  be filled before any other item, with a hit stopping the flow as in
  review-package Step 2). If not, stop: this is not a review issue; list
  review issues with `gh issue list --label pkgreview --state all`.
- If the issue is CLOSED, stop and suggest `/review-status`.
- Version check: find the `Review standard version` line in the first
  (metadata) review issue and compare with
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/VERSION`. On mismatch, warn the
  user and follow failure mode 5 in
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/recovery.md`
  (in-flight reviews finish on the version they started with).

The checklist in the issue body is the work list for this invocation. Also
read the canonical checklist for the area from
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/checklists/[area].md` for
the suggested tools and file lists (for an upgrade issue: every area's
file, since its items span areas). If body and canonical file disagree, the
issue body wins (it records this review's pinned standard); mention the
difference to the user.

## Step 1b: Unattended preflight (only with `--unattended`)

Unattended mode needs a check run to wait for and the right to merge.
Verify both before anything else:

```bash
git fetch origin dev
git cat-file -e origin/dev:.github/workflows/R-CMD-check.yaml
gh repo view --json viewerPermission --jq .viewerPermission
```

- The workflow file must exist on `dev`. The tests issue is the one that
  adds it to a package that lacks it, so on such a package the issues up
  to and including the tests issue run attended; a PR merged without an
  R CMD check run would land on `dev` unchecked.
- The permission must be `ADMIN`, `MAINTAIN`, or `WRITE`.

If either check fails, say which one in one line and continue attended
from Step 2, as if the flag had not been given.

**What unattended mode never does, whatever the plan says:**

1. It never continues past a PII or history finding. A PII signal that
   names a column, or a history FLAG, that the Intake screen section of
   the first review issue does not already record stops the run at a
   check-in before any branch exists (Step 2). So does a hit in the
   Intake re-screen of an upgrade issue (Step 1).
2. It never certifies the PII item. The item is checked only against a
   human record: the intake outcome in the first review issue and, for
   household- or person-level data, a named human sign-off comment on
   the review issue. Without that record the item stays unchecked.
3. It never writes or rewords a variable description. Dictionary
   descriptions are written or confirmed by a human; unattended mode may
   only carry a description that already exists and passes the
   placeholder check into another file (for example from the dictionary
   into the roxygen block). A missing or placeholder description leaves
   the required dictionary item unchecked, with the variables named.
4. It never checks a required item without evidence. Nobody watches the
   session, so the evidence rule of Step 5 is all there is: a required
   item is checked only when a command run in this session shows it, and
   a required item whose verdict rests on reading instead of on a
   command output stays unchecked for the maintainer.
5. It never performs the external actions: repository settings, the
   GitHub Pages setting, and anything on Zenodo stay with the
   maintainer.

## Step 2: Analyze and CHECK-IN #1 (the single implementation approval)

Run the deterministic check script first and read its section for this
issue's area:

```bash
Rscript "${CLAUDE_SKILL_DIR}/../pkgreview-core/check/pkgreview-check.R" . --org=[org] > /tmp/pkgreview-check.md
```

`[org]` is the lowercased `Organization profile` stamp from the metadata
issue (`openwashdata` when the review predates the stamp). For a review
pinned to an older version, pass `--org-file=[path]` with the fetched
stamped profile instead.

Its FAIL lines for the area are verified facts and seed the plan; do not
re-derive what the script already measured. Its PII line is a FLAG
signal, never a verdict.

Analyze what needs to change, item by item, using the Required and
Advisory tiers from the issue body. Present ONE consolidated plan
covering the whole issue; a table works well, required fixes first,
advisory suggestions after them:

| # | Tier | Change | Checklist item | Planned commit message |
|---|------|--------|----------------|------------------------|

Required fixes block publication and must all be in the plan. Advisory
findings are optional improvements: plan to fix the quick ones in this
issue's PR and record the rest as optional follow-ups; they never block
publication. Separating the tiers keeps the required half of the plan
small enough to approve at a glance.

> "Here's the full plan for this issue (table above). Once you approve, I
> will implement all of it with one atomic commit per change, run the
> tests, update the issue checklist, and open the PR against dev, with
> no further prompts. Proceed? (yes/no/edit)"

**Wait for the reply. "no" or "edit" means discuss, do not implement.
This is the only approval in the whole flow: it covers implementation,
testing, the issue checklist update, and PR creation. Anything beyond
the approved plan, and any failing check, needs a new check-in before
the flow continues.**

Unattended mode (Step 1b passed): do not ask. First compare the check
report with the Intake screen section of the first review issue. A PII
signal that names a column, or a history FLAG, that the section does not
record is a new finding: stop here at a check-in and wait, as
review-package Step 2 does. Otherwise write the same plan table to
`/tmp/pkgreview-plan.md`, add one line under it for every required item
that waits for a human (rules 2 to 4 of Step 1b), and post it on the
issue, so the record the check-in used to produce still exists:

```bash
gh issue comment [issue-number] --body-file /tmp/pkgreview-plan.md
```

Then continue with Step 3 without waiting. The posted plan stands in for
the approved plan in every later step: work outside it, and any failing
check, stops the run at a check-in exactly as in attended mode.

## Step 3: Branch

Only after approval (attended) or after the plan is posted (unattended):

```bash
git checkout dev && git pull
git checkout -b issue-[issue-number]-[short-slug]
```

Branch from `dev`, never from `main`. Keep the `issue-[number]-` prefix; it
is how later steps link branch to issue.

## Step 4: Implement the approved plan with atomic commits

For EACH change in the approved plan:

1. Announce the specific change
2. Make it and show the result
3. Commit immediately:
   `git add -A && git commit -m "[the planned commit message]"`
   (while `docs/` is still tracked: `git add -A -- . ':!docs'`)

Per-issue PRs never commit `docs/`. The site is deployed by the pkgdown
workflow from `main` (docs checklist, required Website item), and a
locally rebuilt site only adds toolchain churn to the diff
(openwashdata/pkgreview#54). Until the docs-area issue untracks the
directory, exclude it from every commit and leave any local rebuild
uncommitted.

Atomic commits, one logical change each; never batch the whole issue into
one commit. Do not pause between changes: the plan was approved at
CHECK-IN #1 and the check-in currency is the plan, not the individual
commit. If implementation reveals work outside the approved plan, stop
and CHECK-IN before doing it.

## Step 5: Test

Rerun the deterministic check script and confirm the FAIL lines for this
issue's area that the approved plan addressed are now PASS; post the
fresh report on the issue so it records the after-state:

```bash
Rscript "${CLAUDE_SKILL_DIR}/../pkgreview-core/check/pkgreview-check.R" . --org=[org] > /tmp/pkgreview-check.md
gh issue comment [issue-number] --body-file /tmp/pkgreview-check.md
```

Then run the checks the script cannot cover (from the canonical checklist
file), for example `R -e "devtools::check()"`,
`R -e "devtools::build_readme()"`, `R -e "pkgdown::build_site()"`. Show
the results faithfully; if something fails, say so with the output.

Evidence rule: every required item that gets checked off must be backed
by a command run in this session with its output shown. A check that was
not executed is reported as NOT RUN with a reason, never checked. Example
of a NOT RUN line in the PR body:

```markdown
- [ ] Package passes `devtools::check()` with no errors or warnings:
      NOT RUN (check takes too long in this session; run locally before
      the final review PR)
```

If every check passed (or is honestly marked NOT RUN with a reason),
continue to Step 6 without pausing: the plan approval at CHECK-IN #1
already covers finalization. If a check FAILED, stop and CHECK-IN with
the output; a failing state is a decision the user makes, not the skill.

## Step 6: Update the issue

Check off completed items in the issue body: `gh issue view [issue-number]`
to get the body, flip `- [ ]` to `- [x]` for completed items only, save
with `gh issue edit [issue-number] --body "..."`. Leave genuinely
incomplete items unchecked. In unattended mode an item that waits for a
human (rules 2 to 4 of Step 1b) is incomplete.

Continue straight to Step 7; do not ask for permission to create the PR.

## Step 7: Push and create the PR (against dev, never main)

```bash
git push -u origin issue-[issue-number]-[short-slug]
```

Build the PR body from
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/templates/pr-body.md`:
Summary (`Addresses #[issue-number]`), Changes Made, Commits in this PR,
Checklist with a Required and an Advisory section (every issue item,
checked or unchecked with reasons; unexecuted checks marked NOT RUN per
the evidence rule in Step 5). Unresolved advisory findings stay listed as
optional follow-ups; they are collected in the final review PR body and
never block the merge to `dev`, the dev-to-main merge, or the release. Do
NOT add `Closes #[issue-number]`: it only fires on default-branch merges,
and this PR merges into `dev`; `/create-next-issue` closes the issue
explicitly after the merge. No attribution trailers, no emojis. The body
is built the same way in both modes, item for item: in unattended mode
the evidence sections are the only thing standing in for a reader.

```bash
gh pr create --base dev --title "Fix: [description]" --body "[body]"
```

**The base branch is `dev`. Creating this PR against `main` is the single
worst failure of this workflow; double-check the `--base dev` flag before
running the command.**

## Step 7b: Merge on green checks (only with `--unattended`)

Skip this step in attended mode: the maintainer merges.

Wait for the checks of the PR, then read them:

```bash
gh pr checks [pr-number] --watch --interval 30
gh pr checks [pr-number] --json name,workflow,bucket
gh pr view [pr-number] --json baseRefName --jq .baseRefName
```

If the first command reports no checks, wait a minute and run it once
more. A PR without a check run is never merged here.

Merge only when all of this holds:

- at least one check belongs to the R-CMD-check workflow (its `workflow`
  value starts with `R-CMD-check`), and every check of that workflow has
  the bucket `pass`
- no other check has the bucket `fail`, `cancel`, or `pending`
- the base branch is `dev`
- every required item in the issue body is checked (Step 6); an
  unchecked required item, whatever the reason, leaves the merge to the
  maintainer

```bash
gh pr merge [pr-number] --merge
```

`--merge`, never `--squash`: the atomic commits of Step 4 are the review
record on `dev`. Never `--auto`: on a repository without a required
status check it merges at once, on red checks too. Leave the branch in
place.

**If a condition does not hold, or the merge command is refused or
denied, do not merge and do not try another way. Go to Step 8 and use
the attended message, followed by one line per reason the PR was not
merged.**

## Step 8: STOP COMPLETELY

Output exactly this and nothing more:

> "PR created for issue #[issue-number]: [PR URL]. Issue checklist updated.
> Please review and merge to dev, then run /create-next-issue to continue
> (it syncs dev, closes this issue, and creates the next one)."

For an upgrade issue the last sentence reads: "then run /review-complete
(it closes this issue and opens the dev-to-main PR)".

After a merge in Step 7b, output this instead and nothing more:

> "PR for issue #[issue-number] merged into dev after green checks:
> [PR URL]. Issue checklist updated. Run /create-next-issue --unattended
> to continue (it syncs dev, closes this issue, and creates the next
> one)."

For an upgrade issue the last sentence reads: "Run /review-complete (it
closes this issue and opens the dev-to-main PR)".

- Do NOT continue with any other task
- Do NOT suggest further next steps
- Do NOT start the next issue or create the next issue yourself
- The conversation ends here until the user explicitly continues
