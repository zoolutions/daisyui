# Review rules: the docs site

Accepted findings about the `docs/` Rails app, its lint and its deploy. See
[`../docs-site/summary.md`](../docs-site/summary.md) for how it is put together.

## `config/deploy.yml` and the Dockerfile describe one container, twice

Kamal's config and `docs/Dockerfile` must agree on the runtime layout or the
deploy succeeds and the site comes up wrong. The pairs that have to match:

| Dockerfile | `config/deploy.yml` |
|---|---|
| `WORKDIR /gem/docs` | `asset_path: /gem/docs/public/assets` |
| `VOLUME /data` | `volumes: ["daisyui_data:/data"]` |
| `ENV DATABASE_URL="sqlite3:///data/production.sqlite3"` | *(absent — set by the image)* |

An `asset_path` pointing at the old layout means the asset bridge between
versions silently does nothing, and a volume mounted at the wrong path loses the
SQLite database on every deploy.

- **Safe direction**: a change to either file is a change to both. Re-read the
  Dockerfile's `WORKDIR`, `VOLUME` and `ENV` lines before editing `deploy.yml`.
- **Test**: none — no spec covers deploy config.
- Origin: PR 15 thread on `docs/config/deploy.yml:36` (`44b5b3d`).

## A value the image already sets is not a Kamal secret

`DATABASE_URL` is set by `ENV` in the Dockerfile (line 90) and appears nowhere in
`config/deploy.yml` or `.kamal/secrets`. Listing it as a secret means a missing
environment variable at deploy time overrides the image's correct default with an
empty string, and `.kamal/secrets` grows an entry nobody can explain. Today that
file carries exactly one line, `KAMAL_REGISTRY_PASSWORD`, and says in a comment
why `SECRET_KEY_BASE` sits in `deploy.yml` under `env.clear` instead.

- **Safe direction**: the image owns its own defaults; Kamal supplies only what
  differs per host.
- **Test**: none.
- Origin: PR 15 thread on `.github/workflows/deploy-docs.yml:88` (`44b5b3d`).

## The docs app's RuboCop is not the gem's

`docs/.rubocop.yml` inherits docs-kit's config, targets Ruby 3.4, and disagrees
with the root file where the two overlap:

- `Style/TrailingCommaInHashLiteral` / `InArrayLiteral`: `comma` in `docs/`,
  `no_comma` at the root.
- `Rails/FilePath: EnforcedStyle: arguments`: `Rails.root.join("app", "assets",
  "images", "og")`, not `Rails.root.join("app/assets/images/og")`.

The root config excludes `docs/**/*` entirely, so running `bundle exec rubocop`
at the root proves nothing about `docs/`.

- **Safe direction**: lint the tree you edited from its own directory —
  `bundle exec rubocop` at the root, `bin/rubocop` inside `docs/`.
- **Test**: CI's `docs-lint` job runs `bin/rubocop` from `docs/`.
- Origin: PR 33 threads on `docs/lib/tasks/docs_kit_og.rake:31` and `:32`
  (`ceb8ef3`) — two findings, one rule.

## Every fenced code block declares a language

Markdown in this repo — `README.md`, `docs/DEPLOYMENT.md`, the command and rule
files under `.claude/` — opens every fence with a language, `text` for diagrams
and transcripts that have no syntax. Nothing in CI enforces it; the review bot
does, on every PR that touches a Markdown file.

- **Safe direction**: `text` when in doubt. A bare fence is a review comment.
- **Test**: none — no markdownlint config exists in the repo.
- Origin: PR 13 thread on `.claude/commands/review-pr.md:53` (`bf479cd`) and
  PR 15 threads on `docs/DEPLOYMENT.md:14` and `:20` (`99dafbe`) — three
  findings, one rule.
