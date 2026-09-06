# pkgreview mechanical check report

Package: `(normalized)`  
Standard: mechanical subset of the pkgreview checklists  
Organization profile: --org=openwashdata (openwashdata.md)  
Result: 2 PASS, 15 FAIL (9 required-tier), 2 FLAG, 2 NOT RUN

## metadata

- [FAIL] (required) License: CC BY 4.0: License field: missing
- [FAIL] (required) CITATION.cff present and valid: file missing
- [FAIL] (advisory) DESCRIPTION carries X-schema.org-keywords: field missing or empty; CITATION.cff missing
- [FAIL] (advisory) DESCRIPTION carries X-schema.org spatial and temporal coverage: missing: X-schema.org-spatialCoverage, X-schema.org-temporalCoverage
- [PASS] (advisory) Title is under 65 characters: 20 characters

## data

- [FAIL] (required) Raw data files preserved in data-raw/
- [FAIL] (required) data_processing.R in data-raw/
- [FAIL] (required) Primary data present in data/ as .rda and loads: 0 file(s), 0 dataset(s)
- [FAIL] (required) CSV and XLSX exports in inst/extdata/: facilities.csv
- [FAIL] (required) data-raw/dictionary.csv present: file missing
- [FLAG] (required) PII signal scan (never auto-certified; human sign-off required): no suspicious column names or value patterns detected; the item still requires the intake screen and human judgment
- [FLAG] (required) Git-history PII signal scan (text data files): identifier-like columns in historical revisions of: inst/extdata/facilities.csv - inspect these revisions and treat as disclosed if confirmed

## docs

- [FAIL] (required) README.Rmd and rendered README.md present
- [FAIL] (advisory) Roxygen @source present for the datasets
- [FAIL] (advisory) README links the CSV/XLSX exports in inst/extdata/ for non-R users: no link to a .csv or .xlsx file under inst/extdata/ (the washr README template's download table provides them)
- [PASS] (advisory) No vignettes directly in vignettes/ (they belong in vignettes/articles/)
- [FAIL] (advisory) _pkgdown.yml present: file missing
- [NOT RUN] (advisory) docs/ untracked while the pkgdown workflow deploys the site: no .github/workflows/pkgdown.yaml; the required Website item covers the missing workflow

## tests

- [FAIL] (required) GitHub Actions R-CMD-check workflow present
- [NOT RUN] (required) R-CMD-check workflow triggers include dev (push and pull_request): workflow file missing; see the presence line above
- [FAIL] (advisory) R-CMD-check badge in README.Rmd

Not machine-checked (reviewer judgment, run in the session per the
evidence rule): description and provenance prose quality, tidy-data
structure, plausibility of values, devtools::check(), README rebuild,
website build, the pkgdown workflow's Pages setting, ORCID and
maintainer identification, dictionary
description accuracy (a present description can still be wrong), PII
certification (the FLAG above is a signal, never a verdict), and the
history parts the script does not cover: historical .rda column names
(compressed, not text-searchable) and commit-message wording that
names identifying data being added or removed.
