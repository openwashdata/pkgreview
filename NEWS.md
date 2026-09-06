# pkgreview NEWS

One section per release. Skill, script, template, fixture, and process changes are recorded here; checklist wording changes are recorded in `docs/checklist-reconciliation.md` (repo rule 3), one row per item. Releases before 1.5.0 are described by their reconciliation sections and tag messages.

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
