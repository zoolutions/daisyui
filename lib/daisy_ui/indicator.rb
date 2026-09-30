# frozen_string_literal: true

module DaisyUI
  # @component html class="indicator"
  class Indicator < Base
    self.component_class = :indicator

    def view_template
      public_send(as, class: classes, **attributes) do
        yield self if block_given?
      end
    end

    def item(*item_modifiers, **options, &)
      item_classes = build_item_classes(item_modifiers, options)
      span(class: item_classes, **options, &)
    end

    private

    def build_item_classes(item_modifiers, options)
      # Start with base class
      base = apply_prefix("indicator-item")
      # Add modifier classes from position modifiers
      mod_classes = item_modifiers.filter_map { |m| apply_prefix(modifier_map[m]) }
      # Add custom class if provided
      custom = options.delete(:class)
      merge_classes(base, *mod_classes, custom)
    end

    register_modifiers(
      horizontal: {
        # "sm:indicator-start"
        # "@sm:indicator-start"
        # "md:indicator-start"
        # "@md:indicator-start"
        # "lg:indicator-start"
        # "@lg:indicator-start"
        start: "indicator-start",
        # "sm:indicator-center"
        # "@sm:indicator-center"
        # "md:indicator-center"
        # "@md:indicator-center"
        # "lg:indicator-center"
        # "@lg:indicator-center"
        center: "indicator-center",
        # "sm:indicator-end"
        # "@sm:indicator-end"
        # "md:indicator-end"
        # "@md:indicator-end"
        # "lg:indicator-end"
        # "@lg:indicator-end"
        end: "indicator-end"
      },
      vertical: {
        # "sm:indicator-top"
        # "@sm:indicator-top"
        # "md:indicator-top"
        # "@md:indicator-top"
        # "lg:indicator-top"
        # "@lg:indicator-top"
        top: "indicator-top",
        # "sm:indicator-middle"
        # "@sm:indicator-middle"
        # "md:indicator-middle"
        # "@md:indicator-middle"
        # "lg:indicator-middle"
        # "@lg:indicator-middle"
        middle: "indicator-middle",
        # "sm:indicator-bottom"
        # "@sm:indicator-bottom"
        # "md:indicator-bottom"
        # "@md:indicator-bottom"
        # "lg:indicator-bottom"
        # "@lg:indicator-bottom"
        bottom: "indicator-bottom"
      }
    )
  end
end
