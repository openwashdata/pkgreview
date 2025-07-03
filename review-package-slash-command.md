# /review-package Slash Command Template

## Command: `/review-package`

**Description**: Initiates a comprehensive review of an openwashdata R data package following the PLAN → CREATE → TEST → DEPLOY workflow.

**Usage**: `/review-package [package-name]`

**Parameters**:
- `package-name` (required): Name of the R package to review (e.g., "glaas", "worldhdi")

## Implementation Template

```markdown
When the user types `/review-package [package-name]`, execute the following:

## 📋 Starting OpenWashData Package Review

**Package**: `[package-name]`
**Review Type**: Comprehensive R Data Package Review
**Workflow**: PLAN → CREATE → TEST → DEPLOY

### 🔍 PLAN Phase - Initial Analysis

I'll now analyze the `[package-name]` package structure and create a review plan.

#### Step 1: Package Structure Analysis
- [ ] Checking package directory structure
- [ ] Verifying washr template compliance
- [ ] Identifying missing components
- [ ] Analyzing data files and documentation

#### Step 2: Creating Review Issues

I'll create 5 review issues covering:

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

[Present summary of findings]

### ✅ Ready to Proceed?

The PLAN phase is complete. I've identified [X] issues that need attention.

**Would you like me to proceed to the CREATE phase?** 
- Type "yes" to continue with fixes
- Type "no" to stop here
- Type "review" to see the detailed plan again

---

## 🔧 CREATE Phase (After User Approval)

I'll now work through each issue systematically. For each issue, I'll:
1. Show you the planned changes
2. Wait for your approval
3. Implement the changes

### Working on Issue #1: General Information & Metadata

**Planned changes:**
[List specific changes]

**Proceed with these changes?** (yes/no)

[Continue pattern for each issue...]

---

## 🧪 TEST Phase

Running comprehensive package checks:
- `devtools::check()`
- `devtools::build()`
- `pkgdown::build_site()`

**Test Results:**
[Show results]

---

## 🚀 DEPLOY Phase

- [ ] Building pkgdown website
- [ ] Verifying analytics tracking
- [ ] Confirming all changes committed
- [ ] Ready for PR merge

**Package review complete!** The package is ready for publication.
```

## Additional Slash Commands

### `/review-status`
Shows current review progress and pending tasks.

```markdown
## 📊 Review Status for `[package-name]`

**Current Phase**: CREATE
**Issues Completed**: 2/5

✅ Issue #1: General Information & Metadata
✅ Issue #2: Data Content & Quality
🔄 Issue #3: Data Processing Script Review (in progress)
⏳ Issue #4: Documentation
⏳ Issue #5: Tests & CI/CD

**Next Action**: Continue with Issue #3 changes
```

### `/review-issue [number]`
Jump to a specific issue in the review process.

```markdown
## 🎯 Reviewing Issue #[number]: [Issue Title]

[Show issue details and planned changes]

**Ready to implement these changes?** (yes/no)
```

## Error Handling

If package not found:
```markdown
❌ Package '[package-name]' not found in the current directory.

Please ensure:
1. You're in the correct directory
2. The package name is spelled correctly
3. The package exists in the openwashdata organization

Try: `/review-package [correct-package-name]`
```

If already in review:
```markdown
⚠️ A review is already in progress for '[other-package]'.

Would you like to:
1. Continue the existing review: `/review-status`
2. Start a new review (this will cancel the current one): Type "new"
3. Cancel: Type "cancel"
```