# frozen_string_literal: true

module Views
  module Components
    # A faint checkerboard backdrop for the live preview, matching the daisyUI
    # docs preview surface. Shared by the reactive ExampleViewer.
    PREVIEW_STYLE = <<~CSS
      background-image: repeating-linear-gradient(
        45deg,
        var(--color-base-200) 0,
        var(--color-base-200) 13px,
        var(--color-base-100) 13px,
        var(--color-base-100) 14px
      );
    CSS

    # Base class for one component-reference example. A subclass renders a live
    # daisyUI component (via the gem) in #example; the reactive ExampleViewer
    # shows that live render in a Preview tab and the extracted #example source
    # in a Source tab, so the shown code and the running component never drift.
    #
    #   class Views::Components::Examples::Button::Colors < Views::Components::Example
    #     include DaisyUI
    #     title "Buttons with colors"
    #     def example
    #       Button(:primary) { "Primary" }
    #       Button(:secondary) { "Secondary" }
    #     end
    #   end
    class Example < Phlex::HTML
      # Example subclasses render docs-kit chrome (DocsUI::Icon) alongside daisyUI
      # components, so expose the DocsUI kit's short form here too.
      include DocsUI

      class << self
        # The heading shown above this example (e.g. "Buttons with colors").
        # Defaults to a humanized version of the class's last name segment.
        def title(value = nil)
          @title = value if value
          @title || name.to_s.demodulize.underscore.humanize
        end

        # Sort key for ordering examples on a component page (lower first).
        # Defaults to 100 so unordered examples fall after explicitly-ordered ones.
        def order(value = nil)
          @order = value if value
          @order || 100
        end

        # Optional one-paragraph note shown under the heading, for behaviour the
        # live preview cannot show (e.g. touch). Nil renders nothing.
        def description(value = nil)
          @description = value if value
          @description
        end
      end

      # Override with the live component render(s) to demonstrate.
      def example
        raise NotImplementedError, "#{self.class} must implement #example"
      end

      # The Ruby source of #example, extracted via method_source — the exact
      # lines a host app would write. Strips the `def example` / final `end`
      # wrapper and re-dedents to the least-indented body line.
      def example_source
        body = method(:example).source.lines[1..-2] || []
        dedent(body).join.strip
      end

      # Rendered live inside the Preview tab.
      def view_template
        example
      end

      private

      def dedent(lines)
        indents = lines.reject { |l| l.strip.empty? }
                       .map { |l| l[/\A */].length }
        margin = indents.min || 0
        lines.map { |l| l.strip.empty? ? l : l[margin..] }
      end
    end
  end
end
