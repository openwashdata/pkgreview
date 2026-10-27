# README sections

`washr::setup_readme()` writes `README.Rmd` from the washr template.
The sections come in the order below. The parts marked "washr" are
generated and stay as they are; the parts marked "person" are prose that
the person writes or confirms. What a review requires of the README is
in the docs checklist
(`skills/pkgreview-core/references/checklists/docs.md`).

| Order | Section | Who | Content |
|---|---|---|---|
| 1 | Title | washr | the package name |
| 2 | Badges | washr | license, R CMD check, and the DOI once there is one, between the `badges: start` and `badges: end` markers |
| 3 | Introduction | person | one paragraph in place of "The goal of [package] is to ..." |
| 4 | Installation | washr | the install line for the repository, and the chunk that loads the packages the README uses |
| 5 | Download table | washr | one row per dataset with links to the CSV and XLSX exports in `inst/extdata/` |
| 6 | Data | person | one sentence in place of "The package provides access to ..." |
| 7 | One block per dataset | both | heading with the dataset name, a sentence on what it contains, the dimensions, a preview of three rows, the variable table from the dictionary |
| 8 | Example | person | only with `has_example = TRUE`: what the plot shows, and one plot of the data |
| 9 | License | washr | the license of DESCRIPTION with a link to `LICENSE.md` |
| 10 | Citation | washr | the output of `citation("[package]")` |

## The introduction

- One paragraph, 3 to 5 sentences.
- It carries the provenance sentence: who collected the source data, the
  collection method, the collection period, the region, and any license
  or permission attached to the source data.

## The dataset blocks

- The template writes the block for the first data object in `data/`.
  For each further data object, copy the block from the `### [dataset]`
  heading to the end of its variable table, and replace the dataset name
  in the heading, in the sentence, in the preview chunk and in the
  `file_name` filter of the variable table.
- The sentence "The dataset `[dataset]` contains data about ..." is
  completed by the person. The numbers of observations and variables are
  computed inline and are not typed.
- The preview and the variable table are code chunks. Their output is
  not copied into the text.

## The example

- One plot that gives a useful first look at the data.
- Edited, human readable labels: axis labels, a legend title where
  there is a legend, a title.
- The text describes what the plot shows and refers to it by the label
  of its code chunk.
- The template carries the plot as commented code; it is filled with
  variables of the dataset and then uncommented, together with the
  `library(ggplot2)` line.

## Building

`README.md` is built from `README.Rmd` with `devtools::build_readme()`
and is never edited by hand. The build loads the packages named in the
installation chunk (dplyr, knitr, readr, stringr, gt, kableExtra), so
they have to be installed.
