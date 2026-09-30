# frozen_string_literal: true

module DaisyUI
  # @component html class="status"
  class Status < Base
    self.component_class = :status

    def initialize(*, as: :span, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      size: {
        # "sm:status-xs"
        # "@sm:status-xs"
        # "md:status-xs"
        # "@md:status-xs"
        # "lg:status-xs"
        # "@lg:status-xs"
        xs: "status-xs",
        # "sm:status-sm"
        # "@sm:status-sm"
        # "md:status-sm"
        # "@md:status-sm"
        # "lg:status-sm"
        # "@lg:status-sm"
        sm: "status-sm",
        # "sm:status-md"
        # "@sm:status-md"
        # "md:status-md"
        # "@md:status-md"
        # "lg:status-md"
        # "@lg:status-md"
        md: "status-md",
        # "sm:status-lg"
        # "@sm:status-lg"
        # "md:status-lg"
        # "@md:status-lg"
        # "lg:status-lg"
        # "@lg:status-lg"
        lg: "status-lg",
        # "sm:status-xl"
        # "@sm:status-xl"
        # "md:status-xl"
        # "@md:status-xl"
        # "lg:status-xl"
        # "@lg:status-xl"
        xl: "status-xl"
      },
      color: {
        # "sm:status-neutral"
        # "@sm:status-neutral"
        # "md:status-neutral"
        # "@md:status-neutral"
        # "lg:status-neutral"
        # "@lg:status-neutral"
        neutral: "status-neutral",
        # "sm:status-primary"
        # "@sm:status-primary"
        # "md:status-primary"
        # "@md:status-primary"
        # "lg:status-primary"
        # "@lg:status-primary"
        primary: "status-primary",
        # "sm:status-secondary"
        # "@sm:status-secondary"
        # "md:status-secondary"
        # "@md:status-secondary"
        # "lg:status-secondary"
        # "@lg:status-secondary"
        secondary: "status-secondary",
        # "sm:status-accent"
        # "@sm:status-accent"
        # "md:status-accent"
        # "@md:status-accent"
        # "lg:status-accent"
        # "@lg:status-accent"
        accent: "status-accent",
        # "sm:status-info"
        # "@sm:status-info"
        # "md:status-info"
        # "@md:status-info"
        # "lg:status-info"
        # "@lg:status-info"
        info: "status-info",
        # "sm:status-success"
        # "@sm:status-success"
        # "md:status-success"
        # "@md:status-success"
        # "lg:status-success"
        # "@lg:status-success"
        success: "status-success",
        # "sm:status-warning"
        # "@sm:status-warning"
        # "md:status-warning"
        # "@md:status-warning"
        # "lg:status-warning"
        # "@lg:status-warning"
        warning: "status-warning",
        # "sm:status-error"
        # "@sm:status-error"
        # "md:status-error"
        # "@md:status-error"
        # "lg:status-error"
        # "@lg:status-error"
        error: "status-error"
      }
    )
  end
end
