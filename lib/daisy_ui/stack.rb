# frozen_string_literal: true

module DaisyUI
  # @component html class="stack"
  class Stack < Base
    self.component_class = :stack

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      placement: {
        # "sm:stack-top"
        # "@sm:stack-top"
        # "md:stack-top"
        # "@md:stack-top"
        # "lg:stack-top"
        # "@lg:stack-top"
        top: "stack-top",
        # "sm:stack-bottom"
        # "@sm:stack-bottom"
        # "md:stack-bottom"
        # "@md:stack-bottom"
        # "lg:stack-bottom"
        # "@lg:stack-bottom"
        bottom: "stack-bottom",
        # "sm:stack-start"
        # "@sm:stack-start"
        # "md:stack-start"
        # "@md:stack-start"
        # "lg:stack-start"
        # "@lg:stack-start"
        start: "stack-start",
        # "sm:stack-end"
        # "@sm:stack-end"
        # "md:stack-end"
        # "@md:stack-end"
        # "lg:stack-end"
        # "@lg:stack-end"
        end: "stack-end"
      }
    )
  end
end
