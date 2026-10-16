# frozen_string_literal: true

module Views
  module Docs
    module Pages
      # Template guide page. Each private method renders one Section interleaving
      # Code + Prose + Callout — copy this shape to author the rest of the docs.
      class Installation < DocsUI::Page
        title "Installation"
        eyebrow "Guide"

        def lead
          "Add the gem, then render daisyUI components as plain Ruby with Phlex."
        end

        def content
          add_the_gem
          render_a_component
          tailwind_setup
        end

        private

        def add_the_gem
          DocsUI::Section("Add the gem") do
            DocsUI::Prose() do
              p do
                plain "Add "
                code { "daisyui" }
                plain " to your Gemfile and install:"
              end
            end
            DocsUI::Code(<<~RUBY, lexer: :ruby, filename: "Gemfile")
              gem "daisyui"
            RUBY
            DocsUI::Code("bundle install", lexer: :shell)
          end
        end

        def render_a_component
          DocsUI::Section("Render a component") do
            DocsUI::Prose() do
              p do
                plain "Components are Phlex classes under the "
                code { "DaisyUI" }
                plain " namespace. Include the module to use the short-form kit "
                plain "syntax, then call a component like a method:"
              end
            end
            DocsUI::Code(<<~RUBY, lexer: :ruby, filename: "app/views/home_view.rb")
              class HomeView < Phlex::HTML
                include DaisyUI

                def view_template
                  Button(:primary) { "Click me" }
                end
              end
            RUBY
            DocsUI::Callout(:tip, title: "Modifiers are symbols") do
              plain "Pass daisyUI modifiers as leading symbols — "
              plain "Button(:primary, :lg) renders btn btn-primary btn-lg."
            end
          end
        end

        def tailwind_setup
          DocsUI::Section("Tailwind & daisyUI CSS") do
            DocsUI::Prose() do
              p do
                plain "The gem renders the class names; Tailwind + the daisyUI "
                plain "plugin produce the CSS. Generate Tailwind sources for just "
                plain "the components your app uses, then import them from your "
                plain "Tailwind entry:"
              end
            end
            DocsUI::Code(<<~SHELL, lexer: :shell)
              bundle exec daisyui-tailwind app -o app/assets/stylesheets/generated/daisyui.css
            SHELL
            DocsUI::Code(<<~CSS, lexer: :plaintext, filename: "application.tailwind.css")
              @import "tailwindcss";

              @plugin "daisyui" {
                themes: all;
              }

              /* Your own classes, as before. */
              @source "../../views";

              /* One @source inline(...) per DaisyUI component the app uses. */
              @import "./generated/daisyui.css";
            CSS
            tailwind_sources_details
          end
        end

        def tailwind_sources_details
          DocsUI::Prose() do
            p do
              plain "daisyui-tailwind finds the components your Ruby and "
              plain "templates reference (a kit call like "
              code { "Button(:primary)" }
              plain " or "
              code { "Badge :primary do" }
              plain ", "
              code { "Card.new" }
              plain ", "
              code { "DaisyUI::Navbar" }
              plain "), adds the components those render, and writes each "
              plain "one's classes. Run it before Tailwind in your CSS build: it "
              plain "rewrites the file only when it changes, and the file names "
              plain "no path, so it is the same on every machine. "
              code { "--format json" }
              plain " gives a Node build script the components, classes and "
              plain "files instead; "
              code { "DaisyUI::Tailwind.sources(scan: [\"app\"])" }
              plain " does the same from Ruby."
            end
          end
          DocsUI::Callout(:tip, title: "Smaller, and more complete") do
            plain "On an app using 33 of the 77 components, the CSS the gem's "
            plain "classes add went from 210 KB (scanning the whole gem) to "
            plain "126 KB. Tailwind v4 cannot see a Symbol component class "
            plain "(component_class = :navbar) or a Ruby comment, so a whole-gem "
            plain "scan misses .navbar, .card and the rules daisyUI nests under "
            plain "them; the generated sources carry them."
          end
          DocsUI::Callout(:note, title: "Scanning the whole gem still works") do
            plain "An @source pointing at the gem's lib/ (resolved at build time "
            plain "with bundle info daisyui --path) builds the same CSS as before."
          end
        end
      end
    end
  end
end
