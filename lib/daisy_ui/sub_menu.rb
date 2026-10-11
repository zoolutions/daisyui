# frozen_string_literal: true

module DaisyUI
  # @private
  class SubMenu < Base
    register_flags :open

    def initialize(*, **)
      super
      @items = []
    end

    def view_template(&)
      yield(self) if block_given?

      if @title
        div do
          render @title
        end
      end

      return unless @items.any?

      ul do
        @items.each do |item|
          render item
        end
      end
    end

    def title(&block)
      @title = block
    end

    def item(...)
      @items << MenuItem.new(...)
    end
  end
end
