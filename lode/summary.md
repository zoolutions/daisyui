# daisyui (the Ruby gem)

`daisyui` is a Phlex component library: 77 Ruby classes under `DaisyUI::`
(`lib/daisy_ui/*.rb`, every one a `< Base`) that render daisyUI 5 markup, so a
view writes `Button(:primary) { "Save" }` instead of `button class="btn
btn-primary"`. The gem depends on `phlex` and `zeitwerk` only; Rails is optional
and reached through a guarded `require` (`lib/daisy_ui.rb` loads
`daisy_ui/engine` only `if defined?(Rails::Engine)`), so the library stays plain
Phlex outside Rails. It ships a stdio MCP server (`exe/daisyui-mcp`) that
answers questions about its own components, two bundled Stimulus controllers
for the popover forms of `Dropdown` and `Tooltip`, and a docs site under `docs/`
— a separate Rails 8.1 app with its own bundle, lint and specs, deployed by
Kamal on every GitHub Release.

Three invariants govern changes:

1. **A modifier's CSS class must appear as a literal string in a Ruby file
   Tailwind scans.** `register_modifiers` maps a symbol to a class name, and the
   responsive variants (`sm:`, `@sm:`, `md:` …) exist only because they are
   written out in comments above each entry; `docs/bin/build-css` resolves the
   gem's install path with `bundle show` and writes `@source "<path>/**/*.rb"`
   so Tailwind reads those comments. Drop a comment and the responsive class
   silently stops being generated.
2. **Components are pure render — no state, no I/O.** `Base#initialize` sorts
   arguments into modifiers, options and attributes and `view_template` emits
   tags; nothing reads the filesystem, the network or a database. The engine
   only appends asset paths.
3. **The library works without Rails, and JavaScript is opt-in everywhere but
   one place.** The engine and the importmap pin file are additive; every
   component renders server-side. `Dropdown` defaults to `stimulus: false`, so
   `Dropdown(:popover)` is zero-JS (native Popover API + CSS anchor
   positioning). The one exception is `Tooltip(:popover)`, which defaults to
   `stimulus: true` and *raises* `ArgumentError` on `stimulus: false`
   (`Tooltip#validate_stimulus!`, `lib/daisy_ui/tooltip.rb:82-87`) — its
   collision flipping has no CSS-only form.
