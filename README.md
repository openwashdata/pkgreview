# openwashdata Package Review System

A streamlined workflow for reviewing R data packages in the openwashdata ecosystem.

## Quick Start

```bash
# Navigate to the package you want to review
cd /path/to/package

# Start the review
/review-package
```

That's it! The review system will guide you through the entire process.

## Installation

Copy the commands to your Claude commands directory:

```bash
mkdir -p ~/.claude/commands
cp commands/*.md ~/.claude/commands/
```

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
| `/review-issue [n]` | Work on specific issue | `/review-issue 1` |
| `/review-pr` | Create pull request | `/review-pr` |

## Review Issues

Each review addresses 5 key areas:

1. **General Information & Metadata** - DESCRIPTION, citations, authors
2. **Data Content & Quality** - Data integrity, formats, exports
3. **Data Processing** - Reproducibility, documentation, raw data
4. **Documentation** - README, pkgdown, function docs
5. **Tests & CI/CD** - R CMD check, GitHub Actions

## Requirements

- R and RStudio
- GitHub CLI (`gh`)
- Git
- Claude Code with slash commands enabled

## Project Structure

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

- **Automatic Setup**: Downloads latest review standards
- **GitHub Integration**: Creates issues, branches, and PRs
- **Smart Detection**: Uses current directory as package name
- **Quality Checks**: Ensures consistency across all packages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT © openwashdata