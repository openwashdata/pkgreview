---
name: review-issue
description: Work on one openwashdata review issue (by actual GitHub issue number) with mandatory check-ins, atomic commits, and a hard stop after the PR to dev is created.
disable-model-invocation: true
argument-hint: "[issue-number]"
---

# review-issue

Work on review issue `$ARGUMENTS` for the package in the current directory.

**Core discipline, non-negotiable: pause at every CHECK-IN below and wait
for the user's reply. After creating the PR, STOP COMPLETELY. One
invocation of this skill handles exactly one issue and ends at its PR;
never continue to another issue or another review area.**

## Step 1: Verify the issue

```bash
gh issue view $ARGUMENTS --json title,labels,body,state
```

- The issue must carry exactly one of: `pkgreview-metadata`,
  `pkgreview-data`, `pkgreview-docs`, `pkgreview-tests`. If not, stop:
  this is not a review issue; list review issues with
  `gh issue list --label pkgreview --state all`.
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
the suggested tools and file lists. If body and canonical file disagree, the
issue body wins (it records this review's pinned standard); mention the
difference to the user.

## Step 2: Analyze and CHECK-IN #1 (the single implementation approval)

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
> will implement all of it with one atomic commit per change and no
> further per-change prompts. Proceed? (yes/no/edit)"

**Wait for the reply. "no" or "edit" means discuss, do not implement.
This is the only approval for implementation; anything beyond the
approved plan needs a new check-in before it is done.**

## Step 3: Branch

Only after approval:

```bash
git checkout dev && git pull
git checkout -b issue-$ARGUMENTS-[short-slug]
```

Branch from `dev`, never from `main`. Keep the `issue-[number]-` prefix; it
is how later steps link branch to issue.

## Step 4: Implement the approved plan with atomic commits

For EACH change in the approved plan:

1. Announce the specific change
2. Make it and show the result
3. Commit immediately:
   `git add -A && git commit -m "[the planned commit message]"`

Atomic commits, one logical change each; never batch the whole issue into
one commit. Do not pause between changes: the plan was approved at
CHECK-IN #1 and the check-in currency is the plan, not the individual
commit. If implementation reveals work outside the approved plan, stop
and CHECK-IN before doing it.

## Step 5: Test and CHECK-IN

Run the checks relevant to the area (from the canonical checklist file),
for example `R -e "devtools::check()"`, `R -e "devtools::build_readme()"`,
`R -e "pkgdown::build_site()"`. Show the results faithfully; if something
fails, say so with the output.

Evidence rule: every required item that gets checked off must be backed
by a command run in this session with its output shown. A check that was
not executed is reported as NOT RUN with a reason, never checked. Example
of a NOT RUN line in the PR body:

```markdown
- [ ] Package passes `devtools::check()` with no errors or warnings:
      NOT RUN (check takes too long in this session; run locally before
      the final review PR)
```

**CHECK-IN: "Tests done (results above). Ready to finalize? (yes/no)"**

## Step 6: Update the issue and CHECK-IN

Check off completed items in the issue body: `gh issue view $ARGUMENTS` to
get the body, flip `- [ ]` to `- [x]` for completed items only, save with
`gh issue edit $ARGUMENTS --body "..."`. Leave genuinely incomplete items
unchecked.

**CHECK-IN: "Issue checklist updated. Ready to create the PR? (yes/no)"**

## Step 7: Push and create the PR (against dev, never main)

```bash
git push -u origin issue-$ARGUMENTS-[short-slug]
```

Build the PR body from
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/templates/pr-body.md`:
Summary (`Addresses #$ARGUMENTS`), Changes Made, Commits in this PR,
Checklist with a Required and an Advisory section (every issue item,
checked or unchecked with reasons; unexecuted checks marked NOT RUN per
the evidence rule in Step 5). Unresolved advisory findings stay listed as
optional follow-ups; they are collected in the final review PR body and
never block the merge to `dev`, the dev-to-main merge, or the release. Do
NOT add `Closes #$ARGUMENTS`: it only fires on default-branch merges, and
this PR merges into `dev`; `/create-next-issue` closes the issue
explicitly after the merge. No attribution trailers, no emojis.

```bash
gh pr create --base dev --title "Fix: [description]" --body "[body]"
```

**The base branch is `dev`. Creating this PR against `main` is the single
worst failure of this workflow; double-check the `--base dev` flag before
running the command.**

## Step 8: STOP COMPLETELY

Output exactly this and nothing more:

> "PR created for issue #$ARGUMENTS. Issue checklist updated. Please review
> and merge to dev, then run /create-next-issue to continue (it syncs dev,
> closes this issue, and creates the next one)."

- Do NOT continue with any other task
- Do NOT suggest further next steps
- Do NOT start the next issue or create the next issue yourself
- The conversation ends here until the user explicitly continues
