# Popover components, the Rails engine, and the bundled Stimulus controllers

Two components render into the browser's top layer via the native Popover API,
and each ships an accompanying Stimulus controller under
`app/javascript/daisy_ui/controllers/`. Everything else in the gem is markup only.

## How the JavaScript reaches an app

`lib/daisy_ui/engine.rb` (36 lines) is required from `lib/daisy_ui.rb` only
`if defined?(Rails::Engine)`. It has no `isolate_namespace` — it ships no
routes, models or helpers — and registers two initializers:

| Initializer | Guard | Effect |
|---|---|---|
| `daisy_ui.assets` | `app.config.respond_to?(:assets)` | appends `<gem>/app/javascript` to `config.assets.paths` so Propshaft/Sprockets serve the files |
| `daisy_ui.importmap` (`before: "importmap"`) | `app.config.respond_to?(:importmap)`, then `respond_to?` again per collection | appends `<gem>/config/importmap.rb` to `importmap.paths` and `<gem>/app/javascript` to `importmap.cache_sweepers` |

`config/importmap.rb` is a single `pin_all_from … under: "daisy_ui/controllers",
to: "daisy_ui/controllers"`, so the host app gets
`daisy_ui/controllers/daisy_dropdown_controller` and
`…/daisy_tooltip_controller` with no manual pin. Registering them is the host
app's job (`lazyLoadControllersFrom("daisy_ui/controllers", application)`).

Both `app/` and `config/` are in the gemspec's file list, and the comment there
says so explicitly — dropping either prefix publishes a gem whose engine points
at files that are not in the package.

## `Dropdown` — zero-JS by default

`lib/daisy_ui/dropdown.rb` (258 lines). `Dropdown(:popover)` renders daisyUI's
**flat** structure: the trigger `<button>` and the popover panel are siblings,
and `dropdown` plus the placement classes ride the *panel* (that is the element
carrying `position-area`), not the wrapper. `popover_menu_options`
(`dropdown.rb:145-155`) therefore strips any `dropdown-content` class the caller
passes — that descendant rule forces `position: absolute`, which fights the top
layer.

- `popover_id` (`dropdown.rb:95-97`) memoises `"dropdown_#{SecureRandom.hex(8)}"`
  unless the caller passed `popover_id:`; the trigger's `popovertarget`, the
  panel's `id`, and the CSS `anchor-name`/`position-anchor` pair all derive from it.
- `stimulus:` defaults to **`false`** — `stimulus?` (`dropdown.rb:104-106`) is
  `@popover && @stimulus`, so a popover dropdown works with no JavaScript at all.
  `true` uses `DEFAULT_STIMULUS_IDENTIFIER = "daisy-dropdown"`; a String or
  Symbol overrides the identifier (`stimulus_identifier`, `dropdown.rb:109-113`).
- `PLACEMENT_MODIFIERS` is `%i[start center end top bottom left right]` (7).

The controller (`daisy_dropdown_controller.js`, 170 lines) deliberately
implements *nothing* the Popover API already does — no open/close, no
light-dismiss, no Escape handling. It listens for the popover's own `toggle`
event and does two things: mirror `aria-expanded` onto the invoker, and, only
when `#supportsAnchorPositioning()` is false (Safari < 26, Firefox < 147),
lazily import `@floating-ui/dom` to position the panel. That import is **not**
bundled — the host app must pin it, and if it is missing the menu still opens
unpositioned with a console warning. Roving keyboard navigation is a second
opt-in (`data-daisy-dropdown-keyboard-value="true"`).

## `Tooltip` — JavaScript required in popover mode

`lib/daisy_ui/tooltip.rb` (231 lines). Outside popover mode a tooltip is one
element with `data-tip`; `tip:` defaults to `nil` and `view_template`
(`tooltip.rb:29-40`) emits `data_tip` only when `tip` is truthy, so a
content-only tooltip needs no dummy string.

In popover mode:

- `stimulus:` defaults to **`true`**, and `validate_stimulus!`
  (`tooltip.rb:82-87`) raises `ArgumentError` unless the value is `true` or a
  String/Symbol matching `/\A\S+\z/` — so anything else (`false`, `nil`, `""`,
  `" "`, `:""`, a String with a space in it, a non-String/Symbol) raises rather
  than emitting `data-controller=""`. The spec exercises the first five.
- `PLACEMENTS` is `%i[top bottom left right]` (4) and `placement`
  (`tooltip.rb:93-95`) falls back to `:top`. `initialize` (`tooltip.rb:16-27`)
  passes `modifiers + PLACEMENTS.select { options[it] == true }` into
  `wire_controller`, so `Tooltip(:popover, bottom: true)` wires `bottom`, not the
  `:top` default — the boolean-keyword form and the positional form agree.
- `content` (`tooltip.rb:42-62`) marks the panel `popover="manual"`,
  `role="tooltip"`, applies `POPOVER_STYLE` (which starts it
  `visibility:hidden`) and emits an arrow `<span>` carrying `ARROW_STYLE` and
  the controller's `arrow` target.
- `view_template` adds `after:hidden` to the host element so daisyUI's stock
  CSS arrow does not double up with the controller-positioned one.

The controller (`daisy_tooltip_controller.js`, 231 lines) owns the lifecycle:
`connect` returns early without a `content` target, wires
pointerenter/pointerleave/focusin/focusout and sets `aria-describedby`;
`show()` sets `visibility:hidden`, calls `showPopover()`, then positions inside
a `requestAnimationFrame`. `#position()` (line 87) restores the caller's
`originalMaxWidth`, reads the computed `max-width`, and caps it at the viewport
width only when the viewport is narrower — a `max-w-64` tooltip stays 256px.
It then picks between the requested placement and its `OPPOSITE`, whichever
overflows less, shifts into the padded viewport, and only then sets
`visibility: "visible"`.

`disconnect()` (line 40) removes every listener, tears down the open state and
restores `aria-describedby` **unconditionally**; only the `max-width` restore is
guarded by `hasContentTarget`. Global `resize`/`scroll`/`keydown` and
`visualViewport` listeners exist only while the tooltip is open
(`#setupOpen`/`#teardownOpen`).

## Shared idiom: merging Stimulus data, never clobbering

Both components merge rather than overwrite. `Dropdown#popover_root_attributes`
(`dropdown.rb:117-124`) and `Tooltip#wire_controller` (`tooltip.rb:97-103`)
space-join the new controller onto any caller-supplied `data[:controller]`;
`Dropdown#merge_stimulus_data` (`dropdown.rb:159-166`) and
`Tooltip#merge_stimulus_target` (`tooltip.rb:105-110`) do the same for
`data-<identifier>-target`, `uniq`-ing the tokens. Caller `style` is merged by
each class's `merge_style`, which chomps a trailing `;` before joining.

## Related

- `../components/summary.md` — the `Base` pipeline both of these build on
- `../review/interactive.md` — accepted review findings about this layer
- README sections "Optional `daisy-dropdown` Stimulus controller" and
  "Collision-aware `Tooltip(:popover)`" are the user-facing versions
