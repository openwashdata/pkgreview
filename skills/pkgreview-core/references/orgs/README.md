# Registered organization profiles

pkgreview reviews R data packages for registered GitHub organizations. A
profile in this directory is what registers an organization: one file per
org, holding every org-specific value the review uses. The checklists,
templates, and skills stay org-neutral and read these values; the profile
is the single source for them (repo rule 4 applied to org conventions).

## Resolution

`/review-package` asks for the pasted GitHub URL of the repository under
review as its first question, derives the organization from it, lowercases
the org name, and reads `orgs/[org].md`. The release skills resolve the
org the same way from `git remote get-url origin`. If the file does not
exist, the organization is not registered and the skill stops; it never
falls back to another org's values.

## Pinning

The resolved org is stamped into the first review issue as
`Organization profile: [org]`, next to the `Review standard version`
stamp. In-flight reviews finish on the org profile and standard version
they started with; on a version mismatch, skills fetch both the stamped
checklists and the stamped org profile from
`https://raw.githubusercontent.com/openwashdata/pkgreview/v[stamp]/skills/pkgreview-core/references/orgs/[org].md`.
Reviews that predate org profiles (before v1.3.0) carry no org stamp and
are openwashdata reviews by definition (recovery.md failure mode 9).

## Fields

Every profile carries this field table:

| Field | Meaning |
|-------|---------|
| GitHub organization | The org name as it appears in repository URLs |
| Pages domain | GitHub Pages domain for package websites |
| Package site URL pattern | The pkgdown `url:` value per package |
| Analytics | Analytics header for `_pkgdown.yml`, or `none` |
| Funding sidebar text | The `home.sidebar` custom component text |
| Citation tooling | Tooling that keeps DESCRIPTION, CITATION.cff, and inst/CITATION in sync, with its version floor |
| README template | The template the docs checklist item points at |
| Discovery keywords (minimum) | The discovery keyword set for the metadata checklist item (`X-schema.org-keywords` in DESCRIPTION) |
| Brand | The pkgdown brand for the org's package sites (`_brand.yml` and where it comes from), or `none`; `_pkgdown.yml` wires a brand through `template.bslib.brand` only when the profile defines one |
| Zenodo community | The community checked in the add-doi record review |

## Machine-readable block

Below the table, every profile carries a fenced `yaml` block with the same
values under stable keys, read by the check script (`--org=<name>`, or
`--org-file=<path>` for a stamped copy): `github_org`, `pages_domain`,
`site_url_pattern` (with `<package>` as the placeholder), `analytics`
(`plausible` or `none`), `analytics_domain`, `funding_text` (matched
verbatim in `_pkgdown.yml`), `citation_tooling`, `readme_template`,
`keywords_required` (the literal keywords every package must carry; the
topic and the country or region stay reviewer judgment), `brand` (a
source such as `openwashdata/brand`, or `none`), `zenodo_community`. The
table and the block must agree; the block is what the script reads.

## Registering a new organization

Open a PR to openwashdata/pkgreview adding `orgs/[org].md` with the field
table filled in. Two constraints hold until the standard is extended:

- Citation tooling: the checklists and the standards template currently
  express only the washr flow (1.1.0 or newer). Registering an org with
  different tooling requires reworking those files, which is a standard
  change with its own version bump (repo rule 1).
- Analytics: the check script understands `analytics: plausible` and
  `analytics: none` in the profile block. Other analytics stacks need a
  check script extension first.
