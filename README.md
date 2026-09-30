<picture>
  <source srcset="https://github.com/user-attachments/assets/2c4d7fdb-abe7-4f71-a6d0-ef4d41b5625a" media="(prefers-color-scheme: dark)">
  <img src="https://github.com/user-attachments/assets/9afa9755-4aab-412a-9dc9-5eb2f76c12d6" width="350" alt="DaisyUI logo"><br>
</picture>

A Ruby UI component library for DaisyUI using Phlex

# Installation

## 1. Install CSS dependencies

You can install TailwindCSS and DaisyUI either via a JS bundler or via importmaps.

### JS Bundler

**TailwindCSS**

Install TailwindCSS by following the instructions in the TailwindCSS documentation, using either the Tailwind CLI or PostCSS.

**DaisyUI**

Install DaisyUI by following the instructions in the DaisyUI documentation as a Node package.

### Importmaps

**TailwindCSS with DaisyUI**

You'll need to download a TailwindCSS standalone CLI that comes bundled with DaisyUI by following the instructions in the [tailwind-cli-extra repo](https://github.com/dobicinaitis/tailwind-cli-extra).

Afterwards, place it somewhere in your project, e.g. in the bin directory.

If you want to compile the standalone TailwindCSS CLI with DaisyUI yourself, you can follow the instructions here.

**tailwindcss-rails gem**

Install tailwindcss-rails gem for Rails to automatically include your TailwindCSS stylesheets when the asset pipeline compiles your assets.

For this, you'll need to install the gem by following the instructions in the [tailwindcss-rails repo](https://github.com/rails/tailwindcss-rails).

Finally, you'll need to set the `TAILWINDCSS_INSTALL_DIR` environment variable in your Rails app pointing to the directory where you placed the binary from the tailwind-cli-extra repo mentioned above. e.g. `TAILWINDCSS_INSTALL_DIR=bin`

## 2. Install Ruby dependencies

### Install Phlex

Install Phlex by following the instructions in the [Phlex documentation](https://www.phlex.fun/#rails-introduction).

### Install DaisyUI gem

1. Add the DaisyUI gem to your Gemfile:

```
bundle add daisyui
```

2. (Optional) Include the `DaisyUI` module in `ApplicationComponent`:

```rb
class ApplicationComponent < Phlex::HTML
  include DaisyUI
end
```

This will allow you to use DaisyUI components using the short-form syntax. For example:

```rb
class SomeView < ApplicationView
  def view_template
    Button :primary do
      "Hello, world!"
    end
  end
end
```

If you don't include DaisyUI, you can still use the namespaced syntax:

```rb
class SomeView < ApplicationView
  def view_template
    render DaisyUI::Button.new(:primary) do
      "Hello, world!"
    end
  end
end
```

Consider not including DaisyUI in ApplicationComponent if:

- You have your own component library with the same component names as DaisyUI.
- You're including your own components module in `ApplicationComponent`.

In this scenario, including both DaisyUI and your own component library in `ApplicationComponent` will lead to naming conflicts.

3. Update your `tailwind.config.js` file to include DaisyUI component styles:

```js
const execSync = require("child_process").execSync;
const outputDaisyUI = execSync("bundle show daisyui", { encoding: "utf-8" });
const daisyUIPath = outputDaisyUI.trim() + "/**/*.rb";
module.exports = {
  content: [
    // ... other paths
    daisyUIPath,
  ],
};
```

4. Update your tailwind.config.js file to detect TailwindCSS classes in Ruby files.

```js
module.exports = {
  content: [
    // ... other paths
    //
    // Note the "rb" extension at the end
    "./app/views/**/*.{erb,haml,html,slim,rb}",
  ],
};
```

## Class merging

Components merge their classes so the last conflicting class wins, for Tailwind
utilities and daisyUI modifiers alike:

```ruby
Button(:sm, class: "btn-lg")          # => class="btn btn-lg"
Badge(:primary, class: "badge-error") # => class="badge badge-error"
Card(class: "p-2 p-4")                # => class="card p-4"
```

Tailwind conflicts follow [tailwind_merge](https://github.com/gjtorikian/tailwind_merge)
(its engine is ported into the gem as `DaisyUI::ClassMerge`, with no runtime
dependency). daisyUI modifiers conflict when they share a component and a
family: color, size, style, direction, placement (`top middle bottom left right`)
or alignment (`start center end`). `dropdown-top dropdown-end` keeps both;
`btn-sm btn-lg` keeps `btn-lg`. Component base classes such as `table` and
`collapse` are never dropped.

Register custom utilities so the merger knows what they are. Unregistered,
`text-display` reads as a color and a later `text-error` drops it. Custom
colors (`bg-brand`, `text-brand`) need no registration.

```ruby
DaisyUI.configure do |config|
  # text-display and text-hero are font sizes, like text-lg
  config.class_merge.utility("text-display", "text-hero", like: "text-lg")

  # Extend a Tailwind theme scale: p-gutter, m-gutter, gap-gutter, ...
  config.class_merge.theme(spacing: %w[gutter])
end
```

`class_groups` and `conflicts` take raw tailwind_merge groups for anything
else. Components subclassing `DaisyUI::Base` in your app get daisyUI families
for their own modifiers (`widget-sm widget-lg` keeps `widget-lg`).

Merge in your own components with `DaisyUI::ClassMerge.merge(*parts)` (strings,
arrays, `nil` and `false`; returns a frozen String). Opt out globally with
`config.class_merge.enabled = false`, or per component by overriding the
private `merge_classes`.

# Compatibility Notes

## @tailwindcss/forms plugin

If you're using the `@tailwindcss/forms` plugin alongside DaisyUI, you may encounter styling conflicts with form components like Toggle, Checkbox, and Radio. The forms plugin adds default checkbox/radio styling that can interfere with DaisyUI's custom styling.

**Solution:** Add the following CSS to your stylesheet to override the forms plugin styling for DaisyUI components:

```css
/* Override @tailwindcss/forms checkbox styles for DaisyUI components */
.toggle,
.checkbox,
.radio {
  background-image: none !important;
}
.toggle:checked,
.checkbox:checked,
.radio:checked {
  background-image: none !important;
}
```

Alternatively, you can configure `@tailwindcss/forms` to use the `class` strategy instead of `base`, which only applies styles when you explicitly add form classes:

```js
// tailwind.config.js
plugins: [
  require('@tailwindcss/forms')({
    strategy: 'class', // only apply form styles to elements with form-* classes
  }),
],
```

## Dropdown `:popover` positioning on older browsers

The `:popover` Dropdown modifier renders the menu in the browser top layer (so it
escapes `overflow` clipping) and positions it next to the trigger using **CSS
anchor positioning** (`anchor-name` / `position-anchor`). This works with **zero
JavaScript** on Chrome/Edge 125+, Safari 26+, and Firefox 147+.

```ruby
Dropdown(:popover, :end) do |dropdown|
  dropdown.button(:ghost, :sm) { "Actions" }
  dropdown.menu(:sm, class: "w-52") do |menu|
    menu.item { a(href: "#") { "Edit" } }
    menu.item { a(href: "#") { "Delete" } }
  end
end
```

On **older engines (Safari < 26, Firefox < 147)** the popover still opens in the
top layer, but without CSS anchor positioning it falls back to the viewport
default (DaisyUI centers it via `@supports not (position-area)`), so it is not
positioned next to the trigger.

To position correctly on those browsers with no application code, pin the
[OddBird CSS anchor positioning polyfill](https://github.com/oddbird/css-anchor-positioning)
and load it lazily:

```ruby
# config/importmap.rb
pin "@oddbird/css-anchor-positioning", to: "https://ga.jspm.io/npm:@oddbird/css-anchor-positioning@1/dist/css-anchor-positioning.fn.js", preload: false
```

```js
// app/javascript/application.js — load only when the browser lacks native support
if (!CSS.supports("anchor-name: --x")) {
  import("@oddbird/css-anchor-positioning").then(({ default: polyfill }) => polyfill())
}
```

Modern browsers fetch nothing extra; the polyfill loads only where it is needed.
For WAI-ARIA roving keyboard navigation inside `role="menu"` menus (which a CSS
polyfill cannot provide), see the optional Stimulus controller below.

## Optional `daisy-dropdown` Stimulus controller

The `:popover` dropdown needs **no JavaScript** on modern browsers. For two
specific cases — a JS positioning fallback on browsers without CSS anchor
positioning, and roving keyboard navigation over `role="menu"` items — the gem
ships an **opt-in** Stimulus controller. It deliberately does **not** re-implement
open/toggle, light-dismiss, or Escape; the native Popover API already handles
those.

Under Rails with importmap-rails, the gem auto-pins the controller (no manual
pin). Register it once, lazily:

```js
// app/javascript/controllers/index.js
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("daisy_ui/controllers", application)
```

Then opt in per call site:

```ruby
Dropdown(:popover, :end, stimulus: true) do |dropdown|
  dropdown.button(:ghost, :sm) { "Actions" }
  dropdown.menu(:sm, class: "w-52") do |menu|
    menu.item { a(href: "#", role: "menuitem", tabindex: "-1") { "Edit" } }
  end
end
```

- `stimulus: true` wires the `daisy-dropdown` controller (namespaced to avoid
  colliding with your own `dropdown` controller).
- `stimulus: "your-id"` overrides the identifier.
- The positioning fallback lazily imports `@floating-ui/dom` **only** when CSS
  anchor positioning is unavailable (Safari < 26, Firefox < 147), so modern
  browsers fetch nothing. The gem does **not** bundle it — if you enable the
  controller **and** need to support those browsers, pin it yourself (lazy, so
  modern browsers still skip it):

  ```ruby
  # config/importmap.rb
  pin "@floating-ui/dom", to: "https://ga.jspm.io/npm:@floating-ui/dom@1.7.6/dist/floating-ui.dom.mjs", preload: false
  ```

  If the pin is missing the menu still opens (native popover) — it just won't be
  repositioned on those legacy browsers, and the controller logs a console
  warning. Evergreen-only apps can skip the pin entirely.
- Enable keyboard navigation with
  `data: { daisy_dropdown_keyboard_value: true }` on the dropdown. Roving focus
  targets `role="menuitem"` items, falling back to links/buttons in the menu.

JS-bundler (esbuild/vite/webpack) consumers: import the controller from the
gem's `app/javascript/daisy_ui/controllers/daisy_dropdown_controller.js` and
register it manually.

## Collision-aware `Tooltip(:popover)`

The `:popover` Tooltip modifier renders real tooltip content in the browser top
layer instead of a `data-tip` pseudo-element. It therefore escapes clipping
ancestors, and the bundled `daisy-tooltip` controller flips and shifts the
tooltip to remain inside the visual viewport. Geometry listeners are attached
only while the tooltip is open.

```ruby
Tooltip(:popover, tip: "Helpful details") do
  Button(:circle) { "?" }
end
```

Directional and color modifiers compose normally:

```ruby
Tooltip(:popover, :bottom, :info, tip: "Saved automatically") do
  Button(:ghost) { "Status" }
end
```

Rich content uses the existing `content` sub-component:

```ruby
Tooltip(:popover) do |tooltip|
  tooltip.content(class: "max-w-64") do
    strong { "Keyboard shortcut" }
    kbd { "⌘ K" }
  end
  Button { "Commands" }
end
```

Register the gem controllers once with
`lazyLoadControllersFrom("daisy_ui/controllers", application)`, as shown in the
dropdown controller section above. Importmap-rails applications receive the
controller pin from the gem automatically. Bundler applications can import
`app/javascript/daisy_ui/controllers/daisy_tooltip_controller.js` and register
it as `daisy-tooltip`.

Popover tooltips:

- open on pointer hover or keyboard focus and close on leave, blur, or Escape;
- use `role="tooltip"` and merge their id into the first interactive trigger's
  `aria-describedby`;
- preserve caller-supplied Stimulus controllers;
- accept `popover_id:` for a stable tooltip id and `stimulus: "your-id"` to
  override the controller identifier.

Classic `Tooltip(tip: ...)` rendering remains unchanged.

# MCP Server (Claude Code Integration)

This gem includes an MCP (Model Context Protocol) server that provides component information to AI assistants like Claude Code.

## Setup

Add to your Claude Code MCP settings (`~/.claude.json` or project `.claude.json`):

```json
{
  "mcpServers": {
    "daisyui": {
      "command": "bundle",
      "args": ["exec", "daisyui-mcp"]
    }
  }
}
```

## Available Tools

- **list_components** - List all available DaisyUI components
- **get_component** - Get detailed info about a specific component (modifiers, usage examples)
- **search_components** - Search components by name or modifier

# Usage

Refer to [the docs](https://daisyui.phlex.fun) to see how to use components. Here's an example:

```rb
Card :base_100 do |card|
  figure do
    img(src:)
  end
  card.body do
    card.title do
      "Shoes!"
    end
    p do
      "If a dog chews shoes whose shoes does he choose?"
    end
    card.actions class: "justify-end" do
      Button :primary do
        "Buy Now"
      end
    end
  end
end
```

Which produces:

<img width="544" alt="Card example" src="https://github.com/user-attachments/assets/fad06a89-85fa-43cd-8c8f-7ed23b4ad77b">

# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhenrixon/daisyui. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mhenrixon/daisyui/blob/main/CODE_OF_CONDUCT.md).

1. Visit [the docs](https://daisyui.phlex.fun/) to see which components are still not implemented or not yet added to the docs.

2. Implement it.

3. After your PR is merged, [add it to the docs](https://github.com/mhenrixon/daisyui-docs).

4. Celebrate!

# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Code of Conduct

Everyone interacting in the DaisyUI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mhenrixon/daisyui/blob/main/CODE_OF_CONDUCT.md).
