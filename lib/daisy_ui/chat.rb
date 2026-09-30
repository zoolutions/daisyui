# frozen_string_literal: true

module DaisyUI
  # @component html class="chat"
  class Chat < Base
    self.component_class = :chat

    # Bubble color modifiers (applied to chat-bubble element)
    BUBBLE_MODIFIERS = {
      # "sm:chat-bubble-neutral"
      # "@sm:chat-bubble-neutral"
      # "md:chat-bubble-neutral"
      # "@md:chat-bubble-neutral"
      # "lg:chat-bubble-neutral"
      # "@lg:chat-bubble-neutral"
      neutral: "chat-bubble-neutral",
      # "sm:chat-bubble-primary"
      # "@sm:chat-bubble-primary"
      # "md:chat-bubble-primary"
      # "@md:chat-bubble-primary"
      # "lg:chat-bubble-primary"
      # "@lg:chat-bubble-primary"
      primary: "chat-bubble-primary",
      # "sm:chat-bubble-secondary"
      # "@sm:chat-bubble-secondary"
      # "md:chat-bubble-secondary"
      # "@md:chat-bubble-secondary"
      # "lg:chat-bubble-secondary"
      # "@lg:chat-bubble-secondary"
      secondary: "chat-bubble-secondary",
      # "sm:chat-bubble-accent"
      # "@sm:chat-bubble-accent"
      # "md:chat-bubble-accent"
      # "@md:chat-bubble-accent"
      # "lg:chat-bubble-accent"
      # "@lg:chat-bubble-accent"
      accent: "chat-bubble-accent",
      # "sm:chat-bubble-info"
      # "@sm:chat-bubble-info"
      # "md:chat-bubble-info"
      # "@md:chat-bubble-info"
      # "lg:chat-bubble-info"
      # "@lg:chat-bubble-info"
      info: "chat-bubble-info",
      # "sm:chat-bubble-success"
      # "@sm:chat-bubble-success"
      # "md:chat-bubble-success"
      # "@md:chat-bubble-success"
      # "lg:chat-bubble-success"
      # "@lg:chat-bubble-success"
      success: "chat-bubble-success",
      # "sm:chat-bubble-warning"
      # "@sm:chat-bubble-warning"
      # "md:chat-bubble-warning"
      # "@md:chat-bubble-warning"
      # "lg:chat-bubble-warning"
      # "@lg:chat-bubble-warning"
      warning: "chat-bubble-warning",
      # "sm:chat-bubble-error"
      # "@sm:chat-bubble-error"
      # "md:chat-bubble-error"
      # "@md:chat-bubble-error"
      # "lg:chat-bubble-error"
      # "@lg:chat-bubble-error"
      error: "chat-bubble-error"
    }.freeze

    def view_template(&)
      public_send(as, class: classes, **attributes, &)
    end

    def image(**options, &)
      div(class: component_classes("chat-image", options:), **options, &)
    end

    def header(**options, &)
      div(class: component_classes("chat-header", options:), **options, &)
    end

    def bubble(*modifiers, **options, &)
      bubble_classes = build_bubble_classes(modifiers, options)
      div(class: bubble_classes, **options, &)
    end

    def footer(**options, &)
      div(class: component_classes("chat-footer", options:), **options, &)
    end

    register_modifiers(
      placement: {
        # "sm:chat-start"
        # "@sm:chat-start"
        # "md:chat-start"
        # "@md:chat-start"
        # "lg:chat-start"
        # "@lg:chat-start"
        start: "chat-start",
        # "sm:chat-end"
        # "@sm:chat-end"
        # "md:chat-end"
        # "@md:chat-end"
        # "lg:chat-end"
        # "@lg:chat-end"
        end: "chat-end"
      }
    )

    private

    def build_bubble_classes(modifiers, options)
      modifier_classes = modifiers.filter_map { |mod| apply_prefix(BUBBLE_MODIFIERS[mod]) }
      merge_classes(apply_prefix("chat-bubble"), *modifier_classes, options.delete(:class))
    end
  end
end
