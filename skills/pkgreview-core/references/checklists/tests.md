# Review Checklist: Tests & CI/CD

Review area 4 of 4. Issue label: `pkgreview-tests`.

- [ ] GitHub Actions workflow for R-CMD-check present (`.github/workflows/R-CMD-check.yaml`)
- [ ] R-CMD-check badge added to README.Rmd
- [ ] Package passes `devtools::check()` with no errors or warnings; any notes are explained in the PR
- [ ] Examples run successfully
- [ ] Data loads correctly

Badge markdown (replace `PACKAGENAME`):

```markdown
[![R-CMD-check](https://github.com/openwashdata/PACKAGENAME/workflows/R-CMD-check/badge.svg)](https://github.com/openwashdata/PACKAGENAME/actions)
```

## Files to review or create

- `.github/workflows/R-CMD-check.yaml` (create if missing)
- `README.Rmd` (add badge)
- `tests/testthat/` (if it exists)
