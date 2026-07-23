# Roadmap: incremental v1.1 progression of the review standard

Date: 2026-07-12
Status: PLAN ONLY. Nothing in this document is implemented. All issues
below were posted to openwashdata/pkgreview on 2026-07-12:

- Milestone v1.1.0: issue 1.1 = #27, 1.2 = #28, 1.3 = #29, 1.4 = #30,
  1.5 = #31, 1.6 = #32
- Milestone v1.2.0: issue 2.1 = #33, 2.2 = #34, 2.3 = #35, 2.4 = #36
- Milestone v1.3.0: issue 3.1 = #37, 3.2 = #38, 3.3 = #39

The three milestones must be created manually (the GitHub integration
used to post the issues cannot create milestones); each issue names its
milestone in the first line of its body so attachment is unambiguous.

## Background

A five-specialist panel (tidyverse cleaning, data quality, tidy data, R
data package development, FAIR sharing) reviewed the v1.0.0 standard and
a premortem stress-tested the resulting revision plan (record:
premortem-report-20260712-045625.html and the matching transcript).
The maintainer then set the direction:

- Data packages are increasingly written by contributors outside the
  core team; the goal is to get as much data published as possible.
- The standard splits into a small REQUIRED publication floor and an
  ADVISORY tier. Advisory items (for example tidyverse style in the
  processing script) never block publication.
- The PII and data sensitivity check runs FIRST, before review issues
  are created and, per the guidebook, before data is pushed anywhere
  public.
- The four floor items: (1) raw data lands in `data-raw/`; (2) PII and
  sensitivity check done up front; (3) a description of the data exists;
  (4) a dictionary is available, where the one-sentence description per
  variable is the most important part.
- No v2.0.0 rearchitecture. Progress from v1.0.0 in minor increments.

Maintainer decisions already taken: the REQUIRED tier is the four floor
items plus publication mechanics (CC BY 4.0 license, valid citation
files, `devtools::check()` passes, data loads, `.rda` in `data/` with
CSV/XLSX exports in `inst/extdata/`). NA coding and everything else is
advisory. The dictionary keeps the 5-column washr schema in the v1.1
line (no schema extension), which avoids the washr ownership collision
(premortem F9) and the inferred-metadata circularity (F6).

Premortem constraints that bind every release below:

- P1 Gate integrity (F3): any checklist change runs the fixture gate
  with exact reconciliation (finding count equals defect count, no
  waived noise) before merge to main.
- P2 Small, timeboxed changes; deferred items never leak into a running
  issue (F7).
- P3 Carrying capacity (F1): the required tier must complete in a single
  short session on the fixture; if not, trim required, not advisory.
- P4 No agent-invented metadata (F6): dictionary descriptions are
  written or confirmed by a human.
- P5 Verification honesty (F8): every required check is backed by a
  command visible in the session; unexecuted checks are marked NOT RUN,
  never checked.
- P6 Human sign-off for household- or person-level data is a checklist
  item the agent cannot satisfy itself (F5).

---

## Milestone: v1.1.0 - Publication floor, intake screen, guidebook

Goal: reviews enforce a small required floor and treat everything else
as advisory; the PII/sensitivity screen runs before any issue exists; an
external contributor can self-serve from a guidebook.
Suggested due date: 4 weeks after start (timebox per P2; ship what is
merged and gated, move the rest to v1.2).

### Issue 1.1: Split the four checklists into Required and Advisory tiers

Labels: `enhancement`, `checklists`. Milestone: v1.1.0.

Body:

The review standard gains two tiers. Required items block publication.
Advisory items are quality improvements: the reviewer may fix them or
record them as optional follow-ups; they never block publication.

Tasks:

- [ ] Restructure `skills/pkgreview-core/references/checklists/metadata.md`,
      `data.md`, `docs.md`, `tests.md` into a `## Required` and a
      `## Advisory` section each, with a two-line tier definition at the
      top. Keep item wording unchanged wherever possible; only move items.
- [ ] Required tier, metadata: Description field is an informative and
      accurate statement of what the data contains; authors and
      maintainer identified with maintainer contact email; License:
      CC BY 4.0; CITATION.cff present and valid; CITATION.cff version
      matches DESCRIPTION; citation generated with
      `washr::update_citation()`.
- [ ] Required tier, data: raw data preserved in `data-raw/`;
      `data_processing.R` in `data-raw/`; primary data in `data/` as
      `.rda`; CSV/XLSX exports in `inst/extdata/`; PII item (reworded,
      see below); dictionary item (reworded, see below).
- [ ] Required tier, docs: one-paragraph introduction describing the
      data; README dynamic generation works; installation instructions;
      data overview with dimensions; dictionary table rendered; license
      and citation sections; datasets documented with `.Rd` including a
      description of each variable; website builds and is published.
- [ ] Required tier, tests: R-CMD-check workflow present with `dev`
      trigger; `devtools::check()` passes (notes explained); examples
      run; data loads.
- [ ] Everything else moves to Advisory, explicitly including: NA
      coding, tidy data principles, categorical/date/numeric/type
      checks, snake_case, unique IDs, UTF-8, "uses tidyverse
      conventions", commented-out code, obsolete files, README template
      conformance details, visualisation polish, vignettes location,
      `_pkgdown.yml` conformance details, R-CMD-check badge.
- [ ] Reword the PII item (required tier):
      "No sensitive or personally identifiable information is present in
      any data file. The intake screen outcome is recorded in the first
      review issue; household- or person-level data requires a named
      human sign-off comment on the review issue. The review agent never
      certifies this item on its own." (P6)
- [ ] Reword the dictionary item (required tier):
      "`data-raw/dictionary.csv` covers every variable in every dataset,
      each with a one-sentence plain-language description. The
      description is the most important field; it is written or
      confirmed by a human." (P4)
- [ ] Record every moved or reworded item in
      `docs/checklist-reconciliation.md` (repo rule 3).

Acceptance criteria: each checklist has exactly one Required and one
Advisory section; no item dropped; reconciliation entries complete;
fixture gate deferred to issue 1.5.

### Issue 1.2: Intake screen in /review-package (PII and sensitivity first)

Labels: `enhancement`, `skills`. Milestone: v1.1.0. Depends on: 1.1.

Body:

The PII and data sensitivity check moves to the front of the process:
it runs before the review creates any issues.

Tasks:

- [ ] Add an "Intake screen" step to `skills/review-package/SKILL.md`,
      after the dedupe guard and before any issue is created:
      (1) raw data present in `data-raw/` with a processing script;
      (2) direct-identifier scan over column names and sampled values of
      every dataset (names, phone numbers, email addresses, national or
      beneficiary IDs, household-level GPS coordinates);
      (3) sensitivity flags: household- or person-level records,
      small-area or small-group cells, protection-relevant contexts;
      (4) data description exists (DESCRIPTION Description field and
      README introduction);
      (5) dictionary present with a description per variable.
- [ ] Outcome handling in the SKILL body (guardrails live at the point
      of action, per repo CLAUDE.md): any direct identifier or
      sensitivity flag stops the review at a check-in; household- or
      person-level data requires the named human sign-off comment before
      the data issue can complete; missing floor items stop with a
      pointer to the guidebook; all-clear results are recorded in an
      "Intake screen" section at the top of the first review issue body.
- [ ] Every screen check is backed by a command run in the session;
      checks not executed are reported as NOT RUN (P5).

Acceptance criteria: a fixture run with a planted direct identifier
(issue 1.5) stops at the intake screen; a clean package proceeds with
the screen results recorded in issue 1.

### Issue 1.3: Advisory handling and evidence rule in /review-issue

Labels: `enhancement`, `skills`. Milestone: v1.1.0. Depends on: 1.1.

Body:

Tasks:

- [ ] `skills/review-issue/SKILL.md`: advisory findings are listed in
      the issue as optional improvements; the reviewer or agent may fix
      quick ones in the issue PR; unresolved advisory findings are
      recorded in the final review PR body; they never block the
      dev-to-main merge or the release.
- [ ] Evidence rule: every checked required item must be backed by a
      command run in the session; checks not executed are marked NOT RUN
      in the PR body rather than checked (P5).
- [ ] The consolidated plan table at CHECK-IN #1 separates required
      fixes from advisory suggestions, so approval effort stays small
      (P3).

Acceptance criteria: PR body template usage shows required and advisory
sections; a NOT RUN example is documented in the skill.

### Issue 1.4: Contributor guidebook

Labels: `documentation`. Milestone: v1.1.0.

Body:

A data package creation guidebook for contributors outside the core
team, walking from "I have a dataset" to a submittable package.

Tasks:

- [ ] New `docs/guidebook.md` with sections:
      1. Before you share data: the PII and sensitivity check (run it
         before the data is pushed to any public repository).
      2. Quickstart: scaffolding the package with washr.
      3. The publication floor: the exact required list (from issue 1.1).
      4. The dictionary: how to write a good one-sentence description
         per variable, with good and bad examples.
      5. Folder structure: `data-raw/`, `data/`, `inst/extdata/`,
         `analysis/`.
      6. The processing script: keep it simple and reproducible;
         tidyverse style is welcome but not required.
      7. What review looks like: the four issues, who fixes what, what
         advisory findings mean.
      8. Publication: release, Zenodo DOI, citation.
- [ ] Link the guidebook from `README.md` and from the intake-screen
      failure message (issue 1.2).
- [ ] One paragraph in README on required vs advisory tiers.

Acceptance criteria: a contributor can produce a floor-passing package
using only the guidebook; the intake screen points at it.

### Issue 1.5: Fixture defects D13 and D14, scorecard reconciliation rule

Labels: `fixtures`. Milestone: v1.1.0. Depends on: 1.1, 1.2.

Body:

Additive fixture changes only; D1-D12 mechanisms stay untouched (P1,
premortem F3).

Tasks:

- [ ] D13: dictionary present but with an empty description for one
      variable and a placeholder description for another
      (`data-raw/dictionary.csv`). Must be caught by the reworded
      required dictionary item.
- [ ] D14: direct-identifier column `owner_phone` added to the dataset
      (generated in `fixtures/make_pkgreviewtest.R` AFTER all existing
      draws so the RNG stream for D1-D12 does not shift; deterministic
      values without extra RNG consumption). Must be caught by the
      intake screen, which stops before issue creation. Update the
      static fixture files consistently (`data-raw/waterpoints_raw.csv`,
      `inst/extdata/*`, `data/pkgreviewtest.rda`, `R/pkgreviewtest.R`,
      `man/pkgreviewtest.Rd`, dictionary row for `owner_phone` with a
      valid description so D14 stays purely a PII defect).
- [ ] Rerun `fixtures/make_pkgreviewtest.R` (requires R) and verify the
      D1-D12 columns are byte-identical in the regenerated CSVs.
- [ ] `fixtures/SCORECARD.md`: add D13/D14 rows with the checklist item
      or intake step that must catch each; update "exactly twelve" to
      fourteen; mark each defect required-tier or advisory-tier; add the
      exact-reconciliation rule: the gate passes only when the finding
      count equals the defect count, waiving noise is prohibited (P1);
      fix the self-referential typo in the header paragraph.

Acceptance criteria: regenerated fixture preserves D1-D12 byte-for-byte
where applicable; scorecard maps 14 defects; no approximations.

### Issue 1.6: Release v1.1.0

Labels: `release`. Milestone: v1.1.0. Depends on: 1.1-1.5.

Body:

Tasks:

- [ ] Full review workflow run against `fixtures/pkgreviewtest/`; every
      planted defect (D1-D14) caught with exact reconciliation; the
      intake screen stops on D14 (P1). Record the mapping table in the
      release PR.
- [ ] Confirm the fixture data issue completes in a single session with
      a plan table of reasonable size (P3); if not, trim the required
      tier before tagging.
- [ ] `skills/pkgreview-core/VERSION` to 1.1.0;
      `docs/checklist-reconciliation.md` complete; standards.md updated
      with the tier distinction, PII-first rule, and dictionary
      description emphasis.
- [ ] dev-to-main PR; tag `v1.1.0` on the release commit.

Kill criteria: if the gate cannot reach exact reconciliation in two
attempts, cut checklist scope until it can; do not tag.

---

## Milestone: v1.2.0 - Mechanical honesty for the advisory tier

Goal: the vaguest advisory items become checkable without growing the
required tier; light provenance and FAIR improvements.

### Issue 2.1: Reword unverifiable data checks into mechanical advisory items

Labels: `enhancement`, `checklists`. Milestone: v1.2.0.

- [ ] Replace advisory "No data entry errors or inconsistencies" with:
      exact duplicate row count reported (including duplicate-on-all-
      but-ID); simple cross-field consistency checks with violation
      counts (date ordering, part <= whole); hard-range checks (counts
      >= 0, percentages in [0, 100]) separated from plausibility flags
      for maintainer judgment.
- [ ] New advisory coordinate item: latitude in [-90, 90], longitude in
      [-180, 180], no (0, 0) points, no points outside the stated
      region; coordinate precision assessed as disclosure risk (links to
      the intake screen).
- [ ] Date item reworded: stored as `Date` class; rendered ISO 8601 in
      exports (class vs print format).
- [ ] Reconciliation entries for every reworded item.

### Issue 2.2: Enumerate the tidyverse conventions item (advisory)

Labels: `enhancement`, `checklists`. Milestone: v1.2.0.

- [ ] Replace advisory "Uses tidyverse conventions" with a short
      enumerated list: `readr::read_csv()` with explicit `col_types`;
      `readr::write_csv()` / `writexl::write_xlsx()` for exports (always
      UTF-8); no commented-out code; native pipe preferred.
- [ ] Suggested-tools table: add `janitor::make_clean_names()` for the
      snake_case check and a lubridate parsing row; drop the dlookr rows
      (skimr plus dplyr::count cover them without a heavy dependency).
- [ ] Fixture: decide whether the fixture script's own convention
      violations become explicit planted defects or the script is made
      convention-clean without disturbing D1-D12 mechanisms (premortem
      F3 applies; the D3 latin1 mechanism is implemented by code the
      conventions discourage, so this needs its own reconciliation).

### Issue 2.3: Provenance and FAIR light

Labels: `enhancement`, `checklists`. Milestone: v1.2.0.

- [ ] Advisory roxygen `@source` for every dataset (original collector,
      URL or reference, access date).
- [ ] Advisory README provenance sentence: source, collection period,
      region, source license or permission.
- [ ] Advisory README Download section: direct links to the CSV/XLSX
      exports for non-R users.
- [ ] Advisory CITATION.cff `keywords` (open data, washdata, topic,
      country); verify after `washr::update_citation()` since washr may
      not write them.
- [ ] add-doi: one sentence distinguishing the Zenodo concept DOI (for
      citation files and badge) from the version DOI; a single "review
      the Zenodo record" prompt (community, resource type Dataset,
      related identifiers).

### Issue 2.4: Fixture and release v1.2.0

Labels: `fixtures`, `release`. Milestone: v1.2.0. Depends on 2.1-2.3.

- [ ] Planted defects only for items the gate must exercise (candidates:
      one cross-field violation, one coordinate defect); additive, exact
      reconciliation (P1).
- [ ] VERSION 1.2.0, reconciliation entries, gate run, tag.

---

## Milestone: v1.3.0 - Conditional hardening (may never ship)

Gate for the whole milestone: only start if v1.1/v1.2 experience shows
post-review drift in published packages (data updates breaking floor
guarantees).

### Issue 3.1: washr dictionary round-trip spike (blocking precondition)

Labels: `spike`. Milestone: v1.3.0.

- [ ] Test whether `washr::update_dictionary()` preserves columns added
      beyond the 5-column schema on a real package (premortem F9).
- [ ] If columns are dropped: file/implement a washr change, or conclude
      that dictionary schema extensions are off the table and record the
      decision. No v1.3 schema work proceeds without this passing.

### Issue 3.2: Light contract-style data test template (conditional)

Labels: `enhancement`, `templates`. Milestone: v1.3.0. Depends on 3.1.

- [ ] Template `test-data.R` asserting only stable contracts: data
      loads, non-empty, every column in `dictionary.csv` and vice versa.
      Reads the dictionary at runtime; NO `dim()` literals, NO date
      ceilings, NO level-set equality (premortem F2).
- [ ] Data-update playbook (edit dictionary first, rerun tests) shipped
      in the package-resident standards file.

### Issue 3.3: Dictionary schema extensions (unit, allowed_values)

Labels: `enhancement`. Milestone: v1.3.0. Blocked by 3.1.

- [ ] Only if 3.1 passed: optional `unit` and `allowed_values` columns,
      agent may scaffold as TODO cells, values human-authored (P4).

---

## Posting instructions

- Create three milestones: `v1.1.0`, `v1.2.0`, `v1.3.0` (descriptions
  from the milestone headers above; due date only for v1.1.0).
- Post issues 1.1-1.6 immediately (milestone v1.1.0); post 2.x and 3.x
  now for visibility or when their milestone opens, per maintainer
  preference.
- Issue bodies above are self-contained; paste them as-is. Dependencies
  are stated in each issue header line.
