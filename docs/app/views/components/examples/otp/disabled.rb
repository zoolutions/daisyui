# frozen_string_literal: true

module Views
  module Components
    module Examples
      module Otp
        class Disabled < Views::Components::Example
          include DaisyUI

          title "Disabled"
          order 6

          def example
            Otp(digits: 4, input_attributes: { disabled: true, value: "1234" })
          end
        end
      end
    end
  end
end
