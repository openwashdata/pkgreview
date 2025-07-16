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

# Check which review issues already exist by label
echo "Checking existing review issues..."
METADATA_ISSUE=$(gh issue list --label "pkgreview-metadata" --json number,state --jq '.[0].number // empty')
DATA_ISSUE=$(gh issue list --label "pkgreview-data" --json number,state --jq '.[0].number // empty')
DOCS_ISSUE=$(gh issue list --label "pkgreview-docs" --json number,state --jq '.[0].number // empty')
TESTS_ISSUE=$(gh issue list --label "pkgreview-tests" --json number,state --jq '.[0].number // empty')

echo "Review Issues Status:"
if [ -n "$METADATA_ISSUE" ]; then echo "✓ Metadata Issue: #$METADATA_ISSUE"; else echo "○ Metadata Issue: Not created"; fi
if [ -n "$DATA_ISSUE" ]; then echo "✓ Data Issue: #$DATA_ISSUE"; else echo "○ Data Issue: Not created"; fi
if [ -n "$DOCS_ISSUE" ]; then echo "✓ Documentation Issue: #$DOCS_ISSUE"; else echo "○ Documentation Issue: Not created"; fi
if [ -n "$TESTS_ISSUE" ]; then echo "✓ Tests Issue: #$TESTS_ISSUE"; else echo "○ Tests Issue: Not created"; fi
```

### Determine Next Issue

Based on the existing issues, I'll create the next one in sequence:

{{#if create-issue-2}}
```bash
# Create Issue 2: Data Content & Processing
ISSUE_OUTPUT=$(gh issue create \
  --title "Data Package Review: Data Content & Processing" \
  --label "pkgreview-data" \
  --body "## Review Checklist

This is the second step in the openwashdata package review process.

### Prerequisites
- [x] Metadata review (Issue #$METADATA_ISSUE) has been completed and merged to dev

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
1. Use the actual issue number shown above to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/create-next-issue\` to create the Documentation issue")

# Extract the issue number
ISSUE_NUMBER=$(echo "$ISSUE_OUTPUT" | grep -oE '[0-9]+$')
echo "\nCreated Data Content & Processing Issue #$ISSUE_NUMBER"
```
{{/if}}

{{#if create-issue-3}}
```bash
# Create Issue 3: Documentation
ISSUE_OUTPUT=$(gh issue create \
  --title "Data Package Review: Documentation" \
  --label "pkgreview-docs" \
  --body "## Review Checklist

This is the third step in the openwashdata package review process.

### Prerequisites
- [x] Metadata review (Issue #$METADATA_ISSUE) has been completed
- [x] Data review (Issue #$DATA_ISSUE) has been completed

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
1. Use the actual issue number shown above to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/create-next-issue\` to create the Tests & CI/CD issue")

# Extract the issue number
ISSUE_NUMBER=$(echo "$ISSUE_OUTPUT" | grep -oE '[0-9]+$')
echo "\nCreated Documentation Issue #$ISSUE_NUMBER"
```
{{/if}}

{{#if create-issue-4}}
```bash
# Create Issue 4: Tests & CI/CD
ISSUE_OUTPUT=$(gh issue create \
  --title "Data Package Review: Tests & CI/CD" \
  --label "pkgreview-tests" \
  --body "## Review Checklist

This is the final step in the openwashdata package review process.

### Prerequisites
- [x] Metadata review (Issue #$METADATA_ISSUE) has been completed
- [x] Data review (Issue #$DATA_ISSUE) has been completed
- [x] Documentation review (Issue #$DOCS_ISSUE) has been completed

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
1. Use the actual issue number shown above to work on this issue
2. Create a PR to the \`dev\` branch
3. After merging, run \`/review-complete\` to create final PR from dev to main")

# Extract the issue number
ISSUE_NUMBER=$(echo "$ISSUE_OUTPUT" | grep -oE '[0-9]+$')
echo "\nCreated Tests & CI/CD Issue #$ISSUE_NUMBER"
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
⚠️ The previous issue appears to still be open. Please complete and merge its PR before creating the next issue.

Check the status with `/review-status` to see which issues need completion.