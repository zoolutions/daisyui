# frozen_string_literal: true

module DaisyUI
  # @component html class="dock"
  class Dock < Base
    self.component_class = :dock

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def label(**options, &)
      span(class: component_classes("dock-label", options:), **options, &)
    end

    register_modifiers(
      # "sm:dock-active"
      # "@sm:dock-active"
      # "md:dock-active"
      # "@md:dock-active"
      # "lg:dock-active"
      # "@lg:dock-active"
      active: "dock-active",
      size: {
        # "sm:dock-xs"
        # "@sm:dock-xs"
        # "md:dock-xs"
        # "@md:dock-xs"
        # "lg:dock-xs"
        # "@lg:dock-xs"
        xs: "dock-xs",
        # "sm:dock-sm"
        # "@sm:dock-sm"
        # "md:dock-sm"
        # "@md:dock-sm"
        # "lg:dock-sm"
        # "@lg:dock-sm"
        sm: "dock-sm",
        # "sm:dock-md"
        # "@sm:dock-md"
        # "md:dock-md"
        # "@md:dock-md"
        # "lg:dock-md"
        # "@lg:dock-md"
        md: "dock-md",
        # "sm:dock-lg"
        # "@sm:dock-lg"
        # "md:dock-lg"
        # "@md:dock-lg"
        # "lg:dock-lg"
        # "@lg:dock-lg"
        lg: "dock-lg",
        # "sm:dock-xl"
        # "@sm:dock-xl"
        # "md:dock-xl"
        # "@md:dock-xl"
        # "lg:dock-xl"
        # "@lg:dock-xl"
        xl: "dock-xl"
      }
    )
  end
end
