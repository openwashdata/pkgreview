# review-package

**Description**: Initiates a comprehensive review of an openwashdata R data package following the PLAN → CREATE → TEST → DEPLOY workflow.

**Usage**: `/review-package [package-name]`

**Parameters**:
- `package-name` (optional): Name of the R package to review. If not provided, uses current directory name.

---

When the user types `/review-package [package-name]`, execute the following:

First, determine the package name:
```bash
PACKAGE_NAME=${1:-$(basename "$PWD")}
```

## 📋 Starting OpenWashData Package Review

**Package**: `$PACKAGE_NAME`
**Review Type**: Comprehensive R Data Package Review
**Workflow**: PLAN → CREATE → TEST → DEPLOY

### 🔍 PLAN Phase - Initial Analysis

I'll now analyze the `$PACKAGE_NAME` package structure and create a review plan.

#### Step 1: Package Structure Analysis
- [ ] Checking package directory structure
- [ ] Verifying washr template compliance
- [ ] Identifying missing components
- [ ] Analyzing data files and documentation

#### Step 2: Creating Review Issues

I'll create 5 GitHub issues using `gh issue create` covering:

**Issue #1: General Information & Metadata**
- DESCRIPTION file review
- Authors and ORCID IDs
- License verification (CC BY 4.0)
- Citation files (CITATION.cff, inst/CITATION)

**Issue #2: Data Content & Quality**
- Data file formats and locations
- Data integrity checks
- Variable completeness
- Export formats availability

**Issue #3: Data Processing Script Review**
- data_processing.R reproducibility
- Code quality and documentation
- Dictionary completeness
- Raw data preservation

**Issue #4: Documentation**
- README.Rmd structure and content
- Function documentation
- _pkgdown.yml configuration
- Variable dictionary

**Issue #5: Tests & CI/CD**
- R-CMD-check workflow
- Package checks status
- Example code execution
- Build process

### 📊 Initial Findings

*[Present summary of findings]*

### ✅ Ready to Proceed?

The PLAN phase is complete. I've identified [X] issues that need attention.

**Would you like me to proceed to the CREATE phase?** 
- Type "yes" to continue with fixes
- Type "no" to stop here
- Type "review" to see the detailed plan again

---

## 🔧 CREATE Phase (After User Approval)

I'll now work through each issue systematically using GitHub CLI workflow:

### Working on Issue #1: General Information & Metadata

**GitHub CLI Commands:**
- `gh issue view 1` - View issue details
- `gh issue develop 1` - Create branch for issue
- `git checkout 1-general-information-metadata`

**Planned changes:**
*[List specific changes]*

**Proceed with these changes?** (yes/no)

After implementation:
- `gh pr create --title "Fix general information & metadata" --body "Implements #1"`

*[Continue pattern for each issue...]*

---

## 🧪 TEST Phase

Running comprehensive package checks using commands from CLAUDE.md:
- `R -e "devtools::check()"` - Run R CMD check
- `R CMD build .` - Build package
- `R -e "pkgdown::build_site()"` - Build website
- `R -e "devtools::test()"` - Run all tests

**Test Results:**
*[Show results]*

---

## 🚀 DEPLOY Phase

- [ ] Building pkgdown website
- [ ] Verifying analytics tracking
- [ ] Confirming all changes committed
- [ ] Ready for PR merge

**Package review complete!** The package is ready for publication.

---

## Error Handling

If package not found:
❌ Package '$PACKAGE_NAME' not found in the current directory.

Please ensure:
1. You're in the correct directory containing the R package
2. The package has a valid DESCRIPTION file
3. The package follows openwashdata structure

Try: `/review-package [correct-package-name]` or navigate to the correct directory

If already in review:
⚠️ A review is already in progress for '[other-package]'.

Would you like to:
1. Continue the existing review: `/review-status`
2. Start a new review (this will cancel the current one): Type "new"
3. Cancel: Type "cancel"