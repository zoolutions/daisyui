# frozen_string_literal: true

module DaisyUI
  class Badge < Base
    self.component_class = :badge

    def initialize(*, as: :span, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      style: {
        # "sm:badge-outline"
        # "@sm:badge-outline"
        # "md:badge-outline"
        # "@md:badge-outline"
        # "lg:badge-outline"
        # "@lg:badge-outline"
        # "xl:badge-outline"
        # "@xl:badge-outline"
        outline: "badge-outline",
        # "sm:badge-dash"
        # "@sm:badge-dash"
        # "md:badge-dash"
        # "@md:badge-dash"
        # "lg:badge-dash"
        # "@lg:badge-dash"
        # "xl:badge-dash"
        # "@xl:badge-dash"
        dash: "badge-dash",
        # "sm:badge-soft"
        # "@sm:badge-soft"
        # "md:badge-soft"
        # "@md:badge-soft"
        # "lg:badge-soft"
        # "@lg:badge-soft"
        # "xl:badge-soft"
        # "@xl:badge-soft"
        soft: "badge-soft",
        # "sm:badge-ghost"
        # "@sm:badge-ghost"
        # "md:badge-ghost"
        # "@md:badge-ghost"
        # "lg:badge-ghost"
        # "@lg:badge-ghost"
        # "xl:badge-ghost"
        # "@xl:badge-ghost"
        ghost: "badge-ghost"
      },
      color: {
        # "sm:badge-neutral"
        # "@sm:badge-neutral"
        # "md:badge-neutral"
        # "@md:badge-neutral"
        # "lg:badge-neutral"
        # "@lg:badge-neutral"
        # "xl:badge-neutral"
        # "@xl:badge-neutral"
        neutral: "badge-neutral",
        # "sm:badge-primary"
        # "@sm:badge-primary"
        # "md:badge-primary"
        # "@md:badge-primary"
        # "lg:badge-primary"
        # "@lg:badge-primary"
        # "xl:badge-primary"
        # "@xl:badge-primary"
        primary: "badge-primary",
        # "sm:badge-secondary"
        # "@sm:badge-secondary"
        # "md:badge-secondary"
        # "@md:badge-secondary"
        # "lg:badge-secondary"
        # "@lg:badge-secondary"
        # "xl:badge-secondary"
        # "@xl:badge-secondary"
        secondary: "badge-secondary",
        # "sm:badge-accent"
        # "@sm:badge-accent"
        # "md:badge-accent"
        # "@md:badge-accent"
        # "lg:badge-accent"
        # "@lg:badge-accent"
        # "xl:badge-accent"
        # "@xl:badge-accent"
        accent: "badge-accent",
        # "sm:badge-info"
        # "@sm:badge-info"
        # "md:badge-info"
        # "@md:badge-info"
        # "lg:badge-info"
        # "@lg:badge-info"
        # "xl:badge-info"
        # "@xl:badge-info"
        info: "badge-info",
        # "sm:badge-success"
        # "@sm:badge-success"
        # "md:badge-success"
        # "@md:badge-success"
        # "lg:badge-success"
        # "@lg:badge-success"
        # "xl:badge-success"
        # "@xl:badge-success"
        success: "badge-success",
        # "sm:badge-warning"
        # "@sm:badge-warning"
        # "md:badge-warning"
        # "@md:badge-warning"
        # "lg:badge-warning"
        # "@lg:badge-warning"
        # "xl:badge-warning"
        # "@xl:badge-warning"
        warning: "badge-warning",
        # "sm:badge-error"
        # "@sm:badge-error"
        # "md:badge-error"
        # "@md:badge-error"
        # "lg:badge-error"
        # "@lg:badge-error"
        # "xl:badge-error"
        # "@xl:badge-error"
        error: "badge-error"
      },
      size: {
        # "sm:badge-xs"
        # "@sm:badge-xs"
        # "md:badge-xs"
        # "@md:badge-xs"
        # "lg:badge-xs"
        # "@lg:badge-xs"
        # "xl:badge-xs"
        # "@xl:badge-xs"
        xs: "badge-xs",
        # "sm:badge-sm"
        # "@sm:badge-sm"
        # "md:badge-sm"
        # "@md:badge-sm"
        # "lg:badge-sm"
        # "@lg:badge-sm"
        # "xl:badge-sm"
        # "@xl:badge-sm"
        sm: "badge-sm",
        # "sm:badge-md"
        # "@sm:badge-md"
        # "md:badge-md"
        # "@md:badge-md"
        # "lg:badge-md"
        # "@lg:badge-md"
        # "xl:badge-md"
        # "@xl:badge-md"
        md: "badge-md",
        # "sm:badge-lg"
        # "@sm:badge-lg"
        # "md:badge-lg"
        # "@md:badge-lg"
        # "lg:badge-lg"
        # "@lg:badge-lg"
        # "xl:badge-lg"
        # "@xl:badge-lg"
        lg: "badge-lg",
        # "sm:badge-xl"
        # "@sm:badge-xl"
        # "md:badge-xl"
        # "@md:badge-xl"
        # "lg:badge-xl"
        # "@lg:badge-xl"
        # "xl:badge-xl"
        # "@xl:badge-xl"
        xl: "badge-xl"
      }
    )
  end
end
