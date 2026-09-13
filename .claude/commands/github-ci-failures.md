---
description: "Use when CI checks are failing on a PR — fetches failure logs, diagnoses root causes, implements fixes, and pushes until CI is green."
model: opus
argument-hint: "PR number (e.g., 41 or #41)"
allowed-tools: Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh pr checks:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(gh run view:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(git commit:*), Bash(git add:*), Bash(bundle exec:*), Bash(bun:*), Bash(cd:*), Read, Write, Edit, Glob, Grep, Agent
---

# Fix GitHub CI Failures: $ARGUMENTS

Work systematically: identify failures, read logs, diagnose root causes, fix locally, verify, push.

## Phase 0: Determine the PR Number

Parse `$ARGUMENTS` flexibly. If empty, auto-detect from current branch:

```bash
gh pr list --author=@me --head="$(git branch --show-current)" --state=open --json number,title
```

Once you have the PR number, confirm it:

```bash
gh pr view <PR_NUMBER> --json title,state,url,mergeable
```

**Pre-flight: merge conflicts (detection only).** If `mergeable` is `CONFLICTING`, STOP — do not diagnose CI on a conflicted branch (the merge itself may fix or cause the failures). Report the conflict and hand off to `/lode:review-pr`, whose conflict phase owns the resolution runbook — this command's toolset deliberately does not include the merge machinery. If `mergeable` is `UNKNOWN`, note it and proceed: the orchestrator resolves the ambiguity; a standalone run shouldn't block on GitHub's recompute.

## Phase 1: Identify Failing Checks

```bash
gh pr checks <PR_NUMBER>
```

| Check name | What it runs | How to Get Logs |
|------------|--------------|-----------------|
| `Lint` | `bundle exec rubocop lib spec` on the gem | `gh run view <RUN_ID> --job=<JOB_ID> --log-failed` |
| `Gem Tests (Ruby 3.2/3.3/3.4/4.0)` | `bundle exec rspec` at the root | `gh run view <RUN_ID> --job=<JOB_ID> --log-failed` |
| `Docs Lint` | `bin/rubocop`, `bun run lint:js`, `bun run lint:css` in `docs/` | `gh run view <RUN_ID> --job=<JOB_ID> --log-failed` |
| `Docs Tests` | `bundle exec rspec` in `docs/` (Playwright, after `bun run build:css`) | `gh run view <RUN_ID> --job=<JOB_ID> --log-failed` |

Extract the run ID and job IDs from the check URLs. The URL format is:
`https://github.com/mhenrixon/daisyui/actions/runs/<RUN_ID>/job/<JOB_ID>`

## Phase 2: Fetch Failure Logs

```bash
gh run view <RUN_ID> --job=<JOB_ID> --log-failed
```

## Phase 3: Diagnose Each Failure

### Lint Failures
- RuboCop offenses: file path, line number, cop name

### Spec Failures
- Test name and file path
- Error class and message
- Whether test environment issue vs actual code bug

### Docs Test Failures
- Playwright timeouts, missing elements, CSS class mismatches
- May need CSS rebuild: `cd docs && bun run build:css`

## Phase 4: Fix Locally

1. Read the relevant file before fixing
2. Make the fix
3. Verify locally:
```bash
bundle exec rubocop <changed_files>
bundle exec rspec <failing_spec_files>
```

## Phase 5: Commit and Push

```bash
git add <specific_files>
git commit -m "$(cat <<'EOF'
fix(ci): <brief description>

- Fix 1
- Fix 2
EOF
)"
git push
```

## Phase 6: Verify

```bash
gh pr checks <PR_NUMBER>
```

Report status. Do NOT poll in a loop.
