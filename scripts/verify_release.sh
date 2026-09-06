#!/usr/bin/env bash
# Verify that the files the skills fetch by stamped version resolve at a tag
# (openwashdata/pkgreview#73). Usage: scripts/verify_release.sh v1.6.0
set -euo pipefail
tag="${1:?usage: scripts/verify_release.sh <tag>}"
base="https://raw.githubusercontent.com/openwashdata/pkgreview/$tag"
files=(
  skills/pkgreview-core/VERSION
  skills/pkgreview-core/WASHR_FLOOR
  skills/pkgreview-core/references/checklists/metadata.md
  skills/pkgreview-core/references/checklists/data.md
  skills/pkgreview-core/references/checklists/docs.md
  skills/pkgreview-core/references/checklists/tests.md
  skills/pkgreview-core/references/orgs/openwashdata.md
  skills/pkgreview-core/references/orgs/global-health-engineering.md
  skills/pkgreview-core/references/standards.md
  skills/pkgreview-core/references/templates/_pkgdown.yml
  docs/checklist-reconciliation.md
)
status=0
for f in "${files[@]}"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$base/$f")
  printf '%s %-62s %s\n' "$tag" "$f" "$code"
  [[ "$code" == "200" ]] || status=1
done
v=$(curl -s "$base/skills/pkgreview-core/VERSION" | tr -d '[:space:]')
[[ "v$v" == "$tag" ]] || { echo "VERSION at $tag reads $v"; status=1; }
exit $status
