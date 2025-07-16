# openwashdata Package Review System

A comprehensive system for reviewing R data packages in the openwashdata ecosystem, ensuring consistency, quality, and completeness across all published datasets.

## Overview

This repository provides a structured review workflow for openwashdata R packages, with automated GitHub integration and quality checks. The review process follows a systematic **PLAN → CREATE → TEST → DEPLOY** workflow.

## Quick Start

```bash
# Clone this repository
git clone https://github.com/openwashdata/pkgreview.git
cd pkgreview

# Install the slash commands
mkdir -p ~/.claude/commands
cp commands/*.md ~/.claude/commands/

# Navigate to the package you want to review
cd /path/to/package

# Start the review
/review-package
```

That's it! The review system will guide you through the entire process.

## Review Workflow

The review follows a simple **PLAN → CREATE → TEST → DEPLOY** workflow:

1. **PLAN**: Analyze package structure and create 5 review issues
2. **CREATE**: Fix issues systematically with GitHub CLI integration
3. **TEST**: Run comprehensive R package checks
4. **DEPLOY**: Build pkgdown website and prepare for publication

## Available Commands

| Command | Purpose | Usage |
|---------|---------|-------|
| `/review-package` | Start package review | `/review-package [package-name]` |
| `/review-status` | Check review progress | `/review-status` |
| `/review-issue [n]` | Work on specific issue | `/review-issue 42` |
| `/review-pr` | Create pull request | `/review-pr` |
| `/create-next-issue` | Create next review issue | `/create-next-issue` |
| `/review-complete` | Create final PR to main | `/review-complete` |
| `/create-release` | Create a new release | `/create-release [version]` |

## Review Issues

Each review addresses 4 key areas:

1. **General Information & Metadata** - DESCRIPTION, citations, authors (label: `pkgreview-metadata`)
2. **Data Content & Processing** - Data integrity, formats, exports, processing scripts (label: `pkgreview-data`)
3. **Documentation** - README, pkgdown, function docs (label: `pkgreview-docs`)
4. **Tests & CI/CD** - R CMD check, GitHub Actions (label: `pkgreview-tests`)

## Requirements

- R and RStudio
- GitHub CLI (`gh`)
- Git
- Claude Code with slash commands enabled

## Repository Structure

```
pkgreview/
├── commands/           # Slash command files
│   ├── README.md      # Commands documentation
│   ├── review-package.md
│   ├── review-status.md
│   ├── review-issue.md
│   ├── review-pr.md
│   └── create-release.md
├── docs/              # Documentation and resources
│   └── review-checklist.csv
├── .github/           # GitHub configuration
│   └── workflows/
│       └── R-CMD-check.yaml
├── CLAUDE.md          # Review workflow guide for Claude
├── README.md          # This file
└── pkgreview.Rproj    # RStudio project file
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

- **Automatic Setup**: Downloads latest review standards (CLAUDE.md) to each package
- **GitHub Integration**: Creates issues, branches, and PRs automatically
- **Smart Detection**: Uses current directory as package name
- **Quality Checks**: Ensures consistency across all packages
- **Comprehensive Review**: 27-point checklist covering all aspects of package quality
- **Reproducible Workflow**: Standardized process for all reviewers

## Review Checklist

The review process uses a comprehensive checklist covering:

- General information and metadata
- Data content and quality 
- Data processing reproducibility
- Documentation completeness
- Testing and CI/CD setup

See `docs/review-checklist.csv` for the complete list of review points.

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