# DaisyUI

Project instructions for every agent: Claude Code (`CLAUDE.md` imports this file), Grok, Cursor,
Copilot, Codex. Claude-only extras (skills, commands) live under `.claude/`; the delivery workflow comes from the `flow` and `ruby-gem` plugins (`.claude/settings.json`).

## Repository Structure

This is a monorepo containing:
- **Root**: The DaisyUI Ruby gem (Phlex components wrapping DaisyUI)
- **docs/**: Documentation website (Rails 8.1+ app showcasing components)

## Quick Reference

```bash
# Gem development (from root)
bundle exec rspec              # Run gem tests
bundle exec rubocop            # Lint gem code
bundle exec conformance-kit check  # Concurrency gates (.conformance.yml), as CI runs them on Ruby 4.0
bin/console                    # Interactive console
bundle exec rake build:js      # Rebuild the minified Stimulus controllers (bun, see .bun-version) after editing one
bundle exec rake build:js_check  # CI drift guard: fails when a committed .min.js is stale
bundle exec rake tailwind:manifest  # Regenerate data/daisyui/tailwind_manifest.json after changing a component (its spec fails until you do)
bin/release [patch|minor|major|X.Y.Z] [-n]  # Cut a release (list / --dry-run are read-only); drives rake release

# Docs development (from docs/)
bin/dev                        # Start dev server
bundle exec rspec              # Run docs tests (includes Playwright)
bin/rubocop                    # Lint docs code
bun run build:css              # Build Tailwind CSS
```

## Workflow

- **Verify:** `bundle exec rubocop lib spec` · `bundle exec rspec` · `bundle exec conformance-kit check` · docs (`cd docs`): `bin/rubocop` · `bun run lint:js` · `bun run lint:css` · `bundle exec rspec`; after editing a Stimulus controller `bundle exec rake build:js`, after a component change `bundle exec rake tailwind:manifest`
- **Specs:** fast loop `bundle exec rspec spec/lib/daisy_ui/<name>_spec.rb`; full suite gem `bundle exec rspec` + docs `cd docs && bundle exec rspec`; two worktrees at once: yes, but docs system specs bind Capybara port `3001 + TEST_ENV_NUMBER`, so give each worktree its own `TEST_ENV_NUMBER`
- **CI:** required `Lint`, `Gem Tests (Ruby 3.2|3.3|3.4|4.0)`, `Docs Lint`, `Docs Tests`, `cubic · AI code reviewer`, `conformance / Conformance settings`, `conformance / Conformance (Ruby 4.0)`; full suite on the PR (`main.yml`; `conformance.yml` also on merge_group); failure report none (Docs Tests uploads a `playwright-screenshots` artifact)
- **Review bot:** cubic
- **Merge:** squash (ruleset `main`: squash only, linear history, no merge queue) — `gh pr merge <PR> --squash --delete-branch`
- **PR contract:** `## Summary`, `## Test plan`; exactly one `type` + at least one `area` label (Labels below); before/after screenshots for markup or docs-page changes (Screenshots below)
- **Conflicts:** `Gemfile.lock` `docs/Gemfile.lock` `docs/bun.lock` — take main's, re-run `bundle install` (root and/or `docs/`) / `bun install` in `docs/`, commit the regenerated file; `CHANGELOG.md` — union under `[Unreleased]`, no duplicate subheads; `lib/daisy_ui/version.rb` — keep the branch's bump (a release-prep PR) unless accidental; `lib/daisy_ui/updated_at.rb` — main's; `*.min.js`/`*.min.js.map` — `bundle exec rake build:js`; `data/daisyui/tailwind_manifest.json` — `bundle exec rake tailwind:manifest`; `register_modifiers` — keep both sides' modifiers and all six comment lines
- **Worktree setup:** `bundle install` and `cd docs && bundle install && bun install` (remove the worktree to undo)
- **Release:** `bin/release patch|minor|major|X.Y.Z` (`-n` dry run) via `/ruby-gem:release`, never by hand or `gem push`; changelog `CHANGELOG.md`, heading `## [X.Y.Z] - YYYY-MM-DD` under `## [Unreleased]`; lockfiles `Gemfile.lock` `docs/Gemfile.lock`; `deploy-docs.yml` on release published; the release kit files (`bin/release`, `rakelib/release.rake`, `release.yml` shared jobs) are byte-identical across the zoolutions gems: change in every repo or none
- **Main health:** `gh run list --workflow main.yml --branch main --event push --limit 1 --json conclusion,headSha`
- **Upstream:** libraries we own `zoolutions/*`; scrub none
- **Bench:** none

## Command output (rtk)

Command output is condensed by rtk (PreToolUse hook) for `git`, `gh`, `grep`, `rg`, `find`, `ls`,
`cat`, `rspec`, `rubocop`, `bun`, `curl`, `psql`, `docker` — matched by the command's basename, so
`bundle exec rubocop`/`bin/rspec` are covered but the docs `bin/rubocop` binstub is not (it exists
only for its `--ignore-parent-exclusion` flag; its output is already a few lines, nothing to
strip). No project `.rtk/filters.toml` here — rubocop, brakeman and `bin/rails db:*` output in
this repo is already terse; add one only when a real command's captured output is genuinely noisy.
Write commands in hook-rewritable shapes: no `for`/subshell wrappers, no `| head` on rtk-handled
commands, `bundle exec rubocop` (not `bin/rubocop`) from the gem root.

## MCP Server: daisyUI Snippets

The `mcp__daisyui__daisyUI-Snippets` tool provides official DaisyUI component snippets. Use it when:
- Creating new components
- Checking correct DaisyUI class names
- Looking up component structure and modifiers

Example: To get button snippet, call with `{"components": {"button": true}}`

## Gem Architecture

### Component Structure
- All components inherit from `DaisyUI::Base` (`lib/daisy_ui/base.rb`)
- Components use the `register_modifiers` method to map symbols to CSS classes
- The module uses `Phlex::Kit` for short-form syntax

### Key Patterns

```ruby
# Modifier registration with REQUIRED responsive comments.
# Alternatives (sizes, colors, styles, placements) go in a named group so
# ClassMerge keeps only the last one; everything else stays ungrouped.
register_modifiers(
  color: {
    # "sm:btn-primary" "md:btn-primary" "lg:btn-primary"
    primary: "btn-primary"
  },
  size: {
    # "sm:btn-lg" "md:btn-lg" "lg:btn-lg"
    lg: "btn-lg"
  },
  # "sm:btn-wide" "md:btn-wide" "lg:btn-wide"
  wide: "btn-wide"
)
```

**CRITICAL**: Every modifier carries six comment lines, one per `sm:`/`@sm:`/`md:`/`@md:`/`lg:`/`@lg:` (the container-query `@` variants included; the example above abbreviates). Tailwind scans them to generate responsive classes; a dropped line silently breaks the variant. Sub-components follow `def body(**options, &) = div(class: component_classes("card-body", options:), **options, &)`. One component per file. Verify class names with `mcp__daisyui__daisyUI-Snippets` before creating or changing a component.

### Adding a New Component

1. Create component file: `lib/daisy_ui/component_name.rb`
2. Inherit from `DaisyUI::Base`
3. Use `register_modifiers` with responsive comments, grouping mutually exclusive modifiers
4. Create spec: `spec/lib/daisy_ui/component_name_spec.rb`
5. Add example in docs: `bin/rails generate example_view ComponentName Category`
6. From the repository root, regenerate the Tailwind manifest: `bundle exec rake tailwind:manifest` (apps' `daisyui-tailwind` reads it)

## Docs Architecture

### View System (Phlex-Rails)
All views are Ruby classes. Structure:
```
docs/app/views/
├── examples/                    # Component example pages
│   └── buttons/show_view.rb     # ShowView renders all examples
├── components/examples/         # Individual example components
│   └── buttons/basic_component.rb
└── layouts/                     # Layout components
```

### Generators
```bash
# Add new component page
bin/rails generate example_view Menu Navigation

# Add example to existing component
bin/rails generate example_component Menus::Responsive "Title"
```

## Development Workflow

### When modifying a gem component:
1. Check DaisyUI docs for correct classes: use `mcp__daisyui__daisyUI-Snippets`
2. Update modifier mappings with responsive comments
3. Run gem tests: `bundle exec rspec`
4. Update docs examples if needed
5. Run docs tests: `cd docs && bundle exec rspec`

### When adding a new component:
1. Get DaisyUI snippet for reference
2. Create gem component with tests
3. Create docs example with generator
4. Run full test suite

## Testing

### Gem Tests
```bash
bundle exec rspec                                    # All tests
bundle exec rspec spec/lib/daisy_ui/button_spec.rb  # Single file
bundle exec rspec --format documentation             # Verbose output
```

Coverage: 80% minimum, 100% for modifier mappings, `DaisyUI::Base` (classes, attributes, responsive) and configuration. A component spec covers: default render, each modifier alone, modifiers combined, one responsive viewport, `class:`, `data:`, `as:` (when supported), and sub-component methods. Specs use `subject(:output) { render described_class.new(:primary) }` and compare against `html <<~HTML`. Docs examples get system specs in `docs/spec/system/`.

### Docs Tests (with Playwright)
```bash
cd docs
bundle exec rspec                        # All tests including system tests
bundle exec rspec spec/system/           # Only system tests
HEADLESS=false bundle exec rspec         # Watch browser tests run
```

## Slash Commands

Delivery (`/flow:lfg`, `/flow:plan`, `/flow:tdd`, `/flow:review-pr`, `/flow:github-review-pr|failures|comments`, `/flow:finish-prs`, `/flow:follow-through`, `/flow:debug-flaky`, agent `flow:fable-validator`) comes from the `flow` plugin; `/ruby-gem:release` and `/ruby-gem:perf` from `ruby-gem`. Local commands:

| Command | Purpose |
|---------|---------|
| `/add-component` | Create a new DaisyUI component with tests and docs |
| `/check-component` | Verify a single component against DaisyUI 5 spec |
| `/audit-components` | Audit all components against DaisyUI 5 |
| `/test-all` | Run complete test suite (gem + docs) |
| `/fix-docs-tests` | Fix failing docs specs |

Every spawned agent names its `model:`; one that does not runs on `sonnet` (`CLAUDE_CODE_SUBAGENT_MODEL` in `.claude/settings.json`). Sessions run on `opus` with `fable` as the advisor.

## Conformance

The `conformance` workflow runs conformance-kit's `conformance-kit check` on Ruby 4.0: the `:ractor` specs and `conformance-audit --strict`. Ractor-readable state is frozen by `DaisyUI.finalize!`, which `DaisyUI.configure` runs, so the suite's configuration is frozen: specs change settings through `DaisyUI.configure` (or tag `:finalizes` for a writable copy); per-Ractor caches go through `DaisyUI::Store`.

## Labels

Every pull request carries exactly one `type` label and at least one `area`
label from `.github/labels.yml` — never a `status` label. `/flow:plan` labels the
issue, `/flow:lfg` copies the issue's `type` and `area` labels onto the PR (never
`plan` or another status label). Without an issue, the type comes from the
change's conventional-commit prefix and the areas from
`bin/labels infer $(git diff --name-only origin/main...HEAD)`. Labels go on the PR as `--label` flags of the create call (or `--add-label` on an edit if it is already open). Labels change in
the manifest and reach GitHub with `bin/labels sync`, never through the UI.
Rules: `.github/LABELS.md`. `bin/labels` + `.github/LABELS.md` are the shared
labels kit (canonical copy in docs-kit): never edit them in place.

## Screenshots on PRs and issues (always)

`gh` ≥ 2.99 uploads images and videos itself. A change to a gem component's markup/classes, or to
the docs site's rendered pages, ships with before/after pictures **on the PR**, attached from the
terminal. Never a local path, a base64 blob, or "screenshot available on request".

```bash
gh pr create --attach './after.png#Sidebar collapsed on mobile' --title … --body …   # picture in hand already
gh pr comment <n> --attach './after.png#Sidebar collapsed on mobile' --body 'Before/after for the sidebar.'
gh pr comment <n> --attach ./before.png --attach ./after.png   # repeat the flag, up to 50 files
gh issue comment <n> --attach ./repro.mp4                       # video renders as a player
```

- Quote the whole argument: the alt text has spaces and bare `<`/`>` would redirect. `<file>#<alt text>`
  sets the alt text; without it the filename is used. A body that already
  references the file (`![alt](./after.png)`) gets that reference rewritten to the uploaded
  asset, so images can sit inline; unreferenced attachments are appended at the end.
- `create`, `edit` and `comment` all take `--attach` (all three landed in gh 2.99). Attach at create time when
  the picture already exists; comment when it comes later, as it does after a verification run.
- Capture with `agent-browser screenshot <file>` against a running `bin/dev` (docs) server, or the
  Playwright MCP `browser_take_screenshot`. Save under the scratchpad, never in the repo.
- No `--attach` flag means an old `gh`: `brew upgrade gh`.
