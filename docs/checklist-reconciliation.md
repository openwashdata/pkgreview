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

## Amendments from the first real review (fslogisticskampala, 2026-07-08)

The first production run of the skill workflow (openwashdata/fslogisticskampala,
review standard 1.0.0-dev) surfaced checklist and template defects. Decisions,
recorded per rule 3 of CLAUDE.md:

| Ref | Item | Decision | Rationale |
|-----|------|----------|-----------|
| D3 | "Main dataset accessible via a function or object matching the package name" | reworded | The rule was unsatisfiable for multi-dataset packages (fslogisticskampala ships `trips` and `trucks`). Now: single-dataset packages name the object after the package; multi-dataset packages use unique, descriptive names, none matching the package name. Issue #18 |
| T2 | R-CMD-check badge markdown | updated | The template used the deprecated `workflows/R-CMD-check/badge.svg` form; replaced with `actions/workflows/R-CMD-check.yaml/badge.svg`, linking to the workflow page. Issue #25 |
| T6 (new) | Workflow triggers include `dev` | added | The usethis default `branches: [main, master]` meant no review PR into `dev` was ever CI-checked during the whole fslogisticskampala review. Issue #25 |
| PR template | `Closes #N` line | dropped | `Closes` only fires on default-branch merges; review PRs merge into `dev`, so the line never worked. The skills now close issues explicitly with a comment referencing the merged PR. Issue #21 |
| _pkgdown.yml | `url:` value | changed | Was the GitHub repo URL; pkgdown treats `url` as the site base URL, so canonical links, sitemap.xml, and redirects were broken on every reviewed package. Now the Pages URL; the repo link stays in `home.links`. Issue #24 |
| standards.md | CLAUDE.html on the website | accepted | pkgdown renders every top-level `.md` and offers no exclusion mechanism (hardcoded exclusion list in `build-home-md.R`). Post-build deletion would not survive rebuilds or CI. Accepted and documented in the standards file: the page publicly records the review standard. Issue #24 |

Version note: these amendments ship as part of `v1.0.0`, the first tagged
release of the standard. The completed fslogisticskampala review was
stamped `1.0.0-dev` before the tag existed; version-pinned checklist
fetching (rule 1) applies from `v1.0.0` onward. The fixture-run acceptance
gate for these amendments (#17) was waived by the maintainer at release
time and remains open to run afterwards.

## Tier split: Required and Advisory (issue #27, v1.1.0)

Date: 2026-07-23. Each checklist gains exactly one `## Required` and one
`## Advisory` section with a two-line tier definition at the top. Required
items block publication; advisory items never do. No item was dropped; the
tables below record where every item moved, keyed to the item numbers used
earlier in this document. Wording is unchanged except for the three
rewordings listed at the end. The fixture gate run for this split happens
in the fixture issue of the milestone (#31).

### Area 1: General Information & Metadata

| Items | Tier |
|-------|------|
| M3/M4 (Description informative and accurate), M5/M6 (authors and maintainer with ORCID and contact email), M7 (CC BY 4.0), M11 (CITATION.cff present and valid), M12 (CITATION.cff version matches DESCRIPTION), M13 (citation via `washr::update_citation()`) | Required |
| M1 (package name conventions), M2 (title under 65 characters), M8 (dependencies declared), M9 (semantic versioning), M10 (run `washr::update_description()` after edits) | Advisory |

### Area 2: Data Content & Processing

| Items | Tier |
|-------|------|
| D26 (raw data preserved in `data-raw/`), D23 (`data_processing.R` in `data-raw/`), D1 (primary data in `data/` as `.rda`), D2 (CSV/XLSX in `inst/extdata/`), D4 (PII, reworded below), D27 (dictionary, reworded below) | Required |
| D3 (dataset naming), D5 (data size), D31/D32 (obsolete files, blank spaces), D6-D8 (NA coding), D9 (tidy data), D10 (entry errors), D11-D14 (categorical checks), D15 (dates), D16 (numeric ranges), D17 (variable types), D18 (consistent types), D19/D20 (snake_case names), D21 (unique identifiers), D22 (UTF-8), D24/D25 (script well-commented, no commented-out code), D28 (tidyverse conventions), D29 (transparent cleaning), D30 (`analysis/` scripts) | Advisory |

D33 (suggested tools table) stays a non-checklist section.

### Area 3: Documentation

| Items | Tier |
|-------|------|
| O2 (one-paragraph introduction), O3 (dynamic generation works), O4 (installation instructions), O5 (data overview with dimensions), O6 (dictionary table rendered), O10 license item, O10/O11 citation item, O13/O14 (datasets documented with `.Rd` incl. per-variable descriptions), O17 (website builds), O18 (published on GitHub Pages) | Required |
| O1 (README template conformance), O7-O9 (visualisation polish), O12 (roxygen for exported functions), O15 (data structures and types described in `.Rd`), O19 (vignettes location), O16 (`_pkgdown.yml` conformance) | Advisory |

### Area 4: Tests & CI/CD

| Items | Tier |
|-------|------|
| T1 (R-CMD-check workflow present), T6 (`dev` trigger), T3 (`devtools::check()` passes, notes explained), T4 (examples run), T5 (data loads) | Required |
| T2 (R-CMD-check badge; badge markdown block kept with it) | Advisory |

### Rewordings

| Ref | Decision | New wording | Rationale |
|-----|----------|-------------|-----------|
| M3 | reworded | "Description is an informative and accurate statement of what the data contains" | Was "statement of purpose"; the required floor names a description of the data, and the issue #27 required-tier text uses the data framing |
| D4 | reworded | "No sensitive or personally identifiable information is present in any data file. The intake screen outcome is recorded in the first review issue; household- or person-level data requires a named human sign-off comment on the review issue. The review agent never certifies this item on its own." | Encodes premortem constraint P6 (human sign-off); ties the item to the intake screen added in #28 |
| D27 | reworded | "`data-raw/dictionary.csv` covers every variable in every dataset, each with a one-sentence plain-language description. The description is the most important field; it is written or confirmed by a human." | Encodes premortem constraint P4 (no agent-invented metadata); the description is the floor's most important field |

## Fixture and scorecard for v1.1.0 (issue #31)

Date: 2026-07-23. No checklist item changed in this issue; recorded here
because the scorecard is the acceptance instrument for every checklist
change. The fixture gains two strictly additive defects: D13 (dictionary
present but with an empty description for `status` and a placeholder for
`users_count`; caught by the reworded required dictionary item D27) and
D14 (direct-identifier column `owner_phone`; caught by the intake screen
from #28, which stops the review before any issue exists). The D1-D12
mechanisms are untouched; the regenerated CSVs are byte-identical on the
D1-D12 columns. The scorecard now maps fourteen defects, marks each with
its tier, and adopts the exact-reconciliation rule (premortem constraint
P1): the gate passes only when the finding count equals the defect count,
every finding maps to exactly one defect ID, and waiving findings as
noise is prohibited.

Version note: the tier split (#27), the intake screen (#28), the advisory
handling and evidence rule (#29), the guidebook (#30), and the fixture
additions (#31) ship together as `v1.1.0`. The package-resident standards
file gains the tier distinction, the PII-first rule, and the dictionary
description emphasis in the same release (#32).

## Mechanical rewordings of the unverifiable data checks (issue #33, v1.2.0)

Date: 2026-07-23. The specialist panel found the advisory tier's vaguest
items unverifiable by an agent: it either rubber-stamps them or
hallucinates findings. They become checkable items with countable
outputs; the required tier does not grow. Wording is kept one-to-one
implementable by the deterministic check script proposed in #13. Fixture
additions exercising the new items land with the v1.2.0 release issue
(#36).

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| D10 | dropped, replaced by D34-D36 | "No data entry errors or inconsistencies" is not a check an agent can execute | Replaced by three mechanical items with countable outputs |
| D34 (new) | added | Exact duplicate rows counted and reported, including rows identical on all non-ID columns (double-submission pattern) | The common data entry error, made countable |
| D35 (new) | added | Cross-field consistency checks with violation counts (date ordering, part not exceeding whole) | Consistency made mechanical per field pair |
| D36 (new) | added | Hard-range violations counted (counts >= 0, percentages in [0, 100]); unusual but possible values flagged separately as plausibility concerns for maintainer judgment, never reported as errors | Separates the checkable from the judgment call; the agent stops inventing "unreasonable range" findings |
| D37 (new) | added | Coordinate columns: latitude in [-90, 90], longitude in [-180, 180], no (0, 0) points, no points outside the stated region; precision assessed as disclosure risk consistent with the intake screen outcome | Coordinates were previously uncovered; links to the intake screen from #28 |
| D15 | reworded | "Date variables stored as `Date` class and rendered as ISO 8601 (`YYYY-MM-DD`) in the CSV/XLSX exports" | The old wording conflated class and format: a `Date` has no stored print format, so "stored in YYYY-MM-DD format" was uncheckable as written; class and export rendering are separately checkable. Scorecard D8 quote updated in the same change |
| D16 | reworded | "value ranges are reasonable (for example age between 0 and 120)" clause removed | Range checking moved to D36, which splits hard ranges from plausibility; the rest of the item (class, outliers, no numbers as character) is unchanged |

## Tidyverse conventions enumerated, tools table updated (issue #34, v1.2.0)

Date: 2026-07-23. "Uses tidyverse conventions" was unverifiable as
written; it stays advisory (style never blocks publication) but becomes
concrete.

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| D28 | reworded, enumerated | Tidyverse conventions in the processing script: `readr::read_csv()` with explicit `col_types`; exports via `readr::write_csv()` / `writexl::write_xlsx()` (always UTF-8, never base `write.csv()` with `fileEncoding`); native pipe preferred | Each clause is mechanically checkable; silent type guessing is how character dates slip in |
| D28 | deviation from the issue text | "no commented-out code" NOT repeated in the enumerated list | Already covered verbatim by D24/D25 two lines above; repeating it would duplicate checklist content (repo rule 4) and let one fixture defect (scorecard D12) map to two items, breaking exact reconciliation |
| D33 | tools table updated | Added `janitor::make_clean_names()` (snake_case) and a lubridate parsing row (`ymd()` / `dmy()` / `parse_date_time()`); dropped both dlookr rows | skimr plus `dplyr::count()` cover the dlookr diagnostics without a heavy dependency; the "reasonable value ranges" row also lost its checklist item in #33 |

Fixture decision (recorded in the scorecard next to D15): the fixture
script's convention violations become planted defect D15 rather than
being cleaned, because `write.csv(fileEncoding = "latin1")` is the
in-package mechanism of encoding defect D3 (premortem F3) and
`read_csv()` without `col_types` is the mechanism that lets D8's
character dates slip through. No fixture file changed in this issue; the
defect already existed in `data-raw/data_processing.R` and is now named.

## Provenance and FAIR light (issue #35, v1.2.0)

Date: 2026-07-23. The FAIR specialist review found the standard treated
FAIR as "has a DOI and a license": no provenance requirements, no
discovery keywords, no non-R access path, no concept-vs-version DOI
distinction. All new items are advisory; the release-flow fixes live in
skills/add-doi/SKILL.md (the manual floor; automation remains #12).

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| M14 (new) | added, advisory | CITATION.cff carries `keywords` for discovery (open data, washdata, topic, country or region); verify manually after `washr::update_citation()`, which may not write them | Discovery metadata was absent from the standard |
| O20 (new) | added, advisory | README provenance sentence: collector, method, period, region, source-data license or permission | Provenance was entirely uncovered |
| O21 (new) | added, advisory | README Download section with direct links to the CSV/XLSX exports | Non-R users had no documented access path |
| O22 (new) | added, advisory | Roxygen `@source` per dataset: original collector, URL or reference, access date | The single most important Rd field for a data package after the description |

add-doi flow (not checklist items): concept DOI vs version DOI sentence
added (concept DOI in citation files and badge); one manual "review the
Zenodo record" prompt added (openwashdata community, resource type
Dataset not Software, related identifiers for repo and pkgdown site).

Fixture reconciliation for M14 and O20-O22 is deferred to the v1.2.0
fixture issue (#36): the fixture currently satisfies none of the four,
so #36 must either satisfy them or plant them as defects before the
v1.2.0 gate can reconcile exactly.

## Fixture and scorecard for v1.2.0 (issue #36)

Date: 2026-07-23. Strictly additive; the D1-D15 mechanisms are untouched
and the regenerated CSVs are byte-identical on the earlier columns.
Planted defects only for items the gate must exercise: D16 (cross-field
violation, `women_users` exceeds `users_count` in two rows) and D17
(coordinate defects, one (0, 0) point and one out-of-range longitude at
waterpoint-level precision that deliberately does not trip the intake
screen). The three new columns are derived from the row index and
`users_count` with no RNG consumed. The remaining new v1.2.0 items are
satisfied by the fixture instead of planted: exact duplicate rows (count
zero), roxygen `@source` (added, synthetic-data provenance), README
provenance sentence and Download section (added), CITATION.cff
`keywords` (added without touching the D2 placeholder authors). Two
scorecard notes record consolidation rules: the -99 sentinels trip both
the NA-coding and hard-range items but map to the single defect D4, and
D17 is a range defect, not a PII defect.

Version note: the mechanical rewordings (#33), the tidyverse enumeration
(#34), the provenance and FAIR items (#35), and these fixture additions
(#36) ship together as `v1.2.0`.

## Organization profile layer (issue #49, v1.3.0)

Date: 2026-07-27. pkgreview now reviews packages for registered
organizations; org-specific values moved out of the checklists into
per-org profile files (`skills/pkgreview-core/references/orgs/`),
decided in #48. No checklist item was added or dropped; the rewordings
below replace hardcoded openwashdata values with references to the org
profile. openwashdata and Global-Health-Engineering are the registered
orgs; both currently share the washr tooling, the washr README template,
and the Plausible analytics stack, differing in domains, discovery
keyword, and Zenodo community.

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| M1 | reworded | Package name is clear, concise, and indicative of the data content | The "follows openwashdata conventions" attribution added nothing; the convention itself is shared by all registered orgs |
| M14 (v1.2.0 keywords item) | reworded | keywords at minimum: open data, the organization's discovery keyword from its org profile, the topic, and the country or region | "washdata" is the openwashdata profile value; Global-Health-Engineering uses "global health" (#48 decision 3) |
| docs: README template item | reworded | README.Rmd follows the README template named in the org profile | Template choice is an org field; both registered orgs name the washr template |
| docs: `_pkgdown.yml` item | reworded | follows the standard configuration for the registered organization, including the analytics header when the org profile defines one | Site URL domain and analytics domain are org fields; scorecard D7 quote updated in the same change |
| tests: badge markdown | reworded | badge URL uses `ORGNAME` placeholder filled from the org profile | The badge path follows the package's org |
| M10, M13 (washr steps) | unchanged | | Citation tooling is an org profile field, but every registered org uses washr; registering a non-washr org requires reworking these items and the standards template, a standard change with its own version bump |

Template changes (not checklist items): the issue body gains an
`Organization profile: [org]` stamp line next to the version stamp;
`templates/_pkgdown.yml` and `references/standards.md` carry
`ORGDOMAIN`/`ORGNAME` (respectively `{{ORG_DOMAIN}}`/`{{ORG_NAME}}`)
placeholders filled from the profile at review start; the check script
takes `--analytics=plausible|none` and reports the analytics check as
NOT RUN for profile-less analytics; recovery.md gains failure mode 9
(reviews without an org stamp predate v1.3.0 and are openwashdata
reviews by definition).

Fixture note: the fixture remains an openwashdata-profile package; the
planted defects D1 to D17 and their mappings are unchanged. D7's quoted
checklist wording in the scorecard was updated to the reworded item; the
defect mechanism (missing analytics header, repo URL as `url:`) is
untouched and still fails under `--analytics=plausible`, the setting the
openwashdata profile implies.

## Git-history PII scan (issue #52, v1.4.0)

Date: 2026-07-27. The PII floor covered the current data files only. A
review of Global-Health-Engineering/malawihcf passed the intake screen,
then a manual search found facility GPS coordinates in three historical
commits; the columns had been added and removed before the review
started, so no current file held them. A clean working tree is not the
publication floor: anyone who clones the repository can recover the
removed data. The scan now covers every revision in the git history.

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| D4 (PII item) | reworded, scope extended | No sensitive or PII in any data file, in the current files or in any earlier revision of the git history (deleted data files, historical text-file revisions, historical `.rda` column names, commit-message wording); history hits block publication until the history is cleaned (recovery.md failure mode 10) | The item read as current-files-only; the malawihcf finding showed the history is part of the floor |

Standards and skill changes (not new checklist items): the standards.md
rule "PII and sensitivity come first" now states the check covers every
revision, not only the current files, and that history hits block
publication until cleaned; review-package Step 2 gains a four-part
history scan (all-time data paths, historical text-file value scan,
historical `.rda` column scan, commit-message read), FLAG only, full
scan with a slowness note; the check script gains the text-file part of
the scan (FLAG, or NOT RUN when the directory is not a git repo or is a
subdirectory of a larger repo); recovery.md gains failure mode 10 (git
history remediation: filter-repo or clean root, force-push, GitHub
support purge, collaborator re-clone, treat as disclosed); the guidebook
PII section gains the same history warning.

Fixture note (D18): `fixtures/pkgreviewtest/` is a subdirectory of the
tooling repo and has no git history of its own, so the history scan
reports NOT RUN there and the D1 to D17 reconciliation against it is
unchanged (still 17 findings, 19 FAIL + 1 FLAG, plus the new NOT RUN
line, which is a not-applicable report, not a finding). The history
defect D18 is planted in a throwaway repository built deterministically
by `fixtures/make_history_fixture.sh` (identifiers added then removed, so
only the history carries them); the gate scans that repository and must
produce the D18 FLAG. The `.rda`-history and commit-message parts of the
scan stay with the reviewer, so a full D18 gate is script plus workflow,
as for D13 and D14.

## washr 1.1.0 and owdata reconciliation (v1.5.0)

Date: 2026-09-05. washr 1.1.0 reached CRAN on 2026-09-02: an idempotent
core, `setup_ci()`, `use_brand()`, the experimental `update_metadata()`,
keywords and coverage in the DESCRIPTION `X-schema.org` fields, and
`docs/` left ignored when a pkgdown workflow deploys the site. The
reconciliation review of the standard against it (issue #56) found every
washr call the skills make still exists, but the caveat text, two
release-skill calls, and two advisory checks were stale or wrong.
openwashdata/owdata, the weekly catalog harvester, reads exactly the
files the floor enforces plus the three `X-schema.org` fields and the
five-column dictionary schema. The maintainer took every decision on
2026-09-05 (issues #57 to #67, Option A throughout); the release is #68.

| Ref | Decision | New wording (short form) | Rationale |
|-----|----------|--------------------------|-----------|
| M14 (keywords) | reworded | DESCRIPTION carries `X-schema.org-keywords` (org minimum unchanged); `washr::update_citation()` carries them into CITATION.cff, so they are never typed there by hand | DESCRIPTION is the canonical home since washr 1.1.0; keywords typed into CITATION.cff are migrated to DESCRIPTION on the next washr run, so "verify manually" was wrong. The check script reads DESCRIPTION and reports CITATION.cff agreement as a drift detail, never as a second finding (#60) |
| M15 (new) | added, advisory | DESCRIPTION carries `X-schema.org-spatialCoverage` (place name) and `X-schema.org-temporalCoverage` (`YYYY-MM-DD/YYYY-MM-DD`) | `washr::update_metadata()` reads them into the JSON-LD and the owdata catalog reads them for its location column (#64) |
| D38 (new, dictionary schema) | added, advisory | `data-raw/dictionary.csv` has exactly the five washr columns in order, is UTF-8 without a byte order mark, and `variable_type` holds one class name per row | The owdata parser found quoted headers, padded names, trailing and extra columns, a leading unnamed column, BOMs, and deparsed multi-class types across pre-standard packages; the check keeps newly reviewed packages out of that list at no cost to the required tier (#64) |
| O21 (README Download) | reworded | README offers direct links to the CSV/XLSX exports in `inst/extdata/` for non-R users (the washr template's download table satisfies this) | The `## Download` heading the check script tested failed every README scaffolded by washr, which renders the download table under Installation; the check now matches links into `inst/extdata/` regardless of heading (#61) |
| docs: Website (required) | reworded, floor changed | Website published on GitHub Pages, deployed by the pkgdown workflow (`.github/workflows/pkgdown.yaml`) from `gh-pages`; `docs/` ignored and not committed | A committed site went stale between per-issue PRs or churned with the reviewer's toolchain (#54); washr 1.1.0 and owdata are scaffolded for the workflow, and `update_citation()` rebuilds a committed site on every release run. The one change to the required floor in this release, which is why v1.5.0 is a minor bump (#65) |
| docs: `_pkgdown.yml` item | unchanged wording; template and standards block gain optional `bslib.brand` lines | | The brand is an org profile field: openwashdata sets `_brand.yml` from openwashdata/brand via `washr::use_brand()`, Global-Health-Engineering has none. A reviewer can now tell a wanted brand from an unwanted one (#63) |
| tests: trigger item | reworded | Triggers include `dev` for push and pull_request (`washr::setup_ci()` writes `branches: [main, master, dev]`) | `setup_ci()` writes three branches, so the literal `[main, dev]` no longer described the scaffold; the check script gains a dev-trigger line (NOT RUN when the workflow file is missing, which is the presence line's finding) (#63) |
| M10, M13 and the two standards rules on `update_description()` and `update_citation()` | caveats deleted | Run the washr call; no caveat | washr 1.0.2 fixed the four root causes (washr #57, #58, #59, #60, #63) and 1.1.0 is the floor: both release skills stop on an older washr with an `install.packages("washr")` remediation instead of adapting. On a fixed washr the old surgery deleted correct badges and restored fields that were never stripped. #41's version-conditioning is superseded (#57) |

Skill changes (not checklist items): create-release validates the
version argument (`^[0-9]+\.[0-9]+\.[0-9]+$` and greater than the current
version), sets it with `desc::desc_set_version()` because
`usethis::use_version()` takes a bump type rather than a target, calls
`washr::update_citation(build = FALSE)` so no site build happens in the
version-bump commit, drops the dead `.bk1` cleanup, checks the GitHub
default branch, and syncs `dev` after the release commit (#58, #46).
add-doi runs `washr::update_metadata()` only when
`pkgdown/templates/in-header.html` exists (SKIPPED otherwise), reduces
the badge and website steps to verification (washr owns the badge; the
pkgdown workflow deploys the site on the push to `main`, with a
committed-`docs/` fallback for packages reviewed before v1.5.0), and
ends with the `dev` sync (#59, #46, #65). review-package records the
site deployment state for the plan, review-issue never commits `docs/`,
and review-complete verifies the workflow, the untracked `docs/`, and
names the Pages setting as the maintainer action in the final PR body
(#65). The check script gains the keywords, coverage, dictionary schema,
export-link, `docs/`-tracked, and dev-trigger lines and a scope note:
its metadata, docs, and tests sections are frozen pending
`washr::check_publication_readiness()` (#66). Org profiles: the keywords
field is renamed "Discovery keywords (minimum)", the Citation tooling
field reads `washr >= 1.1.0`, and a Brand field is added (#57, #60,
#63). standards.md was re-read and edited once for #57, #63, #64, and
#65. The guidebook is reduced to PII (with the git-history warning),
floor, dictionary, review, and publication, and points at the washr
Get started vignette and the data publishing guide for the scaffold; no
washr function is named in it any more (#62).

Fixture note: `fixtures/pkgreviewtest/DESCRIPTION` gains the three
`X-schema.org` fields (keywords identical to the CITATION.cff list, so
the drift detail reads "agrees"; coverage `Switzerland` and
`2018-01-01/2022-02-05`, the range of the installation dates). The D1 to
D17 mechanisms are untouched and no RNG changed. The mechanical gate
reproduces the v1.4.0 mapping exactly: 19 FAIL + 1 FLAG lines mapping to
D1 to D17 (D4, D5, D7, and D15 as two-line spans), the four new advisory
lines PASS, and three not-applicable NOT RUN lines (history scan:
subdirectory; `docs/` untracked: no pkgdown workflow; dev trigger: no
R-CMD-check workflow, which is D5's finding). The history fixture still
produces the one D18 FLAG. Synthetic checks run during implementation
and not committed: a dictionary with a BOM, an extra column, and a
`c("POSIXct", "POSIXt")` type FAILs naming all three; a README rendered
from the washr 1.1.0 download table PASSes and one without export links
FAILs; nested `branches:` lists with `dev` PASS and one without `dev`
under pull_request FAILs; a tracked `docs/` next to the workflow FAILs.

Not part of the standard: the housekeeping deletions (#67) and the
check-script scope decision (#66) carry no checklist or template change.
