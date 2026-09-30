# Docs Deployment

The docs site is deployed automatically when a new gem version is released.

## Flow

```text
bin/release  (→ rake release[X.Y.Z])
  └─> creates GitHub release
        └─> deploy-docs.yml workflow runs
              ├─> builds Docker image (repo root context)
              ├─> pushes to ghcr.io/mhenrixon/daisyui:vX.Y.Z
              └─> Kamal deploys to the docs server via SSH
                    └─> kamal-proxy routes by Host header
                          └─> Cloudflare Tunnel surfaces it publicly
```

## Architecture

```text
Internet
   │  HTTPS (TLS at edge)
   ▼
Cloudflare edge
   │  Tunnel
   ▼
[oss-docs server]
   ├─ cloudflared (systemd) ─► localhost:80
   │                              │
   ├─ kamal-proxy ◄───────────────┘
   │     │  Host: daisyui.zoolutions.llc
   │     ▼
   └─ daisyui container
```

The server is provisioned by [`mhenrixon/oss-infrastructure`](https://github.com/mhenrixon/oss-infrastructure) (private). See that repo for the Terraform setup. The same server hosts docs for multiple gems (daisyui, pgbus, etc.) — each one is added by creating a Cloudflare Tunnel public hostname pointing at `localhost:80`.

## Prerequisites

A docs server must exist with:

- **Docker** installed (the deploy user must be in the `docker` group)
- **cloudflared** running as a systemd service, connected to a Cloudflare Tunnel
- **kamal-proxy** running on `:80` (started automatically by Kamal on first deploy)
- The **`oss` SSH user** (see `ssh: user:` in `deploy.yml`) configured with the
  public key matching `SSH_PRIVATE_KEY`
- A **Cloudflare Tunnel public hostname** for `${DEPLOY_DOMAIN}` routing to `http://localhost:80`

The provisioned server is `oss@<DEPLOY_HOST>` (e.g. `178.105.2.54`), domain
`daisyui.zoolutions.llc`.

### CSS at build time

The daisyUI/Tailwind stylesheet is compiled by **bun** (`bun run build:css`) into
`app/assets/builds/application.css`, which is gitignored. `rails assets:precompile`
is enhanced to run `css:build` first (see `docs/lib/tasks/build_css.rake`), and the
Dockerfile installs bun in the build stage, so the image is built with fully
compiled CSS — no separate step is required.

## GitHub Setup

In the daisyui repo settings, create an environment named `docs` with these secrets:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | Private key for the `oss` user on the docs server |
| `DEPLOY_HOST` | Server IP or hostname (e.g. `178.105.2.54`) |
| `DEPLOY_DOMAIN` | Public domain (e.g. `daisyui.zoolutions.llc`) |

Set them with:

```bash
gh secret set SSH_PRIVATE_KEY --env docs --repo mhenrixon/daisyui < ~/.ssh/<deploy-key>
gh secret set DEPLOY_HOST --env docs --repo mhenrixon/daisyui --body "178.105.2.54"
gh secret set DEPLOY_DOMAIN --env docs --repo mhenrixon/daisyui --body "daisyui.zoolutions.llc"
```

The `GITHUB_TOKEN` is automatically available and used for ghcr.io authentication.
`DEPLOY_HOST`/`DEPLOY_DOMAIN` are injected into `deploy.yml` via ERB at deploy time.

The docs site is a public showcase with **no encrypted Rails credentials**, so it
needs no `RAILS_MASTER_KEY` and no 1Password secret. If the app ever grows real
secrets, add them to a `daisyui` item in the `oss-infrastructure` 1Password
vault (`bin/secrets set -d daisyui <key> <value>` in the oss-infrastructure repo),
re-add the Kamal 1Password fetch to `docs/.kamal/secrets`, list the keys under
`env.secret` in `deploy.yml`, and add `OP_SERVICE_ACCOUNT_TOKEN` back to the
`docs` GitHub environment.

## Container Layout

The Dockerfile uses the **repo root** as build context (not `docs/`) so the path gem dependency `gem "daisyui", path: ".."` resolves correctly.

Inside the container:
- `/gem/` — gem source (lib/, exe/, gemspec)
- `/gem/docs/` — Rails docs app (working directory)
- `/data/` — persistent SQLite database (volume mount)

## Manual Operations

```bash
# Trigger a deploy manually (without releasing a new version)
gh workflow run deploy-docs.yml --repo mhenrixon/daisyui

# Tail logs on the server
ssh oss@$DEPLOY_HOST "docker logs daisyui-web -f"

# Tail kamal-proxy logs
ssh oss@$DEPLOY_HOST "docker logs kamal-proxy -f"

# Tail cloudflared logs
ssh oss@$DEPLOY_HOST "sudo journalctl -u cloudflared -f"

# SSH into the running container
ssh oss@$DEPLOY_HOST "docker exec -it daisyui-web bash"

# Roll back to a previous version
cd docs && bundle exec kamal deploy --version=v1.0.6
```

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Workflow fails at "Login to GHCR" | Token missing `packages: write` | Already set in workflow `permissions:` |
| Kamal "host unreachable" | `DEPLOY_HOST` wrong or SSH key not authorized | Verify secret + `~/.ssh/authorized_keys` on server |
| 502 from Cloudflare after deploy | App container crashed or kamal-proxy not running | `docker logs daisyui-web`, `docker logs kamal-proxy` |
| 404 from kamal-proxy | `proxy.host` doesn't match `DEPLOY_DOMAIN` | Check the `host:` value in `docs/config/deploy.yml` matches the GitHub secret |
| Tunnel showing as DOWN in CF dashboard | cloudflared not running on server | `sudo systemctl status cloudflared` on the server |
| Asset 404s after deploy | Asset bridging didn't run | Verify `asset_path` in `deploy.yml` is `/gem/docs/public/assets` |
| SQLite data lost | Volume not mounted correctly | Verify `daisyui_data:/data` in `deploy.yml` volumes |
