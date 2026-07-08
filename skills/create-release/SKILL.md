---
name: create-release
description: Create a versioned release of an openwashdata R data package after the review PR is merged to main. Handles version bump, NEWS.md, GitHub release, and the two-step Zenodo DOI flow with mandatory pauses.
disable-model-invocation: true
argument-hint: "[version]"
---

# create-release

Create release `$ARGUMENTS` (semantic version, for example 0.1.0) for the
package in the current directory.

Prerequisites: the final review PR is merged, you are on `main`, no
uncommitted changes, R with `usethis` and `washr` installed.

**This skill has two mandatory PAUSE points (Zenodo pre-check and DOI
entry). Wait for the user's answer at each; do not assume or skip.**

## Step 1: Pre-release Zenodo check (PAUSE)

Ask:

> "Before proceeding, please ensure the repository is enabled/synced on
> Zenodo. Is Zenodo integration enabled for this repo? (yes/no)"

If no: direct the user to https://zenodo.org/account/settings/github/ and
wait until they confirm.

## Step 2: Version bump

- `usethis::use_version()` to set the version in DESCRIPTION to `$ARGUMENTS`
- Run `washr::update_citation()` (still without a DOI) so DESCRIPTION,
  CITATION.cff, and inst/CITATION agree on version and date

## Step 3: NEWS.md

- `usethis::use_news_md()` if NEWS.md does not exist
- Add a section for this version with the release date, summarizing changes
  from the merged review PRs and commits, tidyverse NEWS conventions:

```markdown
# [packagename] $ARGUMENTS

* Initial release / summary bullets, one per change, with issue or PR
  numbers in parentheses
```

## Step 4: Commit and release

- Commit DESCRIPTION, CITATION.cff, inst/CITATION, NEWS.md with message
  `Release version $ARGUMENTS`, push to main
- `gh release create v$ARGUMENTS --title "v$ARGUMENTS" --notes "[NEWS.md
  section for this version]"`
- Zenodo generates the DOI automatically after this step

## Step 5: Post-release DOI update (PAUSE)

Ask:

> "GitHub release created. Please check Zenodo for the generated DOI and
> provide it (format: 10.5281/zenodo.XXXXXXX):"

With the DOI provided:

- `washr::update_citation(doi = "10.5281/zenodo.XXXXXXX")`
- Add the badge to README.Rmd:
  `[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)`
- Rebuild README: `R -e "devtools::build_readme()"`
- Commit with message `Add Zenodo DOI to package`, push to main

## Step 6: Website

Rebuild and deploy the pkgdown site so the new version and DOI badge are
live. Confirm to the user, then stop.

Note: automating this flow with tag-triggered CI (inbo/checklist pattern) is
tracked in openwashdata/pkgreview issue #12; until then both pauses are
manual by design.
