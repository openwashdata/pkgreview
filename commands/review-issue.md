# review-issue

**Description**: Jump to a specific issue in the openwashdata package review process and work on it systematically.

**Usage**: `/review-issue [number]`

**Parameters**:
- `number` (required): The actual GitHub issue number to work on

---

When the user types `/review-issue [number]`, execute the following:

First, get the issue number and verify it's a review issue:
```bash
ISSUE_NUMBER=$1
PACKAGE_NAME=$(basename "$PWD")

# Get issue details including labels
ISSUE_JSON=$(gh issue view $ISSUE_NUMBER --json title,labels,body,state)
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_LABELS=$(echo "$ISSUE_JSON" | jq -r '.labels[].name' | grep '^pkgreview-' || echo "")

# Determine which type of review issue this is
if echo "$ISSUE_LABELS" | grep -q "pkgreview-metadata"; then
    ISSUE_TYPE="metadata"
elif echo "$ISSUE_LABELS" | grep -q "pkgreview-data"; then
    ISSUE_TYPE="data"
elif echo "$ISSUE_LABELS" | grep -q "pkgreview-docs"; then
    ISSUE_TYPE="docs"
elif echo "$ISSUE_LABELS" | grep -q "pkgreview-tests"; then
    ISSUE_TYPE="tests"
else
    echo "⚠️ Issue #$ISSUE_NUMBER doesn't appear to be a package review issue."
    echo "Package review issues should have one of these labels: pkgreview-metadata, pkgreview-data, pkgreview-docs, pkgreview-tests"
    exit 1
fi
```

## 🎯 Reviewing Issue #$ISSUE_NUMBER: $ISSUE_TITLE

### GitHub CLI Commands
- `gh issue view $ISSUE_NUMBER` - View issue details
- `gh issue develop $ISSUE_NUMBER` - Create branch for issue
- `git checkout $ISSUE_NUMBER-$ISSUE_SLUG`

### Issue Details

The checklist for this issue lives in the issue body itself (created from the
canonical checklist when the issue was opened). Work from the issue body as
the primary source; it is the record for this review.

Additionally, read the canonical checklist file for the issue type to make
sure nothing was lost from the issue body, and to get the suggested tools and
file lists:

- metadata: `docs/checklists/metadata.md`
- data: `docs/checklists/data.md`
- docs: `docs/checklists/docs.md`
- tests: `docs/checklists/tests.md`

Read them from a local clone of openwashdata/pkgreview if available, otherwise
fetch from
`https://raw.githubusercontent.com/openwashdata/pkgreview/main/docs/checklists/[type].md`.

If the issue body and the canonical checklist disagree, the issue body wins
for this review (it records the standard the review started with); mention the
difference to the user.

### Planned Changes

*[List specific changes identified for this issue]*

### Ready to Implement?

**Please review the planned changes above.**

Once you've reviewed and are satisfied with the plan:
- Type **"yes"** to proceed with implementation
- Type **"no"** to discuss alternative approaches
- Type **"edit"** if you want to modify the plan

If you proceed, I'll:
1. Create/checkout the issue branch
2. Implement the planned changes
3. Test the changes
4. Prepare for pull request

### After Implementation

**GitHub CLI Commands:**
```bash
# Create PR to dev branch (not main!)
gh pr create --base dev \
  --title "Fix: $ISSUE_TITLE" \
  --body "## Summary
Implements #$ISSUE_NUMBER

## Changes Made
- [List specific changes]

## Checklist
- [ ] All tasks from issue completed
- [ ] Package checks pass
- [ ] Ready for review

Closes #$ISSUE_NUMBER"
```

**After PR is merged:**
1. Pull latest changes: `git checkout dev && git pull`
2. Run `/create-next-issue` to create the next issue in sequence
3. Or run `/review-status` to check overall progress

---

## Error Handling

If invalid issue number:
❌ Issue #$ISSUE_NUMBER not found or is not a package review issue.

Package review issues have these labels:
- `pkgreview-metadata` - General Information & Metadata
- `pkgreview-data` - Data Content & Processing
- `pkgreview-docs` - Documentation
- `pkgreview-tests` - Tests & CI/CD

Use `gh issue list --label "pkgreview-*"` to see all review issues.

If no review in progress:
⚠️ No package review is currently in progress.

Start a new review with: `/review-package [package-name]`

If issue already completed:
✅ Issue #$ISSUE_NUMBER is already completed.

Use `/review-status` to see current progress or select a different issue.