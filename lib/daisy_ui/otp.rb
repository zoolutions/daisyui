# frozen_string_literal: true

module DaisyUI
  class Otp < Base
    self.component_class = :otp

    def initialize(*, digits: 4, as: :label, input_attributes: {}, **)
      super(*, as:, **)
      @digits = digits
      @input_attributes = input_attributes
    end

    def view_template(&)
      public_send(as, class: classes, **attributes) do
        digits.times { span }
        input(
          type: :text,
          autocomplete: "one-time-code",
          inputmode: :numeric,
          maxlength: digits,
          pattern: "[0-9]{#{digits}}",
          required: true,
          **input_attributes
        )
      end
    end

    private

    attr_reader :digits, :input_attributes

    register_modifiers(
      # "sm:otp-joined"
      # "@sm:otp-joined"
      # "md:otp-joined"
      # "@md:otp-joined"
      # "lg:otp-joined"
      # "@lg:otp-joined"
      joined: "otp-joined",
      size: {
        # "sm:otp-xs"
        # "@sm:otp-xs"
        # "md:otp-xs"
        # "@md:otp-xs"
        # "lg:otp-xs"
        # "@lg:otp-xs"
        xs: "otp-xs",
        # "sm:otp-sm"
        # "@sm:otp-sm"
        # "md:otp-sm"
        # "@md:otp-sm"
        # "lg:otp-sm"
        # "@lg:otp-sm"
        sm: "otp-sm",
        # "sm:otp-md"
        # "@sm:otp-md"
        # "md:otp-md"
        # "@md:otp-md"
        # "lg:otp-md"
        # "@lg:otp-md"
        md: "otp-md",
        # "sm:otp-lg"
        # "@sm:otp-lg"
        # "md:otp-lg"
        # "@md:otp-lg"
        # "lg:otp-lg"
        # "@lg:otp-lg"
        lg: "otp-lg",
        # "sm:otp-xl"
        # "@sm:otp-xl"
        # "md:otp-xl"
        # "@md:otp-xl"
        # "lg:otp-xl"
        # "@lg:otp-xl"
        xl: "otp-xl"
      },
      color: {
        # "sm:otp-neutral"
        # "@sm:otp-neutral"
        # "md:otp-neutral"
        # "@md:otp-neutral"
        # "lg:otp-neutral"
        # "@lg:otp-neutral"
        neutral: "otp-neutral",
        # "sm:otp-primary"
        # "@sm:otp-primary"
        # "md:otp-primary"
        # "@md:otp-primary"
        # "lg:otp-primary"
        # "@lg:otp-primary"
        primary: "otp-primary",
        # "sm:otp-secondary"
        # "@sm:otp-secondary"
        # "md:otp-secondary"
        # "@md:otp-secondary"
        # "lg:otp-secondary"
        # "@lg:otp-secondary"
        secondary: "otp-secondary",
        # "sm:otp-accent"
        # "@sm:otp-accent"
        # "md:otp-accent"
        # "@md:otp-accent"
        # "lg:otp-accent"
        # "@lg:otp-accent"
        accent: "otp-accent",
        # "sm:otp-success"
        # "@sm:otp-success"
        # "md:otp-success"
        # "@md:otp-success"
        # "lg:otp-success"
        # "@lg:otp-success"
        success: "otp-success",
        # "sm:otp-info"
        # "@sm:otp-info"
        # "md:otp-info"
        # "@md:otp-info"
        # "lg:otp-info"
        # "@lg:otp-info"
        info: "otp-info",
        # "sm:otp-warning"
        # "@sm:otp-warning"
        # "md:otp-warning"
        # "@md:otp-warning"
        # "lg:otp-warning"
        # "@lg:otp-warning"
        warning: "otp-warning",
        # "sm:otp-error"
        # "@sm:otp-error"
        # "md:otp-error"
        # "@md:otp-error"
        # "lg:otp-error"
        # "@lg:otp-error"
        error: "otp-error"
      }
    )
  end
end
