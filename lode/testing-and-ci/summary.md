# Testing and CI

## The gem's suite

RSpec, 71 spec files, all under `spec/lib/daisy_ui/` — one per component plus
`base_spec.rb`. There is no spec for `mcp_server.rb`, `engine.rb` or
`configurable.rb`; `Configurable` is exercised indirectly by the specs that
configure a prefix or add modifiers.

`spec/spec_helper.rb` requires `daisyui` and `super_diff/rspec`, loads
`spec/support/**`, and defines `ComponentHelpers#render(component, &)` as
`component.call(&)` — Phlex renders straight to a string, no Rails, no view
context.

Two support files shape every example:

- `spec/support/html_helpers.rb` — `html(string)` normalises an expected HTML
  heredoc (collapses inter-tag whitespace, folds attribute values, one space
  between attributes, strips). Expectations are written as readable multi-line
  HTML and compared with `eq`, so a spec asserts the **whole** rendered string,
  attribute order included — not a substring.
- `spec/support/phlex_helpers.rb` — `phlex_context(&)` renders inside a plain
  `<div>` wrapper for sub-components that need a parent, and `config.include DaisyUI`
  makes the Kit short form (`Button(...)`) available in examples.

`.rspec` is `--format documentation --color --require spec_helper`.

### The `around` convention, and its hazard

13 of the 71 spec files set `DaisyUI.configuration.prefix`, and 4 of those 13
(`aura`, `card`, `megamenu`, `table`) also call `config.modifiers.add`.
`DaisyUI.configure` memoises one `Configuration` per process, so each of those
13 wraps the change in an `around` hook that restores the previous value
**after** a bare `example.run`. No file in `spec/` uses `ensure` — a
`grep` for it in `spec/` returns nothing. The consequence is real: an example
that raises (not merely fails an expectation) skips the restore and leaks a
prefix into every later example. The convention is uniform on purpose; changing
it is a suite-wide refactor, not a per-PR edit (see `../review/testing-and-ci.md`).

## The docs app's suite

`docs/spec/` holds one request spec (`spec/requests/pages_spec.rb`, 8 examples
covering the landing page, an authored guide, three 404 paths, a component page,
a `POST /reactive/actions` round-trip and `/up`) and one system spec
(`spec/system/tooltip_popover_spec.rb`) driven by Capybara + the Playwright
driver against headless Chromium.

`spec/system/support/precompile_assets.rb` runs `bun run build:css` in a
`before(:suite)` hook — but only outside CI (`ENV["CI"]`/`ENV["GITHUB"]`), only
when a system/controller/request example is selected, and only when no
`tailwindcss` process is already running in the directory. It clobbers assets
again `after(:suite)`. Locally that means a spec run mutates
`app/assets/builds/`.

The system spec reads geometry out of the page with `page.evaluate_script`. The
controller positions inside a `requestAnimationFrame`, so `:popover-open` alone
is not enough to read from — the spec waits on
`have_css("#left_edge_tooltip:popover-open", visible: true)` and asserts
`visibility == "visible"` before trusting any coordinate.

## CI (`.github/workflows/main.yml`)

Four jobs, all in parallel, on `push` to `main` and on every `pull_request`:

| Job | Name in checks | Runs |
|---|---|---|
| `lint` | Lint | `bundle exec rubocop lib spec` (Ruby 4.0) |
| `gem-test` | Gem Tests (Ruby 3.2 / 3.3 / 3.4 / 4.0) | `bundle exec rspec`, `fail-fast: false` |
| `docs-lint` | Docs Lint | in `docs/`: `bin/rubocop`, `bun run lint:js` (Biome), `bun run lint:css` (Stylelint) |
| `docs-test` | Docs Tests | in `docs/`: Playwright chromium + libvips, `bun run build:css`, `db:create db:migrate`, `assets:precompile`, then `bundle exec rspec` with `HEADLESS=true`; 15-minute timeout; uploads `docs/tmp/capybara/screenshots/*.png` on failure |

Ruby is pinned to `4.0` for the three non-matrix jobs and bun to `1.3.2`.
Nothing filters by path: a gem-only PR still runs both docs jobs.

The CI lint command is `rubocop lib spec` — narrower than the local
`bundle exec rubocop`, which also covers the `Rakefile` and the gemspec, and
whose `AllCops.Exclude` drops `docs/**/*` entirely. The docs app has a separate
`.rubocop.yml` that inherits docs-kit's config, targets Ruby 3.4, and disagrees
with the root file on trailing commas: the gem wants
`EnforcedStyleForMultiline: no_comma`, the docs app wants `comma`.

## Related

- `../review/testing-and-ci.md` — accepted review findings about the suites
- `../packaging-and-release/summary.md` — the release and deploy workflows
