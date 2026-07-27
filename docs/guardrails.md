# Guardrails: keeping the review discipline enforced

The workflow's core value is enforced discipline: check-ins before commits, a
hard STOP after each PR, PRs only against `dev` until the final dev-to-main
PR. The premortem rated the loss of these guardrails the most likely failure
of the skill refactor. Enforcement is layered; no layer relies on a
progressively disclosed reference file.

## Layer 1: prompt level (always in context once a skill runs)

The STOP and check-in rules are written directly in each SKILL.md body,
repeated at the point of action (for example, the `--base dev` warning sits
inside the PR-creation step of `review-issue`). Verified platform behavior:
skill content is injected at invocation and stays pinned for the session; it
is not compacted away.

## Layer 2: local mechanical enforcement (PreToolUse hook)

`hooks/block-main-pr.sh` blocks any `gh pr create` targeting `main` while
pkgreview review issues are open in the repository. It fails open when
GitHub is unreachable, and allows the final PR once all four review issues
are closed (which is exactly when `/review-complete` runs).

Install it in your user settings so it covers every review session
(`~/.claude/settings.json`), pointing at your clone of this repo:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/pkgreview/hooks/block-main-pr.sh"
          }
        ]
      }
    ]
  }
}
```

Make it executable: `chmod +x hooks/block-main-pr.sh`. Requires `jq` and
`gh`.

Evaluation notes (issue #8): the hook is deliberately narrow. It inspects
only Bash `gh pr create` calls, so it cannot catch a PR created through the
GitHub web UI; that is what layer 3 is for. It adds one `gh issue list` call
(four label queries) per `gh pr create`, which is negligible since PR
creation is rare.

## Layer 3: remote mechanical enforcement (branch protection)

Enable branch protection on `main` in each openwashdata data package repo so
direct pushes and premature merges are blocked at the GitHub level
regardless of what any local tool does. Requires admin on the repo:

```bash
gh api -X PUT "repos/openwashdata/PACKAGENAME/branches/main/protection" \
  --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
```

This blocks direct pushes to `main` and requires one approving review on
the final dev-to-main PR. Apply it at review start.

Note (2026-07-23): the org-wide alternative, a ruleset at
https://github.com/organizations/openwashdata/settings/rules, was tried
and is gated to GitHub Team plans; it is not available on the current
openwashdata plan. Per-repo protection with the command above works on
the current plan for public repositories. As of the same date, neither
layer 2 nor layer 3 is deployed by maintainer decision (issue #8);
enforcement stands on layer 1.

## Rollout gate

If Claude violates a STOP or a check-in even once during the first real
skill-driven review, halt further use and fix enforcement mechanically
before continuing. Do not rationalize a single violation; the premortem's
hidden assumption ("where instructions live doesn't change how they
behave") is exactly what this gate tests.
