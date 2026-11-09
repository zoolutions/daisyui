# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Documentation website for the DaisyUI Ruby gem (Phlex components wrapping daisyUI).
A registry-driven Rails 8.1+ app modeled on phlex-reactive's `site/`, with live,
zero-custom-JS reactive demos powered by the `phlex-reactive` gem. Stack: Phlex-Rails,
Tailwind CSS 4 + daisyUI 5.7, importmap + Stimulus + Turbo 8, Propshaft.

## Common Commands

```bash
bin/setup              # Install dependencies and setup database
bin/dev                # Start development server
bin/ci                 # Run full CI pipeline locally

# Testing
bundle exec rspec      # RSpec tests (request specs in spec/requests/)

# Code Quality
bin/rubocop            # Ruby linting
bin/rubocop -A         # Auto-fix Ruby issues
bin/brakeman --quiet --no-pager  # Security scan
bun run lint:js        # JavaScript linting (Biome)
bun run lint:css       # CSS linting (Stylelint)

# CSS
bun run build:css      # Build Tailwind CSS
bun run watch:css      # Watch CSS changes
```

## Architecture

### Layout-as-document + render_page
Every page is a Phlex class. `Views::Layout` IS the full HTML document (its own
`<html>/<head>/<body>` + the daisyUI Drawer shell). Controllers render pages with
`ApplicationController#render_page` (`render view, layout: false`) so there is no
double `<html>` nesting; phlex-rails still renders through a real view context so
CSRF, url helpers, and the reactive token signer work inside components.

### Phlex autoload namespaces (`config/initializers/phlex.rb`)
- `app/views/**`            → `Views::`        (e.g. `Views::Docs::Pages::Installation`)
- `app/components/**`       → `Components::`    (`Phlex::Kit` short-form)
- `app/reactive_components/` → **top-level**    (no namespace — the signed reactive
  token carries the class name verbatim, so `CounterComponent`, not `Components::…`)

### Registries (plain Ruby, no DB) drive nav + routing
Add a row to a registry + author its Phlex class to publish a page. The sidebar and
landing filter to entries whose class actually exists, so there are never dead links.

| Registry              | Slug → …                              | Renders via                         |
|-----------------------|---------------------------------------|-------------------------------------|
| `Doc`                 | guide pages                           | `Views::Docs::Pages::<View>`        |
| `ComponentDoc`        | component-reference pages             | `Views::Components::Examples::<Ex>` |
| `Demo`                | live reactive demos                   | `Views::Demos::Show` (shared)       |

Routes (`config/routes.rb`): `/` (landing), `/docs/:doc`, `/components/:component`,
`/demos/:demo`, `/up`. The phlex-reactive engine mounts `POST /reactive/actions`
itself — do NOT add it, and keep no catch-all that could shadow it.

### Docs kit (`app/views/docs/`)
Author a guide as a `Views::Docs::Page` subclass: set `title`/`eyebrow` via class DSL,
implement `#content` where each private method renders one `Section` interleaving
`Views::Code`, `Views::Docs::Prose`, and `Views::Docs::Callout`.
See `app/views/docs/pages/installation.rb` for the template.

### Component reference (`app/views/components/`)
A `Views::Components::Examples::<Name>` subclasses `Views::Components::Example`,
includes `DaisyUI`, and renders the live component in `#example`. The shared
`Views::Components::Show` page shows a Preview tab (live render) + Source tab (the
`#example` body, extracted via method_source). Template: `examples/button.rb`.

### Reactive demos (`app/reactive_components/`)
Top-level Phlex classes including `Phlex::Reactive::Streamable` +
`Phlex::Reactive::Component`. Define `reactive_state`/`reactive_record`, `action`s,
and bind triggers with `on(...)` inside `reactive_root`. `Views::Examples::DemoPanel`
shows Demo / Call-site / Component tabs. Templates: `counter_component.rb`,
`searchable_combobox_component.rb`.

### Frontend Stack
- Tailwind CSS 4 + daisyUI 5.7 (entry: `app/assets/stylesheets/application.tailwind.css`,
  built to `app/assets/builds/application.css` via `bun run build:css`)
- Theme switcher is zero-JS (daisyUI `theme-controller` + CSS `:has()`)
- Lucide icons via `rails_icons` (`Views::Icon` / `IconHelper#_lucide`)
- Importmap for JavaScript; the phlex-reactive Stimulus controller is registered
  eagerly in `app/javascript/controllers/index.js`

## Adding content

```ruby
# A guide page: add to Doc::REGISTRY, then author the page class:
class Views::Docs::Pages::Theming < Views::Docs::Page
  title "Theming"; eyebrow "Guide"
  def content = render Views::Docs::Section.new("…") { … }
end

# A component page: add to ComponentDoc::REGISTRY, then:
class Views::Components::Examples::Card < Views::Components::Example
  include DaisyUI
  def example = Card { … }
end

# A reactive demo: add to Demo::REGISTRY, then author the component under
# app/reactive_components/.
```
