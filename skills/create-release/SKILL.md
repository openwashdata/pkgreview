---
name: create-release
description: Create a versioned release of a reviewed R data package after the review PR is merged to main. Handles the preflight, the version bump, NEWS.md, the GitHub release, the two-step Zenodo DOI flow with mandatory pauses, the dev sync, and the development version on dev afterwards.
disable-model-invocation: true
argument-hint: "[version]"
---

# create-release

Create release `$ARGUMENTS` (semantic version, for example 0.1.0) for the
package in the current directory.

Prerequisite: the final review PR is merged into `main`. Step 0 verifies
everything else.

**This skill has two mandatory PAUSE points (pre-release checks and DOI
entry). Wait for the user's answer at each; do not assume or skip.**

## Step 0: Preflight

The same checks as `/add-doi` Step 1, each with its remedy. Run all of
them, report every one that does not hold together with its remedy, and
stop; nothing is written on a partial preflight.

- Branch. `git branch --show-current` prints `main`. Otherwise:
  `git checkout main && git pull`. If the final review PR is not merged
  yet, the release waits for it (`/review-complete`).
- Clean tree. `git status --porcelain` prints nothing. Otherwise name
  the files and ask the user to commit or stash them; a release never
  carries along uncommitted changes.
- R packages. `desc`, `usethis`, and `washr` are installed:
  ```bash
  Rscript -e 'need <- c("desc", "usethis", "washr"); miss <- need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)]; if (length(miss)) stop("not installed: ", paste(miss, collapse = ", "))'
  ```
  Otherwise: `install.packages()` for the packages named.
- washr floor. The calls below depend on washr 1.1.0 or newer
  (`update_citation(build = FALSE)` is new in 1.1.0, and the workarounds
  older versions needed are gone from this skill):
  ```bash
  Rscript -e 'floor <- readLines("${CLAUDE_SKILL_DIR}/../pkgreview-core/WASHR_FLOOR"); stopifnot(packageVersion("washr") >= floor)'
  ```
  The floor is recorded once in `pkgreview-core/WASHR_FLOOR` (1.1.0 at
  this writing). Otherwise: `install.packages("washr")`, then rerun the
  skill. Do not adapt the steps below to an older washr.
- Organization profile. Derive the org from `git remote get-url origin`,
  lowercase it, and read
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. It
  provides the Zenodo community used in the DOI steps. If no profile
  exists, the organization is not registered (registration path in
  `orgs/README.md` there).

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

Review PRs keep NEWS.md current (review-issue Step 4 adds a bullet per
area under the development heading), so the section for this release
already exists:

- NEWS.md has a `# [packagename] (development version)` heading: rename
  it to `# [packagename] $ARGUMENTS`. Read the bullets under it once for
  tidyverse NEWS conventions (one per change, issue or PR number in
  parentheses); do not rebuild the section from the PR list. If the
  section is empty, write its bullets from the PRs and commits merged
  since the last release tag.
- No such heading, because the review predates this practice or NEWS.md
  does not exist: run `usethis::use_news_md()` when the file is missing,
  then write the section from the merged review PRs and commits:

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
- Do not set the development version on `dev` here. It is set once the
  DOI is in, in add-doi Step 9 (reached through Step 5 below, or through
  `/add-doi` later). A version bump on `dev` before the DOI commit lands
  on `main` turns that second sync into a merge with a conflict in
  CITATION.cff (openwashdata/pkgreview#55).

## Step 5: Post-release DOI integration (PAUSE)

Ask:

> "GitHub release created. Please check Zenodo for the generated DOI and
> provide it (format: 10.5281/zenodo.XXXXXXX):"

With the DOI provided, follow steps 2 to 9 of the `add-doi` skill
(`${CLAUDE_SKILL_DIR}/../add-doi/SKILL.md`): citation files, site
metadata, badge verification, commit and push, website deployment,
Zenodo record review, DOI verification, dev sync, development version
on `dev`. That skill is the single implementation of DOI integration; do
not duplicate its steps here.

If the session ends before the DOI exists, the user can resume later with
`/add-doi [doi]`; nothing is lost.

Note: automating this flow with tag-triggered CI (inbo/checklist pattern) is
tracked in openwashdata/pkgreview issue #12; until then both pauses are
manual by design.
