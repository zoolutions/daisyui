# frozen_string_literal: true

module Views
  module Docs
    module Pages
      # The `variants` DSL on DaisyUI::Base: what each declaration is for, how a
      # match reads, the render order and the three ways it surprises.
      class Variants < DocsUI::Page
        title "Variants, states and slots"
        eyebrow "Guide"

        def lead
          "Declare a component's design as data: alternatives, flags, defaults, " \
            "compounds, browser states and slots, in one variants block."
        end

        def content
          which_declaration
          match_values
          render_order
          pitfalls
          slots
          introspection
        end

        private

        def which_declaration
          DocsUI::Section("Which declaration") do
            md <<~MD
              `register_modifiers` maps a symbol to classes. A component that owns its
              design also needs classes for two modifiers together, the same classes under
              a browser state, and classes for its parts. Declare them in a `variants`
              block on any `DaisyUI::Base` subclass (2.2.0, unreleased: `main` today):

              ```ruby
              class Widget < DaisyUI::Button
                variants do
                  base "font-medium"
                  variant :size, sm: "btn-sm", md: "btn-md"
                  default :size, :md

                  compound style: :outline, color: nil, class: "[--btn-bg:var(--color-base-100)]"

                  state :hover, "hover"
                  on :hover, style: %i[ghost link], class: "[--btn-bg:transparent]"
                end
              end

              Widget()                  # btn font-medium btn-md
              Widget(:outline)          # btn font-medium btn-outline btn-md [--btn-bg:var(--color-base-100)]
              Widget(:ghost, :sm)       # btn font-medium btn-ghost btn-sm hover:[--btn-bg:transparent]
              ```

              | You need | Use |
              |---|---|
              | Alternatives where one applies: sizes, colors | `variant :group, member: "classes"` |
              | An on/off modifier | `flag :name, "classes"`. `flag :name` alone has no class; compounds match on it |
              | Classes every instance gets | `base "classes"`, appended to the inherited base |
              | A member when the caller names none of the group | `default :group, :member` |
              | Classes when modifiers hold together, or one is absent | `compound(**match, class:, set: {})` |
              | The same classes under a browser state | `state :name, "<tailwind variant>"` once, then `on(states, **match, class:)` |
              | A part of the component: trigger, menu | `slot :name, "classes"` |

              `variant` and `flag` are `register_modifiers` underneath: groups, ClassMerge
              and inheritance work as before. A typo fails where it is declared, at boot:
              a `compound`, `on`, `default` or `set:` that names a group, member, flag,
              state or slot the component does not have raises `ArgumentError`.
            MD
          end
        end

        def match_values
          DocsUI::Section("Match values") do
            md <<~MD
              `compound` and `on` take a match: one key per group or flag.

              | Value | Holds when |
              |---|---|
              | `:member` | that member is selected: given, defaulted or set by an earlier compound |
              | `[:a, :b]` | any of them is. A `nil` in the list means "or none": `shape: [nil, :row]` |
              | `nil` or `false` | no member of the group is |
              | `true` | any member of the group is: `color: true` |
              | `true` or `false` | for a flag: it is on or off |

              Every key must hold. `set: { group: :member }` on a compound selects members
              for the caller's empty groups, in declaration order, and later compounds see
              them. `class` and `set` are reserved keys: a group called that could never be matched, and nothing stops you naming one.
            MD
          end
        end

        def render_order
          DocsUI::Section("Render order") do
            md <<~MD
              Classes render in this order and ClassMerge keeps the last of any conflicting pair:

              1. the component class (`btn`)
              2. `base`
              3. the modifiers the caller gave
              4. defaulted and `set:` members
              5. compounds, in declaration order
              6. `on` rules
              7. `responsive:`
              8. the caller's `class:`

              Every declared class goes through `DaisyUI.configuration.prefix` like a
              modifier (`hover:d-...` with `prefix = "d-"`).
            MD
          end
        end

        def pitfalls
          DocsUI::Section("Three pitfalls") do
            md <<~MD
              ### A default renders after the caller's modifiers

              A default member's class beats a modifier the caller gave when both set the
              same property. Here the default size wins over `:inline`:

              ```ruby
              class Chip < DaisyUI::Badge
                register_modifiers(inline: "[--fontsize:0.75rem]")
                variants do
                  variant :size, md: "[--fontsize:1rem]"
                  default :size, :md
                end
              end

              Chip(:inline)   # badge [--fontsize:1rem]     the caller's :inline lost
              ```

              Put a value that both can set in `base`, which renders before the modifiers:

              ```ruby
              variants { base "[--fontsize:1rem]" }

              Chip(:inline)   # badge [--fontsize:0.75rem]
              Chip()          # badge [--fontsize:1rem]
              ```

              ### A compound can override a modifier's property

              Compounds and `on` rules also land after the caller's modifiers. This one
              runs for `:inline` and replaces its `--gap`:

              ```ruby
              register_modifiers(layout: { inline: "[--gap:0.25rem]", row: "flex" })
              variants { compound color: nil, class: "[--gap:1rem]" }

              Tag(:inline)    # badge [--gap:1rem]
              ```

              Leave the conflicting member out of the match, with `nil` for "or none":

              ```ruby
              variants { compound color: nil, layout: [nil, :row], class: "[--gap:1rem]" }

              Tag(:inline)    # badge [--gap:0.25rem]
              Tag()           # badge [--gap:1rem]
              ```

              ### The state prefix is outermost

              `on` writes `"<state>:<class>"`. A rule that needs a child selector first, such
              as `[&_li]:hover:bg-base-200` (an item inside the component hovered), cannot be an
              `on :hover` rule, which would write `hover:[&_li]:bg-base-200`. Keep that class
              literal in `base`.

              ```ruby
              state :hover, "hover"
              on :hover, class: "bg-base-200"   # badge hover:bg-base-200
              ```

              Two smaller ones. Do not name a group after one the parent already has with a
              different meaning: `DaisyUI::Button` has `shape` (circle, square), and a group
              of the same name makes your members alternatives of those. And a state
              selector with a child combinator, such as `[.dropdown[open]>&]`, puts `>` inside
              the class attribute, so a spec that matches rendered HTML with a regexp breaks:
              parse it with Nokogiri.
            MD
          end
        end

        def slots
          DocsUI::Section("Slots") do
            md <<~MD
              A component with parts declares each one. A variant, compound or `on` value
              can then be a Hash keyed by slot (`root` is the component itself):

              ```ruby
              class Picker < DaisyUI::Dropdown
                variants do
                  slot :trigger
                  slot :menu, "mt-2"
                  variant :reach, wide: { root: "picker-wide", menu: "w-96" }
                  state :open, "[.dropdown[open]>&]"
                  on :open, class: { menu: "shadow-lg" }
                end

                def trigger(*mods, **options, &) = render DaisyUI::Button.new(*mods, **slot_options(:trigger, options), &)
                def list(*mods, **options, &) = render DaisyUI::Menu.new(*mods, class: slot_classes(:menu, options), **options, &)
              end
              ```

              `slot_classes(:menu, options)` returns the slot's classes: those of every
              selected member, compound and `on` rule for it, then `options.delete(:class)`,
              merged. `slot_options(:trigger, options)` returns `options` with that `class:`.
            MD
          end
        end

        def introspection
          DocsUI::Section("Introspection") do
            md <<~MD
              `Widget.variants.schema` is plain, frozen data for a docs page, a component
              gallery or a design-tool parity check. Every component has one, a
              `register_modifiers` one included (variants and flags, the rest empty):

              ```ruby
              Widget.variants.schema
              # { base: "btn font-medium",
              #   variants: { style: [...], size: [:sm, :md, ...], ... },
              #   flags: [:active, :disabled, :wide, :block],
              #   defaults: { size: :md },
              #   compounds: [{ match: { style: :outline, color: nil }, class: "[--btn-bg:...]", set: {} }],
              #   on: [{ states: [:hover], match: { style: [:ghost, :link] }, class: "[--btn-bg:transparent]" }],
              #   states: { hover: "hover" },
              #   slots: { root: "btn font-medium" } }
              ```

              The bundled MCP server returns the same schema from `get_component`, and
              `variants_guide` returns a short version of this page, so an agent sees a
              component's groups and states before it writes one.
            MD
            DocsUI::Callout(:note, title: "State classes need Tailwind sources") do
              plain "An on rule writes classes that appear nowhere literally, so Tailwind never "
              plain "compiles them on its own. See Tailwind sources for your components."
            end
          end
        end
      end
    end
  end
end
