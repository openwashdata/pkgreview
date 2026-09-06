# pkgreviewtest expected-findings scorecard

The fixture package `fixtures/pkgreviewtest/` contains exactly seventeen planted defects (D1 to D17), listed below. It is otherwise correct: any additional finding produced by a review run against it means either the fixture drifted or the checklist produces false positives, and the gate fails until that is resolved.

One further defect, D18 (identifying data in the git history, issue #52), is exercised separately. `fixtures/pkgreviewtest/` is a subdirectory of the tooling repo and has no git history of its own, so the git-history scan reports NOT RUN there (the visible history belongs to the enclosing repo). D18 is planted in a throwaway repository built on demand by `fixtures/make_history_fixture.sh`; the gate scans that repository. D18 is the eighteenth defect of the standard, but it is not a file inside `pkgreviewtest/`, so the pkgreviewtest count stays at seventeen.

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
| D7 | `_pkgdown.yml` deviates from the standard configuration: no `includes: in_header:` block with the Plausible analytics script, and `url:` is the repo URL instead of the Pages URL | `_pkgdown.yml` | docs | advisory | docs.md: "`_pkgdown.yml` follows the standard configuration for the registered organization, including the analytics header when the org profile defines one (canonical template: `skills/pkgreview-core/references/templates/_pkgdown.yml` in openwashdata/pkgreview, with the org profile values substituted)" |
| D8 | `installation_date` stored as character in mixed formats ("2021-03-15" and "30/10/2021"), not `Date` class | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Date variables stored as `Date` class and rendered as ISO 8601 (`YYYY-MM-DD`) in the CSV/XLSX exports; no impossible or out-of-range dates" |
| D9 | Inconsistent categorical values in `status`: "functional", "Functional", "FUNCTIONAL", "non-functional", "Non-Functional" | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Categorical variables: frequency tables prepared; similar or misspelled values flagged (for example \"male\" vs \"Male\" vs \"MALE\"); ordinal variables stored as `factor` with correct level order; unused factor levels removed" |
| D10 | One duplicated `id` value (WP-005 appears twice; row 17 repeats row 5) | `data/pkgreviewtest.rda`, `inst/extdata/*` | data | advisory | data.md: "Unique identifiers are unique where expected" |
| D11 | Column named in camelCase: `waterSource` instead of `water_source` | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/dictionary.csv` | data | advisory | data.md: "Column names are syntactically valid snake_case, with no unexplained acronyms and no unexplained numbers in variable names" |
| D12 | Block of commented-out dead code in the data processing script | `data-raw/data_processing.R` | data | advisory | data.md: "Script is reproducible and well-commented; no commented-out code" |
| D13 | Dictionary present but defective: empty description for `status`, placeholder description ("TODO") for `users_count` | `data-raw/dictionary.csv` | data | required | data.md: "`data-raw/dictionary.csv` covers every variable in every dataset, each with a one-sentence plain-language description. The description is the most important field; it is written or confirmed by a human." |
| D14 | Direct-identifier column `owner_phone` (phone numbers) present in the dataset | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/waterpoints_raw.csv` | data | required | review-package SKILL.md Step 1 intake screen: "Direct-identifier scan over the column names and sampled values of every dataset"; data.md: "No sensitive or personally identifiable information is present in any data file" |
| D15 | Processing script convention violations: `read_csv()` without explicit `col_types`, and the CSV export written with base `write.csv(fileEncoding = "latin1")` instead of `readr::write_csv()` | `data-raw/data_processing.R` | data | advisory | data.md: "Tidyverse conventions in the processing script: data read with `readr::read_csv()` and explicit `col_types` (silent type guessing is how character dates slip in); exports written with `readr::write_csv()` and `writexl::write_xlsx()` (both always UTF-8, never base `write.csv()` with `fileEncoding`); native pipe `|>` preferred" |
| D16 | Cross-field violation: `women_users` exceeds `users_count` in rows 4 and 22 (the part exceeds its whole) | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/waterpoints_raw.csv` | data | advisory | data.md: "Cross-field consistency checks run with violation counts reported (for example a date column that must not precede a related date column, a part that must not exceed its whole)" |
| D17 | Coordinate defects: row 9 is a (0, 0) point and row 21 has longitude 181.5, outside [-180, 180] | `data/pkgreviewtest.rda`, `inst/extdata/*`, `data-raw/waterpoints_raw.csv` | data | advisory | data.md: "Coordinate columns, if present: latitude within [-90, 90], longitude within [-180, 180], no (0, 0) points, no points outside the stated study region; coordinate precision assessed as a disclosure risk consistent with the intake screen outcome" |
| D18 | Identifying data in the git history only: a first commit adds `gps_latitude`, `gps_longitude`, and `owner_phone` columns to `inst/extdata/facilities.csv`, a second commit removes them, so the working tree at HEAD is clean but the identifiers remain in the first revision | throwaway repo from `fixtures/make_history_fixture.sh` (not `pkgreviewtest/`) | data | required | data.md: "No sensitive or personally identifiable information is present in any data file, in the current files or in any earlier revision of the git history"; review-package Step 2 intake screen history scan |

Notes on D13 and D14:

- The `owner_phone` dictionary row carries a valid description on purpose, so D14 stays purely a PII defect and does not double-count with D13.
- D14 must be caught by the intake screen, which STOPS the review before any issue is created and before anything is pushed. A gate run that reaches issue creation without having flagged `owner_phone` has missed D14, regardless of what the data issue later finds.
- D13 also surfaces at the intake screen (dictionary floor check); its canonical mapping is the required dictionary item in data.md.

Note on D7: like D5, one defect spanning two clauses of the same
checklist item (the `_pkgdown.yml` configuration item): the missing
Plausible header and the repo-URL `url:` value. Both surface as separate
check lines but map to the single defect D7. The url clause was part of
the fixture all along and went unobserved by the manual v1.1.0 and
v1.2.0 gate runs; the deterministic check script (#13) surfaced it.

Note on D4 and the hard-range item: the four -99 sentinel values in `users_count` also trip the hard-range check (counts are >= 0). Both observations trace to the single root cause D4; a gate run reports them as one consolidated finding mapped to D4, following the D5 precedent of one defect spanning more than one checklist clause.

Note on D17 and the intake screen: the coordinates are waterpoint-level at two-decimal precision (about 1 km), deliberately below household-level precision, so they are not a direct identifier and must NOT stop the review at the intake screen. D17 is a data-area range defect, not a PII defect; the disclosure-risk clause of the coordinate item is satisfied by the fixture and produces no finding.

Note on D15 (decision from issue #34): the script's convention violations are planted defects, not accidents, and the script must never be made convention-clean. The `write.csv(fileEncoding = "latin1")` line is the in-package mechanism of D3 (premortem finding F3: cleaning it to `readr::write_csv()` would narratively un-plant the encoding defect), and `read_csv()` without `col_types` is how D8's character dates slip through. Like D5, D15 spans two clauses of one checklist item and counts as one defect with one finding. The script's commented-out block remains D12; the "no commented-out code" wording lives only in the D12 item, not in the conventions item, so the two cannot double-map.

Note on D18 and the fixture layout (issue #52): `fixtures/pkgreviewtest/` cannot carry D18, because it is a subdirectory of the tooling repo and has no independent git history. Against `pkgreviewtest/` the git-history scan reports NOT RUN with the reason "package is a subdirectory of a larger git repository"; that NOT RUN line is a not-applicable report, not a finding, and maps to no defect (the cross-field NOT RUN line is the same shape). D18 is planted in a throwaway repository that `fixtures/make_history_fixture.sh` builds deterministically (fixed author, fixed dates, no RNG): commit one adds `gps_latitude`, `gps_longitude`, and `owner_phone` to `inst/extdata/facilities.csv`, commit two removes them, so the working tree at HEAD is clean and the identifiers survive only in the first revision. A gate run scans that repository and must produce the D18 FLAG naming `facilities.csv`; a run whose working tree is clean and that still misses the history has missed D18. The check script covers the text-file part of the scan; the historical `.rda` column names and the commit-message wording stay with the reviewer (review-package Step 2), so a full gate for D18 is script plus workflow, as for D13 and D14.

Note on the v1.5.0 lines (washr 1.1.0 and owdata reconciliation, issues #56 to #68): the fixture DESCRIPTION carries `X-schema.org-keywords` (the same four keywords as CITATION.cff), `X-schema.org-spatialCoverage`, and `X-schema.org-temporalCoverage`, so the keywords, coverage, and dictionary-schema advisory lines PASS and the README export-link line PASSes on the existing `## Download` links. Three lines report NOT RUN against `pkgreviewtest/`, and each is a not-applicable report, not a finding: the git-history scan (subdirectory, see D18), the `docs/`-tracked line (no pkgdown workflow; the missing workflow is the reviewer's required Website item, not a script finding), and the R-CMD-check dev-trigger line (no workflow file; that gap is D5's presence finding). The 17-finding count and the D1 to D17 mapping are unchanged.

## How to use this scorecard

Run the full review workflow against `fixtures/pkgreviewtest` after every significant change to the checklists in `skills/pkgreview-core/references/checklists/` or to the review skills and commands.

The mechanical layer of the gate is scripted and runs in CI (`bash fixtures/run_gate.sh`, which diffs against `fixtures/expected/`): `Rscript skills/pkgreview-core/check/pkgreview-check.R fixtures/pkgreviewtest --org=openwashdata` runs the machine-checkable subset and must reproduce the defect mapping exactly (every FAIL/FLAG line maps to a defect ID, no unmapped lines; NOT RUN lines are not-applicable reports and map to nothing). Since v1.2.1 that is 19 FAIL + 1 FLAG lines for D1 to D17, with D4, D5, D7, and D15 as two-line spans. The judgment items, the intake conversation, and the guardrail behavior still require the workflow run.

The git-history defect D18 is exercised against its own repository, since `pkgreviewtest/` reports NOT RUN for history:

```
HISTREPO=$(bash fixtures/make_history_fixture.sh)
Rscript skills/pkgreview-core/check/pkgreview-check.R "$HISTREPO" --org=openwashdata   # expect the D18 history FLAG naming facilities.csv
rm -rf "$HISTREPO"
```

Because D14 stops the review at the intake screen, a gate run has two stages: first confirm the intake screen flags `owner_phone` (D14) and the defective dictionary descriptions (D13) and stops; then the maintainer explicitly acknowledges the intake findings at the check-in and lets the review proceed, so the remaining defects are exercised through the review issues.

### Exact-reconciliation rule

The gate passes only under exact reconciliation (premortem constraint P1):

- Against `fixtures/pkgreviewtest`, the finding count equals the defect count: exactly seventeen findings, one per defect D1 to D17. The git-history line there is a NOT RUN report (package is a subdirectory), not a finding.
- Against the `make_history_fixture.sh` repository, the history scan produces the one D18 FLAG naming `facilities.csv`.
- Every finding maps to exactly one defect ID, attributed to the correct review area.
- Every defect is caught. A missed defect means the change weakened the standard; the change must not merge until the defect is caught again.
- Waiving findings as noise is prohibited. A finding that maps to no defect ID fails the gate: either the fixture drifted or the checklist produces false positives, and either cause must be fixed before merge.

## Do not fix the fixture

The package is intentionally defective. Never "fix" a defect in place, not even when a review run, a linter, or an R CMD check points at it. Fixture changes are strictly additive: the D1 to D12 defect mechanisms stay untouched, and new defects are added without shifting the RNG stream that generates the existing ones (see the comments in `fixtures/make_pkgreviewtest.R`). If the planted defects need to change (for example because a checklist item changed), edit and rerun `fixtures/make_pkgreviewtest.R` to regenerate the data files deterministically, adjust the static files as needed, and update this scorecard in the same change.
