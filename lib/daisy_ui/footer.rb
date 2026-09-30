# frozen_string_literal: true

module DaisyUI
  # @component html class="footer"
  class Footer < Base
    self.component_class = :footer

    def initialize(*, as: :footer, **)
      super
    end

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def title(**options, &)
      div(class: component_classes("footer-title", options:), **options, &)
    end

    register_modifiers(
      # "sm:footer-center"
      # "@sm:footer-center"
      # "md:footer-center"
      # "@md:footer-center"
      # "lg:footer-center"
      # "@lg:footer-center"
      center: "footer-center",
      direction: {
        # "sm:footer-horizontal"
        # "@sm:footer-horizontal"
        # "md:footer-horizontal"
        # "@md:footer-horizontal"
        # "lg:footer-horizontal"
        # "@lg:footer-horizontal"
        horizontal: "footer-horizontal",
        # "sm:footer-vertical"
        # "@sm:footer-vertical"
        # "md:footer-vertical"
        # "@md:footer-vertical"
        # "lg:footer-vertical"
        # "@lg:footer-vertical"
        vertical: "footer-vertical"
      }
    )
  end
end
