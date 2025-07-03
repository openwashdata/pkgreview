# review-issue

**Description**: Jump to a specific issue in the openwashdata package review process and work on it systematically.

**Usage**: `/review-issue [number]`

**Parameters**:
- `number` (required): Issue number (1-5) to work on

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
**Issue #1: General Information & Metadata**

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
**Issue #2: Data Content & Quality**

**Checklist:**
- [ ] Data files in data/ directory (.rda format)
- [ ] CSV/XLSX exports in inst/extdata/
- [ ] Main dataset accessible via function matching package name
- [ ] Data quality checks:
  - No unexpected missing values
  - Consistent data types
  - Reasonable value ranges
  - Proper encoding (UTF-8)

**Files to Review:**
- `data/*.rda`
- `inst/extdata/*.csv`
- `inst/extdata/*.xlsx`
- `R/[package-name].R`
{{/if}}

{{#if issue-3}}
**Issue #3: Data Processing Script Review**

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

{{#if issue-4}}
**Issue #4: Documentation**

**Checklist:**
- [ ] README.Rmd follows openwashdata template:
  - Dynamic content generation
  - Installation instructions
  - Data overview with dimensions
  - Variable dictionary table
  - License and citation sections
- [ ] Roxygen documentation for all exported functions
- [ ] _pkgdown.yml configured with Plausible analytics
- [ ] Package website builds without errors

**Files to Review:**
- `README.Rmd`
- `README.md`
- `_pkgdown.yml`
- `man/*.Rd`
{{/if}}

{{#if issue-5}}
**Issue #5: Tests & CI/CD**

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
❌ Invalid issue number '$ISSUE_NUMBER'. Please use a number between 1 and 5.

Available issues:
1. General Information & Metadata
2. Data Content & Quality
3. Data Processing Script Review
4. Documentation
5. Tests & CI/CD

If no review in progress:
⚠️ No package review is currently in progress.

Start a new review with: `/review-package [package-name]`

If issue already completed:
✅ Issue #$ISSUE_NUMBER is already completed.

Use `/review-status` to see current progress or select a different issue.