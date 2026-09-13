# Workflow profile

Everything the shared workflow skills (`/lode:lfg`, `/lode:review-pr`,
`/lode:finish-prs`, `/lode:debug-flaky`, `/lode:tdd`, `/lode:plan`) need to know
about this repository that is not already in `CLAUDE.md`, `.claude/rules/` or the
rest of `lode/`.

## Commands

Two bundles: the gem at the repo root, the docs app in `docs/`. A `docs/` command
runs from `docs/`.

| Purpose | Command | Notes |
|---|---|---|
| fast loop (one file) | `bundle exec rspec spec/lib/daisy_ui/<name>_spec.rb` | pure Phlex rendering; no Rails, no DB, no network |
| full suite (gem) | `bundle exec rspec` | 71 files, no services, no network. Safe in two worktrees at once. |
| full suite (docs) | `cd docs && bundle exec rspec` | needs a Playwright chromium and a SQLite DB; **not** safe in two worktrees — `spec/system/support/precompile_assets.rb` rebuilds and then clobbers `docs/app/assets/builds/` around the run |
| lint (gem) | `bundle exec rubocop` | `AllCops.Exclude` drops `docs/**/*`; CI runs the narrower `rubocop lib spec` |
| lint (docs) | `cd docs && bin/rubocop && bun run lint:js && bun run lint:css` | Biome for JS, Stylelint for CSS; docs-kit's RuboCop config, Ruby 3.4 target |
| one CI cell locally | `rbenv/asdf` to the matrix Ruby (3.2, 3.3, 3.4, 4.0), then `bundle install && bundle exec rspec` | the matrix has one dimension, the Ruby version; `.tool-versions` pins 4.0.0 at the root |
| docs build / check | `cd docs && bun run build:css` | `bin/build-css --minify`; resolves the `daisyui` and `docs-kit` gem paths with `bundle show` and aborts if either is missing |
| run the app | `cd docs && bin/dev` | `bin/rails server` only. For live CSS run `bun run watch:css` beside it, or use `Procfile.dev`. |
| gem console | `bin/console` | `DaisyUI::Button.new(:primary).call` renders to a String |
| release | `bundle exec rake release[X.Y.Z]` | runs on `main` and pushes to `origin/main` itself — never from a feature branch |

The `mcp__daisyui__daisyUI-Snippets` tool in `.claude/settings.local.json` is an
**external** daisyUI class-name lookup. It is not `exe/daisyui-mcp`, this gem's
own server.

## Branches and PRs

- Default branch: `main`.
- Work branches: `.claude/rules/git-workflow.md` names `feature/*`, `fix/*`,
  `refactor/*`, `ci/*`, `chore/*`, rooted off fresh `origin/main`. The history
  also carries `feat(...)`-titled PRs; the branch prefix is the rule, the commit
  subject follows conventional commits.
- Commits: conventional, scope in parentheses (`feat(dropdown):`,
  `chore(docs):`), body says why.
- PR body sections, in order: Summary, Test plan, Deviations & judgment calls,
  Gate.
- Merge policy: squash on `main` when green and approved. Never force-push a
  branch that has a PR — merge `main` forward into it instead.
- Attribution: no `Co-Authored-By` and no "Generated with" line. End a commit
  body and a PR body with the session line the harness supplies.

## Layers

| Layer | Files | Edit rule |
|---|---|---|
| `Base` and the argument pipeline | `lib/daisy_ui/base.rb` | owned here; every component depends on it, so a change needs `base_spec.rb` coverage for Symbol, String and nil `component_class` |
| Components | `lib/daisy_ui/*.rb` (77 `< Base`) | owned here; one class per file, one spec per file |
| Configuration | `lib/daisy_ui/configurable.rb` | owned here; process-global, so anything that touches it needs a restoring `around` hook in specs |
| Rails engine + pins | `lib/daisy_ui/engine.rb`, `config/importmap.rb` | owned here; both paths must stay inside the gemspec's `app/`+`config/` file filter |
| Stimulus controllers | `app/javascript/daisy_ui/controllers/*.js` | owned here; no build step, no JS test suite — the only coverage is `docs/spec/system/` |
| MCP server | `lib/daisy_ui/mcp_server.rb`, `exe/daisyui-mcp` | owned here; no spec exists |
| Docs app | `docs/**` | owned here, separate bundle and lint; run its commands from `docs/` |
| Docs chrome | the `docs-kit` gem (`~> 1.0.8`) | vendored upstream — `DocsUI::Shell`, `DocsKit::Controller`, `/llms.txt`; change it in `zoolutions/docs-kit`, not here |
| `docs/app/assets/builds/`, `docs/app/assets/stylesheets/tailwind.sources.css` | generated | gitignored; regenerate with `bun run build:css`, never edit |
| `Gemfile.lock`, `docs/Gemfile.lock`, `docs/bun.lock` | generated, tracked | regenerate, never hand-edit |

## Shapes

Every component change is checked against all of these; a reviewer will name the
one that was skipped.

- **Modifier, positional**: `Button(:primary)`.
- **Modifier, boolean keyword**: `Button(primary: true)` and `primary: false` —
  `Base#extract_boolean_modifiers` handles both, and `false` adds nothing.
- **A registered key with a non-boolean value**: `Button(primary: "x")` stays in
  the options and renders as an HTML attribute. That is deliberate.
- **`responsive:` with `true`**: the base class is emitted *only* prefixed
  (`base_class` returns `nil`). With a symbol or an array of symbols each token is
  prefixed separately.
- **A configured prefix**: `DaisyUI.configuration.prefix` changes every emitted
  class, and `apply_prefix` calls `String#split` — so a Symbol `component_class`
  (58 of 77) is the shape that breaks.
- **`component_class` shapes**: Symbol (58), String (13), `nil` (4), unset (2,
  derived from the class name).
- **Caller-supplied attributes**: `class:` as a String, an Array or absent;
  `data:`, `style:` and `aria:` that must be merged onto, never assigned over.
- **`as:`**: a Symbol tag, or another component class (`render_as`).
- **Sub-components rendered inside a parent**: `phlex_context` in
  `spec/support/phlex_helpers.rb`.
- **Popover mode**: `Dropdown(:popover)` (zero JS by default) and
  `Tooltip(:popover)` (JS required), and for both `stimulus:` as `true`, a String,
  a Symbol, and the invalid values `Tooltip` rejects.
- **A browser without CSS anchor positioning**: the dropdown controller's
  `@floating-ui/dom` fallback, which the gem does not bundle.
- **Ruby 3.2**: the gemspec floor and the root RuboCop target. CI runs 3.2 → 4.0.
- **Without Rails**: `lib/daisy_ui/engine.rb` loads only
  `if defined?(Rails::Engine)`; nothing else may assume Rails.

## Constraints

Reviewer suggestions that are wrong in this repository.

| Suggestion | Why it is wrong here |
|---|---|
| "Wrap the `around` hook's restore in `ensure`." | The bare-`example.run` shape is uniform across all 13 spec files that mutate global config. Converting the files one PR touches creates two conventions. It is a suite-wide refactor with its own PR. See `review/testing-and-ci.md`. |
| "Delete the commented-out class strings above `register_modifiers`." | Those comments are the **only** place the breakpoint-prefixed class names exist as literal text. Tailwind scans the gem's `.rb` files (via `bin/build-css`'s `@source` glob) and generates the responsive variants from them. Deleting one removes that class from the built CSS with no error. |
| "Normalise this component's `component_class` to a String." | It fixes one class and leaves the other 57 Symbols. The fix belongs at the callers of `apply_prefix`, which coerce with `.to_s`. |
| "Publish the GitHub release only after CI passes." | Deliberate. `release.yml` triggers on `release: published` and the jobs are chained, so nothing reaches RubyGems unless `test` and `build` pass. |
| "Run RuboCop over the whole tree from the root." | The root config excludes `docs/**/*` and disagrees with `docs/.rubocop.yml` on trailing commas. Lint each tree from its own directory. |
| "Add a catch-all route to the docs app." | The phlex-reactive engine mounts `POST /reactive/actions` itself; a catch-all shadows it. `config/routes.rb` says so in a comment. |

## Docs

- User-facing docs live in two places: `README.md` (installation, compatibility
  notes, the Stimulus controllers, the MCP server) and the docs site under
  `docs/app/views/`. A component page is published by a row in
  `ComponentDoc::REGISTRY` plus at least one example class under
  `docs/app/views/components/examples/<slug>/`; a guide by a row in
  `Doc::REGISTRY` plus `Views::Docs::Pages::<View>`.
- Changelog: `CHANGELOG.md`. Entries go under `## [Unreleased]`, in the
  `### Added` / `### Changed` / `### Fixed` subsections. `rake release` does not
  touch this file — release notes come from `gh release create --generate-notes`.
- A change to a component's modifiers always updates that component's examples
  under `docs/app/views/components/examples/<slug>/` in the same PR — nothing
  fails if you forget.
- Files that pin a version and drift after a release: `docs/Gemfile.lock` pins
  `daisyui (X.Y.Z)` through `path: ".."`. `rake release` runs
  `cd docs && bundle install` for exactly this reason; if it is ever skipped, the
  frozen install in the `docs-lint` / `docs-test` jobs fails on the next PR.

## CI

- `.github/workflows/main.yml` — on `push` to `main` and on every
  `pull_request`. Four jobs in parallel, **no path filters**: a gem-only PR still
  runs both docs jobs.
- `.github/workflows/release.yml` — on `release: published`. `test` (Ruby 3.3,
  3.4, `fail-fast: true`) → `build` (tag-vs-`VERSION` check, package contents
  check) → `publish-rubygems` (trusted publishing + Sigstore) →
  `upload-release-assets`.
- `.github/workflows/deploy-docs.yml` — on `release: published` and
  `workflow_dispatch`. Calls `zoolutions/docs-kit/.github/workflows/deploy.yml@main`.
- Matrix: Ruby `3.2 / 3.3 / 3.4 / 4.0` for `gem-test` only (`fail-fast: false`).
  The other three jobs pin Ruby `4.0` and bun `1.3.2`.
- Cells that differ from local: CI's lint is `bundle exec rubocop lib spec`,
  narrower than the local `bundle exec rubocop` (which also covers `Rakefile` and
  the gemspec). `docs-test` sets `ENV["CI"]`, which turns off the local
  `precompile_assets.rb` build/clobber hook.
- Fetch a failure: `gh pr checks <PR>` for the list, then
  `gh run view --job <id> --log-failed`.
- "Green" means all four checks: `Lint`, `Gem Tests (Ruby 3.2/3.3/3.4/4.0)`,
  `Docs Lint`, `Docs Tests`.
- Known not-this-branch failures: `docs-test`'s Playwright browser install is
  cached on `docs/bun.lock` and capped at 5 minutes; a cache miss plus a slow
  download fails the job for reasons unrelated to the diff. The whole job has a
  15-minute timeout.
- Shared or rate-limited services the checks hit: none. Nothing in CI calls a
  third-party API, so PRs do not have to run one at a time.

## Flake sources

- **`requestAnimationFrame` in `daisy_tooltip_controller.js`.** `show()` opens the
  popover, then positions it a frame later. `:popover-open` matches before that,
  so anything in `docs/spec/system/tooltip_popover_spec.rb` that reads geometry
  without first asserting computed `visibility == "visible"` is racy. This is the
  one flake this repo has actually had.
- **Playwright and the browser cache** in the `docs-test` job (above).
- **`DaisyUI.configuration` is process-global** and restored after a bare
  `example.run`. An example that *raises* skips its restore and leaks a prefix
  into every later example in that process — so a burst of failures after one
  error is one bug, and the first failure is the real one.
- **`precompile_assets.rb`, locally only.** It shells out to `pgrep`/`lsof` to
  guess whether Tailwind is running, then rebuilds and later clobbers
  `docs/app/assets/builds/`. Two docs suites in the same directory, or a suite
  beside a running `watch:css`, interfere.

## Conflicts

| File | Rule |
|---|---|
| `Gemfile.lock`, `docs/Gemfile.lock` | never hand-merge: take the base's, then `bundle install` (in `docs/` for the docs one) |
| `docs/bun.lock` | take the base's, then `cd docs && bun install` |
| `CHANGELOG.md` | union under `## [Unreleased]`, most recent first, without duplicating the `### Added` / `### Changed` subheads |
| `lib/daisy_ui/version.rb` | releases land directly on `main` via `rake release`, so a feature branch never edits it. A conflict means the branch bumped on purpose — keep the branch's bump; if the intent is not obvious from its commits, ask |
| `lib/daisy_ui/updated_at.rb` | machine-written by `rake release` — take the base's; it is regenerated at the next release |
| `register_modifiers` blocks | keep both sides' modifiers **and** the full set of breakpoint variants commented above each one (six variants, or eight in `badge`, `drawer`, `dropdown`, `loading`, `menu`, `modal`, `table`, `tabs`) |
| `Doc::REGISTRY`, `ComponentDoc::REGISTRY` | append-only, base order first |
| `docs/app/views/components/examples/<slug>/` | add a second example file rather than merge two example bodies into one |
| generated assets | nothing generated is tracked, so there is no artifact to regenerate instead of merging — every remaining conflict is source and merges semantically |

## Verification

- The manual check a user of this change would do: `bin/console`, then
  `puts DaisyUI::<Component>.new(...).call` and read the class attribute; for
  anything with JavaScript or a docs page, `cd docs && bun run build:css &&
  bin/dev` and open `/components/<slug>`, toggling Preview and Source.
- A change to a modifier map is not verified until the class appears in the built
  CSS: `bun run build:css` then grep `docs/app/assets/builds/application.css` for
  it, including the `sm:`/`@sm:` variants.
- Stress iterations for a flake proof: 50 runs of the affected spec
  (`for i in (seq 50); ...; end`), and for the docs system spec that is 50 runs of
  the file, not of the whole suite.
- Where evidence goes: `lode/tmp/` (gitignored), unless the PR needs an auditable
  trail.
