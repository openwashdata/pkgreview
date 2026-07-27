# Canonical review issue body template

One template for all four review issues. Placeholders in `[brackets]` are
filled in at creation time. The checklist content is inserted verbatim from
the canonical checklist file for the area; do not retype or paraphrase it.

| Area | Title suffix | Labels | Checklist file |
|------|--------------|--------|----------------|
| 1 Metadata | General Information & Metadata | `pkgreview`, `pkgreview-metadata` | `skills/pkgreview-core/references/checklists/metadata.md` |
| 2 Data | Data Content & Processing | `pkgreview`, `pkgreview-data` | `skills/pkgreview-core/references/checklists/data.md` |
| 3 Documentation | Documentation | `pkgreview`, `pkgreview-docs` | `skills/pkgreview-core/references/checklists/docs.md` |
| 4 Tests | Tests & CI/CD | `pkgreview`, `pkgreview-tests` | `skills/pkgreview-core/references/checklists/tests.md` |

Issue title: `Data Package Review: [Title suffix]`

---

## Review Checklist

This is step [N] of 4 in the [organization] package review process.

Review standard version: [version stamp: the git tag, or short commit hash, of openwashdata/pkgreview that the reviewer has installed]

Organization profile: [the GitHub organization whose profile was resolved at review start, for example openwashdata]

### Prerequisites

[Omit this section for issue 1. For issues 2 to 4, list each previously
completed review issue as a checked item with its actual issue number:]

- [x] Metadata review (#[number]) completed and merged to dev
- [x] Data review (#[number]) completed and merged to dev
- [x] Documentation review (#[number]) completed and merged to dev

### Tasks

[Insert the "- [ ]" checklist sections from the canonical checklist file for
this area, including the "Files to review" list.]

### Next Steps

1. Run `/review-issue [this issue's number]` to work on this issue
2. Create a PR to the `dev` branch
3. [For areas 1 to 3:] After merging, run `/create-next-issue` to create the next issue
   [For area 4:] After merging, run `/review-complete` to create the final PR from dev to main
