# {{ORG_NAME}} package standards

Standard version: {{PKGREVIEW_VERSION}}
Organization profile: {{ORG_NAME}}
Source: https://github.com/openwashdata/pkgreview

This package was reviewed against the pkgreview standards recorded in this
file, applied with the {{ORG_NAME}} organization profile. It guides every
future Claude session working in this package, including sessions by student
contributors and external collaborators who have no review tooling installed.
Do not delete this file: it is the only record of which standard version and
organization profile this package was reviewed against. The `/review-package`
command writes it at review start; the stamps above pin the standard and the
org values for the whole review.

Note: pkgdown renders every top-level `.md` file, so this file appears on the
package website as `CLAUDE.html`. That is accepted behavior (it
publicly records the standard the package was reviewed against); pkgdown
offers no configuration to exclude it. Do not delete the file to hide it.

## Required floor and advisory tier

The standard has two tiers. Required items are the publication floor and
block publication: raw data preserved in `data-raw/` with a processing
script, the PII and sensitivity check done up front, a description of the
data, a dictionary with a description per variable, plus the publication
mechanics (CC BY 4.0 license, valid citation files, `devtools::check()`
passes, data loads, `.rda` in `data/` with CSV/XLSX exports in
`inst/extdata/`). Advisory items are quality improvements (for example
tidyverse style in the processing script or NA coding); fix them when
practical, record the rest as optional follow-ups, and never let them
block publication.

## Rules a future session must not undo

- PII and sensitivity come first: no data is pushed anywhere public
  before the PII and sensitivity check has run over the column names and
  sampled values of every dataset. No direct identifiers (person names,
  phone numbers, email addresses, national or beneficiary IDs,
  household-level GPS coordinates) in any data file. Household- or
  person-level data requires a named human sign-off on the review issue;
  an agent never certifies this on its own.
- `data-raw/dictionary.csv` covers every variable in every dataset, each
  with a one-sentence plain-language description. The description is the
  most important field; it is written or confirmed by a human, never
  invented by an agent.
- Vignettes live in `vignettes/articles/`, never directly in `vignettes/`.
  This keeps pkgdown rendering correct and avoids CRAN issues.
- `_pkgdown.yml` follows the standard configuration below,
  including the analytics header and the funding sidebar from the
  organization profile. Do not remove or reorganize these blocks.
- Analysis, validation, and testing scripts live in `analysis/` at the
  package root. They are intentionally outside `R/` and are not built into
  the installed package. Do not move or delete them; they exist for
  reproducibility.
- The license is CC BY 4.0. Do not change it.
- Missing values are coded as `NA`, never as empty strings, "NULL", "N/A",
  or sentinel numbers such as -99.
- After editing DESCRIPTION, run `washr::update_description()`. Caveat
  (washr 1.0.1): it strips `Config/Needs/website` entries; diff DESCRIPTION
  after the call and restore anything it removed.
- After version or author changes, run `washr::update_citation()` so
  DESCRIPTION, CITATION.cff, and inst/CITATION stay in sync. Caveats
  (washr 1.0.1): the `doi` argument is required, so call it with the
  package DOI or `doi = NULL` before a DOI exists; with `doi = NULL` it can
  inject a broken empty badge (`zenodo.org/badge/DOI/.svg`) into
  README.Rmd, which must be removed; and it leaves `inst/CITATION.bk1`
  backup files that must not be committed.
- Raw data stays in `data-raw/`, processed `.rda` data in `data/`, and
  CSV/XLSX exports in `inst/extdata/`.

## Package structure

```
package-name/
├── DESCRIPTION
├── NAMESPACE
├── R/package-name.R          # roxygen data documentation
├── data/package-name.rda     # single dataset: named after the package
├── data-raw/
│   ├── data_processing.R
│   └── dictionary.csv
├── inst/
│   ├── CITATION
│   └── extdata/              # CSV and XLSX exports
├── man/
├── vignettes/articles/       # all vignettes go here
├── analysis/                 # analysis scripts, not built
├── README.Rmd / README.md
├── NEWS.md
├── CITATION.cff
├── _pkgdown.yml
└── .github/workflows/R-CMD-check.yaml
```

Multi-dataset packages: one `.rda` in `data/` and one roxygen `.R` file per
dataset, each with a unique, descriptive name; no dataset is named after
the package. The `_pkgdown.yml` reference index lists every dataset.

## Standard _pkgdown.yml

Replace `packagename` with the actual package name. `url` is the site base
URL (canonical links, sitemap.xml, redirects), so it must be the Pages URL,
never the GitHub repo URL; the repo link lives in `home.links`.

```yaml
url: https://{{ORG_DOMAIN}}/packagename/
template:
  bootstrap: 5
  includes:
    in_header: |
      <script defer data-domain="{{ORG_DOMAIN}}" src="https://plausible.io/js/script.js"></script>

home:
  links:
    - icon: github
      text: GitHub repository
      href: https://github.com/{{ORG_NAME}}/packagename
  sidebar:
    structure: [links, citation, authors, dev, custom]
    components:
      custom:
        title: Funding
        text: This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).

authors:
  footer:
    roles: [cre, fnd]
    text: "Crafted by"
  sidebar:
    roles: [cre, aut, ctb]
    before: "So *who* does the work?"
    after: "Thanks all!"

reference:
- title: "Data"
  desc: "Access the packagename dataset"
  contents:
  - packagename
```

Multi-dataset packages: list one entry per data object under `contents`,
each with its unique, descriptive name; none of them is named after the
package.

## Code style

- 2 spaces for indentation, no tabs; maximum 80 characters per line
- tidyverse style for R code; snake_case for functions and variables

## Useful commands

- Rebuild README: `R -e "devtools::build_readme()"`
- Rebuild documentation: `R -e "devtools::document()"`
- Full check: `R -e "devtools::check()"`
- Build website: `R -e "pkgdown::build_site()"`
