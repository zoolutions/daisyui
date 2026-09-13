# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Memory

Durable project memory lives in `lode/` (index: `lode/lode-map.md`). Read it
before exploring the code. `lode/review/` holds accepted review findings as rules
about the system; `/lode:gate` enforces them before any push, and `/lode:learn`
adds to them. `lode/workflow.md` is the profile the shared `/lode:` workflow
skills read.

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
| `/lode:plan` | Read-only planning → GitHub issue or `lode/plans/` markdown (execute with `/lode:lfg`) |
| `/lode:lfg` | Full autonomous engineering workflow with verification |
| `/lode:tdd` | RED → GREEN → REFACTOR cycle |
| `/lode:review-pr` | Full PR pass: resolve merge conflicts, then fix CI failures, then resolve review comments (in that order) |
| `/lode:finish-prs` | Drive a stack of open PRs to merge-ready, one at a time |
| `/lode:debug-flaky` | Root-cause an intermittent test — evidence, repro, stress-proofed fix |
| `/lode:gate` | Pre-PR gate: fresh-context review against the rules and `lode/review/`; the push hook requires it |
| `/lode:learn` | Write accepted review findings into `lode/review/` |
| `/lode:sync` | Keep `lode/` true to the code after a change |
| `/add-component` | Create a new DaisyUI component with tests and docs |
| `/check-component` | Verify a single component against DaisyUI 5 spec |
| `/audit-components` | Audit all components against DaisyUI 5 |
| `/test-all` | Run complete test suite (gem + docs) |
| `/fix-docs-tests` | Fix failing docs specs |
| `/review-pr` | Review a GitHub PR for quality and patterns |
| `/github-ci-failures` | Diagnose and fix CI failures |

The `/lode:` commands come from the `lode@zoolutions` plugin, enabled in
`.claude/settings.json`; they read `lode/workflow.md` for this repository's
commands, shapes, CI and conflict rules. The local `lfg`, `plan`, `tdd`,
`github-review-pr` and `github-review-comments` commands were retired in favour
of them.

### Model tier convention

Commands and agents pin a model tier via frontmatter aliases: `haiku` for mechanical/config work, `sonnet` for layer specialists (the default), `opus` for orchestration and PR review, `fable` for read-only planning. Always use tier aliases, never full model IDs — aliases track the latest model in each tier. When spawning subagents for mechanical work (file finding, pattern scans), pass a cheaper model explicitly rather than letting them inherit the session model.

## CI Pipeline

All jobs run in parallel:
- `lint`: RuboCop on gem
- `gem-test`: Gem specs on Ruby 3.2, 3.3, 3.4, 4.0
- `docs-lint`: RuboCop, Biome, Stylelint on docs
- `docs-test`: Playwright browser tests on docs
