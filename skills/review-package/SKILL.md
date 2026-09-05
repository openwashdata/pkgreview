---
name: review-package
description: Start an R data package review for a registered organization. Asks for the repository URL first and resolves the organization profile, runs the PII and sensitivity intake screen, then analyzes the package in the current directory, writes the stamped standards file into it, and creates the first review issue (metadata). Stops for user approval before and after.
disable-model-invocation: true
argument-hint: "[package-name]"
---

# review-package

Start the review for the R data package in the current directory.
Package name: use `$ARGUMENTS` if given, otherwise `basename "$PWD"`.

The review is a sequential, issue-per-area process on the `dev` branch:
metadata, data, docs, tests. Each area gets one GitHub issue and one PR into
`dev`; only after all four are merged does `/review-complete` open the single
final PR from `dev` to `main`.

**Guardrail (applies to this skill and every later review step): never open
a PR against `main` during the review, and stop for explicit user approval
at every check-in point. Do not proceed past a check-in without a user
reply.**

## Step 0: Repository URL and organization profile

1. Ask the user to paste the GitHub URL of the repository under review
   (for example `https://github.com/openwashdata/waterpoints`). Derive
   the organization and repository name from it; call them `[ORG]` and
   `[REPO]` below.
2. Confirm the URL matches this working copy: `git remote get-url origin`
   must name the same organization and repository. On mismatch, stop and
   report both values; either the directory or the pasted URL is wrong.
3. Resolve the organization profile: lowercase `[ORG]` and read
   `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. The
   profile is the source of every org-specific value used below: pages
   domain, analytics header, funding sidebar text, citation tooling,
   README template, keywords, Zenodo community.
4. **If no profile file exists, the organization is not registered:
   STOP.** Never fall back to another org's values. Tell the user how to
   register: open a PR to openwashdata/pkgreview adding
   `skills/pkgreview-core/references/orgs/[org].md` (field list and
   constraints in `orgs/README.md` there), then rerun `/review-package`.

## Step 1: Preconditions

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

## Step 2: Intake screen (PII and sensitivity first)

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
3. Git-history scan. A clean working tree is not enough: identifying data
   removed in an earlier commit stays recoverable from any clone, so the
   scan covers every revision, not only the current files (issue #52).
   Skip only when `git rev-parse --is-inside-work-tree` fails (the package
   is not a git repository); record that as NOT RUN with the reason. A
   full history scan can be slow on a large repository; run it anyway, the
   intake screen is a one-time gate. Four parts, each with its command
   shown:
   - Every data file path that ever existed, so deleted datasets are found:
     `git log --all --pretty=format: --name-only --diff-filter=AMD -- data-raw/ inst/extdata/ | sort -u`.
   - Identifier column names and value patterns (person names, phone
     numbers, emails, national or beneficiary IDs, GPS coordinates) in the
     historical revisions of the text data files (`.csv`, `.tsv`, `.txt`,
     `.json`). The deterministic check script covers this part; start from
     its FLAG line and confirm.
   - Historical `.rda` column names. The files are compressed, so a text
     search cannot see into them: for each historical blob, load it in a
     throwaway R session and read `names()`. The check script cannot do
     this; it is the reviewer's to run.
   - Commit messages for wording that names identifying data being added
     or removed: `git log --all --oneline` plus a keyword read (phone,
     email, name, ID, GPS, coordinate, anonymi, redact, remove PII).
   Report every hit as a FLAG for a human decision; the agent never
   certifies this on its own.
4. Sensitivity flags: household- or person-level records, small-area or
   small-group cells, protection-relevant contexts.
5. Data description exists: DESCRIPTION `Description` field and README
   introduction.
6. Dictionary present: `data-raw/dictionary.csv` with a description per
   variable.

Outcome handling:

- Any direct identifier or sensitivity flag in the current files: STOP at
  a check-in. Present the findings and wait for the user; do not create
  issues, do not push anything.
- Identifying data found in the git history (a history-scan FLAG the user
  confirms): STOP. Publication stays blocked until the history is clean,
  even when the current files are clean. Point the user at the history
  remediation path in
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/recovery.md`
  (failure mode 10) and treat the data as disclosed to everyone who had
  access to the repository.
- Household- or person-level data: the review may proceed after the
  check-in, but record in the intake results that the data issue cannot
  complete without a named human sign-off comment on the review issue.
  The review agent never certifies the PII item on its own.
- Missing floor items (raw data, processing script, description, or
  dictionary): STOP and point the contributor at the guidebook
  (`docs/guidebook.md` in openwashdata/pkgreview) for how to get the
  package to the publication floor.
- All clear: continue; the results are recorded in an "Intake screen"
  section at the top of the first review issue body (Step 5).

## Step 3: Write the package-resident standards file

Read `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/standards.md` and
fill its placeholders: `{{PKGREVIEW_VERSION}}` with `[VERSION]`,
`{{ORG_NAME}}` with the profile's GitHub organization, and
`{{ORG_DOMAIN}}` with its pages domain. Write the result into the
package:

- If the package has no `CLAUDE.md`: write the content as `CLAUDE.md`.
- If `CLAUDE.md` exists: back it up to `CLAUDE.md.backup`, then append the
  standards content under a separator line
  `# --- pkgreview standards (from openwashdata/pkgreview) ---`.

This file is the package's record of the standard it was reviewed against.
It stays in the package permanently; never delete it in later steps.

## Step 4: Analyze the package

- Run the deterministic check script and keep its full report:

  ```bash
  Rscript "${CLAUDE_SKILL_DIR}/../pkgreview-core/check/pkgreview-check.R" . > /tmp/pkgreview-check.md
  ```

  Pass `--analytics=none` after the package directory when the org
  profile defines no analytics header; the default expects Plausible.
  It verifies the mechanical subset of the checklists (file presence,
  license, citation consistency, sentinel values, encoding, naming,
  ranges, coordinates) and prints a Markdown report. Its PII line is a
  FLAG signal only; the intake screen in Step 2 remains the decision
  point. The analysis below starts from the report's verified facts
  instead of re-deriving them.
- Check the structure against the standards file just written (required
  directories and files, compliance with the org profile's README
  template).
- Site deployment state (docs area, required since v1.5.0):
  `test -f .github/workflows/pkgdown.yaml` and `git ls-files docs | head -1`.
  Record the outcome for the plan: when the workflow is missing or
  `docs/` is tracked, the docs issue creates the workflow, untracks
  `docs/`, and ignores it (docs checklist, "Files to review or create").
  Do not make that change here; per-issue PRs never commit `docs/`.
- Check git state: current branch, existing `dev` branch, open PRs
  (`git branch -a`, `gh pr list --state open`).
- If no `dev` branch exists, create it from `main` and push it; all review
  work happens on branches off `dev`.

## Step 5: Create the first review issue

Build the issue body from the canonical sources; insert checklist content
verbatim, never retype or paraphrase it:

- Template: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/templates/issue-body.md`
- Checklist: `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/checklists/metadata.md`

Create with title `Data Package Review: General Information & Metadata` and
labels `pkgreview` and `pkgreview-metadata` (create the labels first if they
do not exist: `gh label create pkgreview ...`). This is issue 1, so omit the
Prerequisites section. Include the lines
`Review standard version: [VERSION]` and `Organization profile: [ORG]` in
the body; later commands read these stamps to keep the whole review on one
standard and one org profile.

At the top of the body, before the checklist, add an "Intake screen"
section recording the Step 2 results: each screen check with its outcome
(pass, NOT RUN with reason, or flagged with details), and, for
household- or person-level data, the pending named human sign-off
requirement.

Capture the issue number GitHub assigns from the `gh issue create` output.

Then post the Step 4 check report as the first comment on the issue, so
the review starts from verified facts:

```bash
gh issue comment [number] --body-file /tmp/pkgreview-check.md
```

## Step 6: Present the plan and STOP

Report to the user:

- The resolved organization profile from Step 0
- Intake screen outcome from Step 2
- Summary of structural findings from Step 4, including the site
  deployment state
- The created issue number and URL
- Explicit next steps:
  1. Review the issue on GitHub and adjust checklist items if needed
  2. When ready, run `/review-issue [actual-number]` to start working on it

**STOP here. Do not start working on the issue, do not create branches or
PRs, do not create further issues. The user drives each next step.**
