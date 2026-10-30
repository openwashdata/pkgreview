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

## Unattended mode (since 1.7.0)

`/review-issue [issue-number] --unattended` and
`/create-next-issue --unattended` (issue #69, Option B) take two human
actions out of each review issue: the plan approval at CHECK-IN #1 and
the merge of the per-issue PR into `dev`. The maintainer still types one
command per skill run. The layers hold as follows:

- Layer 1: the unattended path is an explicit branch in the two SKILL.md
  bodies, at the point of action (Steps 1b, 2, 7b, and 8 of
  `review-issue`; Steps 2 and 4 of `create-next-issue`). No stop was
  removed. Each run still handles one issue and ends there, and
  `disable-model-invocation: true` still keeps Claude from chaining
  skills.
- Layer 2: the hook blocks `gh pr create` against `main` in both modes.
  The unattended merge is a `gh pr merge` on a PR whose base the skill
  has verified to be `dev`; the final dev-to-main PR is never merged by
  a skill.
- Layer 3: an unattended merge waits for the R-CMD-check run of the PR
  and refuses when there is none, when a check failed, or when a
  required item is unchecked. That is a prompt-level rule. Making
  R-CMD-check a required status check on `dev` (classic branch
  protection, one setting per repository, set by the maintainer) turns
  it into a mechanical one.

Five things stay with a human in both modes, and the unattended branch
of `review-issue` lists them at Step 1b: a PII or history finding stops
the run; the PII item is checked only against the recorded intake
outcome and, for household- or person-level data, a named human sign-off
comment; variable descriptions are written or confirmed by a human and
never by the unattended run; a required item is checked only on the
evidence of a command run in the session; repository settings, the
Pages setting, and Zenodo stay with the maintainer.

The rollout gate below covers unattended mode as well: one PR merged
with an unchecked required item, or one description written by an
unattended run, halts its use until enforcement is fixed.

## Rollout gate

If Claude violates a STOP or a check-in even once during the first real
skill-driven review, halt further use and fix enforcement mechanically
before continuing. Do not rationalize a single violation; the premortem's
hidden assumption ("where instructions live doesn't change how they
behave") is exactly what this gate tests.
