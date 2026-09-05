# Data package creation guidebook

This guidebook walks you from "I have a dataset" to an R data package you can submit for review to openwashdata. You do not need to be part of the core team, and you do not need to know everything about R packages. If you follow the steps in order, your package will meet the publication floor, which is the small set of required items a package needs before it can be published. Everything beyond the floor is advisory, which means a reviewer may suggest it, but it never blocks publication.

The canonical review checklists live in [`skills/pkgreview-core/references/checklists/`](../skills/pkgreview-core/references/checklists/). If this guidebook and a checklist ever disagree, the checklist wins.

## 1. Before you share data: check for PII and sensitivity

Run this check before you push your data to any public repository. Once data is on a public site, deleting it later does not undo the exposure, because copies and caches remain.

Look at every column and a sample of the values in every dataset, and ask:

- Are there direct identifiers? Direct identifiers are values that name a person, e.g., person names, phone numbers, email addresses, national or beneficiary ID numbers, or GPS coordinates of a household.
- Is each row a household or a person? Data at that level can identify people even without a name column, so it needs a named person to sign off during review.
- Could small groups be identified? If a table shows a small area or a small group with few observations, individuals may be identifiable from the combination of columns.
- Is the context protection-relevant? Data about refugees, patients, children, or other groups at risk needs extra care even when no single column looks sensitive.

If you find any of the above, stop and resolve it before you continue. You can remove the columns, aggregate the data, or ask the openwashdata team for help. When a review starts, the reviewer runs this same check as an intake screen before any review issue is created.

The check also covers your git history. A column you added in an earlier commit and removed later is still in the repository: anyone who clones it can recover the removed data, and the review scans every revision, not only the current files. If identifying data ever reached a commit, the history has to be cleaned before the package can be published, so run the check before the first commit that contains data, not only before the first push.

## 2. Scaffold the package with washr

The [washr](https://github.com/openwashdata/washr) package sets up the whole structure, from the raw data folder to the website, and each function tells you what it created and what to do next. Follow the washr [Get started](https://openwashdata.github.io/washr/articles/washr.html) vignette for the steps in order; the narrative version with the reasoning behind each step is the [data publishing guide](https://global-health-engineering.github.io/ghedatapublishing/). Package names are lowercase, short, and descriptive of the data, e.g., `waterpointdata`.

## 3. The publication floor

A package must meet the items below before it can be published. The reviewer checks them during review, and the wording here is a summary. The canonical wording lives in the checklist files linked at the top.

Data:

- Raw data files are preserved in `data-raw/`.
- `data_processing.R` is in `data-raw/`.
- The primary data is in `data/` as `.rda`.
- CSV and XLSX exports are in `inst/extdata/`.
- No sensitive or personally identifiable information is in any data file, in the current files or in any earlier revision. Household- or person-level data needs a named human sign-off during review.
- `data-raw/dictionary.csv` covers every variable in every dataset, each with a one-sentence description written or confirmed by a human.

Metadata:

- The Description field in DESCRIPTION says what the data contains.
- Authors and maintainer are identified, with a contact email for the maintainer.
- The license is CC BY 4.0.
- CITATION.cff is present, valid, and matches the version in DESCRIPTION. washr generates it from DESCRIPTION; do not edit it by hand.

Documentation:

- The README has a one-paragraph introduction, installation instructions, a data overview with dimensions, the rendered dictionary table, and license and citation sections, and it rebuilds from README.Rmd.
- Every dataset is documented with an `.Rd` file that describes each variable.
- The package website builds and is published on GitHub Pages by the pkgdown workflow; the generated `docs/` folder is not committed.

Tests:

- The R-CMD-check GitHub Actions workflow is present and also triggers on the `dev` branch (washr writes it that way).
- `devtools::check()` passes with no errors or warnings, and any notes are explained.
- The examples run, and the data loads.

Folders and the processing script: `data-raw/` holds the raw data exactly as you received it (never edited by hand), the `data_processing.R` script, and `dictionary.csv`; `data/` holds the processed, analysis-ready data as `.rda` files, written by the script; `inst/extdata/` holds CSV and XLSX exports of the processed data for people who do not use R; `analysis/` holds any analysis or exploration scripts that are not part of the processing itself. The processing script reads the raw files, cleans them, and writes the outputs to `data/` and `inst/extdata/`. Anyone should be able to run it top to bottom on a fresh clone and get the same outputs, so comment the steps that need explanation and delete code that is commented out. Tidyverse style is welcome but not required; the reviewer will not block your package over code style, because style is advisory.

## 4. The dictionary

The dictionary is the file `data-raw/dictionary.csv`. It has one row per variable, and the one-sentence description per variable is the most important part of the whole package. A reader who has never seen your project should understand what a variable means from its description alone.

A good description says what was measured, in plain language, with the unit if there is one:

- Good: "Distance in meters from the household to the nearest water point."
- Good: "Whether the water point was working on the day of the visit (yes or no)."

A bad description repeats the variable name or stays vague:

- Bad: "The distance variable."
- Bad: "Status."

Write or confirm every description yourself. A generated description that nobody checked does not meet the floor, because the review standard requires a human to confirm each one.

## 5. What review looks like

When your package is ready, the openwashdata team starts the review. The review runs on the `dev` branch of your repository and opens four GitHub issues, one per area, in order:

1. General information and metadata
2. Data content and processing
3. Documentation
4. Tests and CI/CD

Each issue lists the required items and the advisory items for its area. The reviewer works through them with you, fixes what is quick to fix, and opens one pull request per issue into `dev`. Required items must pass. Advisory findings are optional improvements; the reviewer may fix small ones or record them as follow-ups, and they never block publication. After all four issues are done, one final pull request goes from `dev` to `main`, and merging it completes the review.

You stay the maintainer of your package. The review is help, not a takeover.

## 6. Publication

After the review, the package is published:

- A GitHub release is created from `main`.
- The release is archived on Zenodo, which assigns a DOI (a permanent identifier that makes the dataset citable).
- The DOI goes into the citation files, the README badge, and the website metadata, so the citation in the README and on the website shows how to cite your dataset.

After publication, your dataset has a website, a DOI, and a citation, and anyone can install it as an R package or download the CSV files.
