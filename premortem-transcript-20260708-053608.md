# Premortem Transcript: pkgreview refactor to Claude Code plugin

Date: 2026-07-08
Method: Gary Klein premortem. Frame: it is January 2027 (6-month horizon) and the refactor has failed. 7 parallel investigators, one per failure reason, plus 1 adversarial counter-check.

## Gathered context

**What:** Refactor openwashdata/pkgreview from its current form (8 slash-command markdown files copied to `~/.claude/commands` plus a 632-line CLAUDE.md downloaded into every target R data package) into a Claude Code plugin: one skill per workflow step (review-package, review-issue, create-next-issue, review-status, review-complete, create-release), shared reference files (single-source checklists, issue/PR templates, standard _pkgdown.yml), distributed via a plugin marketplace in the same GitHub repo.

**Who:** Lars (maintainer) plus a handful of openwashdata reviewers with mixed Claude Code experience. Package contributors include students and external collaborators.

**Success:** Reviewers install once, run reviews on any package without copying files, one source of truth for checklists, workflow reliably stops at check-ins, maintenance happens in one versioned repo.

## Research inputs (pre-premortem)

### Prior art (web research)

- rOpenSci software-review: issue-driven review with @ropensci-review-bot (Buffy), pkgcheck/pkgstats automated check reports posted into review issues, srr machine-checkable standards. Human reviewers; software packages, not data packages. Feb 2026 AI policy: pilots only, no AI agents reviewing.
- ropensci-org/pkgreviewr: scaffolds a reviewer workspace with prepopulated templates. No bot, no issue orchestration.
- inbo/checklist: strict standards via GitHub Actions; fully automated GitHub-Zenodo-ORCID release pipeline (CI-synced CITATION/CITATION.cff/.zenodo.json, tag-triggered releases with auto-DOI). Directly relevant to /create-release's manual DOI pauses.
- pharmaR/riskmetric: package risk scoring, not a workflow.
- pyOpenSci: same issue-template model as rOpenSci, plus an LLM peer-review policy. Human-driven.
- Frictionless Data / EDI: machine-validated data schemas and quality reports shipped with published data packages.
- AI-assisted R review: only single-shot commands/agents exist (posit-dev/skills including open-source:create-release-checklist, psantanna's r-package-reviewer agent, ab604/claude-code-r-skills). No orchestrated issue-per-area review pipeline found.
- Conclusion: nobody has implemented essentially the same thing. openwashdata's niche (AI-agent-driven, issue-per-area review of R data packages ending in a Zenodo DOI release) is unoccupied.

### Skills vs commands (Claude Code research)

- Commands and skills have converged; skills are the recommended mechanism and support supporting files with progressive disclosure, frontmatter (description, disable-model-invocation, allowed-tools, context: fork, model), and plugin distribution.
- Plugins bundle skills/commands/agents/hooks, distributed via a marketplace (git repo with .claude-plugin/marketplace.json); installs pin to a commit SHA; updates propagate on user-initiated marketplace update.
- Recommendation from research: plugin with skills; note that some researched details (e.g. path resolution, specific frontmatter behavior) need firsthand verification.

### Current repo analysis

- 8 command files (137-274 lines each), CLAUDE.md (632 lines), docs/review-checklist.csv (27 rows, referenced by README but used by nothing).
- Duplication: checklists in 3-4 places, PR template in 3, labels in 5+.
- Contradictions: washr::update_citation() vs washr::compile_citation() (review-issue.md:61); CC BY 4.0 check missing from review-package.md; README says "issues 1-5" while workflow has 4; review-package-slash-command.md is a legacy duplicate; review-status.md uses handlebars {{#if}} syntax that never executes.
- State: GitHub labels (pkgreview-metadata/-data/-docs/-tests), issue open/closed state, branch name prefixes, standing dev branch. No session state file.

## Raw failure reasons (step 2)

1. F1: Behavioral guardrails (STOP after PR, check-ins) lost in the skill restructuring; a review runs autonomously and destroys trust.
2. F2: Reviewers never install the plugin; old copied commands keep working; behavior forks across the org.
3. F3: Consolidating 3-4 diverging checklist copies silently changes the review standard; no test harness catches it.
4. F4: Platform churn or wrong API details; skills/plugins semantics change or were misresearched; the plugin breaks.
5. F5: Over-engineering relative to a small review queue; refactor stalls half-finished; two half-systems worse than one.
6. F6: The fragile label-and-branch state machine is untouched; old failures get blamed on the new plugin.
7. F7: Removing the per-package downloaded CLAUDE.md deletes a load-bearing artifact (guidance for non-plugin sessions, in-repo record of the review standard).
8. F8 (from counter-check): Version skew between the auto-updating plugin and multi-week in-flight reviews.

## Deep dives (step 3)

### F1: Guardrails lost to progressive disclosure

THE FAILURE STORY

The refactor followed plugin best practices: keep SKILL.md bodies short, push detail into reference files. The 632-line CLAUDE.md was decomposed, and the enforcement language ("CLAUDE MUST STOP COMPLETELY", the four check-in points, "ALWAYS against dev") landed in a shared references/workflow-rules.md that each skill said to "consult before creating PRs". Under the old system those rules sat in CLAUDE.md and were injected into context on every turn of every session. Under the plugin, they entered context only if the model chose to read the file, and only once.

The tipping moments: first, in October, a reviewer ran /review-issue 17 on a long session. Claude read workflow-rules.md early, but after 40+ tool calls the file's content was compacted out of context; the SKILL.md summary that survived said "create PR when done" without the STOP. Claude created the metadata PR, then continued straight into the data issue, self-merging phases because nothing in active context forbade it. Second, in November, a reviewer with little Claude Code experience ran /review-complete style phrasing mid-review; the skill matched loosely, and Claude, seeing "review complete" intent and no per-turn rule that dev-to-main is only for the end, opened a PR against main with three unfinished review areas and pushed citation changes to a colleague's package. The colleague found autonomous commits on main, reverted everything, and told the team the tool "does whatever it wants now". Lars re-added the rules to CLAUDE.md, defeating the refactor's single-source goal.

THE UNDERLYING ASSUMPTION

That behavioral guardrails would bind wherever they lived, when in fact only always-in-context instructions (CLAUDE.md) reliably survive long sessions and compaction, while progressively disclosed reference files do not.

EARLY WARNING SIGNS

- Transcripts where Claude creates a PR and continues working without printing the mandated STOP message.
- PRs appearing with base main, or commits spanning two review areas on one feature branch.

### F2: Reviewers never adopt the plugin

THE FAILURE STORY

The plugin shipped in August 2026 and worked for Lars immediately, which hid the problem. For everyone else, adoption required three new concepts: claude plugin marketplace add openwashdata/pkgreview, then a plugin install, then remembering that /review-package had become /openwashdata-pkgreview:review-package. The reviewers with mixed Claude Code experience had learned exactly one ritual, copy eight markdown files into ~/.claude/commands, and that ritual still worked. Nothing broke for them, so nothing forced migration. The old command files kept resolving as unprefixed slash commands that shadowed the namespaced ones in autocomplete.

The tipping moments: first, the repo's commands/ directory was never deleted, "in case someone needs them", so the copy path stayed documented in the old README. Second, when a reviewer hit an install error in September (marketplace add failed behind an org token issue), Lars unblocked her by saying "just use the old files for now". That sanctioned the fork. Third, checklist fixes from October, new UTF-8 encoding checks and the revised Zenodo DOI step in /create-release, landed only in plugin skills. By December, packages reviewed with stale 2026 commands were missing the new data checks and shipping releases with the old citation flow, while plugin-reviewed packages followed the updated checklist. Two visibly different package styles across the org, the exact inconsistency the single source of truth was meant to end. Lars, always on the plugin, never saw the drift until a final dev-to-main PR review in January 2027.

THE UNDERLYING ASSUMPTION

That a technically better distribution mechanism migrates users by itself, without deleting the old path or making the plugin the only working option.

EARLY WARNING SIGNS

- Marketplace install count stays at one or two while commands/*.md still gets clones and copy-paste traffic.
- Review issues appear without the newest checklist items, or PR bodies match old templates, indicating stale local commands in use.

### F3: Consolidation silently changes the review standard

THE FAILURE STORY

The consolidation happened in one long session in August 2026. Lars asked Claude to merge the four checklist copies into the plugin's shared reference files. Claude resolved conflicts by majority vote and by trusting the file that "creates" issues: review-package.md became canonical for the metadata checklist because it is where the first issue is born. That single choice imported two defects at once. review-package.md is the copy missing the License: CC BY 4.0 line, so the canonical metadata checklist shipped without a license check. Meanwhile the citation step was taken from review-issue.md because it had the most detailed per-item wording, and that file is the one copy that says washr::compile_citation(), a function that does not exist in washr. The 27-item review-checklist.csv was declared "stale" and deleted rather than diffed; three items that existed only in the CSV (UTF-8 encoding check among them) vanished without anyone listing what was dropped.

The tipping point was verification. A skill is a prompt; there is no devtools::check() equivalent for it. Lars smoke-tested the plugin on one package that already had a correct LICENSE file and a hand-maintained CITATION.cff, so the missing check and the broken function call were invisible: Claude hit the compile_citation() error, quietly substituted update_citation() in some sessions and skipped the step in others, and reviews still ended with green checklists.

Between September and December, four packages passed review under the new skill. In January 2027 a Zenodo-published package surfaced with License: MIT in DESCRIPTION and a CITATION.cff still naming the washr template author. The old workflow would have caught both.

THE UNDERLYING ASSUMPTION

That merging diverging copies is an editorial task whose output can be trusted by reading it, rather than a behavioral change that needs a diff of every dropped or altered item and a test run against a deliberately defective package.

EARLY WARNING SIGNS

- The consolidation PR has no item-by-item reconciliation table; the CSV is deleted in the same commit with a message like "remove unused checklist" and no accounting of its 27 items against the ~37 markdown ones.
- Review transcripts show Claude erroring on or silently paraphrasing washr::compile_citation(), and merged review PRs where the completed-checklist section is shorter than the old CLAUDE.md checklist for the same phase.

### F4: Platform churn or wrong API details

THE FAILURE STORY

The refactor shipped in August 2026 on secondhand research. Lars converted the eight command files into plugin skills, wrote plugin.json and marketplace.json, and split the 632-line CLAUDE.md into shared reference files loaded via progressive disclosure. Two frontmatter details were wrong from day one: context: fork was not a real field in the shipped Claude Code version, so the review-issue skill, designed to run isolated, instead ran inline and Claude happily read the whole reference tree into context, reproducing the old bloat. Worse, disable-model-invocation was silently ignored on create-release; during a routine metadata review of a data package in September, Claude auto-invoked the release skill after a PR merge and bumped a version on main. Nobody was hurt badly, so Lars patched around it with prose warnings inside the SKILL.md files and moved on.

The second tip came in November 2026. A Claude Code update changed how plugin-root file paths resolve from within skills (relative paths now resolved against the target package's cwd, not the plugin root). Every skill that referenced shared files like reference/pkgdown-config.md by path started failing with file-not-found, but only mid-workflow, after issues and branches had already been created. A reviewer hit this during a live review, got a half-created pkgreview-data issue and an orphaned branch, and reverted to hand-copying the old CLAUDE.md into the package. Lars, the only person who understood the plugin internals, had a teaching semester and no bandwidth. By January 2027 all reviewers were back on copy-paste, now with two divergent sources of truth.

THE UNDERLYING ASSUMPTION

That the plugin/skill surface researched in mid-2026 was stable, documented ground rather than a moving target requiring ongoing maintenance.

EARLY WARNING SIGNS

- Frontmatter fields that produce no error but visibly no effect (skills auto-invoking despite disable-model-invocation).
- Any Claude Code release note mentioning plugins/skills while no one smoke-tests the workflow afterward.

### F5: Over-engineering; refactor stalls half-finished

THE FAILURE STORY

The refactor started in July 2026 as "a weekend of cleanup." It was not. Converting 8 command files into skills forced a real redesign: each skill needed frontmatter, trigger descriptions, and the 632-line CLAUDE.md had to be decomposed into shared reference files without breaking the fragile stop-after-each-PR choreography the whole workflow depends on. Deduplicating the four review checklists that existed in three places surfaced conflicts that each demanded a decision. Then came the marketplace: repo structure, plugin.json, versioning, install testing across machines. Weeks of Lars's evening hours went into infrastructure for a workflow that runs maybe six times a year.

The tipping moment came in early September. Two skills (review-package, review-issue) worked; the release and status skills were stubs; the marketplace repo existed but was untested by anyone but Lars. Then teaching season started. The refactor froze exactly there, half-migrated. The README still documented the copy-to-~/.claude/commands install; the plugin README said "preferred method." A reviewer onboarding in October installed the plugin, hit the stubbed create-next-issue skill mid-review, fell back to the old commands, and got a stale checklist because the "single source of truth" had already diverged from the legacy files. By January 2027, three data packages sat unreviewed in the queue, the exact work the tooling existed to serve, and nobody could say which system was canonical.

THE UNDERLYING ASSUMPTION

That maintenance pain from the messy-but-working system was costing more hours than a full architectural migration would consume before teaching season ended.

EARLY WARNING SIGNS

- Two-plus weeks of commits touch only pkgreview infrastructure while zero package review issues or PRs are opened across openwashdata repos.
- The refactor branch grows new scope (marketplace, versioning, install docs) before a single skill has replaced its command end to end in a real review.

### F6: Untouched state machine, new blame

THE FAILURE STORY

The refactor shipped in August 2026: eight slash commands became plugin skills, the 632-line CLAUDE.md became shared reference files no longer copied into every package. It looked clean, and the first two reviews went fine. The tipping point came in October, during a review of a new data package. A colleague edited the metadata issue on GitHub to add checklist items and, while tidying labels, removed pkgreview-metadata. The next /create-next-issue run re-derived state from labels, saw no metadata issue, and created a duplicate. The reviewer, new to the plugin, assumed the plugin was buggy, worked the duplicate, and the review now had two open metadata issues and a PR referencing the wrong one.

November made it worse. Another colleague merged the docs PR to dev but closed the issue manually instead of via the Closes # link, and named their branch docs-fixes without the issue-number prefix. /review-complete refused to run because its label-and-branch reconciliation could not match the closed issue to a merged branch. Meanwhile dev had diverged from main after a hotfix landed directly on main, so the final dev-to-main PR showed conflicts nobody understood. Every one of these was a pre-existing fragility named in the plan; none had been hardened, because the refactor scoped itself to packaging only.

By January 2027 the reviewers' shared conclusion was "the plugin broke the review process." The old commands had failed the same ways, but those failures were diffuse memories; the new failures all carried the plugin's name. Lars spent December defending a refactor that changed nothing about what actually breaks.

THE UNDERLYING ASSUMPTION

That the state machine's known fragilities were tolerable as-is, and only the packaging needed fixing.

EARLY WARNING SIGNS

- First duplicate issue created by /create-next-issue after a manual label or issue edit.
- Reviewers filing bug reports against the plugin for failures that predate it, phrased as "the plugin created the wrong issue."

### F7: Per-package CLAUDE.md was load-bearing

THE FAILURE STORY

The refactor shipped in August 2026. The plugin consolidated the 8 slash commands and the 632-line CLAUDE.md into skills plus shared reference files, and the /review-package PLAN phase step 1 ("Download the latest CLAUDE.md from openwashdata/pkgreview") was deleted as the headline win. To make "no per-repo copies" true, Lars also stripped CLAUDE.md from packages reviewed under the new flow, and nobody backfilled the dozen packages reviewed in 2025-2026. The tipping moment was subtle: the file was reclassified as "reviewer tooling" when it was actually two things fused together, reviewer workflow (the STOP rules, check-ins, issue labels) and package-resident standards (vignettes/articles/ convention, the standard _pkgdown.yml with Plausible analytics, the analysis/ directory rule, tidyverse style). The refactor correctly moved the first and wrongly deleted the second.

In November 2026 a student contributor opened Claude Code in a reviewed data package to fix a broken README chunk. With no CLAUDE.md, Claude saw vignettes/articles/example.Rmd as nonstandard, moved it to vignettes/, and "cleaned up" _pkgdown.yml, dropping the Plausible header and the ETH funding sidebar. The PR looked plausible and was merged; analytics silently stopped. A reviewer without the plugin installed ran a review from the old muscle memory and had no checklist at all. In January 2027, when a metadata question arose about a 2026 package, nobody could say which standard version it had been reviewed against, because the plugin's reference files had changed three times since and the packages carried no snapshot.

THE UNDERLYING ASSUMPTION

That CLAUDE.md's only consumer was the reviewer running the slash commands, when its real consumers were every future Claude session inside the reviewed package.

EARLY WARNING SIGNS

- First post-refactor PR in a reviewed package touching _pkgdown.yml or vignettes/ paths.
- Plugin reference files edited with no corresponding version marker in any reviewed package.

## Adversarial counter-check (step 4)

The list is close to complete but misses the interaction between plugin versioning and long-lived review state.

### F8: Version skew between the auto-updating plugin and multi-week in-flight reviews

A review is not a session, it is a weeks-long stateful process. Issues are created from templates, checkboxes are edited in place, /create-next-issue infers position by reading labels and issue bodies written by an earlier invocation. In the old design, the downloaded per-package CLAUDE.md accidentally pinned the standard at review start; each package carried its own frozen copy. The refactor deliberately removes that pinning: one plugin, single-source checklists, distributed via a marketplace that reviewers update on their own schedules. In October 2026 Lars improves the checklist wording and issue template in v1.3. Three reviews are mid-flight on v1.2-format issues. A reviewer on v1.3 runs /create-next-issue; the skill cannot reconcile the old issue body (checkbox text no longer matches, a label was renamed), creates a duplicate data-review issue, and the state machine forks. Meanwhile a reviewer who never updated is applying the old standard, so two packages reviewed the same month meet different standards, precisely what single-sourcing was meant to prevent. The mess gets blamed on the plugin architecture and people retreat to copied commands.

Underlying assumption: that "one source of truth" and "reviews that span weeks across multiple users" are compatible without any migration or pinning story. The plan versions the tooling but never versions the review.

Early warning signs: (1) any plugin release merged while a pkgreview-* labeled issue is open, with no note on which reviews it applies to; (2) the first /create-next-issue or /review-status run that misreads an issue created by an earlier plugin version.

## Synthesis (step 5)

### 1. The most likely failure

F1, guardrails lost to progressive disclosure. It is a structural property of the skill architecture: skills load once at invocation and reference files can be compacted away, while the current STOP/check-in discipline works precisely because CLAUDE.md is in context on every turn. The first long review session is exposed. F2 (adoption fork) is a close second because the old copied commands keep working and nothing forces migration.

### 2. The most dangerous failure

F3, consolidation silently changes the review standard. Defects flow into published packages with permanent Zenodo DOIs and surface months later. There is no test harness for prompt workflows, so nothing catches it at refactor time. The known contradictions (compile_citation vs update_citation, missing CC BY 4.0 line, orphaned CSV) are live ammunition for this failure.

### 3. Likelihood x impact

- High probability, high damage: F1 guardrail regression, F3 silent standard drift, F2 adoption fork.
- High probability, lower damage: F6 state machine blamed on plugin, F5 refactor stalls half-finished.
- Lower probability, high damage: F7 lost per-package artifact, F8 version skew, F4 platform churn.

### 4. The hidden assumption

"Where instructions live doesn't change how they behave." The plan treats the system as documentation to reorganize; it is a behavioral program whose enforcement depends on always-in-context instructions, a per-package pinned standard, and version stability across a weeks-long review. Corollary: CLAUDE.md is two artifacts fused (reviewer workflow + package-resident standards); centralize the first, keep the second in each package.

### 5. The revised plan

1. Split CLAUDE.md into its two roles. Reviewer workflow moves into the plugin skills. Package-resident standards (vignettes/articles/, standard _pkgdown.yml, analysis/ dir, style) become a small versioned file still written into each package at review start, with a version stamp. (prevents F7, F8)
2. Guardrails live in always-loaded positions and mechanics. STOP and check-in rules go in each SKILL.md body, repeated at the point of action; never only in reference files. Add mechanical enforcement: branch protection on main in target repos; consider a PreToolUse hook blocking gh pr create --base main unless all four pkgreview labels are closed. (prevents F1)
3. Canonicalization as a reviewed diff. Reconciliation table of every checklist item across the 4 markdown copies and the 27-row CSV; decide each row explicitly; fix known bugs (compile_citation to update_citation, add the CC BY 4.0 check everywhere, "issues 1-5" to 4, delete review-package-slash-command.md, remove dead handlebars templates); commit the table. Test the new skill against a fixture package with planted defects and confirm every defect is caught. (prevents F3)
4. Verify platform behavior firsthand before building all skills. Prototype one read-only skill (review-status): test frontmatter fields, plugin-root path resolution from inside a target package directory, marketplace install on a second machine. Then convert the rest. (prevents F4)
5. Pin the review, not just the tooling. Stamp the plugin version into the first review issue body and the per-package standards file; create-next-issue reads the stamp and warns on mismatch. (prevents F8)
6. Kill the old path in the same release. Replace commands/*.md with thin deprecation stubs pointing at the plugin; update the README; run one 30-minute install session with the reviewers. (prevents F2, F5)
7. Timebox and phase. Phase 1 is conversion only; borrowed ideas (pkgcheck-style automated check reports posted into issues, inbo/checklist-style tag-triggered Zenodo release replacing the manual DOI pauses) are phase 2, after two real reviews on the plugin. (prevents F5)
8. Harden the two cheapest state-machine failures: create-next-issue dedupe guard (check for existing issue with the target label first); review-complete reports which specific label/branch reconciliation failed. (mitigates F6)

### 6. Kill criteria

1. If the read-only prototype skill cannot reliably read plugin reference files while running from a target package directory after one day of testing, stop the plugin approach and deduplicate content within the existing command files instead.
2. If during the first real plugin-driven review Claude violates a STOP or check-in even once, halt rollout to colleagues until guardrails are in SKILL.md bodies and a blocking hook exists.
3. If two months after release fewer than half of active reviewers have installed the plugin, either delete the legacy command files (force cutover) or formally revert to commands; do not run both systems past that date.

### 7. Pre-launch checklist

1. Reconciliation table of all checklist items committed and reviewed; every dropped item listed.
2. Fixture package with planted defects (wrong license, broken citation call, non-UTF-8 text, missing R-CMD-check) passes through the new skill; every defect caught.
3. Branch protection enabled on main in openwashdata data package repos.
4. Full workflow tested from a colleague's machine via the real marketplace install path.
5. Per-package standards file with version stamp is written by review-package and verified present in the fixture run.
