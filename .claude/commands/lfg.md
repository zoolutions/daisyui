---
description: "Executes full autonomous engineering workflow with verification. Use when implementing complete features, tackling GitHub issues, or running end-to-end development cycles."
model: opus
argument-hint: "GitHub issue number/URL or feature description"
allowed-tools: Bash(gh issue view:*), Bash(gh search:*), Bash(gh issue list:*), Bash(gh pr create:*), Bash(gh pr edit:*), Bash(gh pr view:*), Bash(bin/labels infer:*), Bash(bin/labels sync), Bash(bundle exec:*), Bash(git:*), Read, Write, Edit, Glob, Grep, Agent, mcp__daisyui__daisyUI-Snippets
---

# LFG - Full Autonomous Workflow

Execute a complete engineering workflow with verification at each phase.

## Phase 0: Branch Setup

**BEFORE any other work, prepare the git branch:**

1. Check the current branch: `git branch --show-current`
2. If NOT on `main`, switch: `git checkout main`
3. Pull latest: `git pull origin main`
4. Create feature branch: `git checkout -b issue-{number}-{brief-description}` (or `feature/{description}` if no issue number)

---

## Phase 1: Understand

### Step 1: Gather Requirements

If `$ARGUMENTS` is a GitHub issue number or URL:

```bash
gh issue view <number> --json title,body,labels,assignees,comments
```

If `$ARGUMENTS` is a description, use it directly.

**Keep the issue's `type` and `area` labels** — Phase 6 puts them on the pull request. `/lfg` never edits the issue's own labels; the issue's lifecycle is the user's to manage. A `docs/plans/*.md` plan carries them on its `Labels:` line. If there are none, or you were given a description, infer them: one `type` label plus `bin/labels infer <changed paths>` for the areas (`.github/LABELS.md`).

### Step 2: Define Acceptance Criteria

**MANDATORY:** Write explicit acceptance criteria:

- **GIVEN** [context/setup]
- **WHEN** [action taken]
- **THEN** [expected outcome]

You MUST NOT proceed until you can articulate these clearly.

### Step 3: Comprehension Gate

Before proceeding, you must:

1. State the problem/feature in one sentence
2. Explain WHY this is needed
3. List what will change from the user's perspective
4. Identify edge cases not explicitly mentioned
5. Explain the code path involved

If you cannot complete ALL five items, investigate further.

### Step 4: Create Task List

Create a TaskCreate todo list with specific implementation steps.

---

## Phase 2: Explore

1. Find related files (Glob/Grep, or an Explore agent with `model: haiku`)
2. Read existing patterns in similar components
3. Use `mcp__daisyui__daisyUI-Snippets` to get official DaisyUI class names
4. Check existing test coverage
5. Review the Base class pattern in `lib/daisy_ui/base.rb`

---

## Phase 3: Plan

1. List files to modify with specific changes
2. List new files to create with purpose
3. Plan test coverage (TDD: tests FIRST)
4. Update task list with implementation steps

---

## Phase 4: Implement (TDD)

For each logical unit:

### 4.1: Write Failing Test First

Create a test that demonstrates the expected behavior. Run it to confirm it FAILS:

```bash
bundle exec rspec <spec_file>
```

### 4.2: Implement Minimum Code

Write the MINIMUM code to make the test pass. Follow project patterns:

| Never Do | Always Do |
|----------|-----------|
| Guess DaisyUI class names | Use `mcp__daisyui__daisyUI-Snippets` to verify |
| Skip responsive comments | Include `# "sm:class" "md:class" "lg:class"` for every modifier |
| Hardcode HTML tags | Use `as:` parameter with `public_send(as, ...)` |
| Skip sub-components | Add methods for component parts (body, title, etc.) |
| Forget `component_class` | Always set `self.component_class` |

### 4.3: Refactor

Once green, refactor while keeping tests passing.

### 4.4: Validate

```bash
bundle exec rubocop <changed_files>
```

### 4.5: Repeat

Move to next logical unit. Mark task items complete.

---

## Phase 5: Verify

**ALL of these must pass before committing:**

```bash
bundle exec rubocop              # Style
bundle exec rspec                # Tests
```

### Solution Verification

Re-read the original requirements and verify:
- "If I were the requester, would I consider this fully resolved?"
- "Have I addressed the ROOT CAUSE, not just the symptom?"
- "Do my tests prove the feature works?"

---

## Phase 5.5: Fable validation

Spawn the `fable-validator` agent (it is pinned to Fable) with the issue, the acceptance criteria from Phase 1 and the base branch. On **BLOCK**, fix every blocker (back to Phase 4 for code, with a failing test first), re-verify, and run the validator again. On **PASS WITH NOTES**, fix the risks you agree with (if those fixes change the diff, re-verify and run the validator again) and list the rest in the pull request under "Accepted risks". Put the validator's one-line verdict and its "Not verified" list in the pull request body. Do not open the pull request before a PASS or PASS WITH NOTES.

---

## Phase 6: Commit & PR

### Commit

```bash
git add <specific_files>
git commit -m "$(cat <<'EOF'
feat(scope): brief description

## Summary
[What changed and why]

## Test Coverage
- spec 1: validates requirement X
- spec 2: validates edge case Y

## Verification
- [x] bundle exec rubocop passes
- [x] bundle exec rspec passes
EOF
)"
```

### Push & PR

```bash
git push -u origin $(git branch --show-current)

gh pr create --title "feat(scope): brief description" --label <type> --label <area> [--label <area>…] --body "$(cat <<'EOF'
## Summary
- Key change 1
- Key change 2

Closes #<issue_number>

## Validation
- fable-validator: <PASS | PASS WITH NOTES>
- Not verified: <list from the validator>

## Accepted risks
- <risk and why it is accepted, or "None">

## Test plan
- [ ] Scenario 1
- [ ] Scenario 2
EOF
)"
```

**Label the PR — every time.** The `--label` flags are the issue's `type` + `area` labels from Phase 1, never a `status` label (`plan`, `epic`, …). For a description-only run, infer them: one `type` (`.github/LABELS.md` maps conventional-commit prefixes to types) plus `bin/labels infer $(git diff --name-only origin/main...HEAD)`. Exactly one type, at least one area. `gh pr create` fails on a label that doesn't exist on GitHub: run `bin/labels sync` (or label after the fact with `gh pr edit <n> --add-label …`).

---

## Verification Checklist

- [ ] All acceptance criteria met
- [ ] Tests written BEFORE implementation
- [ ] `bundle exec rubocop` passes
- [ ] `bundle exec rspec` passes
- [ ] `fable-validator` verdict is PASS or PASS WITH NOTES (Phase 5.5)
- [ ] DaisyUI class names verified via MCP server
- [ ] Responsive comments present on all modifiers
- [ ] PR created with description
- [ ] PR labelled: one `type` + at least one `area`, no `status` (`.github/LABELS.md`)

Now, execute this workflow for the provided issue or feature.
