# frozen_string_literal: true

module DaisyUI
  class Link < Base
    self.component_class = :link

    def view_template(&)
      a(class: classes, **attributes, &)
    end

    register_modifiers(
      # "sm:link-hover"
      # "@sm:link-hover"
      # "md:link-hover"
      # "@md:link-hover"
      # "lg:link-hover"
      # "@lg:link-hover"
      hover: "link-hover",
      color: {
        # "sm:link-neutral"
        # "@sm:link-neutral"
        # "md:link-neutral"
        # "@md:link-neutral"
        # "lg:link-neutral"
        # "@lg:link-neutral"
        neutral: "link-neutral",
        # "sm:link-primary"
        # "@sm:link-primary"
        # "md:link-primary"
        # "@md:link-primary"
        # "lg:link-primary"
        # "@lg:link-primary"
        primary: "link-primary",
        # "sm:link-secondary"
        # "@sm:link-secondary"
        # "md:link-secondary"
        # "@md:link-secondary"
        # "lg:link-secondary"
        # "@lg:link-secondary"
        secondary: "link-secondary",
        # "sm:link-accent"
        # "@sm:link-accent"
        # "md:link-accent"
        # "@md:link-accent"
        # "lg:link-accent"
        # "@lg:link-accent"
        accent: "link-accent",
        # "sm:link-info"
        # "@sm:link-info"
        # "md:link-info"
        # "@md:link-info"
        # "lg:link-info"
        # "@lg:link-info"
        info: "link-info",
        # "sm:link-success"
        # "@sm:link-success"
        # "md:link-success"
        # "@md:link-success"
        # "lg:link-success"
        # "@lg:link-success"
        success: "link-success",
        # "sm:link-warning"
        # "@sm:link-warning"
        # "md:link-warning"
        # "@md:link-warning"
        # "lg:link-warning"
        # "@lg:link-warning"
        warning: "link-warning",
        # "sm:link-error"
        # "@sm:link-error"
        # "md:link-error"
        # "@md:link-error"
        # "lg:link-error"
        # "@lg:link-error"
        error: "link-error"
      }
    ).freeze
  end
end
