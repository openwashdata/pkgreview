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

Based on the existing issues, create the next one in sequence:

- No `pkgreview-data` issue and the metadata issue is closed: create the
  Data Content & Processing issue
- No `pkgreview-docs` issue and the data issue is closed: create the
  Documentation issue
- No `pkgreview-tests` issue and the docs issue is closed: create the
  Tests & CI/CD issue

Build the issue body from the canonical sources; do not retype or paraphrase
checklist items:

1. Fetch the canonical template and the checklist for the next area:
   - `docs/templates/issue-body.md` (structure, title, and label mapping)
   - `docs/checklists/[area].md` (the checklist content)

   Read them from a local clone of openwashdata/pkgreview if available,
   otherwise fetch from
   `https://raw.githubusercontent.com/openwashdata/pkgreview/main/docs/...`.

2. Create the issue with `gh issue create`, using the title and labels from
   the template's mapping table. Fill the Prerequisites section with the
   actual issue numbers of the previously completed review issues.

3. Capture the issue number GitHub assigns from the command output and
   report it to the user.

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