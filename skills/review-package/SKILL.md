---
name: review-package
description: Start an openwashdata R data package review. Runs the PII and sensitivity intake screen first, then analyzes the package in the current directory, writes the version-stamped standards file into it, and creates the first review issue (metadata). Stops for user approval before and after.
disable-model-invocation: true
argument-hint: "[package-name]"
---

# review-package

Start the openwashdata review for the R data package in the current
directory. Package name: use `$ARGUMENTS` if given, otherwise
`basename "$PWD"`.

The review is a sequential, issue-per-area process on the `dev` branch:
metadata, data, docs, tests. Each area gets one GitHub issue and one PR into
`dev`; only after all four are merged does `/review-complete` open the single
final PR from `dev` to `main`.

**Guardrail (applies to this skill and every later review step): never open
a PR against `main` during the review, and stop for explicit user approval
at every check-in point. Do not proceed past a check-in without a user
reply.**

## Step 0: Preconditions

1. Confirm the current directory is an R package: `DESCRIPTION` exists. If
   not, stop and tell the user.
2. Read the installed standard version from
   `${CLAUDE_SKILL_DIR}/../pkgreview-core/VERSION`. Call it `[VERSION]`
   below.
3. Dedupe guard: check for an existing review in ANY state:
   ```bash
   gh issue list --label "pkgreview-metadata" --state all --json number,state,title
   ```
   If any issue exists, ABORT with a clear message: a review already exists
   (report the issue number and state), suggest `/review-status`, and, if
   something looks wrong, the recovery paths in
   `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/recovery.md`.

## Step 1: Intake screen (PII and sensitivity first)

The PII and data sensitivity check runs before any review issue exists
and before anything else is written into the package. Every screen check
is backed by a command run in this session with its output shown; a
check that was not executed is reported as NOT RUN with a reason, never
treated as passed.

1. Raw data present: `data-raw/` exists and contains the raw data files
   and a processing script.
2. Direct-identifier scan over the column names and sampled values of
   every dataset (`data/*.rda` and `inst/extdata/*`): person names,
   phone numbers, email addresses, national or beneficiary IDs,
   household-level GPS coordinates.
3. Sensitivity flags: household- or person-level records, small-area or
   small-group cells, protection-relevant contexts.
4. Data description exists: DESCRIPTION `Description` field and README
   introduction.
5. Dictionary present: `data-raw/dictionary.csv` with a description per
   variable.

Outcome handling:

- Any direct identifier or sensitivity flag: STOP at a check-in. Present
  the findings and wait for the user; do not create issues, do not push
  anything.
- Household- or person-level data: the review may proceed after the
  check-in, but record in the intake results that the data issue cannot
  complete without a named human sign-off comment on the review issue.
  The review agent never certifies the PII item on its own.
- Missing floor items (raw data, processing script, description, or
  dictionary): STOP and point the contributor at the guidebook
  (`docs/guidebook.md` in openwashdata/pkgreview) for how to get the
  package to the publication floor.
- All clear: continue; the results are recorded in an "Intake screen"
  section at the top of the first review issue body (Step 4).

## Step 2: Write the package-resident standards file

Read `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/standards.md`, replace
the `{{PKGREVIEW_VERSION}}` placeholder with `[VERSION]`, and write it into
the package:

- If the package has no `CLAUDE.md`: write the content as `CLAUDE.md`.
- If `CLAUDE.md` exists: back it up to `CLAUDE.md.backup`, then append the
  standards content under a separator line
  `# --- openwashdata standards (from openwashdata/pkgreview) ---`.

This file is the package's record of the standard it was reviewed against.
It stays in the package permanently; never delete it in later steps.

## Step 3: Analyze the package

- Check the structure against the standards file just written (required
  directories and files, washr template compliance).
- Check git state: current branch, existing `dev` branch, open PRs
  (`git branch -a`, `gh pr list --state open`).
- If no `dev` branch exists, create it from `main` and push it; all review
  work happens on branches off `dev`.

## Step 4: Create the first review issue

Build the issue body from the canonical sources; insert checklist content
verbatim, never retype or paraphrase it:

- Template: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/templates/issue-body.md`
- Checklist: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/checklists/metadata.md`

Create with title `Data Package Review: General Information & Metadata` and
labels `pkgreview` and `pkgreview-metadata` (create the labels first if they
do not exist: `gh label create pkgreview ...`). This is issue 1, so omit the
Prerequisites section. Include the line
`Review standard version: [VERSION]` in the body; later commands read this
stamp to keep the whole review on one standard.

At the top of the body, before the checklist, add an "Intake screen"
section recording the Step 1 results: each screen check with its outcome
(pass, NOT RUN with reason, or flagged with details), and, for
household- or person-level data, the pending named human sign-off
requirement.

Capture the issue number GitHub assigns from the `gh issue create` output.

## Step 5: Present the plan and STOP

Report to the user:

- Intake screen outcome from Step 1
- Summary of structural findings from Step 3
- The created issue number and URL
- Explicit next steps:
  1. Review the issue on GitHub and adjust checklist items if needed
  2. When ready, run `/review-issue [actual-number]` to start working on it

**STOP here. Do not start working on the issue, do not create branches or
PRs, do not create further issues. The user drives each next step.**
