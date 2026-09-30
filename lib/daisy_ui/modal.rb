# frozen_string_literal: true

module DaisyUI
  class Modal < Base
    self.component_class = :modal

    def initialize(*, id:, **)
      super
    end

    def view_template(&block)
      dialog(id:, class: classes, **attributes) do
        block&.call(self)
        # Auto-render backdrop if tap_outside_to_close modifier is present
        backdrop if modifiers.include?(:tap_outside_to_close)
      end
    end

    def body(*, as: :div, **options, &)
      public_send(as, class: component_classes("modal-box", options:), **options, &)
    end

    def action(*, as: :div, **options, &block)
      action_classes = component_classes("modal-action", options:)
      public_send(as, class: action_classes, **options) do
        block&.call(self)
      end
    end

    def backdrop(*, **options, &)
      backdrop_classes = component_classes("modal-backdrop", options:)
      form method: :dialog, class: backdrop_classes, **options do
        button
      end
    end

    def close_button(*, **, &)
      form method: :dialog do
        render DaisyUI::Button.new(*, **, &)
      end
    end

    register_modifiers(
      # "sm:modal-open"
      # "@sm:modal-open"
      # "md:modal-open"
      # "@md:modal-open"
      # "lg:modal-open"
      # "@lg:modal-open"
      # "xl:modal-open"
      # "@xl:modal-open"
      open: "modal-open",
      vertical: {
        # "sm:modal-top"
        # "@sm:modal-top"
        # "md:modal-top"
        # "@md:modal-top"
        # "lg:modal-top"
        # "@lg:modal-top"
        # "xl:modal-top"
        # "@xl:modal-top"
        top: "modal-top",
        # "sm:modal-middle"
        # "@sm:modal-middle"
        # "md:modal-middle"
        # "@md:modal-middle"
        # "lg:modal-middle"
        # "@lg:modal-middle"
        # "xl:modal-middle"
        # "@xl:modal-middle"
        middle: "modal-middle",
        # "sm:modal-bottom"
        # "@sm:modal-bottom"
        # "md:modal-bottom"
        # "@md:modal-bottom"
        # "lg:modal-bottom"
        # "@lg:modal-bottom"
        # "xl:modal-bottom"
        # "@xl:modal-bottom"
        bottom: "modal-bottom"
      },
      horizontal: {
        # "sm:modal-start"
        # "@sm:modal-start"
        # "md:modal-start"
        # "@md:modal-start"
        # "lg:modal-start"
        # "@lg:modal-start"
        # "xl:modal-start"
        # "@xl:modal-start"
        start: "modal-start",
        # "sm:modal-end"
        # "@sm:modal-end"
        # "md:modal-end"
        # "@md:modal-end"
        # "lg:modal-end"
        # "@lg:modal-end"
        # "xl:modal-end"
        # "@xl:modal-end"
        end: "modal-end"
      }
    )
  end
end
