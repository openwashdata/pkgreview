# pkgreview NEWS

One section per release. Skill, script, template, fixture, and process changes are recorded here; checklist wording changes are recorded in `docs/checklist-reconciliation.md` (repo rule 3), one row per item. Releases before 1.5.0 are described by their reconciliation sections and tag messages.

# pkgreview 1.7.0

The release that pairs with washr 1.2.0. The check script takes its metadata, docs, and tests lines from washr, the plugin gains the washr skill, and the review skills gain the unattended mode and the release practice items. No checklist item changed.

- Check script: the metadata, docs, and tests lines come from `washr::check_publication_readiness()`; line texts, tiers, and both expected reports are unchanged. pkgreview keeps the data-quality checks, the dictionary schema check, the PII signal scan, and the git-history scan (#66, #87).
- The check script needs washr 1.2.0 or newer and stops with a message otherwise; the floor is 1.2.0 throughout (`WASHR_FLOOR`, both org profiles, the skill preflights, the README table); the gate workflow installs washr (#87).
- The script stops on a directory without DESCRIPTION and NAMESPACE; the history fixture gains an empty NAMESPACE (#87).
- New skill `/washr`: builds or continues a data package with washr 1.2.0 or newer, in vignette order. It runs each washr function, reads its output, drafts descriptions, titles, and README text for the person to confirm, and fixes until `check_publication_readiness()` has no failing item. Rules in the skill body; writing conventions under `skills/washr/references/`; no scripts (#88, openwashdata/washr#115).
- `/review-issue` and `/create-next-issue` take `--unattended`: the plan is posted on the issue and the PR is merged into `dev` on a green R-CMD-check run with every required item checked; no stop removed (#69).
- `/create-release` runs a preflight with a remedy per check; NEWS.md is maintained per review PR and renamed at release; `dev` gets the development version after the DOI sync, in `/add-doi` Step 9; release post outline under `references/templates/` (#55).
- `/create-release` and `/add-doi` commit `.zenodo.json`, which washr 1.2.0 writes with the citation files. Zenodo reads it from the release tag for the resource type, the community, the creators, and the license (openwashdata/washr#56).
- Dictionary round trip (#37, Part 2): passes with `washr::update_dictionary()`; descriptions and extra columns such as `unit` and `allowed_values` survive a data change. Recorded in `docs/roadmap-v1.1.md`; #38 and #39 are unblocked.

# pkgreview 1.6.1

Patch release for the check script (issue #86, found in the openwashdata sweep of 2026-09-23 and 2026-09-24). No checklist item changed.

- Check script: a dataset, dictionary, or text file with invalid UTF-8 bytes no longer stops the script before the report is written. Strings whose bytes are not valid UTF-8 and that carry no latin1 declaration (Latin-1 text read without its encoding, as in gdho, wsabrazil, and washinvestments) are counted from the data as loaded, then replaced byte by byte with `?` in the copy the scans read (#86).
- Check script: new advisory line per dataset, "No invalid UTF-8 strings in text data", with the affected columns and the number of rows in each. It maps to the existing data item "All text data is encoded in UTF-8; no encoding errors" and sits next to the existing UTF-8 line, which keeps naming every non-UTF-8 column, declared latin1 or not (#86).
- Check script: text files (`README.md`, `CITATION.cff`, `_pkgdown.yml`, the workflow file, `data_processing.R`) are read through the same replacement, so a line with an invalid byte is matched like any other instead of being skipped with a warning; the header of a historical data file is read the same way in the git-history scan (#86).
- Fixtures: case `fixtures/cases/invalid-utf8/` plants undeclared Latin-1 bytes in a copy of `pkgreviewtest` through `plant.R`, so no file with invalid bytes is tracked. The expected report for `pkgreviewtest` gains the one PASS line; the 19 FAIL + 1 FLAG mapping to D1 to D17 is unchanged (#86).

# pkgreview 1.6.0

Development workflow release (issues #72 to #80, filed 2026-09-06). No checklist item changed.

- CI: `.github/workflows/gate.yaml` runs the mechanical fixture gate as a golden-file test against `fixtures/expected/`, the check-script case suite under `fixtures/cases/`, and the repository lint (`scripts/lint.sh`); `.github/workflows/washr-drift.yaml` checks weekly that every `washr::` call the skills execute or instruct still exports from CRAN washr and reports the CRAN version against the recorded floor (#72, #77).
- Release tail: `scripts/release.sh <version>` tags the merge commit, verifies the pinned raw URLs, creates the GitHub release from this file, and fast-forwards `dev`; `.github/workflows/release.yaml` repeats the verification on every tag push. The permission allowlist for the tail's commands is recorded on #73 for the maintainer to add to `.claude/settings.json` (a session cannot write permission rules) (#73).
- Process: proposals use `.github/ISSUE_TEMPLATE/proposal.md` with an objection window; the release PR closes its issues through `Closes` lines; this NEWS file replaces the reconciliation prose for non-checklist changes (#74).
- Plugin: `.claude-plugin/marketplace.json` and `plugin.json` package the skills as a Claude Code plugin; the copy install stays documented until the plugin path has served one release (#75).
- `/review-status` and `/review-package` compare the installed VERSION with the newest tag and warn (status) or stop (package) when the install lags (#76).
- The washr floor lives in `skills/pkgreview-core/WASHR_FLOOR`; both release preflights read it (#77).
- Org profiles carry a YAML block; the check script takes `--org=<name>` (or `--org-file=`) and derives analytics, the site URL pattern, the funding text, the required keywords, and the brand rule from it; `--analytics` stays as a deprecated alias (#78).
- New `/review-upgrade` skill: one issue listing the items that changed between a package's stamped standard and the installed one, worked through the normal flow; `pkgreview-upgrade` label; recovery.md failure mode 11 (#79).
- `fixtures/make_review_fixture.sh create|delete` stands up and tears down the throwaway repository for the interactive gate in a registered org; an evals case for the intake screen under `evals/` (#80).

# pkgreview 1.5.0

Reconciliation with washr 1.1.0 and the owdata catalog (issues #56 to #68, released 2026-09-05). Checklist rows in the reconciliation section of the same name.

- Release skills: washr >= 1.1.0 preflight, every 1.0.1 caveat deleted, version validated and set with `desc::desc_set_version()`, `update_citation(build = FALSE)`, conditional `update_metadata()`, badge and website steps reduced to verification, default branch check and dev sync.
- Standard: keywords and coverage in the DESCRIPTION `X-schema.org` fields, dictionary schema advisory item, README export-link item reworded, Website required item means the pkgdown workflow deploys the site and `docs/` is not committed, tests trigger wording, brand as an org profile field.
- Check script: keywords, coverage, dictionary schema, export-link, `docs/`-tracked, and dev-trigger lines; scope note freezing the metadata, docs, and tests sections pending washr's `check_publication_readiness()`.
- Workflow skills never commit `docs/`; review-complete verifies the workflow and names the Pages setting. Guidebook reduced to intake, floor, dictionary, review, publication. Premortem files, `prompts/`, and `commands/` deleted.
