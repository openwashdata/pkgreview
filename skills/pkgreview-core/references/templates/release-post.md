# Release post outline

For an optional post that announces a data package release. No skill writes
this post; the maintainer does, once the concept DOI exists (`/add-doi` is the
last step that produces an input). Placeholders in `[brackets]`. Where the
post is published is the organization's choice and not part of the standard.

---

## [Package title]: [what the data covers, in a few words]

[One paragraph: what was measured or collected, where, when, and by whom.
Concepts before code.]

## What the data covers

- Geography: [country, region, or sites]
- Time span: [first and last date of collection]
- Size: [number] observations of [number] variables, in [number] data set(s)
- Unit of observation: [what one row is]

## Where the data comes from

[Provenance: the project, the collection method, the original publication or
report when there is one, and the license.]

## How to use it

```r
# [installation line from the package README]
library([packagename])
head([dataset])
```

[One short example that answers a question a reader would have, in a few
lines of code, with the variables it uses explained in a sentence.]

## How to cite it

[The citation from `citation("[packagename]")`, with the concept DOI
`[10.5281/zenodo.XXXXXXX]`.]

---

Notes:

- A data package post announces coverage, provenance, usage, and citation.
  It is not a changelog; what changed between versions belongs in NEWS.md.
- Say why the data matters before what it contains. No superlatives.
- Function names in backticks, package names unstyled.
- Cite the concept DOI, which stays stable across releases; the version DOI
  is only for citing one exact release.
- No attribution trailers or emojis.
