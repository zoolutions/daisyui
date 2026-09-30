# frozen_string_literal: true

module DaisyUI
  # @component html class="kbd"
  class Kbd < Base
    self.component_class = :kbd

    def initialize(*, as: :kbd, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      size: {
        # "sm:kbd-xs"
        # "@sm:kbd-xs"
        # "md:kbd-xs"
        # "@md:kbd-xs"
        # "lg:kbd-xs"
        # "@lg:kbd-xs"
        xs: "kbd-xs",
        # "sm:kbd-sm"
        # "@sm:kbd-sm"
        # "md:kbd-sm"
        # "@md:kbd-sm"
        # "lg:kbd-sm"
        # "@lg:kbd-sm"
        sm: "kbd-sm",
        # "sm:kbd-md"
        # "@sm:kbd-md"
        # "md:kbd-md"
        # "@md:kbd-md"
        # "lg:kbd-md"
        # "@lg:kbd-md"
        md: "kbd-md",
        # "sm:kbd-lg"
        # "@sm:kbd-lg"
        # "md:kbd-lg"
        # "@md:kbd-lg"
        # "lg:kbd-lg"
        # "@lg:kbd-lg"
        lg: "kbd-lg",
        # "sm:kbd-xl"
        # "@sm:kbd-xl"
        # "md:kbd-xl"
        # "@md:kbd-xl"
        # "lg:kbd-xl"
        # "@lg:kbd-xl"
        xl: "kbd-xl"
      }
    )
  end
end
