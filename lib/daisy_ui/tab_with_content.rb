# frozen_string_literal: true

module DaisyUI
  # @private
  class TabWithContent < Base
    self.component_class = :tab
    register_flags :open, :closed

    def initialize(*, content:, label: nil, id: nil, **)
      super(*, **)
      @label = label
      @id = id
      @content = content
    end

    def view_template
      # Build explicit attributes in correct order
      tab_attrs = {
        type: :radio,
        name: id,
        class: classes, # This deletes :class from options
        role: :tab,
        aria: { label: @label }
      }

      # Now get remaining attributes (class has been deleted by classes method)
      attrs = attributes.dup

      # Handle modifiers and keyword args that should be HTML attributes
      # Order matters: modifiers come before keyword args in the original call
      closed_from_modifier = modifiers.include?(:closed)
      open_from_modifier = modifiers.include?(:open)
      closed_from_kwarg = attrs.delete(:closed) == true
      open_from_kwarg = attrs.delete(:open) == true

      # Add attributes from modifiers first (they appear earlier in args)
      tab_attrs[:closed] = true if closed_from_modifier
      tab_attrs[:checked] = true if open_from_modifier

      # Then add attributes from keyword args (they appear later in args)
      tab_attrs[:closed] = true if closed_from_kwarg && !closed_from_modifier
      tab_attrs[:checked] = true if open_from_kwarg && !open_from_modifier

      # Merge remaining attributes
      tab_attrs.merge!(attrs)

      # Render the radio input for the tab
      input(**tab_attrs)

      # Render the content
      @content&.call
    end

    private

    # Override Base#attributes to exclude :id from the tab input.
    # The TabWithContent component uses :id for the `name` attribute
    # to group radio inputs together - NOT for the id attribute.
    def attributes
      options
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
