#!/usr/bin/env bash
# PreToolUse hook for Claude Code: block `gh pr create --base main` (or a
# bare `gh pr create`, which defaults to the repo default branch) while
# pkgreview review issues are still open in the current repository.
#
# Exit 0 lets the tool call through; exit 2 blocks it and feeds stderr back
# to Claude. Requires jq and gh. Fails open by design: if gh cannot reach
# GitHub, the call is allowed (the prompt-level guardrails still apply).

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

case "$cmd" in
  *"gh pr create"*) ;;
  *) exit 0 ;;
esac

# Extract the base branch. No --base flag means gh targets the default
# branch (main for openwashdata repos), so that case is checked too.
base=$(printf '%s' "$cmd" | grep -oE -- '--base[= ]+"?[^ "]+' | head -1 | sed -E 's/--base[= ]+"?//')
if [ -n "$base" ] && [ "$base" != "main" ]; then
  exit 0
fi

count=0
for label in pkgreview-metadata pkgreview-data pkgreview-docs pkgreview-tests; do
  n=$(gh issue list --label "$label" --state open --json number --jq 'length' 2>/dev/null || echo 0)
  count=$((count + ${n:-0}))
done

if [ "$count" -gt 0 ]; then
  {
    echo "BLOCKED: PR against main while $count pkgreview review issue(s) are still open."
    echo "Per-issue PRs go to dev (gh pr create --base dev)."
    echo "Only /review-complete opens the final dev-to-main PR, after all four review issues are closed."
  } >&2
  exit 2
fi

exit 0
