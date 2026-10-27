# The pkgdown site

`washr::setup_website()` writes `_pkgdown.yml` from the washr template
and builds the site. Every value in the file comes from DESCRIPTION, so
a wrong value is fixed in DESCRIPTION before the file is written. Once
`_pkgdown.yml` exists, washr keeps it as it is on every later run. The
standard configuration a review compares against is
`skills/pkgreview-core/references/templates/_pkgdown.yml`.

## The blocks of `_pkgdown.yml`

| Block | Content | Source in DESCRIPTION |
|---|---|---|
| `url` | the Pages URL of the site, never the repository URL | the organisation of the repository in `URL`, or `Config/washr/pages-domain` |
| `template: includes: in_header` | the Plausible analytics header | `Config/washr/analytics-domain`; left out when `none` |
| `template: bslib: brand` | the brand wiring, added by `washr::use_brand()` | `Config/washr/brand-source` |
| `home: links` | the link to the GitHub repository | the repository in `URL` |
| `home: sidebar` | the funding sentence | `Config/washr/funding`; left out when `none` |
| `authors` | the footer and sidebar roles | fixed in the template |
| `reference` | one entry per data object in `data/` | the files in `data/` at the time of writing |

Do not remove or reorganise these blocks. A data object added after the
file was written is added to `reference` by hand, or the site build
stops.

## The `Config/washr/` fields

`washr::update_description()` writes them once, with the openwashdata
values for a package under openwashdata, and never overwrites a field
that is set. For a package under another GitHub organisation it writes
the funding, analytics, community and brand fields as `none`.

| Field | What it sets | Value |
|---|---|---|
| `Config/washr/funding` | the funding sentence in the sidebar | a sentence, Markdown allowed, or `none` |
| `Config/washr/analytics-domain` | the Plausible analytics header | a Plausible domain, or `none` |
| `Config/washr/doi-provider` | the DOI badge of the README | `zenodo`, or another provider for a generic DOI badge |
| `Config/washr/zenodo-community` | the community in `.zenodo.json` | a Zenodo community, or `none` |
| `Config/washr/brand-source` | the repository `use_brand()` copies from | a GitHub repository such as `openwashdata/brand`, or `none` |
| `Config/washr/pages-domain` | the domain of the site | only written by hand, when the site is not served from `[org].github.io` |
| `Config/washr/version` | the washr version that last ran `update_description()` | written by washr |
| `Config/washr/brand` | the brand release that `use_brand()` installed | written by washr |

The values are the person's or the organisation's. Do not write a
funding sentence, an analytics domain or a community the person did not
give.

## Deployment

The review standard has the site deployed by the pkgdown workflow
(`.github/workflows/pkgdown.yaml`) to the `gh-pages` branch, with
`docs/` ignored and never committed. `setup_website()` follows the
repository:

- with the workflow file in place, `docs/` stays in `.gitignore` and
  the local build is a preview
- without it, `docs/` is tracked, so the site can be served from the
  main branch; `track_docs = FALSE` keeps it ignored anyway

`usethis::use_github_action("pkgdown")` writes the workflow file. The
`gh-pages` branch appears with the first run of the workflow on GitHub,
and the Pages source of the repository is then set to that branch by a
maintainer.

## The site URL in DESCRIPTION

pkgdown expects the site URL in the `URL` field of DESCRIPTION, next to
the repository URL, and `washr::update_metadata()` takes the `url` of
the metadata from there. `update_description()` adds the repository
only, so the site URL is added after `setup_website()`:
`desc::desc_add_urls("[url from _pkgdown.yml]")`.

## Brand

`washr::use_brand()` copies `_brand.yml` and the logo files from the
brand repository at its latest release tag, adds them to
`.Rbuildignore`, wires `_pkgdown.yml`, and records the tag in
`Config/washr/brand`. Brand values are never edited in the package:
they change in the brand repository, a release is cut there, and the
package runs `use_brand()` again. A run with no new release changes no
file.

## Metadata in the site head

`washr::update_metadata()` writes `pkgdown/templates/in-header.html`,
the schema.org description of the dataset that the site build embeds in
every page. The file is generated and never edited by hand. Run the
function again after DESCRIPTION, the dictionary or the citation files
change.

## Articles

Articles live in `vignettes/articles/`, never directly in `vignettes/`.
`setup_website(has_example = TRUE)` creates
`vignettes/articles/examples.Rmd` once.
