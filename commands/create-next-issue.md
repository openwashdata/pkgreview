# create-next-issue

**Description**: Creates the next issue in the openwashdata package review sequence after the previous issue's PR has been merged to dev.

**Usage**: `/create-next-issue`

**Parameters**: None

---

When the user types `/create-next-issue`, execute the following:

## 🔄 Creating Next Review Issue

First, check the current review status:

```bash
# Get package name
PACKAGE_NAME=$(basename "$PWD")

# Check which issues already exist
echo "Checking existing issues..."
gh issue list --state all --limit 10
```

### Determine Next Issue

Based on the existing issues, I'll create the next one in sequence:

{{#if create-issue-2}}
```bash
# Create Issue 2: Data Content & Processing
gh issue create \
  --title "Data Package Review: Data Content & Processing" \
  --body "## Review Checklist

This is the second step in the openwashdata package review process.

### Prerequisites
- [x] Issue #1 (General Information & Metadata) has been completed and merged to dev

### Tasks

#### File Structure
- [ ] All primary data files are present in \`data/\` and use \`.rda\` format
- [ ] All raw or exportable data files (CSV/XLSX) are in \`inst/extdata/\`
- [ ] No sensitive or personally identifiable information is present

#### Data Quality Checks
- [ ] Missing values properly coded as \`NA\`
- [ ] Categorical variables checked for consistency
- [ ] Date variables in proper format
- [ ] Numeric variables have reasonable ranges
- [ ] All text data encoded in UTF-8

#### Data Processing Script
- [ ] data_processing.R in data-raw/
- [ ] Script is reproducible and well-commented
- [ ] Raw data files preserved
- [ ] dictionary.csv with variable descriptions

### Files to Review
- \`data/*.rda\`
- \`data-raw/data_processing.R\`
- \`data-raw/dictionary.csv\`
- \`inst/extdata/*\`

### Next Steps
1. Run \`/review-issue 2\` to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/create-next-issue\` to create Issue #3"
```
{{/if}}

{{#if create-issue-3}}
```bash
# Create Issue 3: Documentation
gh issue create \
  --title "Data Package Review: Documentation" \
  --body "## Review Checklist

This is the third step in the openwashdata package review process.

### Prerequisites
- [x] Issue #1 (General Information & Metadata) has been completed
- [x] Issue #2 (Data Content & Processing) has been completed

### Tasks
- [ ] README.Rmd follows openwashdata template
- [ ] Dynamic content generation works
- [ ] Installation instructions present
- [ ] Data overview with dimensions
- [ ] Variable dictionary table rendered
- [ ] License and citation sections complete
- [ ] Roxygen documentation for all exported functions
- [ ] _pkgdown.yml configured with Plausible analytics
- [ ] Package website builds without errors

### Files to Review
- \`README.Rmd\`
- \`_pkgdown.yml\`
- \`man/*.Rd\`

### Next Steps
1. Run \`/review-issue 3\` to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/create-next-issue\` to create Issue #4"
```
{{/if}}

{{#if create-issue-4}}
```bash
# Create Issue 4: Tests & CI/CD
gh issue create \
  --title "Data Package Review: Tests & CI/CD" \
  --body "## Review Checklist

This is the final step in the openwashdata package review process.

### Prerequisites
- [x] Issue #1 (General Information & Metadata) has been completed
- [x] Issue #2 (Data Content & Processing) has been completed
- [x] Issue #3 (Documentation) has been completed

### Tasks
- [ ] Add GitHub Actions workflow for R-CMD-check
- [ ] Add R-CMD-check badge to README.Rmd
- [ ] Package passes \`devtools::check()\` with no errors/warnings
- [ ] Examples run successfully
- [ ] Data loads correctly

### Files to Create/Review
- \`.github/workflows/R-CMD-check.yaml\` (to be created)
- \`README.Rmd\` (add badge)
- Run comprehensive checks

### Next Steps
1. Run \`/review-issue 4\` to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/review-complete\` to create final PR from dev to main"
```
{{/if}}

### ✅ Issue Created!

The next issue in the review sequence has been created.

**What to do next:**
1. Make sure the previous PR has been merged to `dev`
2. Pull the latest changes: `git checkout dev && git pull`
3. Run `/review-issue [number]` to start working on the new issue

---

## Error Handling

If all issues already exist:
✅ All 4 review issues have been created!

Use `/review-status` to check the current progress or `/review-complete` if all issues are resolved.

If previous issue not completed:
⚠️ Issue #[X] appears to still be open. Please complete and merge its PR before creating the next issue.

Use `/review-issue [X]` to continue working on the current issue.