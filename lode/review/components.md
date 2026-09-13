# Review rules: components and `Base`

Accepted findings about `lib/daisy_ui/base.rb` and the 77 classes on it.
See [`../components/summary.md`](../components/summary.md) for how the layer works.

## `apply_prefix` splits a String, so every caller coerces first

`Base#apply_prefix` (`base.rb:262-267`) calls `String#split` to prefix each token
of a multi-class modifier. 58 of the 77 components set `self.component_class` to
a **Symbol**, so any caller that hands it the raw value raises `NoMethodError:
undefined method 'split' for an instance of Symbol` — and only when a prefix is
configured, which is why it survived: the default `apply_prefix` returns its
argument untouched before ever splitting.

Both readers coerce today: `base_class` uses `component_class&.to_s`
(`base.rb:210`) and `responsive_classes` uses `apply_prefix(base_class_value.to_s)`
(`base.rb:227`). `ThemeController#view_template` does the same at
`theme_controller.rb:49`.

- **Safe direction**: `.to_s` before `apply_prefix`, always. It costs nothing on
  a String and is the difference between working and raising on a Symbol.
- **Not a fix**: normalising one component's `component_class` to a String. That
  was the first proposal; it hides the bug for one class and leaves the other 57.
- **Test**: `spec/lib/daisy_ui/base_spec.rb:6-21`, "coerces the symbol
  component_class before prefixing".
- Origin: PR 13 thread on `lib/daisy_ui/link.rb:5`; re-raised and fixed at the
  root in PR 18 (`3e559b4`).

## A guard on an optional style value tests for emptiness, not truthiness

`RadialProgress#view_template` appends `--size:` only when
`size && !size.to_s.empty?` (`radial_progress.rb:21`), and `--thickness:` under
the same shape on the next line. A bare `if size` treats
`""` as present and emits `--size: ;`, which is an invalid declaration the
browser drops silently; a bare `if size.empty?` raises on an Integer. The
`.to_s.empty?` shape keeps both properties.

- **Safe direction**: reject the empty string at the guard rather than let it
  reach the style string.
- **Where else it applies**: any optional value a component interpolates into a
  `style` or a data attribute.
- **Test**: none for the empty string. `spec/lib/daisy_ui/radial_progress_spec.rb`
  covers `size: "6rem"` and the omitted case, not `size: ""`.
- Origin: PR 18 thread on `lib/daisy_ui/radial_progress.rb:22` (`3e559b4`).

## A component with a hidden inner control needs a named path to it

`Otp` renders a `<label>` wrapper around a real `<input>`. Every keyword a caller
passes lands on the wrapper, so `name`, `id`, `value` and `aria-*` never reached
the input and the component could not be submitted in a form. `Otp#initialize`
now takes `input_attributes: {}` and splats it into `input(...)`
(`otp.rb:7`, `otp.rb:23`).

- **Safe direction**: when a new component wraps an interactive element, add the
  keyword in the same change. Retrofitting it is an API addition callers have to
  learn about.
- **Test**: `spec/lib/daisy_ui/otp_spec.rb:165`, the `input_attributes` group.
- Origin: PR 17 thread on `lib/daisy_ui/otp.rb:22` (`92343f8`).

## Removing a modifier orphans the docs examples that use it

Dropping a key from a `register_modifiers` block does not break anything that
fails loudly: the example under
`docs/app/views/components/examples/<component>/` keeps rendering, now emitting a
class daisyUI no longer defines, and no build or spec complains.

- **Safe direction**: grep
  `docs/app/views/components/examples/` for the modifier name before deleting it,
  and delete or rewrite the example in the same PR.
- **Test**: none — this is the gap. `docs/spec/requests/pages_spec.rb` renders
  component pages but asserts nothing about which classes they emit.
- Origin: PR 13 thread on `lib/daisy_ui/button.rb:35` — removing `glass` and
  `no_animation` left two example files behind (`bf479cd` deleted them).
