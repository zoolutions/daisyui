# Lode map

The index of this repository's durable memory. Read `summary.md` first, then the
area you are about to change and its `review/` file.

## Root

| File | What it holds |
|---|---|
| [`summary.md`](summary.md) | what the gem is, what it ships, and the three invariants every change has to keep |
| [`terminology.md`](terminology.md) | the repo's vocabulary — modifier, responsive comment, component class, prefix, sub-component, Kit short form, example, registry |
| [`practices.md`](practices.md) | patterns `.claude/rules/` does not state: Tailwind-readable class names, merging caller attributes, destructive option consumption, raising on invalid configuration, the two RuboCop configs |
| [`workflow.md`](workflow.md) | the profile the shared `/lode:` workflow skills read — commands, branches, layers, input shapes, wrong-here suggestions, docs, CI, flake sources, conflict rules, verification |
| [`plans/README.md`](plans/README.md) | where plans go: GitHub issues, or `lode/plans/` for a file plan |

## Areas

| Area | What it covers |
|---|---|
| [`components/summary.md`](components/summary.md) | `lib/daisy_ui/base.rb` and the 77 classes on it: loading through Zeitwerk, the modifier/option/attribute pipeline, class-string construction, inheritance, sub-components, global configuration |
| [`interactive/summary.md`](interactive/summary.md) | `Dropdown` and `Tooltip` in popover mode, the Rails engine, `config/importmap.rb`, and the two Stimulus controllers under `app/javascript/` |
| [`mcp-server/summary.md`](mcp-server/summary.md) | `exe/daisyui-mcp` and `lib/daisy_ui/mcp_server.rb`: the stdio JSON-RPC loop, its three tools, and how it discovers components through Zeitwerk's autoloads |
| [`docs-site/summary.md`](docs-site/summary.md) | the `docs/` Rails app: the two plain-Ruby registries, the 276 example classes, docs-kit rendering, the Tailwind source resolution, and the Kamal deploy |
| [`packaging-and-release/summary.md`](packaging-and-release/summary.md) | `daisyui.gemspec`'s file filter, `rake build`, `rake release[X.Y.Z]`, and `release.yml`'s four chained jobs |
| [`testing-and-ci/summary.md`](testing-and-ci/summary.md) | the gem's 71 RSpec files and their helpers, the docs app's request and system specs, and `main.yml`'s four jobs |

## Review rules

Accepted review findings, as rules about the system. `/lode:gate` enforces them;
`/lode:learn` adds to them.

| File | What it covers |
|---|---|
| [`review/README.md`](review/README.md) | where these came from — no cubic learnings; merged PR review threads only |
| [`review/components.md`](review/components.md) | `apply_prefix` and Symbol coercion, empty-string guards, routing attributes to an inner control, orphaned docs examples |
| [`review/interactive.md`](review/interactive.md) | structured `class:` inputs, merging Stimulus data, optional `tip:`, boolean modifier forms, rejecting invalid identifiers, the two tooltip-controller rules |
| [`review/testing-and-ci.md`](review/testing-and-ci.md) | waiting for the positioned frame in a browser spec; why `around` hooks deliberately do not use `ensure` |
| [`review/packaging-and-release.md`](review/packaging-and-release.md) | the empty `git ls-files` trap, guard order in `rake release`, SHA-pinning the publishing action, idempotent republish |
| [`review/docs-site.md`](review/docs-site.md) | keeping Kamal and the Dockerfile in step, image-owned defaults, the docs app's own RuboCop, fenced-block languages |

## Not in the lode

- `lode/tmp/` — scratch for a run in progress. Gitignored, never committed.
- Style, commit format, branch names, the TDD loop and agent use live in
  `.claude/rules/` (`coding-style.md`, `git-workflow.md`, `testing.md`,
  `agents.md`). The lode links to them rather than restating them.
