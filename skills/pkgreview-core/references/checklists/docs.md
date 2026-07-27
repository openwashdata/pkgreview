# Review Checklist: Documentation

Review area 3 of 4. Issue label: `pkgreview-docs`.

Required items block publication. Advisory items are quality improvements:
the reviewer may fix them or record them as optional follow-ups; they never
block publication.

## Required

### README

- [ ] Contains a one-paragraph introduction, 3 to 5 sentences long
- [ ] Dynamic content generation works (README.md rebuilds from README.Rmd with `devtools::build_readme()`)
- [ ] Installation instructions present
- [ ] Data overview with dimensions
- [ ] Variable dictionary table rendered
- [ ] License section complete
- [ ] Citation section complete with author, year, title, DOI (once available), and website URL

### Data documentation

- [ ] All datasets documented with `.Rd` files that include a clear title, description, usage examples, and a description of each variable

### Website

- [ ] Package website builds without errors (`pkgdown::build_site()`)
- [ ] Website published on GitHub Pages

## Advisory

- [ ] README.Rmd follows the README template named in the org profile
- [ ] README contains a provenance sentence: who collected the source data, the collection method, the collection period, the region, and any license or permission attached to the source data
- [ ] README contains a Download section with direct links to the CSV/XLSX exports in `inst/extdata/` for non-R users
- [ ] Each data visualisation has edited human-readable labels (axis labels, legend title), is described in the narrative, and is cross-referenced using its code-chunk label
- [ ] Roxygen documentation for all exported functions
- [ ] Data structures (number of rows and columns) and types clearly described
- [ ] Roxygen `@source` present for every dataset: original collector, URL or reference, and access date; for a data package this is the single most important Rd field after the description
- [ ] Vignettes, if present, live in `vignettes/articles/`, not directly in `vignettes/`
- [ ] `_pkgdown.yml` follows the standard configuration for the registered organization, including the analytics header when the org profile defines one (canonical template: `skills/pkgreview-core/references/templates/_pkgdown.yml` in openwashdata/pkgreview, with the org profile values substituted)

## Files to review

- `README.Rmd`, `README.md`
- `_pkgdown.yml`
- `man/*.Rd`
- `vignettes/articles/` (if vignettes exist)
