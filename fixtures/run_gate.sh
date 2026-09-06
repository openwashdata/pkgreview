#!/usr/bin/env bash
# Mechanical fixture gate as a golden-file test (openwashdata/pkgreview#72).
# Runs the check script on fixtures/pkgreviewtest and on the history fixture,
# normalizes the package path line, and diffs against fixtures/expected/.
# Pass --update to rewrite the expected reports (a deliberate, reviewed change).
set -euo pipefail
cd "$(dirname "$0")/.."
CHECK=skills/pkgreview-core/check/pkgreview-check.R
update=0; [[ "${1:-}" == "--update" ]] && update=1
normalize() { sed -E 's|^Package: `.*`|Package: `(normalized)`|'; }
status=0
run_one() {
  local name="$1" dir="$2"; shift 2
  local out; out=$(mktemp)
  Rscript "$CHECK" "$dir" "$@" 2>&1 | normalize > "$out" || true
  if [[ $update -eq 1 ]]; then
    cp "$out" "fixtures/expected/$name.md"; echo "updated fixtures/expected/$name.md"
  elif diff -u "fixtures/expected/$name.md" "$out"; then
    echo "gate: $name matches fixtures/expected/$name.md"
  else
    echo "gate: $name DIFFERS from fixtures/expected/$name.md (see diff above)"; status=1
  fi
  rm -f "$out"
}
run_one pkgreviewtest fixtures/pkgreviewtest --org=openwashdata
HIST=$(bash fixtures/make_history_fixture.sh)
run_one history "$HIST" --org=openwashdata
rm -rf "$HIST"
# Scorecard reconciliation summary for the log: FAIL and FLAG lines are findings.
n_fail=$(grep -c '^- \[FAIL\]' fixtures/expected/pkgreviewtest.md || true)
n_flag=$(grep -c '^- \[FLAG\]' fixtures/expected/pkgreviewtest.md || true)
echo "gate: pkgreviewtest expected report carries $n_fail FAIL and $n_flag FLAG lines (scorecard: 19 + 1 for D1 to D17)"
exit $status
