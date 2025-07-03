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

2. **Create Review Issues** (5 GitHub issues with checklists)
   - Issue 1: General Information & Metadata (with checklist)
   - Issue 2: Data Content & Quality (with checklist)
   - Issue 3: Data Processing Script Review (with checklist)
   - Issue 4: Documentation (with checklist)
   - Issue 5: Tests & CI/CD (with checklist)
   
   Each issue must be created with a checklist that Claude will update as items are completed.

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

**Claude must check off items as completed and update the issue**

- [ ] DESCRIPTION file completeness
  - Title (descriptive, <65 characters)
  - Description (clear purpose statement)
  - Authors with ORCID IDs
  - License: CC BY 4.0
  - Dependencies properly declared
  - Version follows semantic versioning
- [ ] CITATION.cff file present and valid
- [ ] Generate citation using `washr::update_citation()`

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
- [ ] _pkgdown.yml configured with standard openwashdata template
- [ ] Package website builds without errors

#### Issue 5: Tests & CI/CD
- [ ] GitHub Actions workflow for R-CMD-check
- [ ] Package passes `devtools::check()` with no errors/warnings
- [ ] Examples run successfully
- [ ] Data loads correctly

**MANDATORY PROCESS FOR EACH ISSUE**: 
1. Present planned changes and request user confirmation before implementing
2. Create a feature branch from `dev` (e.g., `issue-1-metadata`)
3. Implement changes with regular check-ins:
   - **For each checklist item or major change:**
     - Announce the specific change
     - Implement it
     - Show the result
     - **CHECK-IN**: "Ready to commit this change? (commit/continue)"
     - If "commit": Create atomic commit for this change
4. Run tests after all changes
5. Update the GitHub issue to check off completed items:
   - Use `gh issue view [number]` to get current issue body
   - Update checkboxes from `- [ ]` to `- [x]` for completed items
   - Use `gh issue edit [number] --body "[updated body]"` to save
6. Create PR with detailed summary including all commits:
   ```
   gh pr create --base dev --title "Fix Issue #1: [Description]" \
   --body "## Summary
   Addresses Issue #[number]
   
   ## Changes Made
   - [Specific changes]
   
   ## Completed Checklist Items
   - [x] Item 1
   - [x] Item 2
   
   Closes #[number]"
   ```
7. **STOP IMMEDIATELY** - Output: "✅ PR created for Issue #1. Issue checklist updated. Please review and merge, then run `/review-issue 2` to continue."
8. **DO NOT PROCEED** to any other issue

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
5. Create release using `/create-release` command

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
├── NEWS.md                   # Package changelog
├── CITATION.cff
├── _pkgdown.yml              # Standard openwashdata configuration
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
- usethis (development workflows, including NEWS.md and versioning)

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
- `/create-release [version]` - Create a new release with changelog

## Issue Resolution Workflow

When working on each issue via `/review-issue [number]`:

1. **Branch** - Create feature branch from dev: `git checkout -b issue-[number]-description`

2. **Analyze** - Review the specific issue requirements and checklist items
   - Present analysis of what needs to be done
   - **CHECK-IN #1**: "Here's what I found. Should I proceed with these changes? (yes/no)"

3. **Implement Changes in Stages**
   - For each major change or checklist item:
     a. Announce what you're about to do
     b. Make the change
     c. Show the result
     d. **CHECK-IN**: "Change completed. Ready to commit? Type 'commit' to save this change, or 'continue' to make more changes."
     e. If user says "commit": Run `git add -A && git commit -m "Description of this specific change"`
   - Repeat for each significant change

4. **Test** - After all changes, verify everything works
   - Run relevant tests (devtools::check(), build_readme(), etc.)
   - **CHECK-IN**: "All tests passed. Ready to finalize? (yes/no)"

5. **Update Issue** - Check off completed items in the issue checklist
   - Use `gh issue view [number]` to get current issue body
   - Update checkboxes from `- [ ]` to `- [x]` for completed items
   - Use `gh issue edit [number] --body "[updated body]"` to save
   - **CHECK-IN**: "Issue checklist updated. Ready to create PR? (yes/no)"

6. **Final Commit** (if any uncommitted changes)
   - `git add -A && git commit -m "Final updates for Issue #[number]"`

7. **Push** - Push branch: `git push -u origin issue-[number]-description`

8. **Create PR** - ALWAYS against dev with detailed body:
   ```
   gh pr create --base dev --title "Fix Issue #[number]: [description]" --body "## Summary
   Addresses Issue #[number]
   
   ## Changes Made
   - [List specific changes made]
   - [Include which checklist items were completed]
   
   ## Commits in this PR
   - [List each commit message]
   
   ## Checklist
   - [x] Item 1 completed
   - [x] Item 2 completed
   - [ ] Item 3 (if not completed, explain why)
   
   Closes #[number]"
   ```

9. **STOP COMPLETELY** - Output final message and cease all activity

**CRITICAL STOPPING BEHAVIOR**:
- After creating the PR, Claude MUST output: "✅ PR created for Issue #[number]. Please review and merge to dev, then run `/review-issue [next-number]` to continue with the next issue."
- Claude MUST NOT continue with any other tasks
- Claude MUST NOT suggest next steps
- Claude MUST NOT start working on the next issue
- The conversation effectively ends until the user explicitly restarts with `/review-issue [next-number]`

## Check-In Points and Commit Strategy

**Claude MUST pause at these check-in points:**

1. **Initial Analysis Check-In**
   - After analyzing the issue requirements
   - Before making any changes
   - Ask: "Here's what I plan to do: [list]. Should I proceed? (yes/no)"

2. **Per-Change Check-Ins**
   - After EACH significant change (e.g., each checklist item)
   - Show what was changed
   - Ask: "Ready to commit this change? (commit/continue)"
   - If "commit": Create atomic commit with descriptive message

3. **Test Results Check-In**
   - After running tests
   - Show test results
   - Ask: "All tests passed. Ready to finalize? (yes/no)"

4. **Pre-PR Check-In**
   - After updating issue checkboxes
   - Before creating PR
   - Ask: "Issue updated. Ready to create PR? (yes/no)"

**Commit Guidelines:**
- Each commit should be atomic (one logical change)
- Use descriptive commit messages
- Multiple small commits are preferred over one large commit
- Example messages:
  - "Update DESCRIPTION title and description"
  - "Add ORCID IDs to authors"
  - "Configure CC BY 4.0 license"
  - "Update CITATION with washr::update_citation()"

## Example Issue-by-Issue Workflow

```
User: /review-issue 1
Claude: [Creates branch issue-1-metadata]
        "I'll work on Issue #1: General Information & Metadata. Here's what needs to be done:
        - Update DESCRIPTION file
        - Fix CITATION.cff
        - Generate citation with washr
        
        Should I proceed? (yes/no)"
        
User: yes
Claude: "Starting with DESCRIPTION file updates..."
        [Shows DESCRIPTION changes]
        "✅ DESCRIPTION updated. Ready to commit? (commit/continue)"
        
User: commit
Claude: [Commits: "Update DESCRIPTION file metadata"]
        "Now working on CITATION.cff..."
        [Shows CITATION.cff changes]
        "✅ CITATION.cff created. Ready to commit? (commit/continue)"
        
User: commit
Claude: [Commits: "Add CITATION.cff file"]
        "Running washr::update_citation()..."
        [Shows result]
        "✅ Citation updated. Ready to commit? (commit/continue)"
        
User: commit
Claude: [Commits: "Update CITATION with washr"]
        [Updates Issue #1 checkboxes]
        [Creates PR with 3 commits listed]
        "✅ PR created for Issue #1 with 3 commits. Issue checklist updated. Please review and merge to dev, then run `/review-issue 2` to continue."
        [STOPS COMPLETELY]

[Repeat for all 5 issues]

User: /review-complete
Claude: [Creates final PR from dev to main]
        "✅ All issues resolved. Final PR created from dev to main for package review completion."

[After PR merged to main]

User: /create-release 0.1.0
Claude: [Updates version, creates NEWS.md entry, tags release]
        "✅ Release v0.1.0 created with changelog. Package published!"
```

## Release Management

### Creating a Release with `/create-release [version]`

When creating a release, Claude will:

1. **Pre-Release Zenodo Check**
   - **PAUSE**: Ask user "Before proceeding, please ensure the repository is enabled/synced on Zenodo. Is Zenodo integration enabled for this repo? (yes/no)"
   - If no: Direct user to enable at https://zenodo.org/account/settings/github/

2. **Update Version**
   - Use `usethis::use_version()` to bump version in DESCRIPTION
   - Follow semantic versioning (major.minor.patch)

3. **Initial Citation Update**
   - Update version field to match new version
   - Update date-released to current date
   - Run `washr::update_citation()` to sync all citation files
   - Verify version consistency across DESCRIPTION, CITATION, and CITATION.cff

4. **Update NEWS.md**
   - Use `usethis::use_news_md()` if NEWS.md doesn't exist
   - Add new version section with release date
   - Include summary of changes from recent commits/PRs
   - Format following tidyverse NEWS conventions:
   ```markdown
   # packagename 0.1.0

   * Initial release to GitHub
   * Added core functionality for X (#1)
   * Fixed issue with Y (#2)
   * Enhanced documentation (#3)
   ```

5. **Commit Changes**
   - Commit with message: "Release version [version]"
   - Include updates to DESCRIPTION, CITATION.cff, and NEWS.md
   - Push to main branch

6. **Create GitHub Release**
   - Use `gh release create v[version]`
   - Include NEWS.md content as release notes
   - Tag the release commit
   - **Zenodo automatically generates DOI after this step**

7. **Post-Release DOI Update**
   - **PAUSE**: Ask user "GitHub release created! Please check Zenodo for the generated DOI and provide it (format: 10.5281/zenodo.XXXXXXX):"
   - Add Zenodo badge to README.Rmd: `[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)`
   - Run `washr::update_citation(doi = "10.5281/zenodo.XXXXXXX")` with provided DOI
   - Update all citation files to include DOI
   - Commit with message: "Add Zenodo DOI to package"
   - Push DOI updates to main

8. **Update pkgdown Site**
   - Rebuild site to include new version and DOI badge
   - Deploy updated documentation

### NEWS.md Format Guidelines

- Each version gets its own section with version number and date
- Use bullet points for changes
- Reference issue/PR numbers in parentheses
- Group changes by type (new features, bug fixes, etc.)
- Most recent version at the top
- Follow tidyverse style guide for NEWS files

Example NEWS.md structure:
```markdown
# washrkenya 0.2.0 (2024-01-15)

## New features
* Added support for temporal analysis (#12)
* New vignette on data visualization (#15)

## Bug fixes
* Fixed encoding issues in region names (#10)
* Corrected data type for population column (#11)

# washrkenya 0.1.0 (2023-12-01)

* Initial release
* Basic data access functions
* Documentation and examples
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

## Standard _pkgdown.yml Configuration

All openwashdata packages must use the following standard _pkgdown.yml configuration (replace `packagename` with actual package name):

```yaml
url: https://github.com/openwashdata/packagename
template:
  bootstrap: 5
  includes:
    in_header: |
      <script defer data-domain="openwashdata.github.io" src="https://plausible.io/js/script.js"></script>

home:
  links:
    - icon: github
      text: GitHub repository
      href: https://github.com/openwashdata/packagename
  sidebar:
    structure: [links, citation, authors, dev, custom]
    components:
      custom:
        title: Funding
        text: This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).

authors:
  footer:
    roles: [cre, fnd]
    text: "Crafted by"
  sidebar:
    roles: [cre, aut, ctb]
    before: "So *who* does the work?"
    after: "Thanks all!"

reference:
- title: "Data"
  desc: "Access the packagename dataset"
  contents:
  - packagename
```

**Key elements:**
- URL must point to the correct GitHub repository
- Bootstrap 5 theme required
- Plausible analytics script in header
- Consistent sidebar structure with funding acknowledgment
- Standard author role display
- Reference section for data access function

## Code Style Guidelines

- Use 2 spaces for indentation (no tabs)
- Maximum 80 characters per line
- Use tidyverse style for R code (`dplyr`, `tidyr`, `purrr`)
- Use snake_case for function and variable names

