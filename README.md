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

3. Tell Tailwind which classes the gem renders: see [Tailwind sources](#tailwind-sources).

## Tailwind sources

The gem renders daisyUI class names from Ruby, so Tailwind has to be told
which ones to generate CSS for. Give it the classes of just the components your
app uses: `daisyui-tailwind` finds the components your Ruby and templates
reference, adds the components those render (Dropdown renders Button and Menu,
Menu renders MenuItem), and writes one `@source inline(...)` per component for
your Tailwind entry to import.

```sh
bundle exec daisyui-tailwind app -o app/assets/stylesheets/generated/daisyui.css
```

```css
/* app/assets/stylesheets/application.tailwind.css */
@import "tailwindcss";
@plugin "daisyui";

@source "../../views";                  /* your own classes, as before */
@import "./generated/daisyui.css";      /* the DaisyUI components you use */
```

Run it before Tailwind in your CSS build (it rewrites the file only when its
content changes, so a watcher does not loop on it). The output names no path,
so it is the same on every machine: commit it, or generate it on every build.

**From a Node build script**, spawn the command, or read JSON:

```js
// build-css.js (bun)
Bun.spawnSync(["bundle", "exec", "daisyui-tailwind", "app", "-o", "app/assets/stylesheets/generated/daisyui.css"])

// or per bundle, as JSON: { components, classes, files, shared, daisyui }
const out = Bun.spawnSync(["bundle", "exec", "daisyui-tailwind", "app/views/admin", "--format", "json"])
const { components, classes, files } = JSON.parse(out.stdout.toString())
```

**From Ruby** (a rake task, a build script):

```ruby
DaisyUI::Tailwind.used_components(scan: ["app"])         # => ["Button", "Menu", "MenuItem", ...]
DaisyUI::Tailwind.sources(scan: ["app"])                  # => the CSS partial
DaisyUI::Tailwind.sources(components: %w[Navbar], format: :json)
```

| Option | |
|---|---|
| `PATH...` | Directories (every `.rb`, `.erb`, `.haml`, `.slim` below) or files to scan. A path that does not exist is an error. |
| `-c, --component Button,Navbar` | Components to include whether or not a path references them (repeatable). |
| `-f, --format css\|json` | `css` (default) is the partial to import; `json` is for build scripts. |
| `-o, --output FILE` | Write to FILE instead of stdout, only when its content changes. |
| `--responsive sm,md,lg` | Add those breakpoint variants of each component class and modifier, for apps that render `responsive:` modifiers. Off by default: they multiply each component's CSS (sm,md,lg made the sample below 3.7 times larger). |
| `--prefix d-` | Prefix the classes the way an app that sets `DaisyUI.configuration.prefix` renders them. `DaisyUI::Tailwind.sources` uses the configured prefix by default. |

What counts as a use: a kit call with or without parentheses (`Button(:primary)`,
`Badge :primary do`, `Button variant do`, `Hero do`), an instance (`Card.new`)
or the constant (`DaisyUI::Navbar`, `class AppNavbar < DaisyUI::Navbar`).
Comments do not count (`#` lines in Ruby, `<%# %>` in ERB, `-#` in HAML, `/` in
Slim), nor does a name starting a sentence in a string ("Join thousands of…").
Matching is textual and errs on the side of including a component: a false hit
costs a little CSS, a miss would leave a component unstyled. A gem that renders DaisyUI components for you (phlex-forms wraps
Input, Select, Range...) is scanned like your app:
`daisyui-tailwind app "$(bundle info phlex-forms --path)/lib"`; the classes it
writes in its own Ruby still need its own `@source`. Classes your code builds
by interpolation (`"badge-#{color}"`) are invisible to Tailwind either way:
spell them out.

**The size win.** Measured on [cosmos](https://github.com/zoolutions/cosmos)
(33 of the gem's 77 components), the CSS the gem's classes add to a bundle
(Tailwind 4.3.2, daisyUI 5.6.13, minified):

| Sources | CSS | gzip |
|---|---|---|
| `@source` the gem's whole `lib/` | 210.1 KB | 31.9 KB |
| `daisyui-tailwind` | 125.7 KB | 19.1 KB |
| `daisyui-tailwind --responsive sm,md,lg` | 466.5 KB | 64.3 KB |

It is also more complete. Tailwind v4 drops Ruby comments when it scans a `.rb`
file and cannot see a Symbol component class (`self.component_class = :navbar`),
so the whole-gem scan generated no `.navbar`, `.card`, `.drawer`... rule (the app
only got them by spelling the class itself) and none of the sub-rules daisyUI
nests under them (`indicator-item`, `stack-top`). The manifest carries both.

**Scanning the whole gem still works** as it did:

```css
/* bundle info daisyui --path, resolved by your build script */
@source "/path/to/gems/daisyui-x.y.z/lib";
```

### The manifest

The command reads `data/daisyui/tailwind_manifest.json` in the gem, built from
the components themselves and checked in (`bundle exec rake tailwind:manifest`
in this repo). It sits outside `lib/`, so an `@source` on the gem's `lib/` or
its `**/*.rb` never sees it. A build script in another
language can read it directly from `$(bundle info daisyui --path)`:

```json
{
  "schema": 1,
  "shared": { "files": ["lib/daisy_ui/base.rb"], "classes": ["bg-primary", "skeleton", "..."] },
  "components": {
    "Dropdown": {
      "class": "DaisyUI::Dropdown",
      "name": "dropdown",
      "files": ["lib/daisy_ui/dropdown.rb"],
      "depends_on": ["Button", "Menu"],
      "modifiers": ["dropdown-end", "dropdown-top", "..."],
      "classes": ["dropdown", "dropdown-content", "dropdown-end", "..."]
    }
  }
}
```

- `name`: the daisyUI component class (`null` where it depends on the modifiers, as for Label).
- `files`: relative to the gem root, for a literal `@source` instead of `inline()`.
- `depends_on`: the components it renders; resolve them transitively.
- `modifiers`: the classes `responsive:` can prefix (with `name`).
- `classes`: everything it can render: `name`, the modifiers and the class words in its Ruby. Words that are not classes cost nothing.
- `shared`: base.rb's classes, which every component can render (`:skeleton`, the colour modifiers). Include them with any component.

### Your own components (`--app`)

A component you declare with [`variants`](#variants-states-and-slots) renders
classes that appear nowhere literally in your source: an `on %i[hover open]`
rule writes `hover:…` and `[.dropdown…>&]:…` at render time. Tailwind only
compiles what it finds written out, so hand it your components' classes too:

```sh
bin/rails "daisyui:tailwind[app/assets/stylesheets/generated/daisyui_app.css]"
# without Rails: load your components, then walk them
bundle exec daisyui-tailwind --app --require ./config/components.rb -o app/assets/stylesheets/generated/daisyui_app.css
```

```css
@import "./generated/daisyui.css";      /* the gem's components you use */
@import "./generated/daisyui_app.css";  /* your own: variants, compounds, states, slots */
```

With the app loaded (the rake task eager-loads Rails), it walks every
`DaisyUI::Base` subclass defined outside the gem and writes one
`@source inline(…)` per component, sorted by name: its component class,
modifiers, `base`, compound and slot classes, and each `on` class once per
state. `--responsive` and `--prefix` work as above; `--format json` too. From
Ruby: `DaisyUI::Tailwind.sources(app: true)`, or `app: [Widget, Picker]` for
some. The header carries no version and nothing depends on the machine, so the
file only changes when a declaration does: **commit it**, and let a spec fail
when it is stale, the way this gem checks its own manifest:

```ruby
# spec/daisyui_tailwind_spec.rb
it("has fresh Tailwind sources") { expect(DaisyUI::Tailwind.stale?("app/assets/stylesheets/generated/daisyui_app.css")).to be(false) }
```

`stale?` eager-loads a Rails app before it compares. The CSS build then never
boots the app; it only imports the file.

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
dependency). daisyUI modifiers conflict when the component declares them as
alternatives in one group: `btn-sm btn-lg` keeps `btn-lg`, while
`dropdown-top dropdown-end` keeps both (placement and alignment are separate
groups). Ungrouped modifiers (`btn-wide`, `btn-active`) never conflict.
A group holds only the component's own `<component_class>-*` classes: a
member's Tailwind utilities resolve by Tailwind's groups, and any other class
in it (a plugin utility such as `motion-duration-[400ms]`) never conflicts, so
the classes of one member never knock each other out.
Component base classes such as `table` and `collapse` are never dropped.

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
else.

Your own components declare groups the same way the gem's do, by nesting
modifiers under a group name:

```ruby
class Widget < DaisyUI::Base
  register_modifiers(
    size: { sm: "widget-sm", lg: "widget-lg" }, # widget-sm widget-lg -> widget-lg
    round: "widget-round"                       # ungrouped, never conflicts
  )
end

# Configured modifiers can join a component's group too
DaisyUI.configure do |config|
  config.modifiers.add(:huge, classes: "btn-huge", component: DaisyUI::Button, group: :size)
end
```

Merge in your own components with `DaisyUI::ClassMerge.merge(*parts)` (strings,
arrays, `nil` and `false`; returns a frozen String). Opt out globally with
`config.class_merge.enabled = false`, or per component by overriding the
private `merge_classes`.

## Unknown modifiers

A positional or responsive modifier the component does not know
(`Toggle(:primray)`) is reported instead of silently rendering nothing:

```ruby
DaisyUI.configure do |config|
  # Default: :raise under Rails in development/test, :warn everywhere else.
  config.unknown_modifiers = :raise # raises DaisyUI::UnknownModifierError
  # Or :warn (Kernel#warn), :ignore, or a callable such as
  # ->(error) { Appsignal.report_error(error) }. :warn and a callable fire once
  # per component (or sub-component part, e.g. Chat#bubble) and modifier; the
  # memory of what was reported resets after 1,000 distinct keys.
end
```

Known modifiers are the component's `register_modifiers`, `config.modifiers.add`
(for the component or any DaisyUI ancestor), and `register_flags`: positional
symbols your component handles itself without emitting a class. Flags are not
valid in `responsive:`, since they have no class to prefix. Sub-component
methods with their own modifiers (`Chat#bubble`, `Steps#step`,
`Indicator#item`) are checked too.

```ruby
class Widget < DaisyUI::Base
  register_flags :collapsed # Widget(:collapsed) is valid; read it via `modifiers.include?(:collapsed)`
end
```

Keyword arguments are not validated: `Toggle(primray: true)` renders a
`primray` attribute, because unknown keywords are HTML attributes.

## Variants, states and slots

The full guide, with when to use which declaration, is on the docs site:
[Variants, states and slots](https://daisyui.phlex.fun/docs/variants). Four things
to know before you write one:

- A `default` renders after the caller's modifiers, so it beats one that sets the same property. Put such a value in `base`.
- A `compound` or `on` rule also renders after the caller's modifiers. Leave the member it would override out of the match (`layout: [nil, :row]`).
- `on` writes `"<state>:<class>"`, the state outermost. A rule that needs a child selector first (`[&_li]:hover:...`) stays literal in `base`.
- `on` classes appear nowhere literally: generate [Tailwind sources](#your-own-components---app) for your components or Tailwind never compiles them.

`register_modifiers` maps a symbol to classes. A component that owns its design
also needs classes for two modifiers together, the same declarations under a
browser state, and classes for its parts. Declare them in a `variants` block:

```ruby
class Widget < DaisyUI::Button
  OPEN = "[.dropdown:is(:focus-within,[open],:has(:popover-open))>&]"

  variants do
    base "font-medium"                                        # after the inherited base (btn)
    variant :size, sm: "btn-sm [--fontsize:var(--text-sm)]"  # overrides one inherited member
    default :size, :md                                        # when the caller names no size

    compound style: :outline, color: nil, class: "[--btn-bg:var(--color-base-100)]"
    compound style: %i[ghost link], class: "[--btn-border:transparent]"

    state :hover, "hover"
    state :open, OPEN
    on %i[hover open], style: %i[ghost link], class: "[--btn-bg:color-mix(in_oklab,var(--color-base-content)_8%,transparent)]"
  end
end

Widget()            # btn font-medium btn-md
Widget(:ghost, :sm) # btn font-medium btn-ghost btn-sm [--fontsize:…] [--btn-border:transparent]
                    #   hover:[--btn-bg:…] [.dropdown…>&]:[--btn-bg:…]
```

| Declaration | |
|---|---|
| `variant :group, member: "classes", …` | Alternatives: the grouped `register_modifiers(group: { … })`. Members' own `<component_class>-*` classes merge as one ClassMerge group. |
| `flag :name, "classes"` | An on/off modifier: an ungrouped `register_modifiers` entry. `flag :name` alone is a `register_flags` flag, no class, for compounds to match. |
| `base "classes"` | Classes every instance gets, appended to the inherited base. |
| `default :group, :member` | The member used when the caller names none of the group. Never rendered beside a member the caller gives. |
| `compound(**match, class:, set: {})` | `class:` when every key of `match` holds. `set: { group: :member }` selects members for the caller's empty groups; later compounds see them. Applied in order, after defaults. |
| `state :name, "variant"` | Names a Tailwind variant once: `"hover"`, `"focus-visible"`, `"[.dropdown[open]>&]"`. |
| `on(states, **match, class:)` | Like `compound`, with each class written once per state: `on %i[hover open], class: "a"` renders `hover:a [.dropdown…>&]:a`. |
| `slot :name, "classes"` | A part of the component (see below). |

A `match` value says when a group or flag holds:

| Value | Holds when |
|---|---|
| `:member` | that member is selected: given, defaulted or set by an earlier compound |
| `[:a, :b]` | any of them is; a `nil` in the list means "or none": `shape: [nil, :row]` |
| `nil` / `false` | no member of the group is |
| `true` | any member of the group is: `color: true` |
| `true` / `false` | for a flag: it is on / off |

Classes render in this order, merged by ClassMerge: the component class, `base`,
the given modifiers, the defaulted and set members, compounds, `on` rules,
`responsive:`, then `class:`. Every declared class goes through
`DaisyUI.configuration.prefix` like a modifier (`hover:d-…` with `prefix = "d-"`).
A typo fails where it is declared, at boot: a `compound`, `on`, `default` or
`set:` naming a group, member, flag, state or slot the component does not have
raises `ArgumentError`. `class` and `set` are reserved keys: a group called that could never be matched, and nothing stops you naming one.

**Slots.** A component with parts declares each one; a variant, compound or `on`
value can be a Hash keyed by slot (`root` is the component itself):

```ruby
class Picker < DaisyUI::Dropdown
  variants do
    slot :trigger
    slot :menu, "mt-2"
    variant :reach, wide: { root: "picker-wide", menu: "w-96" }
    state :open, "[.dropdown:is(:focus-within,[open],:has(:popover-open))>&]"
    on :open, class: { menu: "shadow-lg" }
  end

  def trigger(*mods, **options, &) = render DaisyUI::Button.new(*mods, **slot_options(:trigger, options), &)
  def list(*mods, **options, &) = render DaisyUI::Menu.new(*mods, class: slot_classes(:menu, options), **options, &)
end
```

`slot_classes(:menu, options)` returns the slot's classes, those of every
selected member, compound and `on` rule for it, then `options.delete(:class)`,
merged. `slot_options(:trigger, options)` returns `options` with that `class:`.

**Introspection.** `Widget.variants.schema` is plain, frozen data for a docs
page, a component gallery or a design-tool parity check:

```ruby
{
  base: "btn font-medium",
  variants: { style: %i[ghost link outline dash soft], size: %i[lg md xs xl sm], … }, # a re-declared member moves last
  flags: %i[active disabled wide block],
  defaults: { size: :md },
  compounds: [{ match: { style: :outline, color: nil }, class: "[--btn-bg:…]", set: {} }, …],
  on: [{ states: %i[hover open], match: { style: %i[ghost link] }, class: "[--btn-bg:…]" }],
  states: { hover: "hover", open: "[.dropdown…>&]" },
  slots: { root: "btn font-medium" }
}
```

A component that only calls `register_modifiers` has a schema too (variants and
flags). An unknown modifier's error names the groups:
`Widget has no modifier :huge. Variants: style: ghost, link, outline, dash, soft; size: lg, md, xs, xl, sm; …`.
The state-prefixed classes need [Tailwind sources of their own](#your-own-components---app).

## Threads, fibers and Ractors

Components and `DaisyUI::ClassMerge` are safe to share between threads (Puma)
and fibers (Falcon). For Ractors, DaisyUI finalizes itself at boot: it freezes
the configuration and every component's registries, so
`DaisyUI::ClassMerge.merge` runs in any Ractor (as long as the configuration
is shareable, see below), each Ractor with a merger of its own.
`DaisyUI.configure` finalizes at its end and the Rails engine
finalizes again once the app has booted, so there is nothing to call. A
Rails-less app that never calls `configure` calls `DaisyUI.finalize!` at the
end of boot.

After that the configuration is frozen: writing to `DaisyUI.configuration`
directly raises `FrozenError`. `DaisyUI.configure` keeps working at any time:
it yields a writable copy and publishes it once that is finalized, and a
Ractor that already built its merger rebuilds it from the new configuration.
A test that changes a setting goes through it too:

```ruby
around do |example|
  DaisyUI.configure { |config| config.unknown_modifiers = :ignore }
  example.run
ensure
  DaisyUI.configure { |config| config.unknown_modifiers = :raise }
end
```

Finalizing never raises. A configured value that cannot be made shareable is
kept as it is, and the configuration is then readable on the main Ractor only:
a callable `unknown_modifiers` or a raw `class_merge` validator that closes
over app state (`->(error) { Appsignal.report_error(error) }` in an
initializer), or an object that holds a logger. A lambda is shareable when it
captures no local variables and is defined inside a module, or made with
`Ractor.shareable_lambda` on Ruby 4.0. A component that loads after boot (lazy
loading in development) freezes its registries as it writes them, so any
Ractor can read it; a Ractor that already built its merger picks up its groups
after the next `configure`. Rendering components inside a Ractor waits on Phlex
([yippee-fun/phlex#1055](https://github.com/yippee-fun/phlex/pull/1055)).

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

The pin resolves to a minified build with a linked sourcemap (devtools shows the
readable source) and is not preloaded: a page fetches the controller the first
time one of its elements appears.

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
controller pin (minified, not preloaded) from the gem automatically. Bundler applications can import
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
- **variants_guide** - How to declare a component with `variants`: which declaration to use, the match values, render order and the pitfalls

`get_component` also returns the component's variants schema (groups, flags, defaults, compounds, `on` rules, states and slots).

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

After editing a Stimulus controller in `app/javascript/daisy_ui/controllers/`,
rebuild its minified twin with `bundle exec rake build:js` (needs the bun in
`.bun-version`) and commit the `.min.js` and `.min.js.map`. CI runs
`bundle exec rake build:js_check` and fails when they are stale.

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
