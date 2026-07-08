# Slash commands (deprecated)

The command files in this directory are deprecation stubs. The openwashdata
package review workflow moved to a Claude Code skill architecture in
`skills/` (issue #6):

| Old command file | Replacement |
|------------------|-------------|
| `review-package.md` | `skills/review-package/` |
| `review-issue.md` | `skills/review-issue/` |
| `create-next-issue.md` | `skills/create-next-issue/` |
| `review-status.md` | `skills/review-status/` |
| `review-complete.md` | `skills/review-complete/` |
| `create-release.md` | `skills/create-release/` |
| `review-pr.md` | folded into `skills/review-issue/` (step 7) |

Shared reference files (canonical checklists, issue and PR templates, the
package-resident standards file, recovery paths) live in
`skills/pkgreview-core/`.

## Migration

1. Install the skills as described in the repository README
2. Remove the old command files:
   `rm ~/.claude/commands/review-*.md ~/.claude/commands/create-*.md`
3. Invocations stay the same (`/review-package`, `/review-issue [number]`,
   and so on)
