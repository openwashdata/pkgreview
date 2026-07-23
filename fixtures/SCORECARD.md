# pkgreviewtest expected-findings scorecard

The fixture package `fixtures/pkgreviewtest/` contains exactly fourteen planted defects, listed below. It is otherwise correct: any additional finding produced by a review run against it means either the fixture drifted or the checklist produces false positives, and the gate fails until that is resolved.

## Planted defects

The canonical checklists live in `skills/pkgreview-core/references/checklists/` (moved there from `docs/checklists/` during the skill refactor). The tier column records whether the item that catches the defect is required (blocks publication) or advisory. The last column quotes the exact checklist item or intake step that must catch each defect.

| ID | Description | File(s) | Review area | Tier | Canonical checklist item |
| :-- | :-- | :-- | :-- | :-- | :-- |
| D1 | License is `MIT + file LICENSE` (with MIT LICENSE file) instead of CC BY 4.0 | `DESCRIPTION`, `LICENSE`, `LICENSE.md` | metadata | required | metadata.md: "License: CC BY 4.0" |
| D2 | Citation files name the washr placeholder author "Firstname Lastname" instead of the DESCRIPTION author Ada Lovelace | `CITATION.cff`, `inst/CITATION` | metadata | required | metadata.md: "CITATION.cff file present and valid" and "Generate citation using `washr::update_citation()` (without a DOI until the first release)" |
| D3 | `region` column contains latin1-encoded strings ("Zürich", "Genève"), not UTF-8 | `data/pkgreviewtest.rda`, `inst/extdata/pkgreviewtest.csv`, `data-raw/waterpoints_raw.csv` | data | advisory | data.md: "All text data is encoded in UTF-8; no encoding errors" |
| D4 | Four missing values in `users_count` coded as -99 instead of `NA` | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Missing values are coded as `NA`, not as empty strings, \"NULL\", \"N/A\", sentinel numbers (such as -99), or similar; report the count and percentage of missing values per variable" |
| D5 | No `.github/workflows/R-CMD-check.yaml` and no R-CMD-check badge in README | `.github/workflows/` (absent), `README.Rmd`, `README.md` | tests | required (workflow); the badge half is advisory | tests.md: "GitHub Actions workflow for R-CMD-check present (`.github/workflows/R-CMD-check.yaml`)" and "R-CMD-check badge added to README.Rmd" |
| D6 | Vignette placed directly in `vignettes/`, not in `vignettes/articles/` | `vignettes/example.Rmd` | docs | advisory | docs.md: "Vignettes, if present, live in `vignettes/articles/`, not directly in `vignettes/`" |
| D7 | `_pkgdown.yml` lacks the `includes: in_header:` block with the Plausible analytics script | `_pkgdown.yml` | docs | advisory | docs.md: "`_pkgdown.yml` follows the standard openwashdata configuration, including the Plausible analytics header (canonical template: `skills/pkgreview-core/references/templates/_pkgdown.yml` in openwashdata/pkgreview)" |
| D8 | `installation_date` stored as character in mixed formats ("2021-03-15" and "30/10/2021"), not `Date` class | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Date variables stored as `Date` class in `YYYY-MM-DD` format; no impossible or out-of-range dates" |
| D9 | Inconsistent categorical values in `status`: "functional", "Functional", "FUNCTIONAL", "non-functional", "Non-Functional" | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Categorical variables: frequency tables prepared; similar or misspelled values flagged (for example \"male\" vs \"Male\" vs \"MALE\"); ordinal variables stored as `factor` with correct level order; unused factor levels removed" |
| D10 | One duplicated `id` value (WP-005 appears twice; row 17 repeats row 5) | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Unique identifiers are unique where expected" |
| D11 | Column named in camelCase: `waterSource` instead of `water_source` | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/dictionary.csv` | data | advisory | data.md: "Column names are syntactically valid snake_case, with no unexplained acronyms and no unexplained numbers in variable names" |
| D12 | Block of commented-out dead code in the data processing script | `data-raw/data_processing.R` | data | advisory | data.md: "Script is reproducible and well-commented; no commented-out code" |
| D13 | Dictionary present but defective: empty description for `status`, placeholder description ("TODO") for `users_count` | `data-raw/dictionary.csv` | data | required | data.md: "`data-raw/dictionary.csv` covers every variable in every dataset, each with a one-sentence plain-language description. The description is the most important field; it is written or confirmed by a human." |
| D14 | Direct-identifier column `owner_phone` (phone numbers) present in the dataset | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/waterpoints_raw.csv` | data | required | review-package SKILL.md Step 1 intake screen: "Direct-identifier scan over the column names and sampled values of every dataset"; data.md: "No sensitive or personally identifiable information is present in any data file" |

Notes on D13 and D14:

- The `owner_phone` dictionary row carries a valid description on purpose, so D14 stays purely a PII defect and does not double-count with D13.
- D14 must be caught by the intake screen, which STOPS the review before any issue is created and before anything is pushed. A gate run that reaches issue creation without having flagged `owner_phone` has missed D14, regardless of what the data issue later finds.
- D13 also surfaces at the intake screen (dictionary floor check); its canonical mapping is the required dictionary item in data.md.

## How to use this scorecard

Run the full review workflow against `fixtures/pkgreviewtest` after every significant change to the checklists in `skills/pkgreview-core/references/checklists/` or to the review skills and commands.

Because D14 stops the review at the intake screen, a gate run has two stages: first confirm the intake screen flags `owner_phone` (D14) and the defective dictionary descriptions (D13) and stops; then the maintainer explicitly acknowledges the intake findings at the check-in and lets the review proceed, so the remaining defects are exercised through the review issues.

### Exact-reconciliation rule

The gate passes only under exact reconciliation (premortem constraint P1):

- The finding count equals the defect count: exactly fourteen findings, one per defect D1 to D14.
- Every finding maps to exactly one defect ID, attributed to the correct review area.
- Every defect is caught. A missed defect means the change weakened the standard; the change must not merge until the defect is caught again.
- Waiving findings as noise is prohibited. A finding that maps to no defect ID fails the gate: either the fixture drifted or the checklist produces false positives, and either cause must be fixed before merge.

## Do not fix the fixture

The package is intentionally defective. Never "fix" a defect in place, not even when a review run, a linter, or an R CMD check points at it. Fixture changes are strictly additive: the D1 to D12 defect mechanisms stay untouched, and new defects are added without shifting the RNG stream that generates the existing ones (see the comments in `fixtures/make_pkgreviewtest.R`). If the planted defects need to change (for example because a checklist item changed), edit and rerun `fixtures/make_pkgreviewtest.R` to regenerate the data files deterministically, adjust the static files as needed, and update this scorecard in the same change.
