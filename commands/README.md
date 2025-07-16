# OpenWashData Package Review Slash Commands

This directory contains individual slash command files for the openwashdata R package review system. These files are designed to be copied to your `~/.claude/commands` folder for use with Claude Code.

## Installation

Copy the individual `.md` files to your Claude commands directory:

```bash
cp review-package.md ~/.claude/commands/
cp review-status.md ~/.claude/commands/
cp review-issue.md ~/.claude/commands/
cp review-pr.md ~/.claude/commands/
```

## Package Name Detection

The slash commands automatically detect the package name using the current working directory. Here's how it works:

### Automatic Detection

When you run any slash command from within a package directory, it uses:

```bash
PACKAGE_NAME=$(basename "$PWD")
```

This extracts the current directory name as the package name.

### Usage Examples

**If you're in the `glaas` package directory:**
```bash
cd /path/to/openwashdata/data-repos/glaas
```

Then these commands are equivalent:
- `/review-package` (uses current directory: "glaas")
- `/review-package glaas` (explicitly specified)

**Directory Structure Example:**
```
/Users/you/openwashdata/data-repos/
├── glaas/                    # basename = "glaas"
│   ├── DESCRIPTION
│   ├── R/
│   └── data/
├── worldhdi/                 # basename = "worldhdi"
│   ├── DESCRIPTION
│   ├── R/
│   └── data/
└── waterdata/                # basename = "waterdata"
    ├── DESCRIPTION
    ├── R/
    └── data/
```

### Variable Usage in Commands

The slash commands use these environment variables:

#### Primary Variables
- `$PACKAGE_NAME` - Current package name (from directory)
- `$ISSUE_NUMBER` - Issue number from command argument
- `$CURRENT_BRANCH` - Current git branch name
- `$CURRENT_ISSUE` - Issue number extracted from branch name

#### Branch-based Detection
For issue tracking, the commands detect the current issue from branch names:

```bash
CURRENT_BRANCH=$(git branch --show-current)
CURRENT_ISSUE=$(echo $CURRENT_BRANCH | grep -o '^[0-9]\+' || echo "unknown")
```

**Example branch names:**
- `1-general-information-metadata` → `CURRENT_ISSUE=1`
- `3-data-processing-review` → `CURRENT_ISSUE=3`
- `main` → `CURRENT_ISSUE=unknown`

#### Generated Variables
- `$PR_TITLE` - Generated PR title based on issue
- `$PR_SUMMARY` - Summary of changes made
- `$CHANGES_LIST` - List of modifications
- `$ISSUE_TITLE` - Title of the current issue
- `$ISSUE_SLUG` - URL-friendly version of issue title

## Available Commands

### `/review-package [package-name]`
**Purpose**: Start comprehensive package review
**Package Detection**: Uses current directory if no argument provided
**Auto-Setup**: Downloads latest CLAUDE.md from GitHub repository
**Usage**:
```bash
cd /path/to/package
/review-package                    # Uses current directory name + downloads CLAUDE.md
/review-package specific-package   # Uses specified name + downloads CLAUDE.md
```

**What happens automatically:**
1. Downloads latest CLAUDE.md from `https://raw.githubusercontent.com/openwashdata/pkgreview/main/CLAUDE.md`
2. Places CLAUDE.md in current package directory
3. Provides comprehensive review guide for the package
4. Starts the PLAN phase of review workflow

### `/review-status`
**Purpose**: Check current review progress
**Package Detection**: Always uses current directory
**Usage**:
```bash
cd /path/to/package
/review-status
```

### `/review-issue [number]`
**Purpose**: Work on specific issue (1-5)
**Package Detection**: Uses current directory
**Required Argument**: Issue number (1-5)
**Usage**:
```bash
cd /path/to/package
/review-issue 42   # Work on issue #42
/review-issue 45   # Work on issue #45
```

### `/review-pr`
**Purpose**: Create pull request for current issue
**Package Detection**: Uses current directory and git branch
**Context**: Automatically detects current issue from branch name
**Usage**:
```bash
cd /path/to/package
git checkout 43-data-content-quality  # Branch for issue #43
/review-pr                            # Creates PR for issue #43
```

## Best Practices

### 1. CLAUDE.md Auto-Download
The `/review-package` command automatically downloads the latest CLAUDE.md file:

```bash
cd /path/to/package
/review-package  # Downloads CLAUDE.md automatically
```

**Benefits:**
- Always have the latest review standards
- Package-specific review guide available locally
- Complete workflow documentation in the package directory
- No manual setup required

### 2. Always Run from Package Root
```bash
# ✅ Correct
cd /path/to/openwashdata/data-repos/glaas
/review-package

# ❌ Incorrect
cd /path/to/openwashdata/data-repos
/review-package glaas
```

### 2. Use Git Branch Naming Convention
The commands expect branches named: `[issue-number]-[descriptive-slug]`

```bash
# ✅ Correct branch names (using actual issue numbers)
42-general-information-metadata
43-data-content-quality
44-documentation
45-tests-ci-cd

# ❌ Incorrect branch names
feature/metadata-fix
issue-metadata
general-info
```

### 3. Check Package Structure
Ensure your package directory contains:
```
package-name/
├── DESCRIPTION      # Required for package detection
├── R/
├── data/
├── data-raw/
├── man/
└── README.Rmd
```

## Troubleshooting

### Package Not Found
If you get "Package not found" errors:
1. Ensure you're in the package root directory
2. Check that `DESCRIPTION` file exists
3. Verify directory name matches package name

### Issue Detection Failed
If issue detection fails:
1. Check your branch name follows the convention
2. Use `git branch --show-current` to verify branch name
3. Create proper branch with `gh issue develop [number]`

### Environment Variables
To debug variable detection, you can check values:
```bash
echo "Package: $(basename "$PWD")"
echo "Branch: $(git branch --show-current)"
echo "Issue: $(echo $(git branch --show-current) | grep -o '^[0-9]\+')"
```

## Integration with GitHub CLI

The commands integrate seamlessly with GitHub CLI workflow:

1. **Create issues**: `gh issue create`
2. **Create branch**: `gh issue develop [number]`
3. **Create PR**: `gh pr create` (handled by `/review-pr`)
4. **View status**: `gh pr list`, `gh issue list`

This ensures a smooth workflow from issue creation to PR merge.