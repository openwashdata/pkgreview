# review-pr

**Description**: Create a pull request for the current issue in the openwashdata package review workflow.

**Usage**: `/review-pr`

**Parameters**: None (uses current issue context)

---

When the user types `/review-pr`, execute the following:

First, determine the current context:
```bash
PACKAGE_NAME=$(basename "$PWD")
CURRENT_BRANCH=$(git branch --show-current)
CURRENT_ISSUE=$(echo $CURRENT_BRANCH | grep -o '^[0-9]\+' || echo "unknown")
```

## 📤 Creating Pull Request

### Current Context
**Package**: $PACKAGE_NAME
**Current Issue**: #$CURRENT_ISSUE - $CURRENT_ISSUE_TITLE
**Branch**: $CURRENT_BRANCH
**Files Modified**: $MODIFIED_FILES_COUNT files

### Modified Files
{{#each modified-files}}
- `{{this.path}}` - {{this.description}}
{{/each}}

### GitHub CLI Commands

**Create Pull Request:**
```bash
gh pr create --title "$PR_TITLE" --body "$(cat <<'EOF'
## Summary
$PR_SUMMARY

## Changes Made
$CHANGES_LIST

## Testing
- [ ] R CMD check passes
- [ ] Package builds successfully
- [ ] Examples run without errors
- [ ] Documentation renders correctly

## Review Checklist
- [ ] Code follows tidyverse style guide
- [ ] Documentation is complete and accurate
- [ ] All tests pass
- [ ] No breaking changes

Implements #$CURRENT_ISSUE

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

### Post-Creation Commands

**View Pull Request:**
```bash
gh pr view $PR_NUMBER
```

**List All Pull Requests:**
```bash
gh pr list
```

**Check PR Status:**
```bash
gh pr checks $PR_NUMBER
```

### PR Details

**Title**: $PR_TITLE
**Body**: 
```
## Summary
$PR_SUMMARY

## Changes Made
$CHANGES_LIST

## Testing
- [ ] R CMD check passes
- [ ] Package builds successfully
- [ ] Examples run without errors
- [ ] Documentation renders correctly

## Review Checklist
- [ ] Code follows tidyverse style guide
- [ ] Documentation is complete and accurate
- [ ] All tests pass
- [ ] No breaking changes

Implements #$CURRENT_ISSUE

🤖 Generated with [Claude Code](https://claude.ai/code)
```

### Next Steps

After PR creation:
1. **Run Tests**: Ensure all CI checks pass
2. **Request Review**: Assign reviewers if needed
3. **Monitor Status**: Check for any failing tests or conflicts
4. **Merge**: Once approved and tests pass

### Available Commands

- `/review-status` - Check overall review progress
- `/review-issue $NEXT_ISSUE` - Work on next issue
- `gh pr merge $PR_NUMBER` - Merge PR when ready

---

## Success Message

✅ **Pull Request Created Successfully!**

**PR #$PR_NUMBER**: $PR_TITLE
**URL**: $PR_URL

The pull request has been created and is ready for review. All CI checks will run automatically.

---

## Error Handling

If no current issue:
❌ No current issue to create PR for.

Use `/review-issue [number]` to work on a specific issue first.

If no changes made:
⚠️ No changes have been made for the current issue.

Please implement the planned changes before creating a PR.

If not on feature branch:
❌ Not currently on a feature branch for issue #$CURRENT_ISSUE.

Please run:
- `gh issue develop $CURRENT_ISSUE`
- `git checkout $CURRENT_ISSUE-$ISSUE_SLUG`

If uncommitted changes:
⚠️ You have uncommitted changes. Please commit them first:

```bash
git add .
git commit -m "$SUGGESTED_COMMIT_MESSAGE"
```

Then retry `/review-pr`.