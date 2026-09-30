# frozen_string_literal: true

module DaisyUI
  class Megamenu < Base
    self.component_class = :megamenu

    def initialize(*, as: :div, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def active_indicator(**options, &)
      span(class: component_classes("megamenu-active", options:), **options, &)
    end

    register_modifiers(
      width: {
        # "sm:megamenu-wide"
        # "@sm:megamenu-wide"
        # "md:megamenu-wide"
        # "@md:megamenu-wide"
        # "lg:megamenu-wide"
        # "@lg:megamenu-wide"
        wide: "megamenu-wide",
        # "sm:megamenu-full"
        # "@sm:megamenu-full"
        # "md:megamenu-full"
        # "@md:megamenu-full"
        # "lg:megamenu-full"
        # "@lg:megamenu-full"
        full: "megamenu-full"
      },
      # "sm:megamenu-vertical"
      # "@sm:megamenu-vertical"
      # "md:megamenu-vertical"
      # "@md:megamenu-vertical"
      # "lg:megamenu-vertical"
      # "@lg:megamenu-vertical"
      vertical: "megamenu-vertical",
      size: {
        # "sm:megamenu-xs"
        # "@sm:megamenu-xs"
        # "md:megamenu-xs"
        # "@md:megamenu-xs"
        # "lg:megamenu-xs"
        # "@lg:megamenu-xs"
        xs: "megamenu-xs",
        # "sm:megamenu-sm"
        # "@sm:megamenu-sm"
        # "md:megamenu-sm"
        # "@md:megamenu-sm"
        # "lg:megamenu-sm"
        # "@lg:megamenu-sm"
        sm: "megamenu-sm",
        # "sm:megamenu-md"
        # "@sm:megamenu-md"
        # "md:megamenu-md"
        # "@md:megamenu-md"
        # "lg:megamenu-md"
        # "@lg:megamenu-md"
        md: "megamenu-md",
        # "sm:megamenu-lg"
        # "@sm:megamenu-lg"
        # "md:megamenu-lg"
        # "@md:megamenu-lg"
        # "lg:megamenu-lg"
        # "@lg:megamenu-lg"
        lg: "megamenu-lg",
        # "sm:megamenu-xl"
        # "@sm:megamenu-xl"
        # "md:megamenu-xl"
        # "@md:megamenu-xl"
        # "lg:megamenu-xl"
        # "@lg:megamenu-xl"
        xl: "megamenu-xl"
      }
    )
  end
end
