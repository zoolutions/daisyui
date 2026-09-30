# frozen_string_literal: true

module DaisyUI
  # @component html class="toast"
  class Toast < Base
    self.component_class = :toast

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    register_modifiers(
      horizontal: {
        # "sm:toast-start"
        # "@sm:toast-start"
        # "md:toast-start"
        # "@md:toast-start"
        # "lg:toast-start"
        # "@lg:toast-start"
        start: "toast-start",
        # "sm:toast-center"
        # "@sm:toast-center"
        # "md:toast-center"
        # "@md:toast-center"
        # "lg:toast-center"
        # "@lg:toast-center"
        center: "toast-center",
        # "sm:toast-end"
        # "@sm:toast-end"
        # "md:toast-end"
        # "@md:toast-end"
        # "lg:toast-end"
        # "@lg:toast-end"
        end: "toast-end"
      },
      vertical: {
        # "sm:toast-top"
        # "@sm:toast-top"
        # "md:toast-top"
        # "@md:toast-top"
        # "lg:toast-top"
        # "@lg:toast-top"
        top: "toast-top",
        # "sm:toast-middle"
        # "@sm:toast-middle"
        # "md:toast-middle"
        # "@md:toast-middle"
        # "lg:toast-middle"
        # "@lg:toast-middle"
        middle: "toast-middle",
        # "sm:toast-bottom"
        # "@sm:toast-bottom"
        # "md:toast-bottom"
        # "@md:toast-bottom"
        # "lg:toast-bottom"
        # "@lg:toast-bottom"
        bottom: "toast-bottom"
      }
    )
  end
end
