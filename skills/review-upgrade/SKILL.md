---
name: review-upgrade
description: Bring an already-reviewed package from the standard version stamped in it up to the installed standard, with one issue that lists only the items that changed between the two versions. Stops for approval before creating the issue; the normal review-issue flow works it.
disable-model-invocation: true
argument-hint: "[package-name]"
---

# review-upgrade

Upgrade the reviewed package in the current directory from its stamped
standard version to the installed one. Package name: `$ARGUMENTS` if
given, otherwise `basename "$PWD"`.

A reviewed package is pinned to the standard it was reviewed against, by
design. This skill is the only path that moves it: it computes the
difference between the two versions from the reconciliation record,
creates exactly ONE issue with the changed items, and stops. `/review-issue`
works that issue with one PR into `dev`; `/review-complete` opens the
dev-to-main PR; `/create-release` makes the patch release.

**Guardrail: never open a PR against `main` here, and stop for explicit
user approval at the check-in below.**

## Step 0: Organization profile

Derive the org from `git remote get-url origin`, lowercase it, and read
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. If no
profile exists, STOP: the organization is not registered (registration
path in `orgs/README.md` there). Call the lowercased org `[org]`.

## Step 1: Read the stamps

1. The package CLAUDE.md: take the LAST `Standard version:` line as
   `[STAMP]` (an upgraded package carries `Upgraded from:` lines under
   it; the last stamp is the current one) and the `Organization profile:`
   line as `[ORG]` (no line: openwashdata, recovery.md failure mode 9).
   Cross-check `[STAMP]` against the first review issue
   (`gh issue list --label "pkgreview-metadata" --state all --json number,body`);
   if CLAUDE.md and the issue disagree and no `Upgraded from:` line
   explains it, STOP with recovery.md failure mode 11.
2. No stamp anywhere (no standards file, no review issue): STOP. The
   package was never reviewed; run `/review-package` instead.
3. Installed version `[VERSION]` from
   `${CLAUDE_SKILL_DIR}/../pkgreview-core/VERSION`. If `[STAMP]` is
   `[VERSION]` or newer (`sort -V`), STOP: nothing to upgrade.
4. Open review issues (`gh issue list --label pkgreview --state open`):
   any open `pkgreview-*` issue means a review or an upgrade is in
   flight; STOP and point at `/review-status`.

## Step 2: Compute the delta

The reconciliation record is keyed by version in its section headings
(`## ... (vX.Y.Z)`). Read it at the installed version:

```bash
curl -fsSL https://raw.githubusercontent.com/openwashdata/pkgreview/v[VERSION]/docs/checklist-reconciliation.md > /tmp/reconciliation.md
```

(`${CLAUDE_SKILL_DIR}/../../docs/checklist-reconciliation.md` works too
when the skills are installed as the plugin, which carries the whole
repository.) Take every section whose heading names a version greater
than `[STAMP]` and at most `[VERSION]`. From each section's table, keep
the rows whose Decision says added, reworded, dropped, or floor changed;
each row names the item and its tier. Also read the section's prose for
rules that changed outside the checklists (standards file rules, skills).

Always include, whatever the delta:

- The intake re-screen: the PII and sensitivity check over the current
  files and the git history (review-package Step 2), because every
  publication standard since v1.4.0 covers the history and the package
  is published.
- The standards file rewrite: CLAUDE.md is regenerated from
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/standards.md` at
  `[VERSION]` with the stamps, plus the line
  `Upgraded from: [STAMP] on [date]` under them.

Present the delta as a table: item (current canonical wording, quoted
verbatim from the checklist file at `[VERSION]`), tier, version that
introduced it, and the section it came from. Required items first.

## Step 3: CHECK-IN and STOP

> "Upgrade [package] from [STAMP] to [VERSION]: [n] required and [m]
> advisory items changed (table above). On yes I create one issue with
> exactly these items; nothing else is written. Proceed? (yes/no/edit)"

Wait for the reply. "no" or "edit" means discuss; do not create anything.

## Step 4: Create the upgrade issue

Labels `pkgreview` and `pkgreview-upgrade` (create them if missing).
Title: `Standard upgrade [STAMP] to [VERSION]`. Body:

```
## Standard upgrade

Review standard version: [VERSION]

Upgraded from: [STAMP]

Organization profile: [ORG]

### Intake re-screen

[To be filled by /review-issue: the PII and sensitivity check over the
current files and the git history, each check with its command and
outcome; any hit STOPS the upgrade until resolved.]

### Tasks

#### Required

- [ ] [each changed required item, canonical wording verbatim, with "(since vX.Y.Z)"]
- [ ] Standards file: regenerate CLAUDE.md from standards.md at [VERSION] with the stamps and add `Upgraded from: [STAMP] on [date]`

#### Advisory

- [ ] [each changed advisory item, same form]

### Next Steps

1. Run `/review-issue [this issue's number]`; the body above is the work list
2. Create a PR to the `dev` branch
3. After merging, run `/review-complete` (it accepts a closed upgrade issue with a merged PR as completion), then `/create-release [patch version]`
```

Run the check script and post its report as the first comment, so the
upgrade starts from verified facts:

```bash
Rscript "${CLAUDE_SKILL_DIR}/../pkgreview-core/check/pkgreview-check.R" . --org=[org] > /tmp/pkgreview-check.md
gh issue comment [number] --body-file /tmp/pkgreview-check.md
```

## Step 5: Report and STOP

Give the user the issue number and URL, the counts, and the next step
(`/review-issue [number]`). **Stop here. Do not start working on the
issue, do not create branches or PRs.**
