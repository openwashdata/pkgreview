# review-status

**Description**: Shows current review progress and pending tasks for the openwashdata package review workflow.

**Usage**: `/review-status`

**Parameters**: None

---

When the user types `/review-status`, execute the following:

First, determine the package name and check review issues:
```bash
PACKAGE_NAME=$(basename "$PWD")

# Get all review issues with their status
METADATA_ISSUE=$(gh issue list --label "pkgreview-metadata" --json number,state,title --jq '.[0] // empty')
DATA_ISSUE=$(gh issue list --label "pkgreview-data" --json number,state,title --jq '.[0] // empty')
DOCS_ISSUE=$(gh issue list --label "pkgreview-docs" --json number,state,title --jq '.[0] // empty')
TESTS_ISSUE=$(gh issue list --label "pkgreview-tests" --json number,state,title --jq '.[0] // empty')

# Count completed issues
COMPLETED_COUNT=0
if [ -n "$METADATA_ISSUE" ] && [ "$(echo "$METADATA_ISSUE" | jq -r '.state')" = "CLOSED" ]; then ((COMPLETED_COUNT++)); fi
if [ -n "$DATA_ISSUE" ] && [ "$(echo "$DATA_ISSUE" | jq -r '.state')" = "CLOSED" ]; then ((COMPLETED_COUNT++)); fi
if [ -n "$DOCS_ISSUE" ] && [ "$(echo "$DOCS_ISSUE" | jq -r '.state')" = "CLOSED" ]; then ((COMPLETED_COUNT++)); fi
if [ -n "$TESTS_ISSUE" ] && [ "$(echo "$TESTS_ISSUE" | jq -r '.state')" = "CLOSED" ]; then ((COMPLETED_COUNT++)); fi
```

## 📊 Review Status for `$PACKAGE_NAME`

**Issues Completed**: $COMPLETED_COUNT/4

### Issue Status

{{#if metadata-issue}}
{{#if metadata-closed}}✅{{else}}🔄{{/if}} Issue #{{metadata-number}}: General Information & Metadata {{#if metadata-closed}}(completed){{else}}(open){{/if}}
{{else}}
⏳ Metadata Review: Not yet created
{{/if}}

{{#if data-issue}}
{{#if data-closed}}✅{{else}}🔄{{/if}} Issue #{{data-number}}: Data Content & Processing {{#if data-closed}}(completed){{else}}(open){{/if}}
{{else}}
⏳ Data Review: Not yet created
{{/if}}

{{#if docs-issue}}
{{#if docs-closed}}✅{{else}}🔄{{/if}} Issue #{{docs-number}}: Documentation {{#if docs-closed}}(completed){{else}}(open){{/if}}
{{else}}
⏳ Documentation Review: Not yet created
{{/if}}

{{#if tests-issue}}
{{#if tests-closed}}✅{{else}}🔄{{/if}} Issue #{{tests-number}}: Tests & CI/CD {{#if tests-closed}}(completed){{else}}(open){{/if}}
{{else}}
⏳ Tests Review: Not yet created
{{/if}}

### Current Phase Details

{{#if phase-plan}}
**PLAN Phase**: Analyzing package structure and creating review issues
- Package structure analysis: {{#if structure-analyzed}}✅{{else}}🔄{{/if}}
- GitHub issues created: {{#if issues-created}}✅{{else}}🔄{{/if}}
- Waiting for user approval to proceed to CREATE phase
{{/if}}

{{#if phase-create}}
**CREATE Phase**: Working through issues systematically
- Current issue: #{{current-issue}} - {{current-issue-title}}
- Branch: {{current-branch}}
- Planned changes ready for approval
{{/if}}

{{#if phase-test}}
**TEST Phase**: Running comprehensive package checks
- R CMD check: {{#if check-passed}}✅{{else}}🔄{{/if}}
- Package build: {{#if build-passed}}✅{{else}}🔄{{/if}}
- Website build: {{#if website-passed}}✅{{else}}🔄{{/if}}
- Tests: {{#if tests-passed}}✅{{else}}🔄{{/if}}
{{/if}}

{{#if phase-deploy}}
**DEPLOY Phase**: Final deployment and verification
- pkgdown website: {{#if website-deployed}}✅{{else}}🔄{{/if}}
- Analytics tracking: {{#if analytics-verified}}✅{{else}}🔄{{/if}}
- Changes committed: {{#if changes-committed}}✅{{else}}🔄{{/if}}
- PR ready for merge: {{#if pr-ready}}✅{{else}}🔄{{/if}}
{{/if}}

### Next Action

{{#if phase-plan}}
Continue with package structure analysis or wait for user approval to proceed to CREATE phase.
{{/if}}

{{#if phase-create}}
Continue with Issue #{{current-issue}} changes or wait for user approval.
{{/if}}

{{#if phase-test}}
Continue running package checks and resolve any failing tests.
{{/if}}

{{#if phase-deploy}}
Complete deployment steps and prepare for PR merge.
{{/if}}

### Available Commands

{{#if next-action-create-first}}
- `/review-package` - Start the review process
{{/if}}
{{#if next-action-work-on-issue}}
- `/review-issue {{next-issue-number}}` - Work on the next open issue
{{/if}}
{{#if next-action-create-next}}
- `/create-next-issue` - Create the next issue in sequence
{{/if}}
{{#if next-action-complete}}
- `/review-complete` - Create final PR from dev to main
{{/if}}

---

## Error Handling

If no review in progress:
⚠️ No package review is currently in progress.

Start a new review with: `/review-package [package-name]`

If review data corrupted:
❌ Review status data appears to be corrupted or incomplete.

Please restart the review process: `/review-package`