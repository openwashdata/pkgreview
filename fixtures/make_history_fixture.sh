#!/usr/bin/env bash
#
# make_history_fixture.sh
#
# Builds a throwaway git repository whose HISTORY carries identifying data
# that no longer exists in the working tree, to exercise the git-history
# PII scan added in issue #52 (scorecard defect D18).
#
# The fixture package fixtures/pkgreviewtest/ has no git history of its own
# (it lives inside the tooling repo), so the history defect cannot be a
# static file like D1-D17. This script synthesizes the repo on demand, in a
# temporary directory, so nothing with a nested .git is committed to the
# tooling repo.
#
# Planted history defect (D18):
#   A first commit adds inst/extdata/facilities.csv with a `gps_latitude`,
#   `gps_longitude`, and `owner_phone` column. A second commit removes
#   those columns. The working tree at HEAD is clean; the identifiers are
#   only in the first revision. The check script's git-history FLAG must
#   name facilities.csv.
#
# Usage:
#   make_history_fixture.sh [target-dir]
# Prints the path to the created repo on stdout. If no target-dir is given,
# a mktemp directory is used. Deterministic: fixed dates and author, no RNG.

set -euo pipefail

target="${1:-$(mktemp -d -t pkgreview-history-fixture.XXXXXX)}"
mkdir -p "$target/inst/extdata" "$target/data-raw"

export GIT_AUTHOR_NAME="Fixture Bot"
export GIT_AUTHOR_EMAIL="fixture@example.org"
export GIT_COMMITTER_NAME="Fixture Bot"
export GIT_COMMITTER_EMAIL="fixture@example.org"
export GIT_AUTHOR_DATE="2024-01-01T00:00:00 +0000"
export GIT_COMMITTER_DATE="2024-01-01T00:00:00 +0000"

git -C "$target" init -q
git -C "$target" symbolic-ref HEAD refs/heads/main

# Minimal package skeleton so the scan has a real data path to walk.
cat > "$target/DESCRIPTION" <<'EOF'
Package: historyfixture
Title: History Scan Fixture
Version: 0.0.1
EOF

# Commit 1: identifiers present in a text data file.
cat > "$target/inst/extdata/facilities.csv" <<'EOF'
facility_id,region,gps_latitude,gps_longitude,owner_phone
F-001,North,-13.9626,33.7741,+265 991 234 567
F-002,South,-15.7861,35.0058,+265 992 345 678
F-003,East,-14.4692,35.3208,+265 993 456 789
EOF
git -C "$target" add -A
git -C "$target" commit -q -m "Add facility locations with GPS and owner phone"

# Commit 2: drop the identifying columns. Working tree is now clean.
cat > "$target/inst/extdata/facilities.csv" <<'EOF'
facility_id,region
F-001,North
F-002,South
F-003,East
EOF
export GIT_AUTHOR_DATE="2024-02-01T00:00:00 +0000"
export GIT_COMMITTER_DATE="2024-02-01T00:00:00 +0000"
git -C "$target" add -A
git -C "$target" commit -q -m "Remove GPS coordinates and phone numbers from facilities"

echo "$target"
