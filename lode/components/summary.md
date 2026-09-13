# Components: `Base` and the 77 classes built on it

## Loading

`lib/daisyui.rb` is the gem's named entry point and does one thing: `require_relative "daisy_ui"`.
`lib/daisy_ui.rb` requires `phlex` and `zeitwerk`, then sets up
`Zeitwerk::Loader.for_gem` with the inflection `"daisy_ui" => "DaisyUI"` and three
ignores — `daisyui.rb` (not a constant), `daisy_ui/updated_at.rb` and
`daisy_ui/engine.rb` (the engine references `Rails::Engine`, so it is required
explicitly at the bottom, only `if defined?(Rails::Engine)`). `version.rb` and
`updated_at.rb` are `require_relative`'d before the loader runs.
`loader.load_file(".../base.rb")` forces `Base` to load eagerly, because every
component's class body calls `register_modifiers` at definition time.

`module DaisyUI` then `extend Configurable` (the `configure`/`configuration`
class methods) and `extend Phlex::Kit` (the `Button(...)` short form for any
view that `include DaisyUI`).

## The argument pipeline

`Base#initialize(*modifiers, as: :div, id: nil, **options)`
(`lib/daisy_ui/base.rb:152-163`) sorts a call into three buckets:

| Bucket | Where it comes from | Where it ends up |
|---|---|---|
| modifiers | positional symbols, plus keys pulled out by `extract_boolean_modifiers` | CSS classes |
| options | `as:`, `id:` | the tag name and the `id` attribute |
| attributes | every other keyword (`data:`, `aria:`, `class:`, `responsive:`) | `@options`, consumed by `classes` / `attributes` |

`extract_boolean_modifiers` (`base.rb:251-260`) walks `modifier_map.keys` and,
for each key present in the options **whose value is exactly `true` or `false`**,
deletes it from the options; only the `true` ones join the modifier list. A key
that is not in `modifier_map`, or whose value is a string, stays in the options
and is rendered as an HTML attribute.

## Building the class string

`classes` (`base.rb:179-186`) is one `merge_classes` call whose arguments are
evaluated left to right, and two of them mutate `options`:

```ruby
merge_classes(base_class, *modifier_classes, *responsive_classes, options.delete(:class))
```

The order is load-bearing. `base_class` (`base.rb:206-211`) returns `nil` when
`options[:responsive]` contains a `true` value — the base class is then emitted
only with breakpoint prefixes — and it must therefore run **before**
`responsive_classes` (`base.rb:217-240`) deletes `:responsive`. `options.delete(:class)`
runs last, which is why `attributes` (`base.rb:195-197`) never re-emits `class`.

`modifier_map` (`base.rb:242-249`) merges four sources, later winning:

1. `skeleton: "skeleton"`, available on every component
2. `self.class.modifiers` — what `register_modifiers` accumulated
3. `DaisyUI.configuration.modifiers.for(component: self.class)` — app-added, scoped
4. `DaisyUI.configuration.modifiers.for(component: nil)` — app-added, global

So a globally-configured modifier overrides a component-scoped one, which
overrides the class's own.

`apply_prefix` (`base.rb:262-267`) returns its argument untouched when no prefix
is configured; otherwise it splits on whitespace and prefixes each token, which
is why a modifier may map to several classes (`primary: "bg-primary text-primary-content"`
in `COLOR_MODIFIERS`, `base.rb:41-119`, 11 entries: primary, secondary, accent,
neutral, base_100, base_200, base_300, info, success, warning, error).

**`apply_prefix` calls `String#split`, so every caller coerces first.** Exactly
three places in `lib/` feed `component_class` to it, and all three call `to_s`:
`base_class` (`base.rb:210`), `responsive_classes` (`base.rb:227`) and
`ThemeController#view_template` (`theme_controller.rb:49`). A new caller that
forgets the `to_s` raises `NoMethodError` for the 58 components whose
`component_class` is a Symbol — but only when a prefix is configured, which 13 of
the 71 spec files do. (`apply_prefix` returns its argument untouched for `nil`
and whenever `DaisyUI.configuration.prefix` is `nil`, which is why the bug hid
for so long. `McpServer` also reads `component_class`, but prints it rather than
splitting it.)

## Inheritance

`Base.inherited` (`base.rb:138-145`) gives each subclass a `dup` of the parent's
modifier hash — so `register_modifiers` in a subclass adds without mutating the
parent — and copies `component_class` only when the parent set one explicitly
(`instance_variable_defined?(:@component_class)`), so an ordinary component
still derives its own from its name.

## Sub-components

A component's parts are instance methods that call `component_classes`
(`base.rb:271-274`), which prefixes the fixed part names and appends
`options.delete(:class)`:

```ruby
def body(**options, &)
  div(class: component_classes("card-body", options:), **options, &)
end
```

`render_as` (`base.rb:276-282`) dispatches `as:` either as a Phlex tag method
(a Symbol) or as another component class to render.

## Configuration

`DaisyUI::Configurable` (`lib/daisy_ui/configurable.rb`, 47 lines) is tiny and
**global mutable state**: `Configuration#prefix` and a `Modifiers` store keyed by
component class (`nil` = every component). `DaisyUI.configure` memoises one
`Configuration` for the process, so any spec that changes it must put it back —
see `../testing-and-ci/summary.md`. (`Configurable#configure` opens with
`self.configuration ||= Configuration.new` even though no `configuration=`
writer exists; the reader memoises and returns truthy, so `||=` short-circuits
and the missing writer is never called. Deleting the reader's `||=` memoisation
would turn that line into a `NoMethodError`.)

## Related

- `../interactive/summary.md` — the two components with JavaScript
- `../review/components.md` — accepted review findings about this layer
