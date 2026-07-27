---
name: create-release
description: Create a versioned release of a reviewed R data package after the review PR is merged to main. Handles version bump, NEWS.md, GitHub release, and the two-step Zenodo DOI flow with mandatory pauses.
disable-model-invocation: true
argument-hint: "[version]"
---

# create-release

Create release `$ARGUMENTS` (semantic version, for example 0.1.0) for the
package in the current directory.

Prerequisites: the final review PR is merged, you are on `main`, no
uncommitted changes, R with `usethis` and `washr` installed.

Resolve the organization profile before starting: derive the org from
`git remote get-url origin`, lowercase it, and read
`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. It
provides the Zenodo community used in the DOI steps. If no profile
exists, stop: the organization is not registered (registration path in
`orgs/README.md` there).

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
- Run `washr::update_citation(doi = NULL)` (no DOI exists yet) so
  DESCRIPTION, CITATION.cff, and inst/CITATION agree on version and date

washr 1.0.1 caveats (openwashdata/pkgreview#23):

- The `doi` argument is required and has no default; a bare
  `update_citation()` errors.
- `update_citation(doi = NULL)` can inject a broken empty badge into
  README.Rmd (`zenodo.org/badge/DOI/.svg`). Check README.Rmd after the
  call and remove it; the real badge is added after the DOI exists.

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

- Delete washr backup files first: `rm -f inst/CITATION.bk1`
  (they otherwise slip into the release commit)
- Commit DESCRIPTION, CITATION.cff, inst/CITATION, NEWS.md with message
  `Release version $ARGUMENTS`, push to main
- `gh release create v$ARGUMENTS --title "v$ARGUMENTS" --notes "[NEWS.md
  section for this version]"`
- Zenodo generates the DOI automatically after this step

## Step 5: Post-release DOI integration (PAUSE)

Ask:

> "GitHub release created. Please check Zenodo for the generated DOI and
> provide it (format: 10.5281/zenodo.XXXXXXX):"

With the DOI provided, follow steps 2 to 6 of the `add-doi` skill
(`${CLAUDE_SKILL_DIR}/../add-doi/SKILL.md`): citation files, README
badge, commit and push, website rebuild, DOI verification. That skill is
the single implementation of DOI integration; do not duplicate its steps
here.

If the session ends before the DOI exists, the user can resume later with
`/add-doi [doi]`; nothing is lost.

Note: automating this flow with tag-triggered CI (inbo/checklist pattern) is
tracked in openwashdata/pkgreview issue #12; until then both pauses are
manual by design.
