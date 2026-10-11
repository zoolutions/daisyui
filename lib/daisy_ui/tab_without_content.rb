# frozen_string_literal: true

module DaisyUI
  # @private
  class TabWithoutContent < Base
    self.component_class = :tab
    register_flags :open, :closed

    def initialize(*, label: nil, **)
      super(*, **)
      @label = label
    end

    def view_template(&)
      attrs = attributes.dup
      # Remove label from attributes if it was passed as a keyword arg
      attrs.delete(:label)

      div role: :tab, class: classes, **attrs, &
    end

    register_modifiers(
      # "sm:tab-active"
      # "@sm:tab-active"
      # "md:tab-active"
      # "@md:tab-active"
      # "lg:tab-active"
      # "@lg:tab-active"
      active: "tab-active",
      # "sm:tab-disabled"
      # "@sm:tab-disabled"
      # "md:tab-disabled"
      # "@md:tab-disabled"
      # "lg:tab-disabled"
      # "@lg:tab-disabled"
      disabled: "tab-disabled"
    )
  end
end
