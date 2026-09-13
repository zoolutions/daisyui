# Terminology

The words this repository uses, and what each one means in the code.

- **component** — a `DaisyUI::` class inheriting `DaisyUI::Base`, one per file
  under `lib/daisy_ui/`. 77 of the 83 files there declare `class X < Base`; the
  other six are `base.rb`, `configurable.rb`, `engine.rb`, `mcp_server.rb`,
  `updated_at.rb` and `version.rb`.
- **modifier** — a symbol a caller passes positionally (`Button(:primary)`) or as
  a `true` keyword (`Button(primary: true)`) that `modifier_map` turns into one
  or more CSS classes. Registered with `register_modifiers`.
- **boolean modifier** — the keyword form. `Base#extract_boolean_modifiers`
  moves `key: true` out of the options hash into the modifier list; `key: false`
  is also removed but adds nothing. Only keys already present in `modifier_map`
  and only the values `true`/`false` are treated this way — `primary: "x"`
  stays in the options and lands on the element as an HTML attribute.
- **responsive comment** — the commented-out class strings above each
  `register_modifiers` entry (`# "sm:btn-primary"`, `# "@sm:btn-primary"`, …).
  They are the only place the breakpoint-prefixed class names exist as literal
  text, and Tailwind's scanner reads them out of the gem's `.rb` files.
- **responsive option** — `responsive: { sm: :lg, md: [:primary, true] }`. A
  `true` value applies the *base* class at that breakpoint; a symbol applies
  that modifier's classes, each token prefixed separately.
- **component class** — the base CSS class for a component. Of the 77
  `< Base` classes, 58 set `self.component_class` to a Symbol, 13 to a String,
  4 to `nil` (`collapsible_sub_menu.rb`, `label.rb`, `menu_item.rb`,
  `table_row.rb` — they carry no class of their own), and 2 set nothing at all
  (`sub_menu.rb`, `tab.rb`), so `Base.component_class` derives it from the class
  name (`MockupBrowser` → `mockup-browser`).
- **prefix** — `DaisyUI.configuration.prefix`, prepended to every emitted class
  by `Base#apply_prefix` for apps that build daisyUI with a CSS prefix.
- **sub-component** — an instance method on a component that renders one of its
  parts (`Card#body`, `Stat#title`, `Drawer#side`), building its classes through
  `Base#component_classes` so the prefix and the caller's `class:` both apply.
- **Kit short form** — `DaisyUI extend Phlex::Kit`, so a view that
  `include DaisyUI` calls `Button(...)` instead of `render DaisyUI::Button.new(...)`.
- **popover mode** — the `:popover` modifier on `Dropdown` and `Tooltip`:
  the panel is a real `popover` element in the browser top layer, escaping
  `overflow` clipping.
- **example** — a `Views::Components::Examples::<Component>::<Name>` class in
  the docs app (276 of them across 70 directories). Its `#example` method both
  renders the live component and supplies the Source tab's text via
  `method_source`.
- **registry** — a plain-Ruby array of hashes that publishes docs pages:
  `Doc::REGISTRY` (3 guides) and `ComponentDoc::REGISTRY` (70 components, in 7
  categories). No database.
- **Markdown twin** — the `.md` rendering of a docs page that docs-kit serves
  from the same Phlex class, and links from `/llms.txt`.
