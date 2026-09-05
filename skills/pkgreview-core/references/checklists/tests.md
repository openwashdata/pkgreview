# Review Checklist: Tests & CI/CD

Review area 4 of 4. Issue label: `pkgreview-tests`.

Required items block publication. Advisory items are quality improvements:
the reviewer may fix them or record them as optional follow-ups; they never
block publication.

## Required

- [ ] GitHub Actions workflow for R-CMD-check present (`.github/workflows/R-CMD-check.yaml`)
- [ ] Workflow triggers include `dev` for both push and pull_request (`washr::setup_ci()` writes `branches: [main, master, dev]`); the usethis default `[main, master]` never checks review PRs into `dev`
- [ ] Package passes `devtools::check()` with no errors or warnings; any notes are explained in the PR
- [ ] Examples run successfully
- [ ] Data loads correctly

## Advisory

- [ ] R-CMD-check badge added to README.Rmd

Badge markdown (replace `ORGNAME` with the GitHub organization from the
org profile and `PACKAGENAME` with the package name):

```markdown
[![R-CMD-check](https://github.com/ORGNAME/PACKAGENAME/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ORGNAME/PACKAGENAME/actions/workflows/R-CMD-check.yaml)
```

## Files to review or create

- `.github/workflows/R-CMD-check.yaml` (create if missing)
- `README.Rmd` (add badge)
- `tests/testthat/` (if it exists)
