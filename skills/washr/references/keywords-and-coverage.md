# Keywords, coverage and vocabulary

Three facts about a dataset have no file of their own and live in
DESCRIPTION, where `washr::update_citation()` and
`washr::update_metadata()` read them. The review standard for them is in
the metadata checklist
(`skills/pkgreview-core/references/checklists/metadata.md`).

```
X-schema.org-keywords: sanitation, faecal sludge, Kampala
X-schema.org-spatialCoverage: Kampala, Uganda
X-schema.org-temporalCoverage: 2022-03-01/2022-09-30
```

## Keywords

- A comma separated list in `X-schema.org-keywords`.
- At minimum: `open data`, the discovery keyword of the organisation,
  the topic, and the country or region.
- The discovery keywords of a registered organisation are in its
  profile: `skills/pkgreview-core/references/orgs/[org].md`, field
  "Discovery keywords". For openwashdata they are `open data` and
  `washdata`.
- Keywords are never typed into `CITATION.cff`. `update_citation()`
  carries them there from DESCRIPTION.

## Spatial coverage

- A place name in `X-schema.org-spatialCoverage`, such as
  "Kampala, Uganda".
- The person names the place.

## Temporal coverage

- A start date and an end date separated by a slash, as
  `YYYY-MM-DD/YYYY-MM-DD`, in `X-schema.org-temporalCoverage`.
- The range of a date variable (`range()`) is a summary and may be
  proposed as the value. The person confirms it.

## Vocabulary

There is no controlled list of water, sanitation and hygiene terms in
washr, in the review standard or in the publishing guide, so this file
holds none. What those sources do say:

- The person's drafts are the source of truth, so their terms are the
  terms of the package.
- Descriptions are written in plain language, for a reader who has
  never seen the project.
- Column names carry no unexplained acronyms and no unexplained numbers
  (data checklist).

## When the data comes from a published article

The article DOI goes into DESCRIPTION as `X-schema.org-isBasedOn`,
several DOIs comma separated:

```
X-schema.org-isBasedOn: https://doi.org/10.2166/wh.2026.173
```

`update_citation()` then cites the article next to the data package,
`update_metadata()` writes it as `isBasedOn`, and `.zenodo.json` lists
it as a related identifier.
