# Review Checklist: Documentation

Review area 3 of 4. Issue label: `pkgreview-docs`.

## README

- [ ] README.Rmd follows the openwashdata template
- [ ] Contains a one-paragraph introduction, 3 to 5 sentences long
- [ ] Dynamic content generation works (README.md rebuilds from README.Rmd with `devtools::build_readme()`)
- [ ] Installation instructions present
- [ ] Data overview with dimensions
- [ ] Variable dictionary table rendered
- [ ] Each data visualisation has edited human-readable labels (axis labels, legend title), is described in the narrative, and is cross-referenced using its code-chunk label
- [ ] License section complete
- [ ] Citation section complete with author, year, title, DOI (once available), and website URL

## Function and data documentation

- [ ] Roxygen documentation for all exported functions
- [ ] All datasets documented with `.Rd` files that include a clear title, description, usage examples, and a description of each variable
- [ ] Data structures (number of rows and columns) and types clearly described
- [ ] Vignettes, if present, live in `vignettes/articles/`, not directly in `vignettes/`

## Website

- [ ] `_pkgdown.yml` follows the standard openwashdata configuration, including the Plausible analytics header (canonical template: `docs/templates/_pkgdown.yml` in openwashdata/pkgreview)
- [ ] Package website builds without errors (`pkgdown::build_site()`)
- [ ] Website published on GitHub Pages

## Files to review

- `README.Rmd`, `README.md`
- `_pkgdown.yml`
- `man/*.Rd`
- `vignettes/articles/` (if vignettes exist)
