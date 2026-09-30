# frozen_string_literal: true

module DaisyUI
  class Card < Base
    self.component_class = :card

    def initialize(*, as: :section, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def body(**options, &)
      div(class: component_classes("card-body", options:), **options, &)
    end

    def title(**options, &)
      header(class: component_classes("card-title", options:), **options, &)
    end

    def actions(**options, &)
      footer(class: component_classes("card-actions", options:), **options, &)
    end

    register_modifiers(
      # "sm:image-full"
      # "@sm:image-full"
      # "md:image-full"
      # "@md:image-full"
      # "lg:image-full"
      # "@lg:image-full"
      image_full: "image-full",
      style: {
        # "sm:card-border"
        # "@sm:card-border"
        # "md:card-border"
        # "@md:card-border"
        # "lg:card-border"
        # "@lg:card-border"
        border: "card-border",
        # "sm:card-border" "@sm:card-border"
        # "md:card-border" "@md:card-border"
        # "lg:card-border" "@lg:card-border"
        bordered: "card-border",
        # "sm:card-dash"
        # "@sm:card-dash"
        # "md:card-dash"
        # "@md:card-dash"
        # "lg:card-dash"
        # "@lg:card-dash"
        dash: "card-dash"
      },
      # "sm:card-side"
      # "@sm:card-side"
      # "md:card-side"
      # "@md:card-side"
      # "lg:card-side"
      # "@lg:card-side"
      side: "card-side",
      size: {
        # "sm:card-xs"
        # "@sm:card-xs"
        # "md:card-xs"
        # "@md:card-xs"
        # "lg:card-xs"
        # "@lg:card-xs"
        xs: "card-xs",
        # "sm:card-sm"
        # "@sm:card-sm"
        # "md:card-sm"
        # "@md:card-sm"
        # "lg:card-sm"
        # "@lg:card-sm"
        sm: "card-sm",
        # "sm:card-md"
        # "@sm:card-md"
        # "md:card-md"
        # "@md:card-md"
        # "lg:card-md"
        # "@lg:card-md"
        md: "card-md",
        # "sm:card-lg"
        # "@sm:card-lg"
        # "md:card-lg"
        # "@md:card-lg"
        # "lg:card-lg"
        # "@lg:card-lg"
        lg: "card-lg",
        # "sm:card-xl"
        # "@sm:card-xl"
        # "md:card-xl"
        # "@md:card-xl"
        # "lg:card-xl"
        # "@lg:card-xl"
        xl: "card-xl"
      },
      **COLOR_MODIFIERS
    )
  end
end
