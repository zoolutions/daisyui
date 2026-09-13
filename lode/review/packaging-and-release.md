# Review rules: packaging and release

Accepted findings about `daisyui.gemspec`, the `release` Rake task and
`.github/workflows/release.yml`. See
[`../packaging-and-release/summary.md`](../packaging-and-release/summary.md) for
how the path works.

## An empty `git ls-files` is a failure, not an empty gem

`daisyui.gemspec` reads its file list from `git ls-files -z` and falls back to a
`Dir[]` glob. `rescue Errno::ENOENT` alone covers only "git is not installed" —
but the case that actually happens is the docs Docker build, where `git` exists
and `.git/` is excluded from the context: `ls-files` exits 0 with no output and
`s.files` silently becomes `[]`. The gemspec therefore ends the `begin` block
with `files.empty? ? raise(Errno::ENOENT) : files`, so the empty result takes the
same branch as the missing binary.

- **Safe direction**: an empty result from a subprocess that should always return
  something is an error. Raise into the fallback rather than shipping the empty
  value.
- **Both branches list the same prefixes** — `exe/`, `lib/`, `app/`, `config/`
  plus `CHANGELOG.md`, `LICENSE.txt`, `README.md`. `app/` and `config/` carry the
  Stimulus controllers and the importmap pin file the engine points at; dropping
  either prefix from one branch makes the two builds differ.
- **Test**: none directly. `rake build` unpacks the gem and prints the file list,
  and `release.yml`'s `build` job fails the release if the package contains a
  `.git*`, a `*.gemspec` or a `spec`/`test` directory.
- Origin: PR 15 thread on `daisyui.gemspec:21` (`44b5b3d`).

## The branch check comes before the dirty check

`rake release[X.Y.Z]` commits, then `git push origin main`. Run from a feature
branch it would push that branch's HEAD onto `main`. The task aborts unless
`git branch --show-current` is `main` (`Rakefile:45-46`) *before* it checks
`git status --porcelain` (`Rakefile:48-49`) — a clean tree on the wrong branch is
the dangerous case, so the cheaper, more specific guard runs first.

- **Safe direction**: any new step added to the task goes after both guards.
- **Test**: none — the task is not covered by a spec.
- Origin: PR 13 thread on `Rakefile:142` (`bf479cd`).

## An action in the publish path is pinned to a commit SHA

`rubygems/configure-rubygems-credentials` runs in `publish-rubygems`, the job
that holds `id-token: write` and pushes to RubyGems. It is pinned to the
40-character SHA `bc6dd217f8a4f919d6835fcfefd470ef821f5c44` with a `# v1.0.0`
comment; a mutable tag there would let a retagged release publish as this gem.
The `actions/*` steps elsewhere in the file are pinned by major tag.

- **Safe direction**: any third-party action that runs with `id-token: write` or
  `contents: write` gets a SHA pin and a version comment.
- **Test**: none — this is a config invariant.
- Origin: PR 13 thread on `.github/workflows/release.yml:132` (`bf479cd`).

## Republishing the same version is a warning, and asset upload clobbers

Re-running a release must not fail on work already done. `publish-rubygems`
checks `gem info daisyui --exact --remote` for the version and emits a
`::warning::` instead of pushing when it is already there; `upload-release-assets`
passes `--clobber` to `gh release upload`.

- **Safe direction**: every step in the release pipeline is safe to run twice.
  The Rake task follows the same rule with its `⊘ … (skipped)` branches.
- **Test**: none.
- Origin: PR 13 thread on `.github/workflows/release.yml:141` (`bf479cd`).

## Not a bug: the GitHub release is published before CI runs

`release.yml` triggers on `release: types: [published]`, so the release is public
for the minutes the pipeline takes. Reviewed and kept: the jobs are chained
(`build` needs `test`, `publish-rubygems` needs `build`), so nothing reaches
RubyGems unless the specs pass and the package verifies. The worst case is a
GitHub release with no matching gem for a few minutes — the release is the
trigger, not the artifact.

- Origin: PR 13 thread on `.github/workflows/release.yml:5`.
