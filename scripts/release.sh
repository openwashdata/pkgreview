#!/usr/bin/env bash
# Release tail (openwashdata/pkgreview#73): after the dev-to-main PR merged,
# tag the merge commit, verify the pinned raw URLs, create the GitHub release
# from NEWS.md, and fast-forward dev. Idempotent: an existing tag or release
# is kept, the verification and the sync run again.
#   bash scripts/release.sh 1.6.0        (from main, clean, at origin/main)
set -euo pipefail
v="${1:?usage: scripts/release.sh <version>}"
cd "$(dirname "$0")/.."
[[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "not a semver: $v"; exit 1; }
[[ "$(git branch --show-current)" == "main" ]] || { echo "switch to main first (git checkout main)"; exit 1; }
[[ -z "$(git status --porcelain)" ]] || { echo "working tree not clean"; exit 1; }
git fetch -q origin
[[ "$(git rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] || { echo "main is not at origin/main; pull first"; exit 1; }
[[ "$(tr -d '[:space:]' < skills/pkgreview-core/VERSION)" == "$v" ]] || { echo "skills/pkgreview-core/VERSION reads $(cat skills/pkgreview-core/VERSION), not $v"; exit 1; }
if git rev-parse -q --verify "refs/tags/v$v" >/dev/null; then
  echo "tag v$v exists at $(git rev-parse --short "v$v^{commit}"); keeping it"
else
  git tag -a "v$v" -m "pkgreview review standard v$v"
  echo "tagged v$v at $(git rev-parse --short HEAD)"
fi
git push origin "v$v"
bash scripts/verify_release.sh "v$v"
if gh release view "v$v" >/dev/null 2>&1; then
  echo "GitHub release v$v exists; keeping it"
else
  gh release create "v$v" --title "v$v" --notes-file <(bash scripts/news_section.sh "$v") >/dev/null
  echo "GitHub release v$v created from NEWS.md"
fi
git checkout -q dev && git merge -q --ff-only main && git push -q origin dev && git checkout -q main
echo "dev synced to main at $(git rev-parse --short main)"
echo "install: claude plugin update pkgreview (plugin install) or cp -R skills/* ~/.claude/skills/ (copy install)"
