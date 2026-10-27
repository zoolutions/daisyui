# frozen_string_literal: true

module Views
  module Components
    # One shared page for every component-reference entry. Renders each registered
    # example through the reactive ExampleViewer (Preview/Source toggle), with the
    # example's title as a section heading.
    class Show < Phlex::HTML
      include Phlex::Rails::Helpers::Routes

      def initialize(component:)
        @component = component
      end

      def view_template
        # on_page: true → the auto "On this page" TOC (config default placement)
        # over the component's example sections, same as the guide pages.
        DocsUI::Shell(title: @component.title, on_page: true) do
          nav(class: "mb-6") do
            a(href: root_path, class: "link link-hover text-sm opacity-70") { "← Home" }
          end

          header(class: "mb-8") do
            div(class: "mb-2 text-xs font-semibold uppercase tracking-wider text-primary") { @component.category }
            h1(class: "text-3xl font-bold") { @component.title }
          end

          @component.examples.each { |example_class| example_section(example_class) }
        end
      end

      private

      def example_section(example_class)
        section(class: "mb-10 scroll-mt-20", id: example_class.title.parameterize) do
          h2(class: "mb-3 text-lg font-semibold") { example_class.title }
          p(class: "mb-3 text-sm opacity-70") { example_class.description } if example_class.description
          render ExampleViewerComponent.new(example: example_class.name)
        end
      end
    end
  end
end
