#!/usr/bin/env bash
# Stand up or tear down the throwaway repository for the interactive fixture
# gate (openwashdata/pkgreview#80, procedure in #17).
#
#   bash fixtures/make_review_fixture.sh create [org] [name] [dir]
#   bash fixtures/make_review_fixture.sh delete [org] [name] [dir]
#
# Defaults: org openwashdata, name pkgreviewtest, dir ~/tmp/<name>. The org
# must be registered (a profile in skills/pkgreview-core/references/orgs/),
# because /review-package stops on an unregistered one. The repository is
# private: the fixture carries synthetic phone numbers and is defective by
# design. Delete it after the run.
set -euo pipefail
cd "$(dirname "$0")/.."
cmd="${1:-}"; org="${2:-openwashdata}"; name="${3:-pkgreviewtest}"; dir="${4:-$HOME/tmp/$name}"
profile="skills/pkgreview-core/references/orgs/$(echo "$org" | tr '[:upper:]' '[:lower:]').md"
case "$cmd" in
  create)
    [[ -f "$profile" ]] || { echo "organization $org is not registered (no $profile); /review-package would stop at Step 0"; exit 1; }
    [[ -e "$dir" ]] && { echo "$dir exists; delete first"; exit 1; }
    mkdir -p "$(dirname "$dir")"
    cp -R fixtures/pkgreviewtest "$dir"; rm -f "$dir/.DS_Store"
    (cd "$dir" && git init -q -b main && git add -A && git commit -q -m "Fixture package for the pkgreview review workflow test (#17)")
    (cd "$dir" && gh repo create "$org/$name" --private --source . --push --description "Throwaway pkgreview fixture for the #17 workflow run; delete after" >/dev/null)
    echo "created $org/$name (private) from $dir at $(git -C "$dir" rev-parse --short HEAD)"
    echo "next: open a Claude Code session in $dir and type /review-package, paste https://github.com/$org/$name"
    echo "after the run: bash fixtures/make_review_fixture.sh delete $org $name $dir"
    ;;
  delete)
    gh repo delete "$org/$name" --yes && echo "deleted $org/$name"
    rm -rf "$dir" && echo "removed $dir"
    ;;
  *) echo "usage: $0 create|delete [org] [name] [dir]"; exit 1 ;;
esac
