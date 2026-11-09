# frozen_string_literal: true

module Views
  module Components
    module Examples
      module Otp
        class InForm < Views::Components::Example
          include DaisyUI

          title "In a form"
          order 5
          description "Every attribute of the input (name, id, form, autofocus, disabled) goes " \
                      "through input_attributes:. The .otp element is itself a <label> with no " \
                      "text, so name the input with aria-label (aria_label:). Keep required and " \
                      "pattern: daisyUI marks the code complete, hiding the caret and outlining " \
                      "every box, only while the input is :valid. If your base styles give inputs a font-size " \
                      "(@tailwindcss/forms, an iOS no-zoom rule), add .otp > input { font-size: inherit; } " \
                      "or the digits drift out of their boxes."

          def example
            Otp(digits: 6, input_attributes: { name: "code", id: "otp-code", aria_label: "Verification code" })
          end
        end
      end
    end
  end
end
