# frozen_string_literal: true

module DaisyUI
  class McpServer
    # The text of the `variants_guide` tool: the `variants` DSL on one page, with
    # the three ways it surprises. Keep it in step with the README's "Variants,
    # states and slots" and the docs site page.
    module VariantsGuide
      TEXT = <<~MARKDOWN
        # Variants, states and slots

        A component that owns its design declares it in a `variants` block on a
        `DaisyUI::Base` subclass. `get_component` shows the result as a schema.

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
        ```

        ## Which declaration

        | Need | Use |
        |---|---|
        | Alternatives, only one applies (sizes, colors) | `variant :group, member: "classes"` |
        | An on/off modifier | `flag :name, "classes"`; `flag :name` alone has no class and exists to be matched |
        | Classes every instance gets | `base "classes"` (appended to the inherited base) |
        | A member when the caller names none of the group | `default :group, :member` |
        | Classes when modifiers hold together or one is absent | `compound(**match, class:, set: {})` |
        | The same classes under a browser state | `state :name, "<tailwind variant>"` once, then `on(states, **match, class:)` |
        | A part of the component (trigger, menu) | `slot :name, "classes"`, then `slot_classes(name, options)` / `slot_options(name, options)` in the part's method |

        ## Match values (`compound`, `on`)

        | Value | Holds when |
        |---|---|
        | `:member` | that member is selected: given, defaulted or set by an earlier compound |
        | `[:a, :b]` | any of them is; a `nil` in the list means "or none": `shape: [nil, :row]` |
        | `nil` / `false` | no member of the group is |
        | `true` | any member of the group is: `color: true` |
        | `true` / `false` | for a flag: on / off |

        `set: { group: :member }` on a compound selects a member for the caller's empty
        groups; later compounds see it. `class` and `set` are reserved: no group is called that.
        A `class:` or a modifier value can be a Hash keyed by slot (`root` is the component).

        ## Render order

        component class, `base`, the caller's modifiers, defaulted and set members,
        compounds, `on` rules, `responsive:`, then the caller's `class:`. ClassMerge
        resolves conflicts, the last one wins.

        ## Pitfalls

        1. A `default` renders after the caller's modifiers. A default member's class
           beats a caller modifier that sets the same property (a default size's
           `--fontsize` beats an `:inline` modifier's). Put a value both can set in
           `base`, not in a default.
        2. A compound or `on` rule also renders after the caller's modifiers, so it
           can override a modifier's arbitrary property. Leave the conflicting member
           out of the match (`layout: [nil, :inline, :row]`).
        3. `on` writes `"<state>:<class>"`: the state prefix is outermost. A rule that
           needs a child selector first (`[&_li]:hover:bg-...`) cannot be an `on :hover`
           rule; keep it literal in `base`.

        Also: do not name a group after an inherited one with a different meaning
        (`Button` already has `shape`); a state selector with a child combinator puts `>`
        in the class attribute, so parse rendered HTML with Nokogiri, not a regexp.

        ## Tailwind sources

        Tailwind v4 compiles only classes written out literally, and an `on` class is
        written nowhere. Generate sources for your own components, commit the file,
        import it from the Tailwind entry and fail a spec when it is stale:

        ```sh
        bin/rails "daisyui:tailwind[app/assets/stylesheets/generated/daisyui_app.css]"
        bundle exec daisyui-tailwind --app --require ./config/components.rb -o app/assets/stylesheets/generated/daisyui_app.css
        ```

        ```ruby
        expect(DaisyUI::Tailwind.stale?("app/assets/stylesheets/generated/daisyui_app.css")).to be(false)
        ```

        ## Introspection

        `Widget.variants.schema` returns `base`, `variants`, `flags`, `defaults`,
        `compounds`, `on`, `states` and `slots` as frozen data.
      MARKDOWN
    end
  end
end
