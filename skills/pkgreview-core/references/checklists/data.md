# Review Checklist: Data Content & Processing

Review area 2 of 4. Issue label: `pkgreview-data`.

## File structure

- [ ] All primary data files are present in `data/` and use `.rda` format
- [ ] All raw or exportable data files (CSV/XLSX) are in `inst/extdata/`
- [ ] Single-dataset package: the dataset is accessible via an object matching the package name. Multi-dataset package: each data object has a unique, descriptive name, and none of them matches the package name
- [ ] No sensitive or personally identifiable information is present in any data file
- [ ] Data size is appropriate for an R package (not excessively large, which would require an external download)
- [ ] No obsolete files; no blank spaces in file names

## Data quality

- [ ] Missing values are coded as `NA`, not as empty strings, "NULL", "N/A", sentinel numbers (such as -99), or similar; report the count and percentage of missing values per variable
- [ ] Processed, analysis-ready data follows tidy data principles
- [ ] No data entry errors or inconsistencies
- [ ] Categorical variables: frequency tables prepared; similar or misspelled values flagged (for example "male" vs "Male" vs "MALE"); ordinal variables stored as `factor` with correct level order; unused factor levels removed
- [ ] Date variables stored as `Date` class in `YYYY-MM-DD` format; no impossible or out-of-range dates
- [ ] Numeric variables stored as `numeric` or `integer` class; value ranges are reasonable (for example age between 0 and 120); outliers flagged using summary statistics; no numeric values stored as character strings
- [ ] Variable types are appropriate: `factor` for ordinal categories, `double` for continuous values, `integer` for counts, `Date` for dates
- [ ] No mixed types within a column; data types consistent across all datasets
- [ ] Column names are syntactically valid snake_case, with no unexplained acronyms and no unexplained numbers in variable names
- [ ] Unique identifiers are unique where expected
- [ ] All text data is encoded in UTF-8; no encoding errors

## Data processing script

- [ ] `data_processing.R` in `data-raw/`
- [ ] Script is reproducible and well-commented; no commented-out code
- [ ] Raw data files preserved in `data-raw/`
- [ ] `dictionary.csv` with variable descriptions
- [ ] Uses tidyverse conventions
- [ ] Handles data cleaning transparently
- [ ] Analysis and testing scripts preserved in the `analysis/` directory

## Suggested tools

| Check | Tool |
| :-- | :-- |
| Missing values per variable | `skimr::skim()` |
| Frequency tables for categoricals | `dplyr::count()` |
| Similar string values | `stringdist::stringdist()` |
| Date format and class | `lubridate::is.Date()` |
| Ordinal as factor | `is.ordered()` |
| Consistent data types | `dlookr::diagnose()` |
| Reasonable value ranges | `dlookr::diagnose_numeric()` |
| UTF-8 encoding | `stringi::stri_enc_isutf8()` |

## Files to review

- `data/*.rda`
- `R/[package-name].R` (or one `R/[dataset-name].R` per dataset)
- `data-raw/data_processing.R`
- `data-raw/dictionary.csv`
- `data-raw/[raw-data-files]`
- `inst/extdata/*`
