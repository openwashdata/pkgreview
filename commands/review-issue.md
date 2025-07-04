# review-issue

**Description**: Jump to a specific issue in the openwashdata package review process and work on it systematically.

**Usage**: `/review-issue [number]`

**Parameters**:
- `number` (required): Issue number (1-4) to work on

---

When the user types `/review-issue [number]`, execute the following:

First, get the issue number and determine context:
```bash
ISSUE_NUMBER=$1
PACKAGE_NAME=$(basename "$PWD")
```

## 🎯 Reviewing Issue #$ISSUE_NUMBER: $ISSUE_TITLE

### GitHub CLI Commands
- `gh issue view $ISSUE_NUMBER` - View issue details
- `gh issue develop $ISSUE_NUMBER` - Create branch for issue
- `git checkout $ISSUE_NUMBER-$ISSUE_SLUG`

### Issue Details

{{#if issue-1}}
**Data Package Review: General Information & Metadata**

**Checklist:**
- [ ] DESCRIPTION file completeness
  - Title (descriptive, <65 characters)
  - Description (clear purpose statement)
  - Authors with ORCID IDs
  - License: CC BY 4.0
  - Dependencies properly declared
  - Version follows semantic versioning
- [ ] CITATION.cff file present and valid
- [ ] Generate citation using `washr::compile_citation()`

**Files to Review:**
- `DESCRIPTION`
- `CITATION.cff`
- `inst/CITATION`
{{/if}}

{{#if issue-2}}
**Data Package Review: Data Content & Processing**

## Data Content & Quality Review Checklist

### 1. File Structure

- **[ ] All primary data files are present in `data/` and use `.rda` format.**
- **[ ] All raw or exportable data files (CSV/XLSX) are in `inst/extdata/`.**
- **[ ] No sensitive or personally identifiable information is present in any data file.**


### 2. Data Quality Checks

#### 2.1. Missing Values

- **[ ] For each variable, report:**
    - Number of missing values (`NA`)
    - Percentage of missing values relative to total rows
- **[ ] Confirm missing values are coded as `NA` (not as empty strings, "NULL", "N/A", etc.).**


#### 2.2. Categorical Variables

- **[ ] Prepare frequency tables for all categorical variables.**
- **[ ] Identify and flag similar or misspelled string values (e.g., "male" vs "Male" vs "MALE").**
- **[ ] For ordinal variables, confirm they are stored as `factor` with correct level order.**
- **[ ] Remove unused factor levels.**


#### 2.3. Date Variables

- **[ ] All date variables are stored as `Date` class.**
- **[ ] All dates are in `YYYY-MM-DD` format.**
- **[ ] No impossible or out-of-range dates (e.g., future dates, 1900-01-01 for modern data).**


#### 2.4. Numeric Variables

- **[ ] All numeric variables are stored as `numeric` or `integer` class.**
- **[ ] Check for reasonable value ranges (e.g., age between 0 and 120).**
- **[ ] Identify and flag outliers using summary statistics (min, Q1, median, Q3, max).**
- **[ ] No numeric values stored as character strings.**


#### 2.5. Data Types \& Consistency

- **[ ] All variables have consistent data types across all datasets.**
- **[ ] No mixed types within a column (e.g., numbers and strings).**
- **[ ] All column names are syntactically valid and consistent (e.g., snake_case).**


#### 2.6. Encoding

- **[ ] All text data is encoded in UTF-8.**
- **[ ] No non-UTF-8 characters or encoding errors.**

### 3. Files to Review

**Files to Review:**
- `data/*.rda`
- `R/[package-name].R`

### 4. Example Table: Data Quality Checks

| Check | Tool/Function Example | Pass/Fail | Notes |
| :-- | :-- | :-- | :-- |
| Data files in `data/` (.rda) | `list.files("data/", "*.rda")` |  |  |
| CSV/XLSX in `inst/extdata/` | `list.files("inst/extdata/")` |  |  |
| Missing values per variable | `skimr::skim()` |  |  |
| Frequency tables for categoricals | `dplyr::count()` |  |  |
| Similar string values | `stringdist::stringdist()` |  |  |
| Date format and class | `lubridate::is.Date()` |  |  |
| Ordinal as factor | `is.ordered()` |  |  |
| Consistent data types | `dlookr::diagnose()` |  |  |
| Reasonable value ranges | `dlookr::diagnose_numeric()` |  |  |
| UTF-8 encoding | `stringi::stri_enc_isutf8()` |  |  |

### 5. Data Processing Script Review

**Checklist:**
- [ ] data_processing.R in data-raw/
- [ ] Script is reproducible and well-commented
- [ ] Raw data files preserved in data-raw/
- [ ] dictionary.csv with variable descriptions
- [ ] Uses tidyverse conventions
- [ ] Handles data cleaning transparently

**Files to Review:**
- `data-raw/data_processing.R`
- `data-raw/dictionary.csv`
- `data-raw/[raw-data-files]`

{{/if}}

{{#if issue-3}}
**Data Package Review: Documentation**

**Checklist:**
- [ ] README.Rmd follows openwashdata template:
  - Dynamic content generation
  - Installation instructions
  - Data overview with dimensions
  - Variable dictionary table
  - License and citation sections
- [ ] Roxygen documentation for all exported functions
- [ ] _pkgdown.yml configured with Plausible analytics along this template: https://raw.githubusercontent.com/openwashdata/washmalawi/refs/heads/main/_pkgdown.yml
- [ ] Package website builds without errors

**Files to Review:**
- `README.Rmd`
- `README.md`
- `_pkgdown.yml`
- `man/*.Rd`
{{/if}}

{{#if issue-4}}
**Data Package Review: Tests & CI/CD**

**Checklist:**
- [ ] GitHub Actions workflow for R-CMD-check
- [ ] Package passes `devtools::check()` with no errors/warnings
- [ ] Examples run successfully
- [ ] Data loads correctly

**Files to Review:**
- `.github/workflows/R-CMD-check.yaml`
- `tests/testthat/`
- `examples/`
{{/if}}

### Planned Changes

*[List specific changes identified for this issue]*

### Ready to Implement?

**Proceed with these changes?** (yes/no)

If yes, I'll:
1. Create/checkout the issue branch
2. Implement the planned changes
3. Test the changes
4. Prepare for pull request

### After Implementation

**GitHub CLI Commands:**
- `gh pr create --title "$ISSUE_TITLE" --body "Implements #$ISSUE_NUMBER"`
- `gh pr list` - View all pull requests
- `gh pr view [PR_NUMBER]` - View specific PR

---

## Error Handling

If invalid issue number:
❌ Invalid issue number '$ISSUE_NUMBER'. Please use a number between 1 and 4.

Available issues:
1. General Information & Metadata
2. Data Content & Processing
3. Documentation
4. Tests & CI/CD

If no review in progress:
⚠️ No package review is currently in progress.

Start a new review with: `/review-package [package-name]`

If issue already completed:
✅ Issue #$ISSUE_NUMBER is already completed.

Use `/review-status` to see current progress or select a different issue.