# /create-release

Create a new release for an openwashdata R package with proper versioning and changelog.

## Usage

```
/create-release [version]
```

## Parameters

- `version`: Semantic version number (e.g., 0.1.0, 1.2.3)

## Process

1. **Pre-Release Zenodo Check**
   - **STOP**: "Before proceeding, please ensure the repository is enabled/synced on Zenodo. Is Zenodo integration enabled for this repo? (yes/no)"
   - If no: "Please enable Zenodo integration at https://zenodo.org/account/settings/github/ then continue"

2. **Version Update**
   - Updates DESCRIPTION file with new version
   - Uses `usethis::use_version()` for proper version bumping

3. **Changelog Management**
   - Creates/updates NEWS.md using tidyverse conventions
   - Adds release section with date and changes
   - Pulls information from recent commits and closed issues

4. **Git Operations**
   - Commits version and NEWS.md changes
   - Creates annotated tag for the version
   - Pushes to main branch

5. **GitHub Release**
   - Creates GitHub release using `gh release create`
   - Uses NEWS.md content as release notes
   - Attaches appropriate assets
   - **Zenodo automatically creates DOI after release**

6. **Post-Release DOI Update**
   - **STOP**: "GitHub release created! Zenodo should now generate a DOI. Please check https://zenodo.org/account/settings/github/repository/openwashdata/[package-name] and provide the DOI (format: 10.5281/zenodo.XXXXXXX):"
   - After DOI is provided:
     - Runs `washr::update_citation(doi = "10.5281/zenodo.XXXXXXX")` to update all citation files
     - Updates README.Rmd with Zenodo DOI badge
     - Commits DOI updates with message "Add Zenodo DOI to package"

7. **Documentation Update**
   - Rebuilds pkgdown site with DOI badge
   - Deploys updated documentation

## Example

```bash
/create-release 0.2.0
```

This will:
- Update version from 0.1.0 to 0.2.0
- Add new section to NEWS.md
- Create git tag v0.2.0
- Create GitHub release
- Update package website with DOI badge after DOI is provided

## Prerequisites

- All changes merged to main branch
- No uncommitted changes
- Valid semantic version number
- R with usethis and washr packages installed
- Repository connected to Zenodo for DOI generation