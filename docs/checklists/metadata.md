# Review Checklist: General Information & Metadata

Review area 1 of 4. Issue label: `pkgreview-metadata`.

## DESCRIPTION

- [ ] Package name follows openwashdata conventions: clear, concise, and indicative of the data content
- [ ] Title is descriptive and under 65 characters
- [ ] Description is an informative and accurate statement of purpose
- [ ] Authors and maintainer clearly identified, with ORCID IDs and a contact email for the maintainer
- [ ] License: CC BY 4.0
- [ ] Dependencies properly declared
- [ ] Version follows semantic versioning
- [ ] If updates are made to DESCRIPTION, run `washr::update_description()`

## Citation

- [ ] CITATION.cff file present and valid
- [ ] Version in CITATION.cff matches the version in DESCRIPTION
- [ ] Generate citation using `washr::update_citation()` (without a DOI until the first release)

## Files to review

- `DESCRIPTION`
- `CITATION.cff`
- `inst/CITATION`
