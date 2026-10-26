# frozen_string_literal: true

module Views
  module Docs
    module Pages
      # `daisyui-tailwind --app`: Tailwind sources for components an app declares.
      class AppTailwindSources < DocsUI::Page
        title "Tailwind sources for your components"
        eyebrow "Guide"

        def lead
          "Classes a variants block renders appear nowhere literally in your source. " \
            "Generate them, commit the file and let a spec say when it is stale."
        end

        def content
          why
          generate
          keep_fresh
        end

        private

        def why
          DocsUI::Section("Why") do
            md <<~MD
              Tailwind v4 compiles only classes it finds written out. An
              `on %i[hover open], class: "bg-base-200"` rule renders `hover:bg-base-200`
              and `[.dropdown[open]>&]:bg-base-200` at runtime, and neither string is in your
              source, so no CSS exists for them. Hand Tailwind your own components'
              classes the way you hand it the gem's (see Installation, "Tailwind sources").
            MD
          end
        end

        def generate
          DocsUI::Section("Generate and import") do
            md <<~MD
              With Rails, a rake task eager-loads the app and writes the file:

              ```sh
              bin/rails "daisyui:tailwind[app/assets/stylesheets/generated/daisyui_app.css]"
              ```

              Without Rails, load your components and walk them:

              ```sh
              bundle exec daisyui-tailwind --app --require ./config/components.rb -o app/assets/stylesheets/generated/daisyui_app.css
              ```

              It walks every `DaisyUI::Base` subclass defined outside the gem and writes one
              `@source inline(...)` per component, sorted by name: its component class,
              modifiers, `base`, compound and slot classes, and each `on` class once per state.

              ```css
              /* Widget */
              @source inline("btn btn-ghost btn-sm font-medium hover:[--btn-bg:transparent] ...");
              ```

              Import it from the Tailwind entry, after the gem's own file:

              ```css
              @import "./generated/daisyui.css";      /* the gem's components you use */
              @import "./generated/daisyui_app.css";  /* your own: variants, compounds, states, slots */
              ```

              `--responsive`, `--prefix` and `--format json` work as for the gem's sources.
              From Ruby: `DaisyUI::Tailwind.sources(app: true)`, or `app: [Widget, Picker]`
              for some.
            MD
          end
        end

        def keep_fresh
          DocsUI::Section("Commit it and fail on stale") do
            md <<~MD
              The header carries no version and nothing depends on the machine, so the file
              changes only when a declaration does. Commit it, and add a spec:

              ```ruby
              # spec/daisyui_tailwind_spec.rb
              it "has fresh Tailwind sources" do
                expect(DaisyUI::Tailwind.stale?("app/assets/stylesheets/generated/daisyui_app.css")).to be(false)
              end
              ```

              `stale?` eager-loads a Rails app before it compares, so the CSS build never boots
              the app: it only imports the file. When the spec fails, run the rake task again
              and commit the result.
            MD
            DocsUI::Callout(:tip, title: "Keep it out of stylelint") do
              plain "The file is generated and long. Add it to ignoreFiles in your stylelint "
              plain "config, for example app/assets/stylesheets/generated/**, so lint:css "
              plain "neither reformats nor fails on it."
            end
          end
        end
      end
    end
  end
end
