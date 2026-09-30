# Git Workflow Rules

## Commit Messages

Use conventional commits:
- `feat:` - New feature or component
- `fix:` - Bug fix or DaisyUI alignment fix
- `refactor:` - Code refactoring
- `docs:` - Documentation only
- `test:` - Adding/updating tests
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

Format:
```
feat(component): brief description

Longer explanation if needed. Focus on WHY, not WHAT.

Refs #123
```

## Branch Naming

- `feature/description` - New features or components
- `fix/description` - Bug fixes
- `refactor/description` - Refactoring
- `ci/description` - CI changes
- `chore/description` - Maintenance

## PR Workflow

1. Create branch from `main`
2. Make focused, atomic commits
3. Run all validators before pushing
4. Create PR with description and test plan
5. Request review
6. Squash merge when approved

## Release

Releases go through `bin/release`, from a clean, up-to-date `main` after the
PRs have merged. It works out the next version (`patch` default, `minor`,
`major`, or an explicit `X.Y.Z`; `rc`/`beta`/`alpha` versions are
prereleases), shows the commits since the last tag, and refuses to run when a
gem in `Gemfile.lock` or `docs/Gemfile.lock` pins `daisyui` below the new
version (release that gem first). It then hands off to `rake release[X.Y.Z]`
(`rakelib/release.rake`), which bumps `version.rb`, runs the Rakefile's
`release:prepare` hook (stamps `updated_at.rb`), bumps the `daisyui` pin in both
lockfiles in place (no re-resolve), verifies the build, commits, pushes `main`
and creates the GitHub Release. The Release workflow publishes to RubyGems via
trusted publishing (OIDC + Sigstore). `bin/release`, `rakelib/release.rake` and
the shared jobs of `release.yml` are byte-identical across the zoolutions gems
(docs-kit, daisyui, dash, pgbus, phlex-reactive): change them in every repo or
none.

```bash
bin/release list        # last releases + what each bump would give
bin/release --dry-run   # show version, changes and lockfile blockers; publish nothing
bin/release major       # 1.3.1 -> 2.0.0, after a y/N confirm
```

A release is the user's call: run `list` / `--dry-run` freely, but never run a
real `bin/release` (it pushes `main` and publishes the gem) unless asked to.

## Pre-Commit Checklist

Run before EVERY commit:
```bash
bundle exec rubocop              # Style
bundle exec rspec                # Tests
```

## Rules

- **NEVER** commit directly to `main`
- **NEVER** force push to shared branches
- **NEVER** `gem push` or bump `lib/daisy_ui/version.rb` by hand — use `bin/release`
- **ALWAYS** run validators before committing
- **ALWAYS** write meaningful commit messages
- Keep commits small and focused
- One logical change per commit
