# Checklist reconciliation table

This table records the consolidation of the review checklists into a single
source of truth (issue #5). Every checklist item that existed in any copy is
listed with an explicit decision, so no item was dropped or altered silently.

Date: 2026-07-08. Baseline: commit after the issue #4 fixes (the
`washr::compile_citation()` typo and the missing CC BY 4.0 item were fixed
before consolidation so that known bugs were not canonicalized).

## Sources

| Key | File | Role before consolidation |
|-----|------|---------------------------|
| CM | `CLAUDE.md` | Master checklist sections (4 review areas) |
| RP | `commands/review-package.md` | Metadata issue body template |
| RI | `commands/review-issue.md` | Per-issue conditional checklist blocks |
| CN | `commands/create-next-issue.md` | Issue body templates for issues 2 to 4 |
| CSV | `docs/review-checklist.csv` | 26 check rows, referenced by README but used by nothing |

## Canonical outputs

| File | Content |
|------|---------|
| `skills/pkgreview-core/references/checklists/metadata.md` | General Information & Metadata checklist |
| `skills/pkgreview-core/references/checklists/data.md` | Data Content & Processing checklist |
| `skills/pkgreview-core/references/checklists/docs.md` | Documentation checklist |
| `skills/pkgreview-core/references/checklists/tests.md` | Tests & CI/CD checklist |
| `skills/pkgreview-core/references/templates/issue-body.md` | Canonical issue body template (all 4 issues) |
| `skills/pkgreview-core/references/templates/pr-body.md` | Canonical PR body template |
| `skills/pkgreview-core/references/templates/_pkgdown.yml` | Standard pkgdown configuration |

Decisions column: **keep** (adopted as-is into the canonical file), **merge**
(folded into another canonical item; target named), **drop** (removed; reason
given).

## Area 1: General Information & Metadata

| # | Item | Sources | Decision | Canonical item / rationale |
|---|------|---------|----------|----------------------------|
| M1 | Package name follows openwashdata conventions, clear, concise, indicative of content | CSV only | keep | New first item in metadata checklist; was CSV-only and previously unenforced |
| M2 | Title descriptive, under 65 characters | CM, RP, RI | keep | Metadata: DESCRIPTION section |
| M3 | Description: clear purpose statement | CM, RP, RI | merge | Merged with CSV "Description field informative and accurate" into one item |
| M4 | Description field informative and accurate | CSV | merge | Into M3 |
| M5 | Authors with ORCID IDs | CM, RP, RI | merge | Merged with CSV "Author(s) and maintainer clearly identified with contact information" into one item covering ORCID plus maintainer email |
| M6 | Author/maintainer identified with contact information | CSV | merge | Into M5 |
| M7 | License: CC BY 4.0 | CM, RI (RP since #4) | keep | Metadata checklist. CSV said "CC-BY or CC0"; the CC0 alternative is **dropped**: CLAUDE.md, both command copies, and the published openwashdata packages use CC BY 4.0 uniformly |
| M8 | Dependencies properly declared | CM, RP, RI | keep | Metadata checklist |
| M9 | Version follows semantic versioning | CM, RP, RI | keep | Metadata checklist |
| M10 | Run `washr::update_description()` after DESCRIPTION edits | CM, RP | keep | Metadata checklist; was missing from RI |
| M11 | CITATION.cff present and valid | CM, RI (RP since #4) | keep | Metadata: Citation section |
| M12 | CITATION.cff version matches latest release / package version | CSV (listed under Documentation) | keep | Moved to metadata Citation section where the other citation items live |
| M13 | Generate citation with `washr::update_citation()`, no DOI before first release | CM, RP, RI (RI had `compile_citation()` typo, fixed in #4) | keep | Metadata: Citation section |
| M14 | Website renders and is published on GitHub Pages | CSV (listed under General Information) | keep | Moved to Documentation checklist (Website section); it is verified during the docs review, not the metadata review |

## Area 2: Data Content & Processing

| # | Item | Sources | Decision | Canonical item / rationale |
|---|------|---------|----------|----------------------------|
| D1 | Primary data files in `data/` as `.rda` | CM, RI, CN | keep | Data: File structure |
| D2 | Raw/exportable CSV/XLSX in `inst/extdata/` | CM, RI, CN | keep | Data: File structure |
| D3 | Main dataset accessible via function/object matching package name | CM only | keep | Data: File structure; was missing from both issue templates |
| D4 | No sensitive or personally identifiable information | CM, RI, CN | keep | Data: File structure |
| D5 | Data size appropriate for an R package | CSV only | keep | Data: File structure |
| D6 | Missing values coded as `NA` (not "", "NULL", "N/A") | CM, RI, CN | merge | One canonical item combining coding rule, the RI reporting requirement (count and percentage per variable), and CSV "missing values handled appropriately" |
| D7 | Report count and percentage of missing values per variable | RI only | merge | Into D6 |
| D8 | Missing values handled appropriately | CSV | merge | Into D6 |
| D9 | Data follows tidy data principles | CSV only | keep | Data: Data quality |
| D10 | No data entry errors or inconsistencies | CSV only | keep | Data: Data quality |
| D11 | Frequency tables for categorical variables | RI | merge | One canonical categorical item with D12 to D14 |
| D12 | Flag similar or misspelled string values | RI (CN/CM "categorical variables checked for consistency") | merge | Into the categorical item |
| D13 | Ordinal variables stored as factor with correct level order | RI | merge | Into the categorical item |
| D14 | Remove unused factor levels | RI only | merge | Into the categorical item |
| D15 | Date variables as `Date` class, YYYY-MM-DD, no impossible dates | CM ("proper format"), RI (detailed), CN | keep | RI's detailed wording adopted as canonical |
| D16 | Numeric variables as numeric/integer, reasonable ranges, outliers flagged | CM ("reasonable ranges"), RI (detailed), CN | keep | RI's detailed wording adopted; includes "no numeric values stored as character strings" |
| D17 | Variable types appropriate (factor/double/integer/Date) | CSV | keep | Data: Data quality; complements D16 |
| D18 | Consistent data types across datasets, no mixed types in a column | RI only | keep | Data: Data quality |
| D19 | Column names syntactically valid, snake_case | RI, CSV | merge | One item, combined with CSV "no unexplained acronyms and no weird numbers in variable names" |
| D20 | No unexplained acronyms or numbers in variable names | CSV only | merge | Into D19 |
| D21 | Unique identifiers unique where expected | CSV only | keep | Data: Data quality |
| D22 | Text data encoded in UTF-8, no encoding errors | CM, RI, CN | keep | Data: Data quality |
| D23 | `data_processing.R` in `data-raw/` | CM, RI, CN | keep | Data: Processing script |
| D24 | Script reproducible and well-commented | CM, RI, CN | merge | Combined with CSV "no commented out code" into one item |
| D25 | No commented-out code | CSV only | merge | Into D24 |
| D26 | Raw data files preserved in `data-raw/` | CM, RI, CN | keep | Data: Processing script |
| D27 | `dictionary.csv` with variable descriptions | CM, RI, CN | keep | Data: Processing script |
| D28 | Uses tidyverse conventions | CM, RI | keep | Data: Processing script; was missing from CN template |
| D29 | Handles data cleaning transparently | CM, RI | keep | Data: Processing script; was missing from CN template |
| D30 | Analysis and testing scripts preserved in `analysis/` | CM only | keep | Data: Processing script; was missing from all issue templates |
| D31 | No blank spaces in file names | CSV only | keep | Data: File structure, combined with D32 |
| D32 | No obsolete files | CSV only | merge | Into D31 |
| D33 | Suggested tools table (skimr, dplyr, stringdist, lubridate, dlookr, stringi) | RI only | keep | Kept as a non-checklist "Suggested tools" section in `data.md` |

## Area 3: Documentation

| # | Item | Sources | Decision | Canonical item / rationale |
|---|------|---------|----------|----------------------------|
| O1 | README.Rmd follows openwashdata template | CM, RI, CN | keep | Docs: README |
| O2 | One-paragraph introduction, 3 to 5 sentences | CSV only | keep | Docs: README |
| O3 | Dynamic content generation works | CM, RI, CN | keep | Docs: README |
| O4 | Installation instructions present | CM, RI, CN | keep | Docs: README |
| O5 | Data overview with dimensions | CM, RI, CN | keep | Docs: README |
| O6 | Variable dictionary table rendered | CM, RI, CN | keep | Docs: README |
| O7 | Visualisations have human-readable labels | CSV only | merge | One canonical visualisation item with O8 and O9 |
| O8 | Each visualisation described in the narrative | CSV only | merge | Into O7 |
| O9 | Each visualisation cross-referenced via its code-chunk label | CSV only (mis-filed under "Codebook/Data Dictionary") | merge | Into O7 |
| O10 | License and citation sections complete | CM, RI, CN | merge | Split into a license item and a citation item; citation item takes the CSV detail (author, year, title, DOI, website URL) |
| O11 | Citation section complete with author, year, title, DOI, website URL | CSV | merge | Into O10 |
| O12 | Roxygen documentation for all exported functions | CM, RI, CN | keep | Docs: Function and data documentation |
| O13 | All datasets documented with .Rd files | CSV only | keep | Docs: Function and data documentation |
| O14 | .Rd files include title, description, usage examples, variable descriptions | CSV only | keep | Docs: Function and data documentation |
| O15 | Data structures (rows/columns) and types clearly described | CSV only | keep | Docs: Function and data documentation |
| O16 | `_pkgdown.yml` with Plausible analytics | CM, RI (linked washmalawi copy), CN | keep | Canonical reference is now `skills/pkgreview-core/references/templates/_pkgdown.yml` in this repo, not the raw URL of another package |
| O17 | Package website builds without errors | CM, RI, CN | keep | Docs: Website |
| O18 | Website published on GitHub Pages | CSV (= M14) | keep | Docs: Website |
| O19 | Vignettes, if present, live in `vignettes/articles/` | CM (prose convention, never a checklist item) | keep | Promoted to a checklist item in Docs; the convention was enforced nowhere |

## Area 4: Tests & CI/CD

| # | Item | Sources | Decision | Canonical item / rationale |
|---|------|---------|----------|----------------------------|
| T1 | GitHub Actions workflow for R-CMD-check | CM, RI, CN | keep | Tests checklist |
| T2 | R-CMD-check badge in README.Rmd | CM, RI, CN | keep | Tests checklist; badge URL template kept from RI |
| T3 | `devtools::check()` passes with no errors/warnings | CM, RI, CN | merge | CSV row 26 demands "no errors, warnings, notes". Canonical wording: no errors or warnings, and any notes must be explained in the PR. Rationale: data packages routinely carry benign size-related notes; a hard "no notes" rule was never enforced in practice |
| T4 | Examples run successfully | CM, RI, CN | keep | Tests checklist |
| T5 | Data loads correctly | CM, RI, CN | keep | Tests checklist |

## PR body template

| Variant | Source | Decision |
|---------|--------|----------|
| Summary / Changes Made / Commits in this PR / Checklist / Closes #N | CM (Issue Resolution Workflow, step 8) | **keep**: canonical, in `skills/pkgreview-core/references/templates/pr-body.md` |
| Summary / Changes Made / Completed Checklist Items / Closes #N | CM (CREATE phase, step 6) | drop: subset of the canonical variant |
| Summary / Changes Made / Checklist (3 fixed items) | RI (After Implementation) | drop: less informative than canonical |
| Summary / Changes / Testing / Review Checklist / "Generated with Claude Code" trailer | `commands/review-pr.md` | drop: fixed checklist items do not reflect actual work; the attribution trailer is dropped deliberately (org style: no emojis, no tool attribution in PR bodies) |

## Fate of `docs/review-checklist.csv`

Deleted. All 26 rows are accounted for above (M1, M3 to M7, M12, M14, D5, D8 to D10, D17, D19 to D21, D25, D31, D32, O2, O7 to O9, O11, O13 to O15, T3). The
README claim that the CSV is "the complete list of review points" was false
(it was used by nothing and diverged from the markdown checklists); README now
points at `skills/pkgreview-core/references/checklists/`.
