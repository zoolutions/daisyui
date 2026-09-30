# frozen_string_literal: true

module DaisyUI
  # @component html class="steps"
  class Steps < Base
    self.component_class = :steps

    def initialize(*, as: :ul, **)
      super
    end

    def view_template
      public_send(as, class: classes, **attributes) do
        yield self if block_given?
      end
    end

    def step(*step_modifiers, **options, &)
      step_classes = build_step_classes(step_modifiers, options)
      li(class: step_classes, **options, &)
    end

    def icon(**options, &)
      div(class: component_classes("step-icon", options:), **options, &)
    end

    private

    def build_step_classes(step_modifiers, options)
      base = apply_prefix("step")
      mod_classes = step_modifiers.filter_map { |m| apply_prefix(step_modifier_map[m]) }
      custom = options.delete(:class)
      merge_classes(base, *mod_classes, custom)
    end

    def step_modifier_map
      {
        primary: "step-primary",
        secondary: "step-secondary",
        accent: "step-accent",
        neutral: "step-neutral",
        info: "step-info",
        success: "step-success",
        warning: "step-warning",
        error: "step-error"
      }
    end

    register_modifiers(
      direction: {
        # "sm:steps-vertical"
        # "@sm:steps-vertical"
        # "md:steps-vertical"
        # "@md:steps-vertical"
        # "lg:steps-vertical"
        # "@lg:steps-vertical"
        vertical: "steps-vertical",
        # "sm:steps-horizontal"
        # "@sm:steps-horizontal"
        # "md:steps-horizontal"
        # "@md:steps-horizontal"
        # "lg:steps-horizontal"
        # "@lg:steps-horizontal"
        horizontal: "steps-horizontal"
      }
    )
  end
end
