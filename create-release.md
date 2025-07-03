# /create-release

Create a new release for an openwashdata R package with proper versioning and changelog.

## Usage

```
/create-release [version]
```

## Parameters

- `version`: Semantic version number (e.g., 0.1.0, 1.2.3)

## Process

1. **Zenodo Check-In**
   - **STOP**: "Before proceeding with the release, please ensure the repository is synced on Zenodo. Have you synced the repo on Zenodo? (yes/no)"
   - If yes: "Please provide the DOI for this version (format: 10.5281/zenodo.XXXXXXX):"
   - Store DOI for citation update

2. **Version Update**
   - Updates DESCRIPTION file with new version
   - Uses `usethis::use_version()` for proper version bumping

3. **Citation Update**
   - Updates CITATION.cff with new version and release date
   - Runs `washr::update_citation(doi = "10.5281/zenodo.XXXXXXX")` with provided DOI
   - Ensures version consistency across all citation files
   - Adds Zenodo DOI to all citation formats

4. **Changelog Management**
   - Creates/updates NEWS.md using tidyverse conventions
   - Adds release section with date and changes
   - Pulls information from recent commits and closed issues

5. **Git Operations**
   - Commits version, CITATION.cff, and NEWS.md changes
   - Creates annotated tag for the version
   - Pushes to main branch

6. **GitHub Release**
   - Creates GitHub release using `gh release create`
   - Uses NEWS.md content as release notes
   - Attaches appropriate assets

7. **Documentation Update**
   - Rebuilds pkgdown site
   - Deploys updated documentation

## Example

```bash
/create-release 0.2.0
```

This will:
- Update version from 0.1.0 to 0.2.0
- Update CITATION.cff with new version and date
- Add new section to NEWS.md
- Create git tag v0.2.0
- Create GitHub release
- Update package website

## Prerequisites

- All changes merged to main branch
- No uncommitted changes
- Valid semantic version number
- R with usethis and washr packages installed
- Repository connected to Zenodo for DOI generation