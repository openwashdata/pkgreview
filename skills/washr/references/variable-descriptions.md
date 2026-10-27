# Variable descriptions, titles and sources

Conventions for the text a person writes about the data: the
`description` column of `data-raw/dictionary.csv` and the head of each
roxygen file under `R/`. The review standard for these items is in the
data and docs checklists
(`skills/pkgreview-core/references/checklists/data.md` and `docs.md`);
if this file and a checklist disagree, the checklist wins.

## The description of a variable

The dictionary has one row per variable, and the description is the
most important field of the whole package. A reader who has never seen
the project should understand what a variable means from its
description alone.

- One sentence, in plain language.
- It says what was measured or recorded.
- It carries the unit when there is one.
- It names the possible values when there are few.
- It is written or confirmed by a person. A description nobody checked
  does not meet the publication floor.

Good:

- "Distance in meters from the household to the nearest water point."
- "Whether the water point was working on the day of the visit (yes or
  no)."

Bad, because they repeat the variable name or stay vague:

- "The distance variable."
- "Status."

No description is left empty, and none is a placeholder such as `TODO`,
`TBD`, `...` or `description`.

## Units and allowed values

Units and possible values belong in the description sentence:
"Volume of faecal sludge emptied, in cubic metres.", "Type of settlement
(formal or informal)."

- Take the unit from the person's draft or ask for it. A unit is never
  guessed from the variable name or from the range of the values.
- For a variable with few distinct values, the values come from the
  factor levels or from a count of the variable, and the person says
  what each one means.
- The dictionary keeps the five washr columns in this order:
  `directory`, `file_name`, `variable_name`, `variable_type`,
  `description`. `washr::update_dictionary()` keeps extra columns a
  person added, such as `unit` or `allowed_values`, but the review
  standard checks for exactly the five columns, so keep units and
  values in the description unless the person asks for extra columns.
- `variable_type` is written by washr from the data and holds one class
  name per row. Do not edit it.
- The file is UTF-8 without a byte order mark.

## The title and description of a dataset

`washr::setup_roxygen()` writes the placeholders
`[dataset]: Title goes here` and `Description of the data goes here...`
into `R/[dataset].R`. Replace both:

- The title is a human readable name of the dataset, one line.
- The description is a brief statement of what the dataset contains and
  its purpose.
- The lines from `#' @format` to the closing `#' }` are generated from
  the dictionary and are not edited.

## The source

Each roxygen file gets a `#' @source` line, placed above the line with
the quoted dataset name. For a data package this is the most important
field of the help page after the description. It names:

- the original collector of the data
- a URL or a reference
- the access date

After any change to a file under `R/`, run `devtools::document()`.
