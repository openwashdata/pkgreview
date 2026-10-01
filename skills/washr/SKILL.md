---
name: washr
description: >-
  Build or continue an R data package with the washr package, in the order
  of the washr vignette: scaffold, processing script, dictionary, roxygen
  documentation, DESCRIPTION, metadata, README, website, citation files,
  then fix until check_publication_readiness() reports no failing item.
  Runs every washr function through Rscript and drafts the prose for the
  person to confirm. Works on the local package only and never pushes.
disable-model-invocation: true
argument-hint: "[step]"
---

# washr

Build the data package in the current directory with washr, or continue
one that is partly built. washr is the engine: every file with a fixed
shape is written by a washr function. This skill is the driver: it runs
the functions in order, reads their output, and drafts the prose that no
function can write (variable descriptions, titles, the README text) for
the person to confirm.

`$ARGUMENTS` is optional. Without it, run Step 0 and continue with the
first step that is not done. With a step number (`3`) or name
(`dictionary`), run Step 0 and go to that step.

The skill needs washr 1.2.0 or newer. It relies on what 1.2.0 added:
messages in three fixed kinds, a returned path from every function,
`update_dictionary()`, `update_zenodo_json()`, the `Config/washr/` fields
in DESCRIPTION, and `check_publication_readiness()`. Do not adapt the
steps to an older washr.

## Rules, non-negotiable

These hold in every step. They are stated here, at the point of action,
and no reference file overrides them.

1. **The person's drafts are the source of truth.** A codebook, a
   cleaning script, notes, a filled dictionary, an earlier README: when a
   draft exists, use its content and its wording. Propose text of your
   own only where the person has written nothing.
2. **Every edit is proposed with a reason.** Show what you would write
   and why, in one table per step, and wait for the reply. Write only
   what was confirmed. A variable description that nobody confirmed does
   not meet the review standard.
3. **Data files are never modified.** Nothing under `data-raw/` except
   `data_processing.R` and `dictionary.csv` is edited, moved, renamed or
   deleted, and `data/` and `inst/extdata/` change only because the
   processing script ran.
4. **Hand written sections are never overwritten without asking.** The
   washr functions keep what a person wrote, and two of them stop when
   their file exists (`setup_dictionary()`, `setup_readme()`). Never pass
   `force = TRUE` and never delete a file to get past a stop without the
   person's explicit yes.
5. **Work from summaries, never from raw rows.** Read the dictionary, the
   structure of the data objects and counts. Do not print rows, do not
   open the raw files or the CSV exports, do not call `head()`, `View()`
   or `print()` on a data object. Step 2 has the commands.
6. **No LLM key is a prerequisite.** Every step also works by hand, as
   the washr vignette describes it. If the person prefers to write a part
   themselves, run the function, name the file to edit, and wait.
7. **No scripts.** This skill ships no code of its own. If a step seems
   to need a script, the function is missing in washr: say so and offer
   to draft an issue for openwashdata/washr.
8. **Local only.** Never run `git push`, never create a repository, never
   create a release. Before the first commit that contains data, ask the
   person whether the PII and sensitivity check is done (Step 0).

## How to run a function and read its output

Run every washr function from the package root, one call per command,
and print what it returns:

```bash
Rscript -e 'cat(washr::setup_rawdata(), sep = "\n")'
```

The messages come in three kinds, and usethis helpers that washr calls
print lines of the same kinds:

| Line starts with | Meaning | What to do |
|---|---|---|
| a tick | a file was written or is up to date | note the path |
| an `i` | something was kept or skipped | read why; nothing was changed |
| an arrow | the next step is left to a person | this is the work of the step |

The last lines of the output are the returned paths: the file or files
the function wrote. Verify that each one exists. An error names the
function and carries a hint line; follow the hint, do not work around
it. Report a step as done only after its "Verify" check passed.

## Step 0: Preflight

- washr version:
  `Rscript -e 'stopifnot(packageVersion("washr") >= "1.2.0")'`.
  If it fails, stop and tell the person to run
  `install.packages("washr")`. `check_publication_readiness()` names the
  installed version in the first line of its report (Step 10).
- The helper packages the templates load are installed:
  `Rscript -e 'need <- c("devtools", "fs", "here", "readr", "readxl", "openxlsx", "dplyr", "knitr", "stringr", "gt", "kableExtra"); cat(need[!vapply(need, requireNamespace, logical(1), quietly = TRUE)], sep = "\n")'`.
  It prints the missing ones. Ask before installing anything.
- Find out where the package stands. In a directory without
  `DESCRIPTION`, the package does not exist yet: Step 1 creates it. In a
  package, list which of these exist and report the first step that is
  open: `.github/workflows/R-CMD-check.yaml` (1),
  `data-raw/data_processing.R` and `data/*.rda` (2),
  `data-raw/dictionary.csv` (3), `R/[dataset].R` and `man/` (4),
  `Config/washr/version` in DESCRIPTION (5),
  `pkgdown/templates/in-header.html` (6), `README.Rmd` and `README.md`
  (7), `_pkgdown.yml` (8), `CITATION.cff` (9).
- Ask the person which drafts exist (rule 1) and where they are.
- PII and sensitivity: ask whether the person has checked every dataset
  for direct identifiers, household or person level rows, small groups
  and protection-relevant context, as the data checklist requires
  (`${CLAUDE_SKILL_DIR}/../pkgreview-core/references/checklists/data.md`,
  the PII item). The check comes before the first commit that contains
  data, because a removed column stays in the git history. This skill
  never certifies the item. If the person has not done the check, say so
  in every later summary and do not commit data.

## Step 1: Package and check workflow

Only when no `DESCRIPTION` exists. The package name is the name of the
dataset, lower case, short, without dots or underscores. Ask for it.

```bash
Rscript -e 'usethis::create_package("[path]/[name]", rstudio = TRUE, open = FALSE)'
```

Then, from the new package root:

```bash
Rscript -e 'cat(washr::setup_ci(), sep = "\n")'
```

Putting the package under version control is the person's call: offer
`git init`, and leave `usethis::use_github()` to them (rule 8).

Verify: `.github/workflows/R-CMD-check.yaml` exists and every `branches:`
line in it names `dev`.

## Step 2: Raw data and processing script

```bash
Rscript -e 'cat(washr::setup_rawdata(), sep = "\n")'
```

The person copies the raw files into `data-raw/` (rule 3: you do not
move them). `data-raw/data_processing.R` is theirs to write. When they
have a cleaning script already, port it into the sections of the
template (read, tidy, export) without changing what it computes, and
propose each change with its reason. The commented example lines of the
template give way to the real import.

More than one dataset: the template exports one data frame named after
the package. For several, repeat the export block (`usethis::use_data()`,
the CSV export, the XLSX export) once per data frame. Each data object
then has a unique, descriptive name and none of them is named after the
package.

Run the script and look at the result through summaries only:

```bash
Rscript data-raw/data_processing.R
Rscript -e 'for (f in list.files("data", full.names = TRUE)) { e <- new.env(); load(f, e); for (n in ls(e)) { cat(n, "\n"); str(e[[n]], vec.len = 0, give.attr = FALSE) } }'
```

The second command prints the names, classes and factor levels of every
data object and no values. For one variable, counts and ranges are
summaries too: `table()` for a variable with few distinct values,
`range()` for dates, `summary()` for numbers. Do not tabulate a variable
that may hold names, numbers of persons or free text.

Verify: one `.rda` file per data object in `data/`, and a CSV and an
XLSX file per data object in `inst/extdata/`. When the person has an
earlier build of the same data, the `.rda` files must be identical
(`tools::md5sum()`); a difference means the port changed the cleaning
and has to be found before going on.

## Step 3: Dictionary

First time:

```bash
Rscript -e 'cat(washr::setup_dictionary(), sep = "\n")'
```

When `data-raw/dictionary.csv` exists, `setup_dictionary()` stops. Run
`update_dictionary()` instead: it adds a row per new variable, removes
the row of a variable that is gone, refreshes the types, and keeps every
description and every column the person added.

```bash
Rscript -e 'cat(washr::update_dictionary(), sep = "\n")'
```

Its arrow line lists the variables that still lack a description. That
list is the work of this step:

1. Take the descriptions the person already wrote (rule 1): a codebook,
   an earlier dictionary, comments in the cleaning script.
2. For each variable still open, draft one sentence following
   `${CLAUDE_SKILL_DIR}/references/variable-descriptions.md`, from the
   variable name, its type and its summary. Where the meaning or the
   unit cannot be known from those, ask; never guess a unit.
3. Present one table: variable, proposed description, where it comes
   from (the person's draft, word for word, or your proposal with its
   basis). Wait for the reply (rule 2).
4. Write the confirmed sentences into the `description` column and touch
   no other column and no other file.

Verify: run `update_dictionary()` again. It must report that the file is
up to date and that every variable has a description. If it lists
variables as added and removed in the same data object, a variable was
renamed: it prints what was written about the removed one, so copy that
to the new row after asking.

## Step 4: Roxygen documentation

```bash
Rscript -e 'cat(washr::setup_roxygen(), sep = "\n")'
```

It writes one file per data object under `R/`, with a placeholder title
and description and the variable table from the dictionary. On a later
run it regenerates only the variable table. For each file, propose in
one table (rule 2), following
`${CLAUDE_SKILL_DIR}/references/variable-descriptions.md`:

- the title, in place of `[dataset]: Title goes here`
- the description, in place of `Description of the data goes here...`
- a `#' @source` line above the dataset name in the last line

Do not edit the lines from `#' @format` to the closing `#' }`: they are
generated from the dictionary. To change a variable description, change
the dictionary and run `setup_roxygen()` again.

```bash
Rscript -e 'devtools::document()'
```

Verify: `man/[dataset].Rd` exists for every data object, and no file
under `R/` still holds the placeholder title or description.

## Step 5: DESCRIPTION

The facts in DESCRIPTION are the person's (rule 1). Ask for what is
missing and never invent a name, an email address or an ORCID iD:

- `Title`, at most 65 characters, and `Description`, an accurate
  statement of what the data contains
- `Authors@R`, each person with role and ORCID iD, the maintainer with an
  email address
- `X-schema.org-keywords`, `X-schema.org-spatialCoverage` and
  `X-schema.org-temporalCoverage`, following
  `${CLAUDE_SKILL_DIR}/references/keywords-and-coverage.md`

Propose the values in one table, then write them, for example:

```bash
Rscript -e 'invisible(desc::desc_set(`X-schema.org-spatialCoverage` = "Kampala, Uganda"))'
```

Then let washr complete the file. For a package under openwashdata:

```bash
Rscript -e 'cat(washr::update_description(), sep = "\n")'
```

For a package under another GitHub organisation, name it once:
`washr::update_description(github_user = "https://github.com/[org]")`.
Later runs read the organisation from `URL`.

`update_description()` also writes the `Config/washr/` fields (funding
sentence, analytics domain, DOI provider, Zenodo community, brand
repository). It never overwrites one that is set. For another
organisation it writes four of them as `none` and lists them in an arrow
line: ask the person for their values, or leave `none`, which switches
the feature off. The fields are explained in
`${CLAUDE_SKILL_DIR}/references/pkgdown-site.md`.

Verify: DESCRIPTION carries `License`, `URL`, `BugReports`, `Date` and
`Config/washr/version`, and the title and description are no longer the
placeholder text of a new package.

## Step 6: Metadata

```bash
Rscript -e 'm <- washr::update_metadata(); cat(names(attr(m, "blank")), sep = "\n")'
```

The function writes `pkgdown/templates/in-header.html` and ends with the
fields it could not fill and where each one is filled. Nothing in that
file is edited by hand: fill the source (Steps 3 and 5) and run it
again. Before the release one field stays blank and is expected:
`identifier (DOI)`.

Verify: the only name the command prints is `identifier (DOI)`.

## Step 7: README

```bash
Rscript -e 'cat(washr::setup_readme(has_example = TRUE), sep = "\n")'
```

When `README.Rmd` exists the function stops (rule 4): keep the file and
work on it. The template leaves the prose open. Propose it in one table
(rule 2), from the person's drafts first, following
`${CLAUDE_SKILL_DIR}/references/readme-sections.md`:

- the introduction in place of `The goal of [package] is to ...`
- the sentences in place of `The package provides access to ...` and
  `contains data about ...`
- the Example section: describe what the plot shows, fill the aesthetics
  of the commented plot with variables of the data, give it readable
  axis labels and a title, and uncomment it. Ask which plot the person
  wants.

More than one dataset: the template documents the first data object. For
each further one, copy the block from the `### [dataset]` heading to the
end of its variable table, and replace the dataset name in the heading,
the sentence, the preview chunk and the `file_name` filter. The download
table already lists every dataset of the dictionary.

Do not edit the badge lines, the download table chunk or the Citation
chunk: washr owns them.

```bash
Rscript -e 'devtools::build_readme()'
```

Verify: `README.md` exists and is newer than `README.Rmd`, and no
placeholder sentence is left:
`grep -n -E "is to \.\.\.|access to \.\.\.|data about \.\.\." README.Rmd`
prints nothing.

## Step 8: Website and brand

Decide the deployment from the repository, before the first build. The
review standard has the site deployed by the pkgdown workflow, with
`docs/` ignored. If `.github/workflows/pkgdown.yaml` is missing, propose
to add it:

```bash
Rscript -e 'usethis::use_github_action("pkgdown")'
```

`setup_website()` reads that choice: with the workflow in place it
leaves `docs/` in `.gitignore`; without one it tracks `docs/` so the
site can be served from the main branch. When the person wants the
second way, say that the review will ask for the workflow.

```bash
Rscript -e 'cat(washr::setup_website(has_example = TRUE), sep = "\n")'
```

Leave `has_example` out when the person wants no example article. The
call writes `_pkgdown.yml` from DESCRIPTION and builds the site into
`docs/`, which takes a minute. An existing `_pkgdown.yml` is kept as it
is, so a data object added later has to be added to its `reference`
index by hand, or the build stops. The file is explained in
`${CLAUDE_SKILL_DIR}/references/pkgdown-site.md`.

pkgdown reports "URLs not ok" while the site URL is missing from
DESCRIPTION. Add it (the `url` line of `_pkgdown.yml`), then refresh the
metadata, which takes its `url` from there:

```bash
Rscript -e 'invisible(desc::desc_add_urls("[url from _pkgdown.yml]"))'
Rscript -e 'invisible(washr::update_metadata())'
```

Then the brand:

```bash
Rscript -e 'cat(washr::use_brand(), sep = "\n")'
```

It installs the brand of `Config/washr/brand-source` at its latest
release tag, records the tag in `Config/washr/brand` and wires
`_pkgdown.yml`. With `brand-source` set to `none` it says so and
installs nothing; that is a valid end of this step.

Verify: `_pkgdown.yml` exists and its `url` is the Pages URL, `docs/` is
in `.gitignore` exactly when the pkgdown workflow exists, and, when a
brand was installed, DESCRIPTION carries `Config/washr/brand`.

## Step 9: Citation files

```bash
Rscript -e 'cat(washr::update_citation(build = FALSE), sep = "\n")'
```

It writes `CITATION.cff`, `inst/CITATION` and `.zenodo.json` from
DESCRIPTION. None of the three is edited by hand: change DESCRIPTION and
run it again. When the data comes from a published article, the person
adds the article DOI to DESCRIPTION as `X-schema.org-isBasedOn` first,
and the call then cites both. `build = FALSE` skips the site rebuild,
which nothing needs before a DOI exists.

Verify: the three returned files exist, and the arrow line asks to
proofread `inst/CITATION`: show the person the citation
(`Rscript -e 'print(readCitationFile("inst/CITATION"))'`).

## Step 10: Fix until ready

```bash
Rscript -e 'r <- washr::check_publication_readiness(); f <- as.data.frame(unclass(r)); cat("ready:", attr(r, "ready"), "\n"); print(f[f$status == "fail", c("id", "detail", "fix")], row.names = FALSE, right = FALSE)'
```

The report lists every item as pass, fail or not applicable, and names
the installed washr version in its first line. The function only reads
the package. For each failing item, the `fix` column names the step and
the washr function that closes the gap: go back to that step of this
skill, apply it under the same rules, and run the command again. Repeat
until it prints `ready: TRUE`. Do not edit a generated file to make an
item pass.

Then the package check:

```bash
Rscript -e 'devtools::check()'
```

Verify: `ready: TRUE`, and `devtools::check()` ends with 0 errors and 0
warnings. Report every note.

## Step 11: Hand over and stop

Summarise for the person: the steps done, the text they confirmed, the
items still open, and whether the PII and sensitivity check is done.
Offer one local commit per step if they want commits and the check is
done; add the files by name, never `git add -A`.

What comes next is outside this skill: the review (`/review-package`),
the release (`/create-release`) and the DOI (`/add-doi`). After the DOI
exists, `/add-doi` runs `update_citation()` with it.

Then stop.

## When the data changes later

Run Step 2 (the script), Step 3 with `update_dictionary()`, Step 4, then
Steps 6, 9 and 10. Each function writes only what changed, so a run on
an unchanged package changes no file.
