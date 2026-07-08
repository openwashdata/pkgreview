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

- [x] [Completed checklist item]
- [ ] [Item not completed, with a short explanation why]

---

Notes:

- List every checklist item from the issue, checked or unchecked; an
  unchecked item needs a reason.
- Do NOT add a `Closes #N` line: it only fires on merges into the default
  branch, and per-issue PRs merge into `dev`. `/create-next-issue` and
  `/review-complete` close the issue explicitly, with a comment
  referencing the merged PR.
- No attribution trailers or emojis in PR bodies.
