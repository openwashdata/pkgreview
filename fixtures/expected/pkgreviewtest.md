# pkgreview mechanical check report

Package: `(normalized)`  
Standard: mechanical subset of the pkgreview checklists  
Organization profile: --org=openwashdata (openwashdata.md)  
Result: 17 PASS, 19 FAIL (4 required-tier), 1 FLAG, 3 NOT RUN

## metadata

- [FAIL] (required) License: CC BY 4.0: License field: MIT + file LICENSE
- [PASS] (required) CITATION.cff present
- [PASS] (required) CITATION.cff version matches DESCRIPTION: DESCRIPTION 0.0.1 vs CITATION.cff 0.0.1
- [FAIL] (required) Citation files carry real authors, not template placeholders: "Firstname Lastname" found in citation files
- [PASS] (advisory) DESCRIPTION carries X-schema.org-keywords: 4 keyword(s): open data, washdata, water points, Switzerland; CITATION.cff agrees
- [PASS] (advisory) DESCRIPTION carries X-schema.org spatial and temporal coverage: spatial: Switzerland; temporal: 2018-01-01/2022-02-05
- [PASS] (advisory) Title is under 65 characters: 52 characters

## data

- [PASS] (required) Raw data files preserved in data-raw/
- [PASS] (required) data_processing.R in data-raw/
- [PASS] (required) Primary data present in data/ as .rda and loads: 1 file(s), 1 dataset(s)
- [PASS] (required) CSV and XLSX exports in inst/extdata/: pkgreviewtest.csv, pkgreviewtest.xlsx
- [PASS] (required) Dictionary covers every variable in every dataset
- [FAIL] (required) Dictionary descriptions present (no empty or placeholder): defective: status, users_count
- [PASS] (advisory) Dictionary schema: five washr columns, UTF-8 without BOM, single-class variable_type
- [FLAG] (required) PII signal scan (never auto-certified; human sign-off required): suspicious columns: owner_phone
- [NOT RUN] (required) Git-history PII signal scan (text data files): package is a subdirectory of a larger git repository; the visible history is the enclosing repo's, not the package's. Run the scan against the package's own repository
- [FAIL] (advisory) Missing values coded as NA, no sentinels [pkgreviewtest]: sentinel values in: users_count (4)
- [FAIL] (advisory) All text data encoded in UTF-8 [pkgreviewtest]: non-UTF-8: region
- [FAIL] (advisory) Date variables stored as Date class [pkgreviewtest]: not Date class: installation_date
- [FAIL] (advisory) Categorical values consistent (no case-only variants) [pkgreviewtest]: status (5 variants, 2 after case-folding)
- [FAIL] (advisory) Unique identifier `id` is unique [pkgreviewtest]: 1 duplicated value(s): WP-005
- [PASS] (advisory) Exact duplicate rows (full and non-ID columns) [pkgreviewtest]: full: 0, non-ID: 0
- [FAIL] (advisory) Column names are snake_case [pkgreviewtest]: not snake_case: waterSource
- [FAIL] (advisory) Hard ranges: counts >= 0, percentages in [0, 100] [pkgreviewtest]: negative counts: users_count (4); out-of-range percentages: none
- [FAIL] (advisory) Coordinates in bounds, no (0, 0) points [pkgreviewtest]: out-of-bounds: 1, (0, 0) points: 1
- [FAIL] (advisory) Cross-field: women_users <= users_count [pkgreviewtest]: 2 violating row(s)
- [FAIL] (advisory) No commented-out code in data_processing.R: 5 line(s): 27, 28, 29, 35, 36
- [FAIL] (advisory) Script conventions: read_csv with col_types; readr/writexl exports: read_csv() without col_types; base write.csv() used for export

## docs

- [PASS] (required) README.Rmd and rendered README.md present
- [PASS] (advisory) Roxygen @source present for the datasets
- [PASS] (advisory) README links the CSV/XLSX exports in inst/extdata/ for non-R users: 2 line(s) link into inst/extdata/
- [FAIL] (advisory) No vignettes directly in vignettes/ (they belong in vignettes/articles/): example.Rmd
- [FAIL] (advisory) _pkgdown.yml carries the Plausible analytics header
- [FAIL] (advisory) _pkgdown.yml url is the Pages URL from the org profile: url: https://github.com/openwashdata/pkgreviewtest (expected https://openwashdata.github.io/pkgreviewtest/)
- [PASS] (advisory) _pkgdown.yml carries the funding sidebar text from the org profile
- [PASS] (advisory) _pkgdown.yml brand wiring matches the org profile: not wired; optional (openwashdata/brand via washr::use_brand())
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
