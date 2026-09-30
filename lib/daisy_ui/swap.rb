# frozen_string_literal: true

module DaisyUI
  # @component html class="swap"
  class Swap < Base
    self.component_class = :swap

    def initialize(*, as: :label, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def on(**options, &)
      div(class: component_classes("swap-on", options:), **options, &)
    end

    def off(**options, &)
      div(class: component_classes("swap-off", options:), **options, &)
    end

    def indeterminate(**options, &)
      div(class: component_classes("swap-indeterminate", options:), **options, &)
    end

    register_modifiers(
      # "sm:swap-active"
      # "@sm:swap-active"
      # "md:swap-active"
      # "@md:swap-active"
      # "lg:swap-active"
      # "@lg:swap-active"
      active: "swap-active",
      animation: {
        # "sm:swap-rotate"
        # "@sm:swap-rotate"
        # "md:swap-rotate"
        # "@md:swap-rotate"
        # "lg:swap-rotate"
        # "@lg:swap-rotate"
        rotate: "swap-rotate",
        # "sm:swap-flip"
        # "@sm:swap-flip"
        # "md:swap-flip"
        # "@md:swap-flip"
        # "lg:swap-flip"
        # "@lg:swap-flip"
        flip: "swap-flip"
      }
    )
  end
end
