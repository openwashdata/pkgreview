---
name: add-doi
description: Integrate a Zenodo DOI into a reviewed package after release, covering citation files, site metadata, README badge verification, website deployment, and the dev sync. Standalone resume path when the DOI arrives after /create-release ended.
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
uncommitted changes, R with `washr` 1.1.0 or newer installed.

## Step 1: Validate

- washr preflight, against the floor recorded in
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/WASHR_FLOOR`:
  `Rscript -e 'floor <- readLines("${CLAUDE_SKILL_DIR}/../pkgreview-core/WASHR_FLOOR"); stopifnot(packageVersion("washr") >= floor)'`.
  If it fails, stop and tell the user to run `install.packages("washr")`.
  The steps below rely on 1.1.0 behavior (badge insertion and repair,
  README rebuild, DOI kept on later runs) and must not be adapted to an
  older washr.
- `$ARGUMENTS` matches `10.XXXX/zenodo.NNNNNNN` (regex
  `^10\.\d{4,9}/zenodo\.\d+$`). If not, stop and ask for the DOI in that
  format.
- Confirm the current branch is `main`, the working tree is clean, and a
  release tag exists (`git tag --list 'v*'`). Report anything that does
  not hold and stop.
- Resolve the organization profile: derive the org from
  `git remote get-url origin`, lowercase it, and read
  `${CLAUDE_SKILL_DIR}/../pkgreview-core/references/orgs/[org].md`. It
  provides the Zenodo community for Step 7 and the site URL pattern for
  Steps 6 and 8. If no profile exists, stop: the organization is not
  registered (registration path in `orgs/README.md` there).

## Step 2: Update the citation files

```r
washr::update_citation(doi = "$ARGUMENTS")
```

washr writes the DOI into CITATION.cff and inst/CITATION, inserts or
repairs the DOI badge in README.Rmd (one badge; an existing or broken one
is replaced, duplicates are removed), rebuilds README.md, deletes its own
backup files, and, when a `docs/` directory exists locally, rebuilds the
site there. That local site is a preview only; the published site is
deployed in Step 6.

Verify DESCRIPTION, CITATION.cff, and inst/CITATION now agree on version,
date, and DOI.

## Step 3: Site metadata (conditional)

If `pkgdown/templates/in-header.html` exists, the package carries the
FAIR layer: schema.org JSON-LD that pkgdown embeds in every page. Run

```r
washr::update_metadata()
```

so the JSON-LD carries the DOI (`identifier` and `sameAs`). If the file
does not exist, report this step as SKIPPED: the package has not adopted
the experimental metadata layer, and this skill does not introduce it.

## Step 4: Verify the README badge

Do not edit the badge by hand; washr owns it. Confirm:

- `grep -c "zenodo.org/badge/DOI/$ARGUMENTS.svg" README.Rmd` prints
  exactly `1`
- README.md carries the same badge line (Step 2 rebuilt it)

If either check fails, stop and report it: that is a washr defect to file
on openwashdata/washr, not something to patch around in this session.

## Step 5: Commit and push

```bash
git add DESCRIPTION CITATION.cff inst/CITATION README.Rmd README.md
git add .Rbuildignore pkgdown/templates/in-header.html 2>/dev/null
git commit -m "Add Zenodo DOI to package"
git push origin main
```

Add only the files listed (the second line covers the two that exist only
in some packages); never `git add -A` here. `docs/` is not committed:
reviewed packages deploy the site through the pkgdown workflow and keep
the directory ignored.

## Step 6: Website

The push to `main` triggers the pkgdown workflow, which builds and
deploys the site with the DOI badge, the citation page, and the
metadata:

```bash
gh run list --workflow=pkgdown.yaml --branch main --limit 1
gh run watch [run-id] --exit-status
```

Report the result. If `.github/workflows/pkgdown.yaml` does not exist,
the package predates the v1.5.0 standard and still publishes a committed
`docs/` site: commit the site Step 2 rebuilt
(`git add docs && git commit -m "Rebuild site with DOI" && git push origin main`)
and recommend moving to the workflow (docs checklist, required Website
item).

## Step 7: Review the Zenodo record

Prompt the user once to review the Zenodo record in the web UI (record
edits stay manual; nothing here is scripted):

> "Please check the Zenodo record: is it in the [Zenodo community from
> the org profile] community, is the resource type Dataset (not
> Software), and do the related identifiers link the GitHub repository
> and the pkgdown site?"

## Step 8: Verify

- The DOI resolves: `curl -sI https://doi.org/$ARGUMENTS` returns a
  redirect to the Zenodo record.
- The website citation page shows the DOI (after the deployment from
  Step 6 finished).
- When Step 3 ran: the site's index page carries the DOI inside its
  `application/ld+json` block
  (`curl -s [site URL] | grep -c "$ARGUMENTS"` is at least 1).

Report every result faithfully.

## Step 9: Sync dev and stop

`dev` is the standing integration branch and, in some packages, still the
GitHub default branch; both must show the released citation
(openwashdata/pkgreview#46):

```bash
git push origin main:dev
```

Right after a release this is a fast-forward. If it is rejected because
`dev` moved ahead, merge instead:
`git checkout dev && git pull && git merge main && git push origin dev && git checkout main`.

Then stop.
