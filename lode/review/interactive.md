# Review rules: `Dropdown`, `Tooltip` and the Stimulus controllers

Accepted findings about the two popover components and the JavaScript that ships
with them. See [`../interactive/summary.md`](../interactive/summary.md) for how
the layer works.

## A caller's `class:` may be a String, an Array or nil

`Dropdown#popover_menu_options` (`dropdown.rb:145-155`) rebuilds the popover
panel's class list from scratch, so it has to take the caller's value apart. It
reads it as `Array(options.delete(:class)).flat_map { |v| v.to_s.split }` and
then rejects the empties and `dropdown-content`. A bare `to_s.split` turns
`class: ["a", "b"]` into the single token `["a",` — a malformed class name the
browser keeps and no test notices.

- **Safe direction**: `Array(...)` first, `to_s.split` per element, `reject` the
  empties. Anywhere a component decomposes a caller-supplied class value.
- **Test**: `spec/lib/daisy_ui/dropdown_spec.rb:509` proves `dropdown-content` is
  stripped; the Array shape itself is not covered.
- Origin: PR 16 thread on `lib/daisy_ui/dropdown.rb:143` (`bc03620`).

## A Stimulus target is merged onto the caller's, never assigned over it

`Dropdown#merge_stimulus_data` (`dropdown.rb:159-166`) splits the existing
`data-<identifier>-target`, appends its own token, `uniq`s and re-joins.
Assigning `data[key] = target` drops whatever the caller wired to the same
controller, and the loss is silent — the element renders, the caller's target
just never resolves.

The same rule governs the controller name itself:
`Dropdown#popover_root_attributes` (`dropdown.rb:117-124`) and
`Tooltip#wire_controller` (`tooltip.rb:97-103`) space-join onto any existing
`data[:controller]`.

- **Safe direction**: read, merge, `uniq`, write. Before any `options[:x] = …`,
  ask whether `x` is caller-visible.
- **Test**: `spec/lib/daisy_ui/dropdown_spec.rb:607`, "space-joins a
  caller-supplied controller instead of clobbering it".
- Origin: PR 16 thread on `lib/daisy_ui/dropdown.rb:164` (`bc03620`).

## `tip:` is optional, and an omitted tip emits no `data-tip`

`Tooltip#initialize` defaults `tip:` to `nil` and `view_template`
(`tooltip.rb:29-40`) sets `data_tip` only when `tip` is truthy. Requiring the
keyword forced a content-only tooltip to pass `tip: ""`, which renders
`data-tip=""` — an empty daisyUI bubble on hover.

- **Safe direction**: a keyword that only exists to feed one attribute defaults
  to `nil`, and the attribute is omitted when it is.
- **Test**: `spec/lib/daisy_ui/tooltip_spec.rb:8`, "renders without data-tip when
  tip is omitted".
- Origin: PR 17 thread on `lib/daisy_ui/tooltip.rb:20` (`92343f8`).

## The boolean-keyword form of a modifier must reach the same code as the symbol

`Tooltip(:bottom)` and `Tooltip(bottom: true)` are the same request, but only the
first arrives in `modifiers` — `Base#extract_boolean_modifiers` runs later, in
`super`. `Tooltip#initialize` (`tooltip.rb:16-27`) therefore computes
`PLACEMENTS.select { |candidate| options[candidate] == true }` itself and passes
`modifiers + boolean_placements` into `wire_controller`, so the controller's
`placement-value` agrees with the rendered class either way.

- **Safe direction**: any component that reads its own modifiers *before*
  `super` has to look in `options` too.
- **Test**: `spec/lib/daisy_ui/tooltip_spec.rb:218`, "derives placement from
  boolean directional modifiers".
- Origin: PR 37 thread on `lib/daisy_ui/tooltip.rb:20` (`04e60e8`).

## An invalid controller identifier raises instead of rendering

`Tooltip#validate_stimulus!` (`tooltip.rb:82-87`) accepts `true` or a
String/Symbol matching `/\A\S+\z/` and raises `ArgumentError` for everything
else. `false`, `nil`, `""`, `"   "` and `:""` would otherwise render
`data-controller=""` or `data-controller="   "`: markup that looks wired and does
nothing, with no error anywhere in the stack.

- **Safe direction**: a Phlex component has no channel to report a problem other
  than raising at construction. Reject at `initialize`.
- **Test**: `spec/lib/daisy_ui/tooltip_spec.rb:253`, which exercises all five
  invalid values.
- Origin: PR 37 thread on `lib/daisy_ui/tooltip.rb:78` (`04e60e8`).

## The tooltip controller restores the caller's `max-width` before measuring

`#position()` (`daisy_tooltip_controller.js:87`) writes
`this.contentTarget.style.maxWidth = this.originalMaxWidth` (captured in
`connect`, line 23) **before** reading the computed value, then caps it at the
padded viewport only when the viewport is narrower. Measuring without restoring
first reads back the previous frame's clamp, so a `max-w-64` tooltip shrinks a
little more on every reposition.

- **Safe direction**: restore, measure, clamp — in that order, every frame.
- **Test**: `docs/spec/system/tooltip_popover_spec.rb` uses `max-w-64` and
  asserts the computed 256px constraint survives.
- Origin: PR 37 thread on `daisy_tooltip_controller.js:89` (`04e60e8`).

## `disconnect()` tears everything down unconditionally

`disconnect()` (`daisy_tooltip_controller.js:40-48`) removes the four element
listeners, calls `#teardownOpen()` and `#restoreDescription()` with no guard;
only the `max-width` restore is behind `if (this.hasContentTarget)`. An early
`return` on `!this.hasContentTarget` leaks the pointer/focus listeners, the
`window`/`visualViewport` listeners and the pending animation frame whenever the
content target goes away while the controller element stays connected.

- **Safe direction**: guard the one line that needs the element, never the whole
  cleanup. Cleanup is not allowed to be conditional on state that may have moved.
- **Test**: none — no JS unit suite exists in this repo.
- Origin: PR 37 thread on `daisy_tooltip_controller.js:41` (`292ff6b`).
