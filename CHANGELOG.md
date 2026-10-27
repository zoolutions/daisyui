## [Unreleased]

## [2.2.2] - 2026-10-27

### Fixed

- A variant member's classes no longer knock each other out. A group now holds
  only the component's own `<component_class>-*` classes; a member's other
  classes Tailwind does not classify (plugin utilities such as
  `motion-opacity-in-0 motion-duration-[400ms]`) are ungrouped, as a flag's
  are, so all of them render. A component without a `component_class` groups
  none of its own classes; globally configured grouped modifiers are unchanged
  (#73).

## [2.2.1] - 2026-10-27

### Fixed

- The Tailwind sources generator accepts named groups and peers
  (`group/item`, `group-has-[…]/item:block`, `peer-checked/field:block`) and a
  plugin utility's named modifier (`motion-ease-in-out/opacity`) instead of
  raising on them as paths. A bare word before the `/` (`app/components`) and a
  second `/` (`lib/daisy_ui/base.rb`) are still rejected (#71).

## [2.2.0] - 2026-10-26

### Documentation for the variants API

- Docs site: "Variants, states and slots" (when to use `variant`, `flag`,
  `compound`, `state`/`on` and `slot`, the match values, render order and its
  three pitfalls, introspection) and "Tailwind sources for your components"
  (`--app`, the rake task, committing the file, the `stale?` spec, stylelint).
- MCP server: `get_component` includes the component's `variants.schema`, and a
  new `variants_guide` tool returns a short guide to the DSL with the pitfalls.
- README: the variants section links the guide and lists the pitfalls.

### Variants, states and slots

A `variants` block declares what a component that owns its design needs
beyond `register_modifiers`, as data the gem owns (#67). See the README's
"Variants, states and slots".

```ruby
class Widget < DaisyUI::Button
  variants do
    base "font-medium"
    default :size, :md
    compound style: :outline, color: nil, class: "[--btn-bg:var(--color-base-100)]"
    state :hover, "hover"
    state :open, "[.dropdown:is(:focus-within,[open],:has(:popover-open))>&]"
    on %i[hover open], style: %i[ghost link], class: "[--btn-bg:transparent]"
  end
end
```

- `variant` and `flag` are `register_modifiers` (groups, ClassMerge,
  inheritance unchanged); `base` appends to the inherited base; `default`
  applies when the caller names no member of a group.
- `compound(**match, class:, set:)` adds classes when modifiers hold together
  or one holds and another is absent (`color: nil`, `shape: [nil, :row]`,
  `color: true`, flags `true`/`false`); `set:` selects members for the
  caller's empty groups, in declaration order.
- `state :name, "variant"` names a Tailwind variant once; `on(states, …)`
  writes a declaration once and renders it under each state.
- `slot :name, "classes"`, per-slot Hash values, and `slot_classes` /
  `slot_options` for components with parts.
- Defaults and `set:` members are resolved, not left to ClassMerge: a default
  never renders beside the member the caller gave, with class merging off too.
- A typo (a group, member, flag, state or slot the component does not have)
  raises `ArgumentError` where it is declared.
- `Component.variants.schema` returns plain, frozen data: variants, flags,
  defaults, compounds, `on` rules, states and slots.
- An unknown modifier's error now lists the component's groups:
  `… has no modifier :huge. Variants: size: xs, sm, …`.
- Registries are frozen by `DaisyUI.finalize!` like the others.

### Tailwind sources for an app's own components

State-prefixed classes appear nowhere literally in an app's source, so
`bin/rails "daisyui:tailwind[app/assets/stylesheets/generated/daisyui_app.css]"`
(or `daisyui-tailwind --app --require FILE`) writes `@source inline(…)` for
every `DaisyUI::Base` subclass the app defines: its classes, compounds, slots
and each `on` class per state. Sorted, versionless output meant to be
committed; `DaisyUI::Tailwind.stale?(path)` fails a spec when a declaration
changed and the file was not regenerated. From Ruby:
`DaisyUI::Tailwind.sources(app: true)`.

## [2.1.1] - 2026-10-17

### Tailwind sources for only the components an app uses

`bundle exec daisyui-tailwind app -o app/assets/stylesheets/generated/daisyui.css`
writes the Tailwind sources for the DaisyUI components an app's Ruby and
templates reference, plus the components those render (Dropdown renders
Button and Menu): one `@source inline("…")` per component, for the Tailwind
entry to `@import`. See the README's "Tailwind sources".

- Smaller: pointing `@source` at the whole gem hands Tailwind every class of
  every component and ClassMerge's catalogue of Tailwind utilities. On an app
  using 33 of the 77 components the gem's share of the CSS went from 210 KB to
  126 KB (32 → 19 KB gzipped).
- More complete: Tailwind v4 drops Ruby comments when it scans a `.rb` file
  and cannot see a Symbol component class (`self.component_class = :navbar`),
  so a whole-gem scan generated no `.navbar`, `.card` or `.drawer` rule, nor
  the rules daisyUI nests under them (`indicator-item`, `stack-top`), unless
  the app spelled the class out itself. The generated sources carry them.
- No path in the output, so it is the same on every machine; `--output`
  rewrites the file only when its content changes, so a CSS watcher does not
  loop on it.
- `--format json` gives a build script the components, their classes and
  their absolute files. From Ruby, `DaisyUI::Tailwind.sources(scan: ["app"])`
  returns the CSS (`format: :json` for the JSON), and
  `DaisyUI::Tailwind.used_components(scan: ["app"])` the component names.
- `--responsive sm,md,lg` adds breakpoint variants of each component class and
  modifier, for apps that render `responsive:` modifiers (off by default: it
  multiplies the CSS). `--prefix` matches `DaisyUI.configuration.prefix`,
  which `DaisyUI::Tailwind.sources` uses by default.
- The manifest behind it, `data/daisyui/tailwind_manifest.json`, lists every
  component's class, daisyUI name, file, the components it renders and its
  classes. It is built from the components (`rake tailwind:manifest`) and a
  spec fails when it is stale. It lives in the gem's data dir, not `lib/`:
  an app that keeps scanning the gem's `lib/` builds the same CSS as before.

## [2.1.0] - 2026-10-15

### DaisyUI finalizes itself at boot: class merging in any Ractor (#58)

At boot DaisyUI now freezes its configuration and every component's
registries, so a non-main Ractor can read them. `DaisyUI::ClassMerge.merge`
then works in any Ractor; each Ractor builds its own merger and LRU.

- Automatic: `DaisyUI.configure` finalizes at its end, and the Rails engine
  finalizes again in `after_initialize`, with no app code. A Rails-less app
  that never calls `configure` calls `DaisyUI.finalize!` at the end of boot.
- **The configuration is frozen after `DaisyUI.configure` (and, in a Rails
  app, after boot).** Writing to `DaisyUI.configuration` directly now raises
  `FrozenError`, e.g. `DaisyUI.configuration.unknown_modifiers = :ignore` in a
  spec: use `DaisyUI.configure { |config| config.unknown_modifiers = :ignore }`.
  `DaisyUI.configure` can be called again at any time: it yields a writable
  copy and publishes it once that is finalized, so no reader ever meets a
  half-changed configuration, and a block that raises changes nothing. A
  Ractor that already built its merger rebuilds it from the new
  configuration.
- Finalizing never raises. A configured value that cannot be made shareable
  is kept as it is, unfrozen, and the configuration is then readable on the
  main Ractor only: a callable `unknown_modifiers` or a raw `class_merge`
  validator that closes over app state (such as
  `->(error) { Appsignal.report_error(error) }` in an initializer), or an
  object that holds a logger.
- Component registries (`register_modifiers`, `register_flags`,
  `self.component_class =`) are frozen as they are written, so a component
  that loads after boot (lazy loading in development) is readable from any
  Ractor too. Writers now replace them instead of mutating them, and
  mutating one in place raises `FrozenError`.
- Thread safety: the Tailwind class groups behind `ClassMerge` were built
  with an unguarded `||=` (8 threads built them 8 times); they are now built
  once per Ractor.
- Rendering components inside a Ractor waits on Phlex
  ([yippee-fun/phlex#1055](https://github.com/yippee-fun/phlex/pull/1055)).

## [2.0.2] - 2026-10-11

### Unknown modifiers are reported (#54)

A positional or responsive modifier a component does not know used to render
nothing, silently. `config.unknown_modifiers` now decides what happens:

```ruby
DaisyUI.configure do |config|
  config.unknown_modifiers = :raise # :raise | :warn | :ignore | ->(error) { ... }
end
```

- The default is `:raise` under Rails in development and test, and `:warn`
  everywhere else (production, plain Ruby). A Rails app's test suite can go red
  after upgrading if it passes a modifier a component never had, e.g.
  `Toggle(:checked)` or `Radio(:checked)` (use `checked: true`): fix the call,
  register the modifier, or set `:warn`/`:ignore`.
- `:raise` raises `DaisyUI::UnknownModifierError` (an `ArgumentError`) naming
  the component, the modifier and the closest registered ones.
- `:warn` and a callable fire once per component (or part, so `Chat` and
  `Chat#bubble` count separately) and modifier. Thread-safe; the memory of what
  was reported resets after 1,000 distinct keys, so a modifier may be reported
  again after that. Use a callable to send it to an
  error tracker:
  `config.unknown_modifiers = ->(error) { Appsignal.report_error(error) }`.
- Known means the component's `register_modifiers`, `config.modifiers.add`, and
  the new `register_flags` for positional symbols a component handles itself
  without a class (Dropdown's `:popover`, Modal's `:tap_outside_to_close`, ...).
  Flags are not valid in `responsive:`.
- `Chat#bubble`, `Steps#step` and `Indicator#item` check their modifiers too
  (`DaisyUI::Chat#bubble has no modifier :primray`).
- Keyword booleans are not validated: unknown keywords stay HTML attributes.

### Changed

- The gem ships minified Stimulus controllers with linked sourcemaps, and the
  importmap pins them without preloading, so with the lazy registration the
  README shows (`lazyLoadControllersFrom`) a page that never uses one never
  fetches it. `daisy_dropdown_controller` 6.1 KB → 2.8 KB (2.4 → 1.3 KB gzipped),
  `daisy_tooltip_controller` 8.8 KB → 5.2 KB (2.4 → 1.8 KB gzipped). The
  `daisy_ui/controllers/*` specifiers and the bundler import paths are unchanged.

### Fixed

- Modifiers added with `config.modifiers.add(component: X)` now apply to
  subclasses of `X` too; the closest class wins.

## [2.0.1] - 2026-10-09

### Fixed

- Button renders the `disabled` attribute on `button`/`input` elements when given
  `:disabled` or `disabled: true`, so a disabled submit button no longer submits
  its form from the keyboard (#52).

## [2.0.0] - 2026-09-30

### Upgrading to 2.0

Components now merge their classes: when two classes conflict, the later one
wins. `Button(:sm, class: "btn-lg")` renders `btn btn-lg` (1.x rendered
`btn btn-sm btn-lg`), and `Card(class: "p-2 p-4")` renders `card p-4`.

- Conflicts are resolved for Tailwind utilities (a port of tailwind_merge 1.5.6)
  and for daisyUI modifiers a component declares as alternatives in one group
  (sizes, colors, styles, placements, mask shapes, loading styles, ...).
  Responsive and state variants (`sm:`, `hover:`) are separate slots.
- Register custom font sizes and other non-color utilities, or they may be
  misread. An unregistered `text-display` reads as a color and is dropped by a
  later `text-error`:

  ```ruby
  DaisyUI.configure do |config|
    config.class_merge.utility("text-display", like: "text-lg")
  end
  ```

- To keep the 1.x behaviour (plain join), disable merging:

  ```ruby
  DaisyUI.configure { |config| config.class_merge.enabled = false }
  ```

- The Tailwind utilities `table`, `collapse`, `filter` and `text-rotate` are treated as the
  daisyUI component classes of the same name and never conflict with `hidden`,
  `invisible` and friends.

### Added

- `DaisyUI::ClassMerge.merge(*parts)`: a daisyUI-aware class merger with no
  runtime dependencies. Configure it with `config.class_merge` (`enabled`,
  `utility`, `theme`, `class_groups`, `conflicts`).
- `register_modifiers` accepts groups of alternatives,
  `register_modifiers(size: { sm: "btn-sm", lg: "btn-lg" }, wide: "btn-wide")`,
  exposed as `.modifier_groups`. Every gem component declares its groups, and
  app components subclassing `DaisyUI::Base` can do the same.
  `config.modifiers.add` takes `group:` to join one.

### Changed

- Maintainers cut releases with `bin/release` (`list`, `--dry-run`, `patch`/`minor`/`major`/`X.Y.Z`), which checks the lockfiles for gems that do not accept the new version yet and then drives `rake release`.

## [1.3.1] - 2026-08-31

### Fixed

- Popover tooltips no longer clip arrows that extend beyond the tooltip card.

## [1.3.0] - 2026-08-30

### Added

- `Tooltip` `:popover` modifier for collision-aware tooltips. It renders real
  tooltip content in the browser top layer, opens on hover or focus, flips and
  shifts within the visual viewport, follows scroll/resize while open, and
  exposes `role="tooltip"`/`aria-describedby` semantics. The bundled
  `daisy-tooltip` Stimulus controller is auto-pinned for importmap-rails apps
  and supports a custom controller identifier via `stimulus:`.

## [1.2.1] - 2026-07-03

- No changes to the gem; this release shipped documentation-site and deploy changes only.

## [1.2.0] - 2026-06-26

### Added

- Aura component (DaisyUI 5.6) with style variants (dual, rainbow, holo, gold, silver, glow) and sizes
- Megamenu component (DaisyUI 5.6) with wide, full, vertical modifiers, sizes, and active_indicator sub-component
- OTP component (DaisyUI 5.6) for one-time password inputs with configurable digit count, joined modifier, sizes, and color variants
- `Dropdown` `:popover` modifier — renders the menu via the native Popover API
  and CSS anchor positioning, so it opens in the top layer and escapes
  `overflow` clipping (e.g. inside a table's `overflow-x-auto`). Accepts a
  `popover_id:` for a stable id. Wires `aria-controls`/`aria-expanded` on the
  trigger and `role="menu"` on the menu popover (the latter overridable, and
  omitted for non-menu `content` panels). Default and `:tap_to_close` dropdowns
  are unchanged. See the README "Dropdown `:popover` positioning" note for the
  optional older-browser polyfill.
- Opt-in `daisy-dropdown` Stimulus controller for `:popover` dropdowns
  (`Dropdown(:popover, stimulus: true)`), delivered to importmap-rails apps via
  a gated Rails engine that auto-pins it. Provides a feature-detected JS
  positioning fallback (Safari < 26, Firefox < 147) and optional roving
  keyboard navigation. The default `:popover` dropdown remains zero-JS, and the
  gem stays a plain Phlex library when Rails is absent.

### Changed

- Range component: added range-vertical modifier for vertical orientation (DaisyUI 5.6)
- Tooltip component: added alignment modifiers (tooltip-start, tooltip-center, tooltip-end) and tooltip-content sub-component (DaisyUI 5.6)

## [1.1.1] - 2026-04-05

### Changed

- The gem packages only `exe/`, `lib/`, `CHANGELOG.md`, `LICENSE.txt` and
  `README.md`, listed with `git ls-files` (#14).

## [1.1.0] - 2026-04-05

### Changed

- Components aligned with DaisyUI 5 (#13): new `Hover3d` and `TextRotate`
  components; `Link` sets the `link` class; `MenuItem` uses
  `menu-disabled`/`menu-active`/`menu-focus`; Button's `no_animation` and
  `glass`, Mask's `parallelogram` shapes and Menu's color modifiers are removed.

## [0.1.0] - 2024-08-02

- Initial release
