# frozen_string_literal: true

module DaisyUI
  # @component html class="join"
  class Pagination < Base
    self.component_class = :join

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def item(**options, &)
      div(class: component_classes("join-item", options:), **options, &)
    end

    register_modifiers(
      direction: {
        # "sm:join-vertical"
        # "@sm:join-vertical"
        # "md:join-vertical"
        # "@md:join-vertical"
        # "lg:join-vertical"
        # "@lg:join-vertical"
        vertical: "join-vertical",
        # "sm:join-horizontal"
        # "@sm:join-horizontal"
        # "md:join-horizontal"
        # "@md:join-horizontal"
        # "lg:join-horizontal"
        # "@lg:join-horizontal"
        horizontal: "join-horizontal"
      }
    )
  end
end
