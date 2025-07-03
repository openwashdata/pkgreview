# review-status

**Description**: Shows current review progress and pending tasks for the openwashdata package review workflow.

**Usage**: `/review-status`

**Parameters**: None

---

When the user types `/review-status`, execute the following:

First, determine the package name:
```bash
PACKAGE_NAME=$(basename "$PWD")
```

## 📊 Review Status for `$PACKAGE_NAME`

**Current Phase**: {{current-phase}}
**Issues Completed**: {{completed-count}}/5

### Issue Status

✅ Issue #1: General Information & Metadata {{#if issue1-completed}}(completed){{else}}{{#if issue1-in-progress}}(in progress){{else}}(pending){{/if}}{{/if}}
{{#if issue2-completed}}✅{{else}}{{#if issue2-in-progress}}🔄{{else}}⏳{{/if}}{{/if}} Issue #2: Data Content & Quality {{#if issue2-completed}}(completed){{else}}{{#if issue2-in-progress}}(in progress){{else}}(pending){{/if}}{{/if}}
{{#if issue3-completed}}✅{{else}}{{#if issue3-in-progress}}🔄{{else}}⏳{{/if}}{{/if}} Issue #3: Data Processing Script Review {{#if issue3-completed}}(completed){{else}}{{#if issue3-in-progress}}(in progress){{else}}(pending){{/if}}{{/if}}
{{#if issue4-completed}}✅{{else}}{{#if issue4-in-progress}}🔄{{else}}⏳{{/if}}{{/if}} Issue #4: Documentation {{#if issue4-completed}}(completed){{else}}{{#if issue4-in-progress}}(in progress){{else}}(pending){{/if}}{{/if}}
{{#if issue5-completed}}✅{{else}}{{#if issue5-in-progress}}🔄{{else}}⏳{{/if}}{{/if}} Issue #5: Tests & CI/CD {{#if issue5-completed}}(completed){{else}}{{#if issue5-in-progress}}(in progress){{else}}(pending){{/if}}{{/if}}

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

- `/review-issue $CURRENT_ISSUE` - Work on current issue
- `/review-pr` - Create pull request for current issue
- `/review-package` - Restart review process

---

## Error Handling

If no review in progress:
⚠️ No package review is currently in progress.

Start a new review with: `/review-package [package-name]`

If review data corrupted:
❌ Review status data appears to be corrupted or incomplete.

Please restart the review process: `/review-package`