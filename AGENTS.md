# DaisyUI

Project instructions for every agent: Claude Code (`CLAUDE.md` imports this file), Grok, Cursor,
Copilot, Codex. Claude-only extras (rules, skills, commands) live under `.claude/`.

## Repository Structure

This is a monorepo containing:
- **Root**: The DaisyUI Ruby gem (Phlex components wrapping DaisyUI)
- **docs/**: Documentation website (Rails 8.1+ app showcasing components)

## Quick Reference

```bash
# Gem development (from root)
bundle exec rspec              # Run gem tests
bundle exec rubocop            # Lint gem code
bin/console                    # Interactive console

# Docs development (from docs/)
bin/dev                        # Start dev server
bundle exec rspec              # Run docs tests (includes Playwright)
bin/rubocop                    # Lint docs code
bun run build:css              # Build Tailwind CSS
```

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
# Modifier registration with REQUIRED responsive comments
register_modifiers(
  # "sm:btn-primary" "md:btn-primary" "lg:btn-primary"
  primary: "btn-primary",
  # "sm:btn-lg" "md:btn-lg" "lg:btn-lg"
  lg: "btn-lg"
)
```

**CRITICAL**: Always include responsive variant comments (sm:, md:, lg:) above each modifier. Tailwind CSS needs these to generate responsive classes.

### Adding a New Component

1. Create component file: `lib/daisy_ui/component_name.rb`
2. Inherit from `DaisyUI::Base`
3. Use `register_modifiers` with responsive comments
4. Create spec: `spec/lib/daisy_ui/component_name_spec.rb`
5. Add example in docs: `bin/rails generate example_view ComponentName Category`

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

### Docs Tests (with Playwright)
```bash
cd docs
bundle exec rspec                        # All tests including system tests
bundle exec rspec spec/system/           # Only system tests
HEADLESS=false bundle exec rspec         # Watch browser tests run
```

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Fable-powered planning → GitHub issue or `docs/plans/` markdown (read-only; execute with `/lfg`) |
| `/lfg` | Full autonomous engineering workflow with verification |
| `/add-component` | Create a new DaisyUI component with tests and docs |
| `/check-component` | Verify a single component against DaisyUI 5 spec |
| `/audit-components` | Audit all components against DaisyUI 5 |
| `/tdd` | RED → GREEN → REFACTOR cycle |
| `/test-all` | Run complete test suite (gem + docs) |
| `/fix-docs-tests` | Fix failing docs specs |
| `/review-pr` | Review a GitHub PR for quality and patterns |
| `/github-review-pr` | Full PR pass: resolve merge conflicts, then fix CI failures, then resolve review comments (in that order) |
| `/github-review-comments` | Respond to unresolved PR review comments |
| `/github-ci-failures` | Diagnose and fix CI failures |

### Model tier convention

Commands and agents pin a model tier via frontmatter aliases: `haiku` for mechanical/config work, `sonnet` for layer specialists (the default), `opus` for orchestration and PR review, `fable` for read-only planning. Always use tier aliases, never full model IDs — aliases track the latest model in each tier. When spawning subagents for mechanical work (file finding, pattern scans), pass a cheaper model explicitly rather than letting them inherit the session model.

## CI Pipeline

All jobs run in parallel:
- `lint`: RuboCop on gem
- `gem-test`: Gem specs on Ruby 3.2, 3.3, 3.4, 4.0
- `docs-lint`: RuboCop, Biome, Stylelint on docs
- `docs-test`: Playwright browser tests on docs

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
