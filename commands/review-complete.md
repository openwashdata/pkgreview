# review-complete

**Description**: Creates the final pull request from dev to main after all review issues have been resolved and merged to dev.

**Usage**: `/review-complete`

**Parameters**: None

---

When the user types `/review-complete`, execute the following:

## ✅ Completing Package Review

First, verify all review issues are completed:

```bash
# Get package name
PACKAGE_NAME=$(basename "$PWD")

# Check all review issues
echo "Checking review issues status..."
METADATA_ISSUE=$(gh issue list --label "pkgreview-metadata" --json number,state,title --jq '.[0] // empty')
DATA_ISSUE=$(gh issue list --label "pkgreview-data" --json number,state,title --jq '.[0] // empty')
DOCS_ISSUE=$(gh issue list --label "pkgreview-docs" --json number,state,title --jq '.[0] // empty')
TESTS_ISSUE=$(gh issue list --label "pkgreview-tests" --json number,state,title --jq '.[0] // empty')

# Check if all issues are closed
ALL_COMPLETE=true
OPEN_ISSUES=""

if [ -z "$METADATA_ISSUE" ] || [ "$(echo "$METADATA_ISSUE" | jq -r '.state')" != "CLOSED" ]; then
    ALL_COMPLETE=false
    if [ -n "$METADATA_ISSUE" ]; then
        OPEN_ISSUES="$OPEN_ISSUES\n- Metadata Review (Issue #$(echo "$METADATA_ISSUE" | jq -r '.number'))"
    else
        OPEN_ISSUES="$OPEN_ISSUES\n- Metadata Review (not created)"
    fi
fi

if [ -z "$DATA_ISSUE" ] || [ "$(echo "$DATA_ISSUE" | jq -r '.state')" != "CLOSED" ]; then
    ALL_COMPLETE=false
    if [ -n "$DATA_ISSUE" ]; then
        OPEN_ISSUES="$OPEN_ISSUES\n- Data Review (Issue #$(echo "$DATA_ISSUE" | jq -r '.number'))"
    else
        OPEN_ISSUES="$OPEN_ISSUES\n- Data Review (not created)"
    fi
fi

if [ -z "$DOCS_ISSUE" ] || [ "$(echo "$DOCS_ISSUE" | jq -r '.state')" != "CLOSED" ]; then
    ALL_COMPLETE=false
    if [ -n "$DOCS_ISSUE" ]; then
        OPEN_ISSUES="$OPEN_ISSUES\n- Documentation Review (Issue #$(echo "$DOCS_ISSUE" | jq -r '.number'))"
    else
        OPEN_ISSUES="$OPEN_ISSUES\n- Documentation Review (not created)"
    fi
fi

if [ -z "$TESTS_ISSUE" ] || [ "$(echo "$TESTS_ISSUE" | jq -r '.state')" != "CLOSED" ]; then
    ALL_COMPLETE=false
    if [ -n "$TESTS_ISSUE" ]; then
        OPEN_ISSUES="$OPEN_ISSUES\n- Tests Review (Issue #$(echo "$TESTS_ISSUE" | jq -r '.number'))"
    else
        OPEN_ISSUES="$OPEN_ISSUES\n- Tests Review (not created)"
    fi
fi

if [ "$ALL_COMPLETE" = false ]; then
    echo "⚠️ Not all review issues are completed!"
    echo -e "\nOpen/missing issues:$OPEN_ISSUES"
    echo "\nPlease complete all review issues before creating the final PR."
    exit 1
fi

echo "✅ All review issues completed!"
```

### Create Final Pull Request

Now I'll create the final PR from dev to main:

```bash
# Ensure we're on dev branch and it's up to date
git checkout dev
git pull origin dev

# Get list of completed issues for PR body
COMPLETED_ISSUES=""
if [ -n "$METADATA_ISSUE" ]; then
    COMPLETED_ISSUES="$COMPLETED_ISSUES\n- #$(echo "$METADATA_ISSUE" | jq -r '.number'): $(echo "$METADATA_ISSUE" | jq -r '.title')"
fi
if [ -n "$DATA_ISSUE" ]; then
    COMPLETED_ISSUES="$COMPLETED_ISSUES\n- #$(echo "$DATA_ISSUE" | jq -r '.number'): $(echo "$DATA_ISSUE" | jq -r '.title')"
fi
if [ -n "$DOCS_ISSUE" ]; then
    COMPLETED_ISSUES="$COMPLETED_ISSUES\n- #$(echo "$DOCS_ISSUE" | jq -r '.number'): $(echo "$DOCS_ISSUE" | jq -r '.title')"
fi
if [ -n "$TESTS_ISSUE" ]; then
    COMPLETED_ISSUES="$COMPLETED_ISSUES\n- #$(echo "$TESTS_ISSUE" | jq -r '.number'): $(echo "$TESTS_ISSUE" | jq -r '.title')"
fi

# Create the final PR
gh pr create --base main \
  --title "Complete package review for $PACKAGE_NAME" \
  --body "## Summary

This PR completes the comprehensive review of the \`$PACKAGE_NAME\` R data package following openwashdata standards.

## Completed Review Issues
$COMPLETED_ISSUES

## Review Process

All review items have been addressed through the sequential review process:
1. ✅ General Information & Metadata
2. ✅ Data Content & Processing
3. ✅ Documentation
4. ✅ Tests & CI/CD

## Changes Included

This PR includes all improvements made during the review:
- Updated package metadata and citations
- Verified data quality and processing scripts
- Enhanced documentation and README
- Added CI/CD workflows and testing
- Configured pkgdown website with analytics

## Final Checks
- [ ] All review issues completed and closed
- [ ] Package passes \`devtools::check()\` with no errors
- [ ] Documentation builds successfully
- [ ] Ready for publication

## Next Steps

After merging this PR:
1. Create a release using \`/create-release [version]\`
2. Package will be ready for publication"
```

### ✅ Review Complete!

The final pull request has been created from `dev` to `main`.

**What's next:**
1. Review the PR on GitHub to ensure all changes look correct
2. Have another team member review if needed
3. Merge the PR to main
4. Run `/create-release [version]` to create the first release

---

## Error Handling

If not all issues completed:
⚠️ Not all review issues are completed!

Open/missing issues:
- [List of incomplete issues]

Please complete all review issues before creating the final PR.

If no dev branch exists:
❌ No `dev` branch found. The review process requires working on a dev branch.

Please ensure you've been following the review workflow correctly.

If PR already exists:
⚠️ A pull request from `dev` to `main` already exists.

Please check the existing PR: [URL]