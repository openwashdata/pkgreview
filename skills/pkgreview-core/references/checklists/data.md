# Review Checklist: Data Content & Processing

Review area 2 of 4. Issue label: `pkgreview-data`.

Required items block publication. Advisory items are quality improvements:
the reviewer may fix them or record them as optional follow-ups; they never
block publication.

## Required

- [ ] Raw data files preserved in `data-raw/`
- [ ] `data_processing.R` in `data-raw/`
- [ ] All primary data files are present in `data/` and use `.rda` format
- [ ] All raw or exportable data files (CSV/XLSX) are in `inst/extdata/`
- [ ] No sensitive or personally identifiable information is present in any data file, in the current files or in any earlier revision of the git history (identifying data removed in an earlier commit stays recoverable from any clone; the history scan covers deleted data files, historical revisions of text files, historical `.rda` column names, and commit-message wording). The intake screen outcome is recorded in the first review issue; household- or person-level data requires a named human sign-off comment on the review issue. Identifying data found in the history blocks publication until the history is cleaned (recovery.md failure mode 10). The review agent never certifies this item on its own.
- [ ] `data-raw/dictionary.csv` covers every variable in every dataset, each with a one-sentence plain-language description. The description is the most important field; it is written or confirmed by a human.

## Advisory

### File structure

- [ ] Single-dataset package: the dataset is accessible via an object matching the package name. Multi-dataset package: each data object has a unique, descriptive name, and none of them matches the package name
- [ ] Data size is appropriate for an R package (not excessively large, which would require an external download)
- [ ] No obsolete files; no blank spaces in file names

### Dictionary

- [ ] `data-raw/dictionary.csv` has exactly the five washr columns in order (`directory`, `file_name`, `variable_name`, `variable_type`, `description`), is UTF-8 without a byte order mark, and `variable_type` holds one class name per row (for example `Date`, not `c("POSIXct", "POSIXt")`); the organization catalog and `washr::update_metadata()` parse it with that schema

### Data quality

- [ ] Missing values are coded as `NA`, not as empty strings, "NULL", "N/A", sentinel numbers (such as -99), or similar; report the count and percentage of missing values per variable
- [ ] Processed, analysis-ready data follows tidy data principles
- [ ] Exact duplicate rows counted and reported, including rows identical on all non-ID columns (the double-submission pattern)
- [ ] Cross-field consistency checks run with violation counts reported (for example a date column that must not precede a related date column, a part that must not exceed its whole)
- [ ] Hard-range violations counted and reported (counts are >= 0, percentages within [0, 100]); values that are unusual but possible are flagged separately as plausibility concerns for maintainer judgment, never reported as errors
- [ ] Categorical variables: frequency tables prepared; similar or misspelled values flagged (for example "male" vs "Male" vs "MALE"); ordinal variables stored as `factor` with correct level order; unused factor levels removed
- [ ] Date variables stored as `Date` class and rendered as ISO 8601 (`YYYY-MM-DD`) in the CSV/XLSX exports; no impossible or out-of-range dates
- [ ] Coordinate columns, if present: latitude within [-90, 90], longitude within [-180, 180], no (0, 0) points, no points outside the stated study region; coordinate precision assessed as a disclosure risk consistent with the intake screen outcome
- [ ] Numeric variables stored as `numeric` or `integer` class; outliers flagged using summary statistics; no numeric values stored as character strings
- [ ] Variable types are appropriate: `factor` for ordinal categories, `double` for continuous values, `integer` for counts, `Date` for dates
- [ ] No mixed types within a column; data types consistent across all datasets
- [ ] Column names are syntactically valid snake_case, with no unexplained acronyms and no unexplained numbers in variable names
- [ ] Unique identifiers are unique where expected
- [ ] All text data is encoded in UTF-8; no encoding errors

### Data processing script

- [ ] Script is reproducible and well-commented; no commented-out code
- [ ] Tidyverse conventions in the processing script: data read with `readr::read_csv()` and explicit `col_types` (silent type guessing is how character dates slip in); exports written with `readr::write_csv()` and `writexl::write_xlsx()` (both always UTF-8, never base `write.csv()` with `fileEncoding`); native pipe `|>` preferred
- [ ] Handles data cleaning transparently
- [ ] Analysis and testing scripts preserved in the `analysis/` directory

## Suggested tools

| Check | Tool |
| :-- | :-- |
| Missing values per variable | `skimr::skim()` |
| Frequency tables for categoricals | `dplyr::count()` |
| Similar string values | `stringdist::stringdist()` |
| Date format and class | `lubridate::is.Date()` |
| Parsing mixed-format dates | `lubridate::ymd()` / `lubridate::dmy()` / `lubridate::parse_date_time()` |
| Syntactically valid snake_case names | `janitor::make_clean_names()` |
| Ordinal as factor | `is.ordered()` |
| UTF-8 encoding | `stringi::stri_enc_isutf8()` |

## Files to review

- `data/*.rda`
- `R/[package-name].R` (or one `R/[dataset-name].R` per dataset)
- `data-raw/data_processing.R`
- `data-raw/dictionary.csv`
- `data-raw/[raw-data-files]`
- `inst/extdata/*`
