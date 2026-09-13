# Accepted review findings

Rules about this system that came out of code review, written in system voice so
`/lode:gate` can enforce them. One file per lode area; each entry names the rule,
why it holds, where it lives in the code, which direction is safe when in doubt,
and the review thread it came from.

## Sources

- **cubic learnings: none.** No learnings are recorded for this repository (it is
  either not active in cubic or has none accepted). Everything here comes from
  the second source.
- **Merged PR review threads** on `zoolutions/daisyui` — CodeRabbit on PRs 13,
  15, 16, 17, 18, 33 and cubic-dev-ai on PR 37, plus the author's replies. A
  reply of the "fixed in `<sha>`" / "agreed" kind made the finding an entry; a
  reasoned rejection made it a `### Not a bug` entry.

An entry stays only while its subject exists in the tree. Findings whose file or
mechanism has since been replaced were dropped rather than carried forward.

## Files

- [`components.md`](components.md) — `Base`, the argument pipeline, and the 77
  components built on it
- [`interactive.md`](interactive.md) — `Dropdown`, `Tooltip` and the two Stimulus
  controllers
- [`testing-and-ci.md`](testing-and-ci.md) — the two suites and their hooks
- [`packaging-and-release.md`](packaging-and-release.md) — gemspec, `rake release`,
  `release.yml`
- [`docs-site.md`](docs-site.md) — the `docs/` Rails app, its lint and its deploy
