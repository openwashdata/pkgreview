# pkgreviewtest expected-findings scorecard

The fixture package `fixtures/pkgreviewtest/` contains exactly twelve planted defects, listed below. It is otherwise correct: any additional finding produced by a review run against it is noise and should be investigated as a false positive.

## Planted defects

The canonical checklists live in `skills/pkgreview-core/references/checklists/` (moved there from `skills/pkgreview-core/references/checklists/` during the skill refactor). The last column quotes the exact checklist item that must catch each defect.

| ID | Description | File(s) | Review area | Canonical checklist item |
| :-- | :-- | :-- | :-- | :-- |
| D1 | License is `MIT + file LICENSE` (with MIT LICENSE file) instead of CC BY 4.0 | `DESCRIPTION`, `LICENSE`, `LICENSE.md` | metadata | metadata.md: "License: CC BY 4.0" |
| D2 | Citation files name the washr placeholder author "Firstname Lastname" instead of the DESCRIPTION author Ada Lovelace | `CITATION.cff`, `inst/CITATION` | metadata | metadata.md: "CITATION.cff file present and valid" and "Generate citation using `washr::update_citation()` (without a DOI until the first release)" |
| D3 | `region` column contains latin1-encoded strings ("Zürich", "Genève"), not UTF-8 | `data/pkgreviewtest.rda`, `inst/extdata/pkgreviewtest.csv`, `data-raw/waterpoints_raw.csv` | data | data.md: "All text data is encoded in UTF-8; no encoding errors" |
| D4 | Four missing values in `users_count` coded as -99 instead of `NA` | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | data.md: "Missing values are coded as `NA`, not as empty strings, \"NULL\", \"N/A\", sentinel numbers (such as -99), or similar; report the count and percentage of missing values per variable" |
| D5 | No `.github/workflows/R-CMD-check.yaml` and no R-CMD-check badge in README | `.github/workflows/` (absent), `README.Rmd`, `README.md` | tests | tests.md: "GitHub Actions workflow for R-CMD-check present (`.github/workflows/R-CMD-check.yaml`)" and "R-CMD-check badge added to README.Rmd" |
| D6 | Vignette placed directly in `vignettes/`, not in `vignettes/articles/` | `vignettes/example.Rmd` | docs | docs.md: "Vignettes, if present, live in `vignettes/articles/`, not directly in `vignettes/`" |
| D7 | `_pkgdown.yml` lacks the `includes: in_header:` block with the Plausible analytics script | `_pkgdown.yml` | docs | docs.md: "`_pkgdown.yml` follows the standard openwashdata configuration, including the Plausible analytics header (canonical template: `skills/pkgreview-core/references/templates/_pkgdown.yml` in openwashdata/pkgreview)" |
| D8 | `installation_date` stored as character in mixed formats ("2021-03-15" and "30/10/2021"), not `Date` class | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | data.md: "Date variables stored as `Date` class in `YYYY-MM-DD` format; no impossible or out-of-range dates" |
| D9 | Inconsistent categorical values in `status`: "functional", "Functional", "FUNCTIONAL", "non-functional", "Non-Functional" | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | data.md: "Categorical variables: frequency tables prepared; similar or misspelled values flagged (for example \"male\" vs \"Male\" vs \"MALE\"); ordinal variables stored as `factor` with correct level order; unused factor levels removed" |
| D10 | One duplicated `id` value (WP-005 appears twice; row 17 repeats row 5) | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | data.md: "Unique identifiers are unique where expected" |
| D11 | Column named in camelCase: `waterSource` instead of `water_source` | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/dictionary.csv` | data | data.md: "Column names are syntactically valid snake_case, with no unexplained acronyms and no unexplained numbers in variable names" |
| D12 | Block of commented-out dead code in the data processing script | `data-raw/data_processing.R` | data | data.md: "Script is reproducible and well-commented; no commented-out code" |

## How to use this scorecard

Run the full review workflow against `fixtures/pkgreviewtest` after every significant change to the checklists in `skills/pkgreview-core/references/checklists/` or to the review skills and commands. Compare the review findings against this table:

- Every planted defect (D1 to D12) must appear in the review findings, attributed to the correct review area.
- A missed defect means the change weakened the standard. The change must not merge until the defect is caught again. This is the acceptance gate for issues #5 and #6.
- Findings that do not map to a planted defect are noise. Investigate them; either the fixture drifted or the checklist produces false positives.

## Do not fix the fixture

The package is intentionally defective. Never "fix" a defect in place, not even when a review run, a linter, or an R CMD check points at it. If the planted defects need to change (for example because a checklist item changed), edit and rerun `fixtures/make_pkgreviewtest.R` to regenerate the data files deterministically, adjust the static files as needed, and update this scorecard in the same change.
