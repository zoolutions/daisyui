# frozen_string_literal: true

module DaisyUI
  # @private
  class CollapsibleSubMenu < Base
    self.component_class = nil
    register_flags :collapsible, :open

    def initialize(*, **)
      super
      @items = []
    end

    def view_template(&block)
      block&.call(self)

      # Extract 'open' attribute for the details element
      details_attrs = {}
      details_attrs[:open] = true if modifiers.include?(:open) || options.delete(:open) == true

      details(**details_attrs) do
        raise ArgumentError, "A collapsible submenu requires a title" unless @title

        summary do
          render @title
        end

        if @items.any?
          ul class: classes, **attributes do
            @items.each do |item|
              render item
            end
          end
        end
      end
    end

    def title(&block)
      raise ArgumentError, "A collapsible submenu can only have one title" if @title

      @title = block
    end

    def item(...)
      @items << MenuItem.new(...)
    end

    register_modifiers(COLOR_MODIFIERS)
  end
end
