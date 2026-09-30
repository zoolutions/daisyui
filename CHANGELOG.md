## [Unreleased]

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

- Maintainers cut releases with `bin/release` (`list`, `--dry-run`, `patch`/`minor`/`major`/`X.Y.Z`), which checks the lockfiles for gems that do not accept the new version yet and then drives `rake release`.

- Range component: added range-vertical modifier for vertical orientation (DaisyUI 5.6)
- Tooltip component: added alignment modifiers (tooltip-start, tooltip-center, tooltip-end) and tooltip-content sub-component (DaisyUI 5.6)

### Fixed

- Popover tooltips no longer clip arrows that extend beyond the tooltip card.

## [0.1.0] - 2024-08-02

- Initial release
