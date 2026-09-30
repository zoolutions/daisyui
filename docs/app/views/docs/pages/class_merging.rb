# frozen_string_literal: true

module Views
  module Docs
    module Pages
      # How components resolve conflicting classes, and how to teach the merger
      # about an app's own utilities.
      class ClassMerging < DocsUI::Page
        title "Class merging"
        eyebrow "Guide"

        EXAMPLES = [
          "btn btn-sm btn-lg",
          "badge badge-primary badge-error",
          "btn btn-outline btn-soft",
          "dropdown dropdown-top dropdown-end",
          "sm:btn-lg btn-sm",
          "btn-wide btn-lg",
          "px-4 py-3 px-2",
          "bg-base-100 bg-base-200",
          "text-base-content/80 text-error",
          "table hidden",
        ].freeze

        def lead
          "Components merge their classes so the last conflicting class wins — " \
            "for Tailwind utilities and daisyUI modifiers alike."
        end

        def content
          overriding_defaults
          how_conflicts_resolve
          custom_utilities
          opting_out
        end

        private

        def overriding_defaults
          DocsUI::Section("Overriding defaults") do
            DocsUI::Prose() do
              p do
                plain "A class passed through "
                code { "class:" }
                plain " replaces a modifier of the same kind instead of sitting next to it:"
              end
            end
            DocsUI::Code(<<~RUBY, lexer: :ruby)
              Button(:sm, class: "btn-lg")          # => class="btn btn-lg"
              Badge(:primary, class: "badge-error") # => class="badge badge-error"
              Card(class: "p-2 p-4")                # => class="card p-4"
            RUBY
          end
        end

        def how_conflicts_resolve
          DocsUI::Section("How conflicts resolve") do
            DocsUI::Prose() do
              p do
                plain "Tailwind utilities follow tailwind-merge's rules. daisyUI modifiers "
                plain "conflict when they share a component and a family: color, size, "
                plain "style, direction, placement (top/middle/bottom/left/right) or "
                plain "alignment (start/center/end). Variants such as "
                code { "sm:" }
                plain " or "
                code { "hover:" }
                plain " are separate slots. These results are computed live:"
              end
            end
            DocsUI::Table(%w[Input Merged],
                          EXAMPLES.map { |input| [[:code, input], [:code, DaisyUI::ClassMerge.merge(input)]] })
            DocsUI::Callout(:note, title: "Base classes are never dropped") do
              plain "Component classes such as table and collapse keep their place even "
              plain "though Tailwind has utilities with the same name."
            end
          end
        end

        def custom_utilities
          DocsUI::Section("Custom utilities") do
            DocsUI::Prose() do
              p do
                plain "Register custom utilities so the merger knows what they are. "
                plain "Unregistered, "
                code { "text-display" }
                plain " reads as a color and would be dropped by a later "
                code { "text-error" }
                plain ". Custom colors need no registration."
              end
            end
            DocsUI::Code(<<~RUBY, lexer: :ruby, filename: "config/initializers/daisy_ui.rb")
              DaisyUI.configure do |config|
                # text-display and text-hero are font sizes, like text-lg
                config.class_merge.utility("text-display", "text-hero", like: "text-lg")

                # Extend a Tailwind theme scale: p-gutter, m-gutter, gap-gutter, ...
                config.class_merge.theme(spacing: %w[gutter])

                # Raw tailwind_merge groups for anything else
                config.class_merge.class_groups("surface" => %w[surface-flat surface-raised])
                config.class_merge.conflicts("surface" => ["shadow"])
              end
            RUBY
            DocsUI::Prose() do
              p do
                plain "Use "
                code { "DaisyUI::ClassMerge.merge(*parts)" }
                plain " directly in your own components; it accepts strings, arrays, nil and false. "
                plain "Components subclassing DaisyUI::Base get daisyUI families for their own modifiers."
              end
            end
          end
        end

        def opting_out
          DocsUI::Section("Opting out") do
            DocsUI::Code(<<~RUBY, lexer: :ruby)
              DaisyUI.configure { |config| config.class_merge.enabled = false }
            RUBY
            DocsUI::Callout(:tip, title: "Plain join") do
              plain "With merging disabled, components join their classes as given, "
              plain "exactly like 1.x."
            end
          end
        end
      end
    end
  end
end
