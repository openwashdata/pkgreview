---
name: add-doi
description: Integrate a Zenodo DOI into a reviewed package after release, covering citation files, README badge, and website. Standalone resume path when the DOI arrives after /create-release ended.
disable-model-invocation: true
argument-hint: "[doi]"
---

# add-doi

Integrate DOI `$ARGUMENTS` (format `10.5281/zenodo.XXXXXXX`) into the
package in the current directory.

Zenodo mints two DOIs: the concept DOI, which stays stable across
releases and is the one to use in the citation files and the README
badge, and the version DOI, which points at one release snapshot and is
only for citing that exact version.

This is the post-release DOI integration of `/create-release` (its Step 5
delegates here; keep one implementation). It exists standalone because a
session can end between creating the GitHub release and Zenodo minting the
DOI; without it the reviewer has to work through the steps by hand. It is
also the repair path for packages released before DOI integration existed.

Prerequisites: the GitHub release exists, you are on `main`, no
uncommitted changes, R with `washr` installed.

## Step 1: Validate

- `$ARGUMENTS` matches `10.XXXX/zenodo.NNNNNNN` (regex
  `^10\.\d{4,9}/zenodo\.\d+$`). If not, stop and ask for the DOI in that
  format.
- Confirm the current branch is `main`, the working tree is clean, and a
  release tag exists (`git tag --list 'v*'`). Report anything that does
  not hold and stop.
- Resolve the organization profile: derive the org from
  `git remote get-url origin`, lowercase it, and read
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. It
  provides the Zenodo community for Step 6. If no profile exists, stop:
  the organization is not registered (registration path in
  `orgs/README.md` there).

## Step 2: Update the citation files

```r
washr::update_citation(doi = "$ARGUMENTS")
```

washr 1.0.1 caveats (openwashdata/pkgreview#23):

- The `doi` argument is required and has no default; never call
  `update_citation()` bare.
- It leaves `inst/CITATION.bk1` backup files behind; delete them before
  committing (`rm -f inst/CITATION.bk1`).
- If an earlier `update_citation(doi = NULL)` call injected a broken empty
  badge into README.Rmd (`zenodo.org/badge/DOI/.svg`, no DOI between
  `DOI/` and `.svg`), remove or repair it in the next step.

Verify DESCRIPTION, CITATION.cff, and inst/CITATION now agree on version,
date, and DOI.

## Step 3: README badge

Ensure README.Rmd carries exactly one correct DOI badge:

```markdown
[![DOI](https://zenodo.org/badge/DOI/$ARGUMENTS.svg)](https://doi.org/$ARGUMENTS)
```

Then rebuild: `R -e "devtools::build_readme()"`.

## Step 4: Commit and push

```bash
rm -f inst/CITATION.bk1
git add DESCRIPTION CITATION.cff inst/CITATION README.Rmd README.md
git commit -m "Add Zenodo DOI to package"
git push origin main
```

## Step 5: Website

Rebuild and deploy the pkgdown site so the DOI badge and the citation page
are live.

## Step 6: Review the Zenodo record

Prompt the user once to review the Zenodo record in the web UI (record
edits stay manual; nothing here is scripted):

> "Please check the Zenodo record: is it in the [Zenodo community from
> the org profile] community, is the resource type Dataset (not
> Software), and do the related identifiers link the GitHub repository
> and the pkgdown site?"

## Step 7: Verify and stop

- The DOI resolves: `curl -sI https://doi.org/$ARGUMENTS` returns a
  redirect to the Zenodo record.
- The website citation page shows the DOI.

Report both results faithfully, then stop.
