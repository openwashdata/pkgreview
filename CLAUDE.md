# CLAUDE.md - OpenWashData R Package Review Guide

This guide helps Claude Code review R data packages for the openwashdata organization, ensuring consistency, quality, and completeness across all published datasets.

## Overview

The review process follows a PLAN → CREATE → TEST → DEPLOY workflow. The entire review process starts with the package on the `dev` branch, and only after ALL issues are resolved will a final PR from dev to main be created. Each phase requires explicit user approval before proceeding.

**CRITICAL WORKFLOW RULE**: Claude MUST stop after completing EACH individual issue. The user must manually restart Claude for the next issue.

## Review Workflow

### 1. PLAN Phase

When initiated via `/review-package [package-name]`, Claude will:

1. **Analyze Package Structure**
   - Verify package was created with `washr` template
   - Check for required directories: R/, data/, data-raw/, inst/extdata/, man/
   - Confirm presence of key files: DESCRIPTION, README.Rmd, _pkgdown.yml

2. **Create Review Issues** (5 GitHub issues)
   - Issue 1: General Information & Metadata
   - Issue 2: Data Content & Quality  
   - Issue 3: Data Processing Script Review
   - Issue 4: Documentation
   - Issue 5: Tests & CI/CD

3. **Present Review Plan**
   - Summary of findings
   - List of issues to be addressed
   - Request user confirmation before proceeding

### 2. CREATE Phase

After user approval, work on issues ONE AT A TIME. 

**WORKFLOW FOR EACH ISSUE:**
1. User runs `/review-issue [number]` to start work on a specific issue
2. Claude creates a new branch from `dev` for this issue
3. Claude implements all changes for this issue
4. Claude commits changes with descriptive message
5. Claude creates a PR **against the `dev` branch** (NOT main!)
6. **CLAUDE MUST STOP COMPLETELY** - Do not proceed to next issue
7. User reviews the PR, merges it to dev
8. User manually restarts Claude with `/review-issue [next-number]` for the next issue

**CRITICAL**: Claude MUST NOT automatically continue to the next issue. The workflow STOPS after creating each PR.

#### Issue 1: General Information & Metadata
- [ ] DESCRIPTION file completeness
  - Title (descriptive, <65 characters)
  - Description (clear purpose statement)
  - Authors with ORCID IDs
  - License: CC BY 4.0
  - Dependencies properly declared
  - Version follows semantic versioning
- [ ] CITATION.cff file present and valid
- [ ] Generate citation using `washr::compile_citation()`

#### Issue 2: Data Content & Quality
- [ ] Data files in data/ directory (.rda format)
- [ ] CSV/XLSX exports in inst/extdata/
- [ ] Main dataset accessible via function matching package name
- [ ] Data quality checks:
  - No unexpected missing values
  - Consistent data types
  - Reasonable value ranges
  - Proper encoding (UTF-8)

#### Issue 3: Data Processing Script Review
- [ ] data_processing.R in data-raw/
- [ ] Script is reproducible and well-commented
- [ ] Raw data files preserved in data-raw/
- [ ] dictionary.csv with variable descriptions
- [ ] Uses tidyverse conventions
- [ ] Handles data cleaning transparently
- [ ] Analysis and testing scripts preserved in analysis/ directory

#### Issue 4: Documentation
- [ ] README.Rmd follows openwashdata template:
  - Dynamic content generation
  - Installation instructions
  - Data overview with dimensions
  - Variable dictionary table
  - License and citation sections
- [ ] Roxygen documentation for all exported functions
- [ ] _pkgdown.yml configured with:
  ```yaml
  template:
    bootstrap: 5
    includes:
      in_header: |
        <script defer data-domain="openwashdata.github.io" src="https://plausible.io/js/script.js"></script>
  ```
- [ ] Package website builds without errors

#### Issue 5: Tests & CI/CD
- [ ] GitHub Actions workflow for R-CMD-check
- [ ] Package passes `devtools::check()` with no errors/warnings
- [ ] Examples run successfully
- [ ] Data loads correctly

**MANDATORY PROCESS FOR EACH ISSUE**: 
1. Present planned changes and request user confirmation before implementing
2. Create a feature branch from `dev` (e.g., `issue-1-metadata`)
3. Implement all changes for this specific issue only
4. Commit changes with message like "Fix Issue #1: Update metadata"
5. Create PR using: `gh pr create --base dev --title "Fix Issue #1: [Description]" --body "Addresses Issue #1"`
6. **STOP IMMEDIATELY** - Output: "PR created for Issue #1. Please review and merge, then run `/review-issue 2` to continue."
7. **DO NOT PROCEED** to any other issue

### 3. TEST Phase

Run comprehensive package checks:
```r
devtools::check()
devtools::build()
pkgdown::build_site()
```

Verify:
- All tests pass
- No R CMD check issues
- Documentation renders correctly
- Website builds successfully

### 4. DEPLOY Phase

1. Build and deploy pkgdown website
2. Verify Plausible analytics tracking
3. Confirm all changes are committed
4. Approve PR merge to main branch

## Key Standards

### Required Files Structure
```
package-name/
├── DESCRIPTION
├── NAMESPACE
├── R/
│   └── package-name.R
├── data/
│   └── package-name.rda
├── data-raw/
│   ├── data_processing.R
│   └── dictionary.csv
├── inst/
│   ├── CITATION
│   └── extdata/
│       ├── package-name.csv
│       └── package-name.xlsx
├── man/
├── vignettes/                # Optional vignettes directory
│   └── articles/             # Always use articles/ subdirectory
│       └── example.Rmd       # Keep all vignettes here
├── analysis/                 # Analysis and testing scripts (not built)
│   ├── test_package.R
│   ├── data_analysis.R
│   └── validation.R
├── README.Rmd
├── README.md
├── CITATION.cff
├── _pkgdown.yml
├── .Rbuildignore
└── .github/
    └── workflows/
        └── R-CMD-check.yaml
```

### Vignettes Convention

**IMPORTANT**: All vignettes must be stored in the `vignettes/articles/` subdirectory, not directly in `vignettes/`. This convention:
- Ensures vignettes are rendered correctly by pkgdown
- Keeps vignettes separate from package documentation
- Prevents CRAN submission issues
- Maintains consistency across openwashdata packages

Example structure:
```
vignettes/
└── articles/
    ├── getting-started.Rmd
    ├── data-analysis.Rmd
    └── case-study.Rmd
```

### R Scripts for Reproducibility

All R scripts used for testing, validation, and analysis during package development must be preserved in the repository for reproducibility purposes. These scripts should be stored in the `analysis/` directory at the package root level.

#### Why `analysis/` directory:
- **Not included** in the installed package (automatically ignored by R CMD build)
- **Available** on GitHub for future reference and reproducibility
- **Organized** separately from package code
- **No configuration needed** - R automatically excludes top-level directories not recognized as package components

#### Script Organization in `analysis/`:
- `test_package.R` - Scripts for testing package functionality
- `data_analysis.R` - Exploratory data analysis scripts  
- `validation.R` - Data validation and quality checks
- `comparison.R` - Scripts comparing different data versions
- Any other analysis or utility scripts used during development

This approach ensures all analysis work remains transparent and reproducible without affecting package installation or CRAN compliance.

### Package Dependencies
Common dependencies for data packages:
- dplyr, tidyr (data manipulation)
- readr, readxl (data import)
- janitor (data cleaning)
- desc (DESCRIPTION parsing)
- gt, kableExtra (table formatting)

### Quality Criteria
1. **Reproducibility**: All data processing steps documented and runnable
2. **Transparency**: Raw data preserved with clear transformation pipeline
3. **Accessibility**: Multiple export formats (R, CSV, XLSX)
4. **Documentation**: Comprehensive variable descriptions and usage examples
5. **Consistency**: Follows openwashdata naming and structure conventions

## Branch and PR Strategy

**Package Review Branch Structure:**
- `main` - Production branch (protected)
- `dev` - Development branch where all review work happens
- `issue-[n]-description` - Feature branches for each issue (created from dev)

**PR Flow:**
1. Each issue gets its own PR from feature branch → dev
2. User reviews and merges each issue PR to dev
3. After ALL issues are resolved, create final PR from dev → main
4. Never create PRs directly to main during the review process

## Commands

- `/review-package [package-name]` - Start package review (analyzes package and creates issues)
- `/review-status` - Check current review progress
- `/review-issue [number]` - Work on specific issue (STOPS after creating PR)
- `/review-complete` - After all issues merged to dev, create final PR to main

## Issue Resolution Workflow

When working on each issue via `/review-issue [number]`:

1. **Branch** - Create feature branch from dev: `git checkout -b issue-[number]-description`
2. **Analyze** - Review the specific issue requirements
3. **Implement** - Make ONLY the changes required for this issue
4. **Test** - Verify changes work correctly
5. **Commit** - Create descriptive commit: `git commit -m "Fix Issue #[number]: [description]"`
6. **Push** - Push branch: `git push -u origin issue-[number]-description`
7. **Create PR** - ALWAYS against dev: `gh pr create --base dev --title "Fix Issue #[number]: [description]" --body "Addresses Issue #[number]"`
8. **STOP COMPLETELY** - Output final message and cease all activity

**CRITICAL STOPPING BEHAVIOR**:
- After creating the PR, Claude MUST output: "✅ PR created for Issue #[number]. Please review and merge to dev, then run `/review-issue [next-number]` to continue with the next issue."
- Claude MUST NOT continue with any other tasks
- Claude MUST NOT suggest next steps
- Claude MUST NOT start working on the next issue
- The conversation effectively ends until the user explicitly restarts with `/review-issue [next-number]`

## Example Issue-by-Issue Workflow

```
User: /review-issue 1
Claude: [Creates branch issue-1-metadata]
        [Makes changes to DESCRIPTION, CITATION.cff]
        [Commits and pushes]
        [Creates PR to dev]
        "✅ PR created for Issue #1. Please review and merge to dev, then run `/review-issue 2` to continue with the next issue."
        [STOPS COMPLETELY]

[User reviews PR #1, merges to dev]

User: /review-issue 2
Claude: [Creates branch issue-2-data-quality from updated dev]
        [Checks data files, runs quality checks]
        [Commits and pushes]
        [Creates PR to dev]
        "✅ PR created for Issue #2. Please review and merge to dev, then run `/review-issue 3` to continue with the next issue."
        [STOPS COMPLETELY]

[Repeat for all 5 issues]

User: /review-complete
Claude: [Creates final PR from dev to main]
        "✅ All issues resolved. Final PR created from dev to main for package review completion."
```

## Important Notes

- Always request user confirmation between phases
- Check in with user before implementing changes in CREATE phase
- Preserve existing git history and commits
- Follow tidyverse style guide for R code
- Use semantic versioning for package versions

## Project Management with GitHub CLI

- List issues: `gh issue list`
- View issue details: `gh issue view 80` (e.g., for issue #80 "Rename geographies parameter")
- Create branch for issue: `gh issue develop 80`
- Checkout branch: `git checkout 80-rename-geographies-parameter-to-entities`
- Create pull request: `gh pr create --title "Rename geographies parameter to entities" --body "Implements #80"`
- List pull requests: `gh pr list`
- View pull request: `gh pr view PR_NUMBER`

## Build/Test/Check Commands

- Build package: `R CMD build .`
- Install package: `R CMD INSTALL .`
- Run all tests: `R -e "devtools::test()"`
- Run single test: `R -e "devtools::test_file('tests/testthat/test-FILE_NAME.R', reporter = 'progress')"`
- Run R CMD check: `R -e "devtools::check()"`
- Build Roxygen2 documentation: `R -e "devtools::document()"`
- Build vignettes: `R -e "devtools::build_vignettes()"`
- Build README.md from README.Rmd: `R -e "devtools::build_readme()"`

## Code Style Guidelines

- Use 2 spaces for indentation (no tabs)
- Maximum 80 characters per line
- Use tidyverse style for R code (`dplyr`, `tidyr`, `purrr`)
- Use snake_case for function and variable names

