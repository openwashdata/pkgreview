---
name: create-release
description: Create a versioned release of a reviewed R data package after the review PR is merged to main. Handles the version bump, NEWS.md, the GitHub release, the two-step Zenodo DOI flow with mandatory pauses, and the dev sync afterwards.
disable-model-invocation: true
argument-hint: "[version]"
---

# create-release

Create release `$ARGUMENTS` (semantic version, for example 0.1.0) for the
package in the current directory.

Prerequisites: the final review PR is merged, you are on `main`, no
uncommitted changes, R with `desc`, `usethis`, and `washr` installed.

Resolve the organization profile before starting: derive the org from
`git remote get-url origin`, lowercase it, and read
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. It
provides the Zenodo community used in the DOI steps. If no profile
exists, stop: the organization is not registered (registration path in
`orgs/README.md` there).

**This skill has two mandatory PAUSE points (pre-release checks and DOI
entry). Wait for the user's answer at each; do not assume or skip.**

## Step 0: washr preflight

The calls below depend on washr 1.1.0 or newer (`update_citation(build =
FALSE)` is new in 1.1.0, and the workarounds older versions needed are
gone from this skill). Run:

```bash
Rscript -e 'floor <- readLines("${CLAUDE_SKILL_DIR}/../pkgreview-core/WASHR_FLOOR"); stopifnot(packageVersion("washr") >= floor)'
```

The floor is recorded once in `pkgreview-core/WASHR_FLOOR` (1.1.0 at
this writing). If the check fails, stop and tell the user to run
`install.packages("washr")`, then rerun the skill. Do not adapt the steps
below to an older washr.

## Step 1: Pre-release checks (PAUSE)

1. Default branch. GitHub reads CITATION.cff, the README, and the "Cite
   this repository" widget from the default branch, so a package whose
   development started on `dev` keeps showing the pre-release citation
   after the release (openwashdata/pkgreview#46). Check it:
   ```bash
   gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
   ```
2. Ask:

> "Before proceeding, please ensure the repository is enabled/synced on
> Zenodo. Is Zenodo integration enabled for this repo? (yes/no)"

   When the default branch is not `main`, add to the same question:

> "The default branch is [name]. I will set it to main before the
> release (gh repo edit --default-branch main). OK? (yes/no)"

If Zenodo is not enabled: direct the user to
https://zenodo.org/account/settings/github/ and wait until they confirm.
With a yes on the default branch, run `gh repo edit --default-branch
main` now.

## Step 2: Version bump

1. Validate `$ARGUMENTS` before anything is written: it must match
   `^[0-9]+\.[0-9]+\.[0-9]+$` (so `2.0` and `v1.0.0` are rejected) and be
   greater than the current version:
   ```bash
   Rscript -e 'v <- "$ARGUMENTS"; stopifnot(grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", v)); stopifnot(utils::compareVersion(v, as.character(desc::desc_get_version())) > 0)'
   ```
   If either check fails, stop and report which one.
2. Set the version directly. `usethis::use_version()` takes a bump type
   (`major`, `minor`, `patch`, `dev`), not a target version, so it cannot
   set an arbitrary one:
   ```r
   desc::desc_set_version("$ARGUMENTS")
   ```
3. Regenerate the citation files without rebuilding anything:
   ```r
   washr::update_citation(build = FALSE)
   ```
   DESCRIPTION, CITATION.cff, and inst/CITATION now agree on version and
   date. No `doi` argument: a run without one keeps any DOI already on
   file, and before the first release there is none. `build = FALSE`
   skips the README and site rebuilds, which have no place in the
   version-bump commit.

## Step 3: NEWS.md

- `usethis::use_news_md()` if NEWS.md does not exist
- Add a section for this version with the release date, summarizing changes
  from the merged review PRs and commits, tidyverse NEWS conventions:

```markdown
# [packagename] $ARGUMENTS

* Initial release / summary bullets, one per change, with issue or PR
  numbers in parentheses
```

## Step 4: Commit, release, and sync dev

- Commit what Steps 2 and 3 changed; `git status` lists them:
  DESCRIPTION, CITATION.cff, inst/CITATION, NEWS.md, and `.Rbuildignore`
  when `update_citation()` added `CITATION.cff` to it. Message:
  `Release version $ARGUMENTS`. Push to `main`.
- `gh release create v$ARGUMENTS --title "v$ARGUMENTS" --notes "[NEWS.md
  section for this version]"`
- Zenodo generates the DOI automatically after this step
- Sync `dev`, so the standing integration branch (and the GitHub default
  branch view, where that is still `dev`) carries the release
  (openwashdata/pkgreview#46):
  ```bash
  git push origin main:dev
  ```
  Right after a release this is a fast-forward. If it is rejected because
  `dev` moved ahead, merge instead:
  `git checkout dev && git pull && git merge main && git push origin dev && git checkout main`.

## Step 5: Post-release DOI integration (PAUSE)

Ask:

> "GitHub release created. Please check Zenodo for the generated DOI and
> provide it (format: 10.5281/zenodo.XXXXXXX):"

With the DOI provided, follow steps 2 to 9 of the `add-doi` skill
(`${CLAUDE_SKILL_DIR}/../add-doi/SKILL.md`): citation files, site
metadata, badge verification, commit and push, website deployment,
Zenodo record review, DOI verification, dev sync. That skill is the
single implementation of DOI integration; do not duplicate its steps
here.

If the session ends before the DOI exists, the user can resume later with
`/add-doi [doi]`; nothing is lost.

Note: automating this flow with tag-triggered CI (inbo/checklist pattern) is
tracked in openwashdata/pkgreview issue #12; until then both pauses are
manual by design.
