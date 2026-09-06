# openwashdata Package Review System

A comprehensive system for reviewing R data packages in the openwashdata ecosystem, ensuring consistency, quality, and completeness across all published datasets.

## Overview

This repository provides a structured review workflow for R data packages in registered organizations (openwashdata and Global Health Engineering), with GitHub integration and a deterministic check script. A review runs issue-per-area on the package's `dev` branch and ends with one pull request from `dev` to `main`.

The review standard has two tiers. Required items are the publication floor: a package is not published until every required item passes. Advisory items are quality improvements; the reviewer may fix them or record them as optional follow-ups, and they never block publication. The tier of every item is recorded in the checklists under `skills/pkgreview-core/references/checklists/`.

Creating a data package for one of the registered organizations? Start with the [contributor guidebook](docs/guidebook.md). It covers the PII and sensitivity check to run before committing data anywhere, the publication floor, the dictionary, and what review and publication look like; for the scaffolding steps it points at the washr Get started vignette.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/openwashdata/pkgreview.git
cd pkgreview

# Install the skills. Either as the plugin (one command to update later):
claude plugin marketplace add openwashdata/pkgreview
claude plugin install pkgreview@pkgreview
# or as copies (re-run after every git pull to update); not both, the two
# would provide the same skill names:
mkdir -p ~/.claude/skills
cp -R skills/* ~/.claude/skills/

# Navigate to the package you want to review
cd /path/to/package

# Start the review (in a Claude Code session)
/review-package
```

The review system guides you through the entire process. Symlinking the
skill directories instead of copying also executes correctly, but skill
discovery/validation has known bugs with symlinks in current Claude Code
versions; copying is the reliable path.

If you previously installed the slash commands (the pre-skill workflow),
remove them: `rm ~/.claude/commands/review-*.md ~/.claude/commands/create-*.md`.

## Review Workflow

`/review-package` asks for the repository URL, resolves the organization profile, runs the PII and sensitivity intake screen (current files and git history), writes the version-stamped standards file into the package, and opens the first of four review issues. Each area (metadata, data, documentation, tests) gets one issue and one pull request into `dev`, worked through `/review-issue` with a single plan approval; `/create-next-issue` closes the finished issue and opens the next. When all four are merged, `/review-complete` opens the single pull request from `dev` to `main`, and `/create-release` and `/add-doi` handle the release, the Zenodo DOI, and the dev sync afterwards.

## Available Commands

All commands are Claude Code skills with `disable-model-invocation: true`:
they run only when you type them, never on the model's own initiative.

| Command | Purpose | Usage |
|---------|---------|-------|
| `/review-package` | Start package review | `/review-package [package-name]` |
| `/review-status` | Check review progress, surface state anomalies | `/review-status` |
| `/review-issue [n]` | Work on a review issue (actual issue number) | `/review-issue 42` |
| `/create-next-issue` | Create next review issue | `/create-next-issue` |
| `/review-complete` | Create final PR to main | `/review-complete` |
| `/review-upgrade` | Bring a reviewed package to the installed standard with one issue of changed items | `/review-upgrade` |
| `/create-release` | Create a new release | `/create-release [version]` |
| `/add-doi` | Integrate a Zenodo DOI after release (resume or repair path) | `/add-doi 10.5281/zenodo.XXXXXXX` |

PR creation for an issue happens inside `/review-issue` (step 7); there is
no separate `/review-pr` anymore.

## Review Issues

Each review addresses 4 key areas:

1. **General Information & Metadata** - DESCRIPTION, citations, authors (label: `pkgreview-metadata`)
2. **Data Content & Processing** - Data integrity, formats, exports, processing scripts (label: `pkgreview-data`)
3. **Documentation** - README, pkgdown, function docs (label: `pkgreview-docs`)
4. **Tests & CI/CD** - R CMD check, GitHub Actions (label: `pkgreview-tests`)

## Requirements

- R and RStudio
- R packages on the reviewer's machine: `washr` 1.1.0 or newer (keeps
  DESCRIPTION, CITATION.cff, and inst/CITATION in sync and owns the site
  metadata; packages in the registered orgs are scaffolded with it), plus
  `desc`, `devtools`, `pkgdown`, and `usethis` for checks, site previews,
  and releases
- GitHub CLI (`gh`)
- Git
- Claude Code (the workflow ships as skills; see Quick Start)

Compatibility (the floor is recorded in `skills/pkgreview-core/WASHR_FLOOR`
and checked weekly by CI):

| pkgreview | washr |
|-----------|-------|
| 1.0.0 to 1.4.0 | 1.0.1, with the caveats the skills carried |
| 1.5.0 and later | >= 1.1.0 |

## Repository Structure

```
pkgreview/
├── skills/                    # Claude Code skills (the review workflow)
│   ├── review-package/
│   ├── review-issue/
│   ├── create-next-issue/
│   ├── review-status/
│   ├── review-complete/
│   ├── review-upgrade/
│   ├── create-release/
│   ├── add-doi/
│   └── pkgreview-core/        # Shared references (not a skill)
│       ├── VERSION            # Review standard version
│       ├── WASHR_FLOOR        # Lowest washr version the skills support
│       ├── check/             # Deterministic check script
│       └── references/
│           ├── checklists/    # Canonical checklists, one per review area
│           ├── templates/     # Issue body, PR body, _pkgdown.yml
│           ├── orgs/          # Registered organization profiles
│           ├── standards.md   # Package-resident standards file
│           └── recovery.md    # State failure modes and recovery paths
├── fixtures/                  # Defective test package, scorecard, history fixture,
│                              # expected reports, check-script cases, throwaway script
├── scripts/                   # release.sh, verify_release.sh, lint.sh, washr_drift.R
├── hooks/                     # Optional PreToolUse hook (docs/guardrails.md)
├── docs/
│   ├── guidebook.md           # Contributor guidebook
│   ├── checklist-reconciliation.md
│   ├── guardrails.md
│   └── roadmap-v1.1.md
├── .github/workflows/         # gate (fixture gate, cases, lint), washr-drift, release
├── .claude-plugin/            # Plugin manifests (version mirrors VERSION)
├── NEWS.md                    # Release notes for non-checklist changes
├── CLAUDE.md                  # Guide for Claude sessions in THIS repo
├── README.md                  # This file
└── pkgreview.Rproj            # RStudio project file
```

## Expected Package Structure

The packages being reviewed should follow this structure:

```
your-package/
├── DESCRIPTION      # Package metadata
├── R/               # R functions
├── data/            # Processed data (.rda)
├── data-raw/        # Raw data & processing scripts
├── inst/extdata/    # CSV/Excel exports
├── man/             # Documentation
├── _pkgdown.yml     # Website config
└── README.Rmd       # Package documentation
```

## Key Features

- **Automatic Setup**: Writes the version-stamped standards file into each reviewed package (as its CLAUDE.md)
- **GitHub Integration**: Creates issues, branches, and PRs automatically
- **Smart Detection**: Uses current directory as package name
- **Quality Checks**: Ensures consistency across all packages
- **Comprehensive Review**: canonical checklists covering all aspects of package quality
- **Reproducible Workflow**: Standardized process for all reviewers

## Review Checklist

The review process uses one canonical checklist per review area, in
`skills/pkgreview-core/references/checklists/`:

- `metadata.md` - General information and metadata
- `data.md` - Data content, quality, and processing reproducibility
- `docs.md` - Documentation completeness
- `tests.md` - Testing and CI/CD setup

Issue and PR bodies are built from the templates in
`skills/pkgreview-core/references/templates/`. The record of how the
previously diverging checklist copies were merged is in
`docs/checklist-reconciliation.md`.

Checklist and template changes get a version bump
(`skills/pkgreview-core/VERSION` plus a git tag through
`scripts/release.sh`); in-flight reviews finish on the version stamped into
their first review issue, and `/review-upgrade` moves a published package
to a newer standard with one issue of changed items. CI runs the check
script against `fixtures/pkgreviewtest/` on every push and diffs the
report against `fixtures/expected/`, so every planted defect in
`fixtures/SCORECARD.md` stays caught.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Resources

- [openwashdata Organization](https://github.com/openwashdata)
- [Package Development Guide](https://r-pkgs.org/)
- [pkgdown Documentation](https://pkgdown.r-lib.org/)

## License

MIT © openwashdata