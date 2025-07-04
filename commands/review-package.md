# review-package

**Description**: Initiates a comprehensive review of an openwashdata R data package following the PLAN → CREATE → TEST → DEPLOY workflow.

**Usage**: `/review-package [package-name]`

**Parameters**:
- `package-name` (optional): Name of the R package to review. If not provided, uses current directory name.

---

When the user types `/review-package [package-name]`, execute the following:

First, determine the package name and setup:
```bash
# Get package name from parameter or use current directory name
if [ -n "$1" ]; then
    PACKAGE_NAME="$1"
else
    PACKAGE_NAME=$(basename "$PWD")
fi
echo "Package name: $PACKAGE_NAME"
```

#### Step 0: Setup CLAUDE.md for Package Review

I'll download the latest CLAUDE.md file from the openwashdata review repository:

```bash
# Check if CLAUDE.md already exists in the working directory
if [ -f "CLAUDE.md" ]; then
    echo "📋 Existing CLAUDE.md found. Appending openwashdata review guide..."
    # Create a backup of the existing file
    cp CLAUDE.md CLAUDE.md.backup
    
    # Download the review guide to a temporary file
    if curl -s -f -o CLAUDE_review.tmp https://raw.githubusercontent.com/openwashdata/pkgreview/main/CLAUDE.md; then
        echo "" >> CLAUDE.md
        echo "# --- APPENDED FROM openwashdata/pkgreview ---" >> CLAUDE.md
        echo "" >> CLAUDE.md
        cat CLAUDE_review.tmp >> CLAUDE.md
        rm CLAUDE_review.tmp
        echo "✅ OpenWashData review guide appended to existing CLAUDE.md"
    else
        echo "⚠️ Failed to download CLAUDE.md from GitHub repository"
        echo "📋 Continuing review with existing CLAUDE.md file"
    fi
else
    # No existing CLAUDE.md, download directly
    if curl -s -f -o CLAUDE.md https://raw.githubusercontent.com/openwashdata/pkgreview/main/CLAUDE.md; then
        echo "✅ CLAUDE.md downloaded successfully"
    else
        echo "⚠️ Failed to download CLAUDE.md from GitHub repository"
        echo "📋 Continuing review without local CLAUDE.md file"
    fi
fi
```

**Note**: If a CLAUDE.md file already exists in your working directory, the review guide content will be appended to preserve your existing instructions.

**What CLAUDE.md provides:**
- Complete review workflow (PLAN → CREATE → TEST → DEPLOY)
- 4-issue structure with detailed checklists
- GitHub CLI commands for project management
- Build/test/check commands for R packages
- Code style guidelines and standards
- Package structure requirements
- Quality criteria and best practices

## 📋 Starting OpenWashData Package Review

**Package**: `${PACKAGE_NAME}`
**Review Type**: Comprehensive R Data Package Review
**Workflow**: PLAN → CREATE → TEST → DEPLOY

### 🔍 PLAN Phase - Initial Analysis

I'll now analyze the `${PACKAGE_NAME}` package structure and create a review plan.

#### Step 1: Check for Existing PRs and Branches

First, I'll check if there are any open pull requests or dev branches:

```bash
# Check current branch
git branch --show-current

# List all branches
git branch -a

# Check for open pull requests
gh pr list --state open

# Check for draft pull requests
gh pr list --state open --draft

# Check if on dev branch or if dev branch exists
if git show-ref --verify --quiet refs/heads/dev; then
    echo "📌 Dev branch exists"
    git log --oneline -n 5 dev
fi
```

#### Step 2: Package Structure Analysis
- [ ] Checking package directory structure
- [ ] Verifying washr template compliance
- [ ] Identifying missing components
- [ ] Analyzing data files and documentation
- [ ] Reviewing any existing PRs or dev branch changes

#### Step 3: Creating First Review Issue

I'll create the first GitHub issue to begin the review process:

```bash
# Create Issue 1: General Information & Metadata
gh issue create \
  --title "Data Package Review: General Information & Metadata" \
  --body "## Review Checklist

This is the first step in the openwashdata package review process.

### Tasks
- [ ] DESCRIPTION file completeness
  - [ ] Title (descriptive, <65 characters)
  - [ ] Description (clear purpose statement)
  - [ ] Authors with ORCID IDs
  - [ ] License: CC BY 4.0
  - [ ] Dependencies properly declared
  - [ ] Version follows semantic versioning
- [ ] CITATION.cff file present and valid
- [ ] Generate citation using \`washr::update_citation()\`

### Files to Review
- \`DESCRIPTION\`
- \`CITATION.cff\`
- \`inst/CITATION\`

### Next Steps
1. Run \`/review-issue 1\` to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, the next issue will be created automatically"
```

**Note**: The review follows a sequential process:
1. **Issue 1**: General Information & Metadata
2. **Issue 2**: Data Content & Processing (created after Issue 1 PR is merged)
3. **Issue 3**: Documentation (created after Issue 2 PR is merged)
4. **Issue 4**: Tests & CI/CD (created after Issue 3 PR is merged)

### 📊 Initial Findings

*[Present summary of findings]*

### ✅ Ready to Proceed?

The PLAN phase is complete. I've created the first review issue.

**Next steps:**
1. Run `/review-issue 1` to start working on Issue #1
2. Complete the changes and create a PR to `dev`
3. After merging, run `/create-next-issue` to create Issue #2

**Note**: Each issue builds on the previous one, ensuring that changes are cumulative throughout the review process.

---

## 📝 Review Workflow Summary

This package review follows a sequential, issue-by-issue approach:

1. **Start**: Run `/review-package` to analyze the package and create Issue #1
2. **Work**: Use `/review-issue [number]` to work on the current issue
3. **Submit**: Create a PR to the `dev` branch for each issue
4. **Continue**: After merging, run `/create-next-issue` to create the next issue

This ensures that:
- Each issue builds on the changes from previous issues
- The `dev` branch stays up-to-date throughout the review
- Changes are reviewed and merged incrementally
- The final PR from `dev` to `main` contains all cumulative improvements

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

If CLAUDE.md download fails:
⚠️ Failed to download CLAUDE.md from GitHub repository.

**Fallback options:**
1. Use cached version if available
2. Manual download: `curl -o CLAUDE.md https://raw.githubusercontent.com/openwashdata/pkgreview/main/CLAUDE.md`
3. Copy from local pkgreview repository: `cp /path/to/pkgreview/CLAUDE.md .`
4. Continue review without local CLAUDE.md file

If package not found:
❌ Package '${PACKAGE_NAME}' not found in the current directory.

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