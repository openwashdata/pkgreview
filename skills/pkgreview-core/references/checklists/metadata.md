# Review Checklist: General Information & Metadata

Review area 1 of 4. Issue label: `pkgreview-metadata`.

Required items block publication. Advisory items are quality improvements:
the reviewer may fix them or record them as optional follow-ups; they never
block publication.

## Required

### DESCRIPTION

- [ ] Description is an informative and accurate statement of what the data contains
- [ ] Authors and maintainer clearly identified, with ORCID IDs and a contact email for the maintainer
- [ ] License: CC BY 4.0

### Citation

- [ ] CITATION.cff file present and valid
- [ ] Version in CITATION.cff matches the version in DESCRIPTION
- [ ] Generate citation using `washr::update_citation()` (without a DOI until the first release)

## Advisory

- [ ] Package name is clear, concise, and indicative of the data content
- [ ] Title is descriptive and under 65 characters
- [ ] Dependencies properly declared
- [ ] Version follows semantic versioning
- [ ] If updates are made to DESCRIPTION, run `washr::update_description()`
- [ ] CITATION.cff carries `keywords` for discovery (at minimum: open data, the organization's discovery keyword from its org profile, the topic, and the country or region); verify manually after `washr::update_citation()`, which may not write them

## Files to review

- `DESCRIPTION`
- `CITATION.cff`
- `inst/CITATION`
