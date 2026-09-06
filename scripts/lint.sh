#!/usr/bin/env bash
# Repository lint (openwashdata/pkgreview#72): skill path references resolve,
# no em dashes or emojis, a blank line after every markdown heading, VERSION
# is a semver and agrees with the plugin manifests; with LINT_CHECK_TAG=1 the
# newest tag must not be newer than VERSION (run on main only).
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
say() { echo "lint: $*"; }

# 1. ${CLAUDE_SKILL_DIR}/../<path> references in SKILL.md files resolve under skills/
while IFS= read -r ref; do
  rest=${ref#*\$\{CLAUDE_SKILL_DIR\}/../}
  [[ "$rest" == *"["* ]] && continue   # placeholder paths such as orgs/[org].md
  [[ -e "skills/$rest" ]] || { say "unresolved skill reference: $ref"; fail=1; }
done < <(grep -rhoE '\$\{CLAUDE_SKILL_DIR\}/\.\./[A-Za-z0-9_./\[\]-]+' skills/*/SKILL.md | sed -E 's/[.,;:)]+$//' | sort -u)

# 2. em dashes and emojis in tracked text files (python: macOS grep has no -P)
python3 scripts/lint_text.py || fail=1

# 3. blank line after every heading, outside fenced code blocks
while IFS= read -r f; do
  awk -v f="$f" '
    /^```/ { fence = !fence }
    { if (!fence && prev ~ /^#{1,6} / && $0 !~ /^$/) { print "lint: heading without a blank line after it: " f ":" NR-1; bad = 1 } prev = $0 }
    END { exit bad }' "$f" || fail=1
done < <(git ls-files '*.md')

# 4. VERSION is a semver
v=$(tr -d '[:space:]' < skills/pkgreview-core/VERSION)
[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { say "VERSION is not a semver: $v"; fail=1; }

# 5. plugin manifests agree with VERSION
if [[ -f .claude-plugin/plugin.json ]]; then
  pv=$(python3 -c 'import json,sys; print(json.load(open(".claude-plugin/plugin.json"))["version"])')
  [[ "$pv" == "$v" ]] || { say "plugin.json version $pv differs from VERSION $v"; fail=1; }
fi
if [[ -f .claude-plugin/marketplace.json ]]; then
  mv=$(python3 -c 'import json; m=json.load(open(".claude-plugin/marketplace.json")); print(m["plugins"][0]["version"])')
  [[ "$mv" == "$v" ]] || { say "marketplace.json plugin version $mv differs from VERSION $v"; fail=1; }
  python3 - <<'PY' || fail=1
import json, os
m = json.load(open(".claude-plugin/marketplace.json"))
bad = [p for p in m["plugins"][0]["skills"] if not os.path.isfile(os.path.join(p, "SKILL.md"))]
if bad: print("lint: marketplace.json names skills without SKILL.md:", bad); raise SystemExit(1)
PY
fi

# 6. the newest tag is never newer than VERSION (main only). VERSION may be
#    one release ahead of the tags between the release merge and
#    scripts/release.sh; the exact match at a tag is verified by the release
#    workflow (scripts/verify_release.sh).
if [[ "${LINT_CHECK_TAG:-0}" == "1" ]]; then
  t=$(git tag --list 'v*' | sort -V | tail -1)
  newest=$(printf '%s\n' "$t" "v$v" | sort -V | tail -1)
  if [[ "$newest" != "v$v" ]]; then
    say "newest tag $t is newer than VERSION $v"; fail=1
  elif [[ "$t" != "v$v" ]]; then
    say "VERSION $v is ahead of the newest tag $t; release pending (scripts/release.sh $v)"
  fi
fi

[[ $fail -eq 0 ]] && say "clean"
exit $fail
