# Organization profile: openwashdata

Registered organization. Field meanings are documented in `orgs/README.md`.
openwashdata is the founding org of this review standard and the default
for reviews that predate org profiles (before v1.3.0).

| Field | Value |
|-------|-------|
| GitHub organization | `openwashdata` |
| Pages domain | `openwashdata.github.io` |
| Package site URL pattern | `https://openwashdata.github.io/<package>/` |
| Analytics | Plausible: `<script defer data-domain="openwashdata.github.io" src="https://plausible.io/js/script.js"></script>` |
| Funding sidebar text | This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/). |
| Citation tooling | washr >= 1.1.0: `washr::update_citation()`, `washr::update_description()`, `washr::update_metadata()` |
| README template | washr README template |
| Discovery keywords (minimum) | open data, washdata, the topic, the country or region |
| Brand | `_brand.yml` from [openwashdata/brand](https://github.com/openwashdata/brand), installed and wired into `_pkgdown.yml` with `washr::use_brand()` |
| Zenodo community | `openwashdata` |

## Machine-readable values

The check script reads this block (`--org=openwashdata`); the table above is the human copy and must say the same (openwashdata/pkgreview#78).

```yaml
github_org: openwashdata
pages_domain: openwashdata.github.io
site_url_pattern: https://openwashdata.github.io/<package>/
analytics: plausible
analytics_domain: openwashdata.github.io
funding_text: This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).
citation_tooling: washr
readme_template: washr
keywords_required:
  - open data
  - washdata
brand: openwashdata/brand
zenodo_community: openwashdata
```
