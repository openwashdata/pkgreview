# The pkgdown site

`washr::setup_website()` writes `_pkgdown.yml` from the washr template
and builds the site. Every value in the file comes from DESCRIPTION, so
a wrong value is fixed in DESCRIPTION before the file is written. Once
`_pkgdown.yml` exists, `setup_website()` keeps it as it is on every later
run; `washr::update_website()` brings a file written by an older washr
up to date (see below). The standard configuration a review compares
against is `skills/pkgreview-core/references/templates/_pkgdown.yml`.

## The blocks of `_pkgdown.yml`

| Block | Content | Source in DESCRIPTION |
|---|---|---|
| `url` | the Pages URL of the site, never the repository URL | the organisation of the repository in `URL`, or `Config/washr/pages-domain` |
| `template: includes: in_header` | the Plausible analytics header | `Config/washr/analytics-domain`; left out when `none` |
| `template: bslib: brand` | the brand wiring, added by `washr::use_brand()` | `Config/washr/brand-source` |
| `template: opengraph: image` | the social preview of the brand, added by `washr::use_brand()` | `Config/washr/brand-source` and `Config/washr/brand` |
| `navbar` | the link to the website of the organisation, before the GitHub icon | `Config/washr/home`; left out when `none` |
| `home: links` | the link to the GitHub repository | the repository in `URL` |
| `home: sidebar` | the funding sentence and the community block | `Config/washr/funding` and `Config/washr/community`; each left out when `none` |
| `authors` | the footer and sidebar roles | fixed in the template |
| `footer` | the publisher sentence and the washr version that last ran `update_description()` | `Config/washr/publisher` (left out when `none`) and `Config/washr/version` |
| `reference` | one entry per data object in `data/` | the files in `data/` at the time of writing |

Do not remove or reorganise these blocks. A data object added after the
file was written is added to `reference` by hand, or the site build
stops.

## The `Config/washr/` fields

`washr::update_description()` writes them once, with the openwashdata
values for a package under openwashdata, and never overwrites a field
that is set. For a package under another GitHub organisation it writes
the funding, analytics, Zenodo community, brand, publisher, website,
catalogue and community fields as `none`.

| Field | What it sets | Value |
|---|---|---|
| `Config/washr/funding` | the funding sentence in the sidebar | a sentence, Markdown allowed, or `none` |
| `Config/washr/analytics-domain` | the Plausible analytics header | a Plausible domain, or `none` |
| `Config/washr/doi-provider` | the DOI badge of the README | `zenodo`, or another provider for a generic DOI badge |
| `Config/washr/zenodo-community` | the community in `.zenodo.json` | a Zenodo community, or `none` |
| `Config/washr/brand-source` | the repository `use_brand()` copies from | a GitHub repository such as `openwashdata/brand`, or `none` |
| `Config/washr/publisher` | the publisher sentence in the footer | a sentence, Markdown allowed, or `none` |
| `Config/washr/home` | the website of the organisation: the navbar link, the line under the README badges, the publisher url in the metadata | a URL, or `none` |
| `Config/washr/catalog` | the data catalogue named in the metadata (`includedInDataCatalog`) | a URL, or `none` |
| `Config/washr/community` | the text of the community block in the sidebar | a text, Markdown allowed, or `none` |
| `Config/washr/pages-domain` | the domain of the site | only written by hand, when the site is not served from `[org].github.io` |
| `Config/washr/version` | the washr version that last ran `update_description()` | written by washr |
| `Config/washr/brand` | the brand release that `use_brand()` installed | written by washr |

The values are the person's or the organisation's. Do not write a
funding sentence, an analytics domain, a publisher, a website, a
catalogue or a community the person did not give.

## Updating the file after a washr release

`washr::update_website()` adds to an existing `_pkgdown.yml` what the
template has gained since the file was written (the footer, the navbar
link, the sidebar blocks, the Open Graph image when the brand is
installed) and refreshes the washr version in the footer. It keeps the
reference index, hand edits, comments and the brand wiring, respects a
footer, navbar or sidebar written by hand, and leaves a current file
untouched. `update_description()` refreshes the version line on its
own. The function is the fix the readiness items `pkgdown_publisher`
and `pkgdown_washr_version` name.

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
