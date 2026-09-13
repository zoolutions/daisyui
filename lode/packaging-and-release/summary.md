# Packaging and release

## What ships in the gem

`daisyui.gemspec` builds `s.files` from `git ls-files -z`, filtered to four
prefixes — `exe/`, `lib/`, `app/`, `config/` — plus `CHANGELOG.md`,
`LICENSE.txt` and `README.md`. `app/` and `config/` are not optional: they carry
the Stimulus controllers and the importmap pin file the engine points at, so a
build that omits them publishes a gem whose `daisy_ui.importmap` initializer
references a missing file.

Two things make that robust:

- The `git ls-files` call runs with `chdir: __dir__` and `err: IO::NULL`, and
  **raises `Errno::ENOENT` itself when the result is empty**. `rescue Errno::ENOENT`
  then falls back to a `Dir[]` glob over the same prefixes. Rescuing only the
  "git is not installed" case would not be enough: in the docs Docker build
  `git` exists but `.git/` is excluded, so `ls-files` succeeds with no output.
  Both branches must list the same prefixes or the two builds differ.
- `s.executables` is derived from the file list (`s.files.grep(%r{\Aexe/})`), so
  adding a binstub is a one-line change.

Runtime dependencies are `phlex ("~> 2.0", ">= 2.0.0")` and `zeitwerk ~> 2.6`; `required_ruby_version`
is `>= 3.2`. `rubygems_mfa_required` is set.

`rake build` (`Rakefile:22-32`) builds with `--strict`, unpacks into
`/tmp/gem-verify`, prints the file list and cleans up — the quick local check
that the filter still does what it should.

## `rake release[X.Y.Z]`

`Rakefile:35-176`. The task is the only supported way to cut a release and it
runs **directly on `main`** — it pushes to `origin/main` itself, so a release is
not a PR.

Guards, in order (`Rakefile:45-49`): abort unless `git branch --show-current` is
`main`; abort unless `git status --porcelain` is empty. The branch check comes
first, because the later steps commit and `git push origin main` — from a
feature branch that would push the feature branch's HEAD onto `main`.

Then: rewrite `lib/daisy_ui/version.rb`; rewrite `lib/daisy_ui/updated_at.rb`
with `Time.now.utc`; `bundle install` at the root and, when it exists,
`cd docs && bundle install` (so `docs/Gemfile.lock`'s `daisyui (X.Y.Z)` pin
never drifts); `gem build --strict` as a smoke test; commit
`chore: bump version to X.Y.Z`; push; `gh release create <tag> --generate-notes`.

`rake release[pre]` keeps the current version and marks the release a
pre-release; a version string matching `/alpha|beta|rc|pre/` is also treated as
one. `rake release[X.Y.Z,force]` deletes the existing release and tag first
(`gh release delete --cleanup-tag`, `git tag -d`) — the escape hatch for a
release whose pipeline failed.

Every step is idempotent-by-skip: the version rewrite, the commit, the push and
the release creation each check first and print a `⊘ … (skipped)` line instead
of failing.

`CHANGELOG.md` is **not** touched by the task. Its only released heading is
`[0.1.0]`; everything since sits under `[Unreleased]` while `VERSION` is at
1.3.1, and GitHub release notes come from `--generate-notes` over the commits.

## `.github/workflows/release.yml`

Triggered by `release: types: [published]` — the release is public before the
pipeline runs. That window is accepted deliberately: the jobs are chained, so
nothing reaches RubyGems unless `test` and `build` pass first, and the worst
case is a public GitHub release with no matching gem for a few minutes. Note
that `rake release` itself runs `gem build --strict` but **not** the specs, so
the `test` job below is the only automated gate between a tag and a push.

| Job | Needs | Does |
|---|---|---|
| `test` | — | `bundle exec rspec` on Ruby 3.3 and 3.4, `fail-fast: true` |
| `build` | `test` | aborts unless the tag (minus `v`) equals `DaisyUI::VERSION`; `gem build --strict`; unpacks and **fails** if the package contains any `.git*`, any `*.gemspec`, or a `spec`/`test` directory; writes `.sha256`/`.sha512`; uploads the artifact |
| `publish-rubygems` | `build` | verifies both checksums, configures trusted publishing, signs with Sigstore and `gem push --attestation` |
| `upload-release-assets` | `build`, `publish-rubygems` | `gh release upload … --clobber` |

Two properties make a rerun safe: `gem push` is skipped when
`gem info daisyui --exact --remote` already reports that version (a
`::warning::`, not a failure), and the asset upload uses `--clobber`.

`rubygems/configure-rubygems-credentials` is pinned to the 40-character commit
SHA `bc6dd217f8a4f919d6835fcfefd470ef821f5c44` with a `# v1.0.0` comment — it
runs in the publish path with `id-token: write`, where a mutable tag would be a
supply-chain hole. The `actions/*` steps are pinned by major tag.

## Related

- `../review/packaging-and-release.md` — accepted review findings
- `../docs-site/summary.md` — the separate docs deploy workflow
