# The docs site (`docs/`)

A self-contained Rails 8.1 app with its own `Gemfile`, `.rubocop.yml`, `.rspec`,
`package.json` and Dockerfile. It depends on the gem through `gem "daisyui",
path: ".."`, so it renders the working tree's components, and on
[docs-kit](https://github.com/zoolutions/docs-kit) (`~> 1.0.8`) for the shell,
sidebar, search, code rendering and `/llms.txt` surfaces. The authoring contract
is `docs/AGENTS.md`, and `docs/.claude/skills/write-docs-page/SKILL.md` is the
page-writing skill it points at.

## Registries, not a database

Two plain-Ruby registries publish pages. Both expose docs-kit's "Registry v2"
shape (`.nav_items`, `#href`, `#view_class`) and are wired into
`c.nav_registries` in `config/initializers/docs_kit.rb`; the sidebar itself comes
from `c.nav = -> { DocsNav.groups }` because it interleaves both.

| Registry | Entries | Slug renders | Linked only when |
|---|---|---|---|
| `Doc` (`app/models/doc.rb`, 53 lines) | 3 (`installation`, `getting-started`, `theming`) | `Views::Docs::Pages::<View>` | `view_class` resolves — today only `installation.rb` exists, so the other two 404 and are absent from the nav |
| `ComponentDoc` (`app/models/component_doc.rb`, 204 lines) | 70 components in 7 categories | the shared `Views::Components::Show` | the component's example namespace has at least one class |

That "only if it exists" rule is deliberate: a registry row can be added before
its page is written without producing a dead link. `DocsController#show` and
`ComponentsController#show` apply the same test and `head :not_found` otherwise,
and `spec/requests/pages_spec.rb` asserts the 404 for `getting-started`.

`ComponentDoc.example_class_for` (`component_doc.rb:144-151`) is the security
boundary for the reactive viewer: a class name arriving in a signed token is
resolved only when it is a `Class`, `< Views::Components::Example`, **and** its
name starts with `Views::Components::Examples::`.

## Examples

276 example classes live in 70 directories under
`app/views/components/examples/<component>/`. Each subclasses
`Views::Components::Example` (`app/views/components/example.rb`), `include`s
`DaisyUI`, and implements `#example`. That one method is used twice: rendered
live for the Preview tab, and read back as text for the Source tab via
`method_source` (`#example_source` strips the `def`/`end` lines and re-dedents).
Preview and Source therefore cannot drift. `.title` defaults to the humanized
class name and `.order` defaults to 100, so explicitly ordered examples sort
first.

## Rendering

`ApplicationController` includes `DocsKit::Controller`, which supplies
`render_page` (renders the Phlex view with `layout: false` — `DocsUI::Shell` is
the whole document — and serves the Markdown twin on a `.md` request). The app
defines no layout of its own. `allow_browser versions: :modern` is on, which is
why `spec/requests/pages_spec.rb` sends an explicit modern `User-Agent`.

Routes (`config/routes.rb`): `/llms-full.txt`, `/llms.txt`, `/docs/search`, the
mounted `RailsIcons::Engine`, `/up`, `/service-worker`, `/manifest`, `root` →
`landings#show`, `/components/:component`, `/docs/:doc`. The phlex-reactive
engine mounts `POST /reactive/actions` itself — the file carries a comment
saying not to add it and to keep no catch-all that could shadow it.

## CSS

`bun run build:css` → `bin/build-css`. It resolves the `daisyui` and `docs-kit`
gem paths with `bundle show` and writes
`app/assets/stylesheets/tailwind.sources.css` with an
`@source "<gem path>/**/*.rb"` line for each, which
`application.tailwind.css` imports. **This is the mechanism the gem's responsive
comments depend on**; `bin/build-css` aborts with a message rather than building
a CSS file that silently omits a gem's classes. The daisyUI plugin is configured
`themes: all`, so `c.themes` in the docs-kit initializer (15 curated names) can
never name a theme the build lacks.

## Deployment

`.github/workflows/deploy-docs.yml` calls the shared
`zoolutions/docs-kit/.github/workflows/deploy.yml@main` with
`image: zoolutions/daisyui`, `service: daisyui`, on every published release and
on `workflow_dispatch`. The caller grants `packages: write`, because a reusable
workflow can only narrow the permissions it is given.

`config/deploy.yml` (Kamal) must stay in step with the Dockerfile's runtime
layout: the app lives at `/gem/docs` (`WORKDIR`), SQLite data at `/data`
(`VOLUME /data`, `DATABASE_URL` set by `ENV` in the Dockerfile, not by Kamal),
volume `daisyui_data:/data`, `asset_path: /gem/docs/public/assets`. The build
context is the repo root (`context: ..`) so the `path: ".."` gem resolves;
`minimum_version: 4.0.7` keeps an older Kamal from deploying it.

## Related

- `../review/docs-site.md` — accepted review findings about this app
- `../testing-and-ci/summary.md` — the docs lint and Playwright jobs
