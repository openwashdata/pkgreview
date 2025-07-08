# R Package Review System

A comprehensive, configurable system for reviewing R data packages, ensuring consistency, quality, and completeness across all published datasets. Originally developed for openwashdata, now available for any GitHub organization.

## Overview

This repository provides a structured review workflow for R packages, with automated GitHub integration and quality checks. The review process follows a systematic **PLAN → CREATE → TEST → DEPLOY** workflow.

## Quick Start

### For New Organizations

```bash
# Clone this repository
git clone https://github.com/openwashdata/pkgreview.git
cd pkgreview

# Run the setup command to configure for your organization
/setup-review

# Follow the interactive prompts to configure:
# - Your GitHub organization name
# - Template package preferences
# - Analytics settings
# - Funding acknowledgments

# The setup will generate customized files for your organization
```

### For openwashdata Users (Default Configuration)

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

## Configuration

The review system can be customized for any organization through the `config.yml` file:

```yaml
organization:
  name: "your-org-name"
  github_url: "https://github.com/your-org-name"
  
template:
  package: "washr"  # or your template package
  citation_function: "washr::update_citation"
  
analytics:
  enabled: true
  type: "plausible"  # or google, matomo, etc.
  
funding:
  enabled: true
  use_default: true  # Uses ETH ORD funding text by default
  custom_text: ""    # Or provide your own funding text
```

## Review Workflow

The review follows a simple **PLAN → CREATE → TEST → DEPLOY** workflow:

1. **PLAN**: Analyze package structure and create 4 review issues
2. **CREATE**: Fix issues systematically with GitHub CLI integration
3. **TEST**: Run comprehensive R package checks
4. **DEPLOY**: Build pkgdown website and prepare for publication

## Available Commands

| Command | Purpose | Usage |
|---------|---------|-------|
| `/setup-review` | Configure for your organization | `/setup-review` |
| `/review-package` | Start package review | `/review-package [package-name]` |
| `/review-status` | Check review progress | `/review-status` |
| `/review-issue [n]` | Work on specific issue | `/review-issue 1` |
| `/create-next-issue` | Create next issue in sequence | `/create-next-issue` |
| `/review-pr` | Create pull request | `/review-pr` |
| `/create-release` | Create a new release | `/create-release [version]` |

## Review Issues

Each review addresses 4 key areas:

1. **General Information & Metadata** - DESCRIPTION, citations, authors
2. **Data Content & Processing** - Data integrity, formats, exports, processing scripts
3. **Documentation** - README, pkgdown, function docs
4. **Tests & CI/CD** - R CMD check, GitHub Actions

## Requirements

- R and RStudio
- GitHub CLI (`gh`)
- Git
- Python 3 (for template processing)
- Claude Code with slash commands enabled

## Repository Structure

```
pkgreview/
├── commands/              # Slash command files
│   ├── *.md              # Original commands (openwashdata)
│   ├── *.md.template     # Template commands with placeholders
│   └── setup-review.md   # Interactive setup command
├── config.yml.template    # Configuration template
├── CLAUDE.md             # Original review guide (openwashdata)
├── CLAUDE.md.template    # Template review guide with placeholders
├── process_templates.py  # Template processor script
├── docs/                 # Documentation and resources
├── README.md             # This file
└── pkgreview.Rproj       # RStudio project file
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

- **Multi-Organization Support**: Configure for any GitHub organization
- **Automatic Setup**: Interactive configuration with `/setup-review`
- **GitHub Integration**: Creates issues, branches, and PRs automatically
- **Smart Detection**: Uses current directory as package name
- **Quality Checks**: Ensures consistency across all packages
- **Comprehensive Review**: Detailed checklist covering all aspects of package quality
- **Reproducible Workflow**: Standardized process for all reviewers
- **Customizable Standards**: Adapt to your organization's needs

## Customization Guide

### Setting Up for Your Organization

1. Run `/setup-review` and answer the prompts
2. The system will create a `config.yml` with your settings
3. Template files will be processed automatically
4. Start reviewing packages with your custom configuration

### Manual Configuration

1. Copy `config.yml.template` to `config.yml`
2. Edit the configuration values
3. Run `python3 process_templates.py` to generate custom files
4. Your customized review system is ready

### Template Placeholders

The template files use these placeholders:
- `{{ORGANIZATION_NAME}}` - Your GitHub organization
- `{{TEMPLATE_PACKAGE}}` - Your R template package
- `{{CITATION_FUNCTION}}` - Function for updating citations
- `{{LICENSE}}` - Required license for packages
- `{{ANALYTICS_*}}` - Analytics configuration
- `{{FUNDING_*}}` - Funding acknowledgment settings

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

## Acknowledgments

This review system was originally developed for the openwashdata organization with funding from the Open Research Data Program of the ETH Board.

## License

MIT © openwashdata