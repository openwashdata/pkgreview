# Organization profile: Global-Health-Engineering

Registered organization. Field meanings are documented in `orgs/README.md`.
Registered 2026-07-27 per the decisions in openwashdata/pkgreview#48.
openwashdata is an initiative of Global Health Engineering (ETH Zurich),
so the two profiles are near equal.

| Field | Value |
|-------|-------|
| GitHub organization | `Global-Health-Engineering` |
| Pages domain | `global-health-engineering.github.io` |
| Package site URL pattern | `https://global-health-engineering.github.io/<package>/` |
| Analytics | Plausible: `<script defer data-domain="global-health-engineering.github.io" src="https://plausible.io/js/script.js"></script>` |
| Funding sidebar text | This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/). Verify during the first GHE review (openwashdata/pkgreview#50). |
| Citation tooling | washr >= 1.1.0: `washr::update_citation()`, `washr::update_description()`, `washr::update_metadata()`. Verify the output carries no openwashdata-specific branding (#48 decision 2) |
| README template | washr README template |
| Discovery keywords (minimum) | open data, global health, the topic, the country or region |
| Brand | none: the openwashdata brand must not appear in a Global-Health-Engineering package, so `washr::use_brand()` is not run and `_pkgdown.yml` carries no `bslib.brand` line |
| Zenodo community | `global-health-engineering` (slug assumed; verify on first use, #48 decision 5) |

## Machine-readable values

The check script reads this block (`--org=global-health-engineering`); the table above is the human copy and must say the same (openwashdata/pkgreview#78).

```yaml
github_org: Global-Health-Engineering
pages_domain: global-health-engineering.github.io
site_url_pattern: https://global-health-engineering.github.io/<package>/
analytics: plausible
analytics_domain: global-health-engineering.github.io
funding_text: This project was funded by the [Open Research Data Program of the ETH Board](https://ethrat.ch/en/eth-domain/open-research-data/).
citation_tooling: washr
readme_template: washr
keywords_required:
  - open data
  - global health
brand: none
zenodo_community: global-health-engineering
```
