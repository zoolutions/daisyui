## [2.1.0]

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
  Ractor too. Writers replace them, as before; mutating one in place now
  raises `FrozenError`.
- Thread safety: the Tailwind class groups behind `ClassMerge` were built
  with an unguarded `||=` (8 threads built them 8 times); they are now built
  once per Ractor.
- Rendering components inside a Ractor waits on Phlex
  ([yippee-fun/phlex#1055](https://github.com/yippee-fun/phlex/pull/1055)).

## [2.0.2] and earlier

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
- `Tooltip` `:popover` modifier for collision-aware tooltips. It renders real
  tooltip content in the browser top layer, opens on hover or focus, flips and
  shifts within the visual viewport, follows scroll/resize while open, and
  exposes `role="tooltip"`/`aria-describedby` semantics. The bundled
  `daisy-tooltip` Stimulus controller is auto-pinned for importmap-rails apps
  and supports a custom controller identifier via `stimulus:`.

### Changed

- The gem ships minified Stimulus controllers with linked sourcemaps, and the
  importmap pins them without preloading, so with the lazy registration the
  README shows (`lazyLoadControllersFrom`) a page that never uses one never
  fetches it. `daisy_dropdown_controller` 6.1 KB → 2.8 KB (2.4 → 1.3 KB gzipped),
  `daisy_tooltip_controller` 8.8 KB → 5.2 KB (2.4 → 1.8 KB gzipped). The
  `daisy_ui/controllers/*` specifiers and the bundler import paths are unchanged.
- Maintainers cut releases with `bin/release` (`list`, `--dry-run`, `patch`/`minor`/`major`/`X.Y.Z`), which checks the lockfiles for gems that do not accept the new version yet and then drives `rake release`.

- Range component: added range-vertical modifier for vertical orientation (DaisyUI 5.6)
- Tooltip component: added alignment modifiers (tooltip-start, tooltip-center, tooltip-end) and tooltip-content sub-component (DaisyUI 5.6)

### Fixed

- Modifiers added with `config.modifiers.add(component: X)` now apply to
  subclasses of `X` too; the closest class wins.
- Popover tooltips no longer clip arrows that extend beyond the tooltip card.
- Button renders the `disabled` attribute on `button`/`input` elements when given
  `:disabled` or `disabled: true`, so a disabled submit button no longer submits
  its form from the keyboard (#52).

## [0.1.0] - 2024-08-02

- Initial release
