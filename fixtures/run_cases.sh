#!/usr/bin/env bash
# Check-script case suite (openwashdata/pkgreview#72). Each case under
# fixtures/cases/<name>/ is an overlay applied to a copy of pkgreviewtest,
# an optional setup.sh run inside the copy, and an expected.txt whose lines
# must each appear verbatim in the report (grep -F). Cases are the synthetic
# checks that verified new check lines; add one per new line.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$PWD
CHECK=$ROOT/skills/pkgreview-core/check/pkgreview-check.R
status=0
for case in fixtures/cases/*/; do
  name=$(basename "$case")
  tmp=$(mktemp -d)
  cp -R fixtures/pkgreviewtest/. "$tmp/"
  [[ -d "$case/overlay" ]] && cp -R "$case/overlay/." "$tmp/"
  if [[ -f "$case/setup.sh" ]]; then (cd "$tmp" && bash "$ROOT/$case/setup.sh"); fi
  args=(); [[ -f "$case/args" ]] && read -r -a args < "$case/args"
  report=$(Rscript "$CHECK" "$tmp" "${args[@]:---org=openwashdata}" 2>&1 || true)
  ok=1
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! grep -F -q -- "$line" <<< "$report"; then echo "case $name: MISSING: $line"; ok=0; fi
  done < "$case/expected.txt"
  if [[ $ok -eq 1 ]]; then echo "case $name: ok"; else status=1; echo "$report" | sed 's/^/    /' | grep -E "FAIL|PASS|NOT RUN" | head -40; fi
  rm -rf "$tmp"
done
exit $status
