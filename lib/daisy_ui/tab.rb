# frozen_string_literal: true

module DaisyUI
  # @private
  class Tab < Base
    def initialize(*modifiers, label: nil, id: nil, **)
      super(*modifiers, **)
      @label = label
      @id = id
    end

    def view_template(&block)
      block&.call(self)

      if @content
        render TabWithContent.new(
          *modifiers,
          label: @label,
          id:,
          content: @content,
          **options
        )
      else
        render TabWithoutContent.new(*modifiers, label: @label, **options)
      end
    end

    def content(*, **options, &block)
      unless id
        raise ArgumentError,
          "You must pass an id to Tabs#new if you want to add content"
      end

      @content = lambda do
        content_classes = component_classes("tab-content", options:)
        div role: :tabpanel, class: content_classes, **options, &block
      end
    end

    private

    # Tab only dispatches: TabWithContent or TabWithoutContent validates the
    # modifiers when it is built.
    def validate_modifiers; end
  end
end
