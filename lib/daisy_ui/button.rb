# frozen_string_literal: true

require "phlex/version"

module DaisyUI
  class Button < Base
    self.component_class = :btn

    def initialize(*, as: :button, modal: nil, **)
      super(*, as:, **)
      @modal = modal
    end

    def view_template(&)
      if modal
        public_send(
          as,
          class: classes,
          onclick: safe("#{Phlex::Escape.html_escape(modal)}.showModal()"),
          **attributes,
          &
        )
      else
        public_send(as, class: classes, **attributes, &)
      end
    end

    private

    attr_reader :modal

    register_modifiers(
      style: {
        # "sm:btn-ghost"
        # "@sm:btn-ghost"
        # "md:btn-ghost"
        # "@md:btn-ghost"
        # "lg:btn-ghost"
        # "@lg:btn-ghost"
        ghost: "btn-ghost",
        # "sm:btn-link"
        # "@sm:btn-link"
        # "md:btn-link"
        # "@md:btn-link"
        # "lg:btn-link"
        # "@lg:btn-link"
        link: "btn-link",
        # "sm:btn-outline"
        # "@sm:btn-outline"
        # "md:btn-outline"
        # "@md:btn-outline"
        # "lg:btn-outline"
        # "@lg:btn-outline"
        outline: "btn-outline",
        # "sm:btn-dash"
        # "@sm:btn-dash"
        # "md:btn-dash"
        # "@md:btn-dash"
        # "lg:btn-dash"
        # "@lg:btn-dash"
        dash: "btn-dash",
        # "sm:btn-soft"
        # "@sm:btn-soft"
        # "md:btn-soft"
        # "@md:btn-soft"
        # "lg:btn-soft"
        # "@lg:btn-soft"
        soft: "btn-soft"
      },
      # "sm:btn-active"
      # "@sm:btn-active"
      # "md:btn-active"
      # "@md:btn-active"
      # "lg:btn-active"
      # "@lg:btn-active"
      active: "btn-active",
      # "sm:btn-disabled"
      # "@sm:btn-disabled"
      # "md:btn-disabled"
      # "@md:btn-disabled"
      # "lg:btn-disabled"
      # "@lg:btn-disabled"
      disabled: "btn-disabled",
      size: {
        # "sm:btn-lg"
        # "@sm:btn-lg"
        # "md:btn-lg"
        # "@md:btn-lg"
        # "lg:btn-lg"
        # "@lg:btn-lg"
        lg: "btn-lg",
        # "sm:btn-md"
        # "@sm:btn-md"
        # "md:btn-md"
        # "@md:btn-md"
        # "lg:btn-md"
        # "@lg:btn-md"
        md: "btn-md",
        # "sm:btn-sm"
        # "@sm:btn-sm"
        # "md:btn-sm"
        # "@md:btn-sm"
        # "lg:btn-sm"
        # "@lg:btn-sm"
        sm: "btn-sm",
        # "sm:btn-xs"
        # "@sm:btn-xs"
        # "md:btn-xs"
        # "@md:btn-xs"
        # "lg:btn-xs"
        # "@lg:btn-xs"
        xs: "btn-xs",
        # "sm:btn-xl"
        # "@sm:btn-xl"
        # "md:btn-xl"
        # "@md:btn-xl"
        # "lg:btn-xl"
        # "@lg:btn-xl"
        xl: "btn-xl"
      },
      # "sm:btn-wide"
      # "@sm:btn-wide"
      # "md:btn-wide"
      # "@md:btn-wide"
      # "lg:btn-wide"
      # "@lg:btn-wide"
      wide: "btn-wide",
      # "sm:btn-block"
      # "@sm:btn-block"
      # "md:btn-block"
      # "@md:btn-block"
      # "lg:btn-block"
      # "@lg:btn-block"
      block: "btn-block",
      shape: {
        # "sm:btn-circle"
        # "@sm:btn-circle"
        # "md:btn-circle"
        # "@md:btn-circle"
        # "lg:btn-circle"
        # "@lg:btn-circle"
        circle: "btn-circle",
        # "sm:btn-square"
        # "@sm:btn-square"
        # "md:btn-square"
        # "@md:btn-square"
        # "lg:btn-square"
        # "@lg:btn-square"
        square: "btn-square"
      },
      color: {
        # "sm:btn-neutral"
        # "@sm:btn-neutral"
        # "md:btn-neutral"
        # "@md:btn-neutral"
        # "lg:btn-neutral"
        # "@lg:btn-neutral"
        neutral: "btn-neutral",
        # "sm:btn-primary"
        # "@sm:btn-primary"
        # "md:btn-primary"
        # "@md:btn-primary"
        # "lg:btn-primary"
        # "@lg:btn-primary"
        primary: "btn-primary",
        # "sm:btn-secondary"
        # "@sm:btn-secondary"
        # "md:btn-secondary"
        # "@md:btn-secondary"
        # "lg:btn-secondary"
        # "@lg:btn-secondary"
        secondary: "btn-secondary",
        # "sm:btn-accent"
        # "@sm:btn-accent"
        # "md:btn-accent"
        # "@md:btn-accent"
        # "lg:btn-accent"
        # "@lg:btn-accent"
        accent: "btn-accent",
        # "sm:btn-info"
        # "@sm:btn-info"
        # "md:btn-info"
        # "@md:btn-info"
        # "lg:btn-info"
        # "@lg:btn-info"
        info: "btn-info",
        # "sm:btn-success"
        # "@sm:btn-success"
        # "md:btn-success"
        # "@md:btn-success"
        # "lg:btn-success"
        # "@lg:btn-success"
        success: "btn-success",
        # "sm:btn-warning"
        # "@sm:btn-warning"
        # "md:btn-warning"
        # "@md:btn-warning"
        # "lg:btn-warning"
        # "@lg:btn-warning"
        warning: "btn-warning",
        # "sm:btn-error"
        # "@sm:btn-error"
        # "md:btn-error"
        # "@md:btn-error"
        # "lg:btn-error"
        # "@lg:btn-error"
        error: "btn-error"
      }
    ).freeze
  end
end
