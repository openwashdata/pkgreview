#!/usr/bin/env bash
# Print the NEWS.md section for one version (the text between its heading and
# the next top-level heading). Usage: scripts/news_section.sh 1.6.0
set -euo pipefail
v="${1:?usage: scripts/news_section.sh <version>}"
cd "$(dirname "$0")/.."
awk -v h="# pkgreview $v" '
  $0 == h { on = 1; next }
  on && /^# / { exit }
  on { print }' NEWS.md | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
