# frozen_string_literal: true

module DaisyUI
  class Alert < Base
    self.component_class = :alert

    def view_template(&)
      public_send(as, role: :alert, class: classes, **attributes, &)
    end

    register_modifiers(
      style: {
        # "sm:alert-outline"
        # "@sm:alert-outline"
        # "md:alert-outline"
        # "@md:alert-outline"
        # "lg:alert-outline"
        # "@lg:alert-outline"
        outline: "alert-outline",
        # "sm:alert-dash"
        # "@sm:alert-dash"
        # "md:alert-dash"
        # "@md:alert-dash"
        # "lg:alert-dash"
        # "@lg:alert-dash"
        dash: "alert-dash",
        # "sm:alert-soft"
        # "@sm:alert-soft"
        # "md:alert-soft"
        # "@md:alert-soft"
        # "lg:alert-soft"
        # "@lg:alert-soft"
        soft: "alert-soft"
      },
      direction: {
        # "sm:alert-vertical"
        # "@sm:alert-vertical"
        # "md:alert-vertical"
        # "@md:alert-vertical"
        # "lg:alert-vertical"
        # "@lg:alert-vertical"
        vertical: "alert-vertical",
        # "sm:alert-horizontal"
        # "@sm:alert-horizontal"
        # "md:alert-horizontal"
        # "@md:alert-horizontal"
        # "lg:alert-horizontal"
        # "@lg:alert-horizontal"
        horizontal: "alert-horizontal"
      },
      color: {
        # "sm:alert-info"
        # "@sm:alert-info"
        # "md:alert-info"
        # "@md:alert-info"
        # "lg:alert-info"
        # "@lg:alert-info"
        info: "alert-info",
        # "sm:alert-success"
        # "@sm:alert-success"
        # "md:alert-success"
        # "@md:alert-success"
        # "lg:alert-success"
        # "@lg:alert-success"
        success: "alert-success",
        # "sm:alert-warning"
        # "@sm:alert-warning"
        # "md:alert-warning"
        # "@md:alert-warning"
        # "lg:alert-warning"
        # "@lg:alert-warning"
        warning: "alert-warning",
        # "sm:alert-error"
        # "@sm:alert-error"
        # "md:alert-error"
        # "@md:alert-error"
        # "lg:alert-error"
        # "@lg:alert-error"
        error: "alert-error",
        # "sm:alert-neutral"
        # "@sm:alert-neutral"
        # "md:alert-neutral"
        # "@md:alert-neutral"
        # "lg:alert-neutral"
        # "@lg:alert-neutral"
        neutral: "alert-neutral",
        # "sm:alert-primary"
        # "@sm:alert-primary"
        # "md:alert-primary"
        # "@md:alert-primary"
        # "lg:alert-primary"
        # "@lg:alert-primary"
        primary: "alert-primary",
        # "sm:alert-secondary"
        # "@sm:alert-secondary"
        # "md:alert-secondary"
        # "@md:alert-secondary"
        # "lg:alert-secondary"
        # "@lg:alert-secondary"
        secondary: "alert-secondary",
        # "sm:alert-accent"
        # "@sm:alert-accent"
        # "md:alert-accent"
        # "@md:alert-accent"
        # "lg:alert-accent"
        # "@lg:alert-accent"
        accent: "alert-accent"
      }
    )
  end
end
