# Canonical PR body template

For per-issue PRs (feature branch into `dev`). Placeholders in `[brackets]`.

PR title: `Fix: [short description of the review area work]`
Base branch: `dev` (never `main` for per-issue PRs)

---

## Summary

Addresses #[issue-number]

## Changes Made

- [List each specific change made]

## Commits in this PR

- [List each commit message]

## Checklist

### Required

- [x] [Completed required item, backed by a command run in the session]
- [ ] [Required item not completed, with a short explanation why]
- [ ] [Required item whose check was not executed]: NOT RUN ([reason])

### Advisory

- [x] [Advisory finding fixed in this PR]
- [ ] [Advisory finding left as an optional follow-up]

---

Notes:

- List every checklist item from the issue, checked or unchecked; an
  unchecked item needs a reason.
- A checked required item must be backed by a command run in the session.
  If the check was not executed, mark the item NOT RUN with a reason
  instead of checking it.
- Advisory findings never block publication, the merge to `dev`, or the
  dev-to-main merge; unresolved ones are optional follow-ups, collected
  in the final review PR body.
- Do NOT add a `Closes #N` line: it only fires on merges into the default
  branch, and per-issue PRs merge into `dev`. `/create-next-issue` and
  `/review-complete` close the issue explicitly, with a comment
  referencing the merged PR.
- No attribution trailers or emojis in PR bodies.
