# frozen_string_literal: true

module DaisyUI
  class Tabs < Base
    self.component_class = :tabs

    def initialize(*, id: nil, as: :div, **)
      super(*, id: nil, as:, **)
      @id = id
    end

    def view_template
      public_send(as, role: :tablist, class: classes, **attributes) do
        yield self if block_given?
      end
    end

    def tab(*args, label: nil, **, &)
      # If first arg is a string, it's the label, rest are modifiers
      # Otherwise all args are modifiers
      label = args.shift if args.first.is_a?(String)

      render Tab.new(*args, label:, id:, **, &)
    end

    private

    # Override Base#attributes to exclude :id from the main tabs container.
    # The Tabs component uses :id internally to wire up the radio inputs
    # and their associated content panels - NOT for the main container.
    def attributes
      options
    end

    register_modifiers(
      style: {
        # "sm:tabs-box"
        # "@sm:tabs-box"
        # "md:tabs-box"
        # "@md:tabs-box"
        # "lg:tabs-box"
        # "@lg:tabs-box"
        box: "tabs-box",
        # "sm:tabs-border"
        # "@sm:tabs-border"
        # "md:tabs-border"
        # "@md:tabs-border"
        # "lg:tabs-border"
        # "@lg:tabs-border"
        border: "tabs-border",
        # "sm:tabs-lift"
        # "@sm:tabs-lift"
        # "md:tabs-lift"
        # "@md:tabs-lift"
        # "lg:tabs-lift"
        # "@lg:tabs-lift"
        lift: "tabs-lift"
      },
      size: {
        # "sm:tabs-xs"
        # "@sm:tabs-xs"
        # "md:tabs-xs"
        # "@md:tabs-xs"
        # "lg:tabs-xs"
        # "@lg:tabs-xs"
        xs: "tabs-xs",
        # "sm:tabs-sm"
        # "@sm:tabs-sm"
        # "md:tabs-sm"
        # "@md:tabs-sm"
        # "lg:tabs-sm"
        # "@lg:tabs-sm"
        sm: "tabs-sm",
        # "sm:tabs-md"
        # "@sm:tabs-md"
        # "md:tabs-md"
        # "@md:tabs-md"
        # "lg:tabs-md"
        # "@lg:tabs-md"
        md: "tabs-md",
        # "sm:tabs-lg"
        # "@sm:tabs-lg"
        # "md:tabs-lg"
        # "@md:tabs-lg"
        # "lg:tabs-lg"
        # "@lg:tabs-lg"
        # "xl:tabs-lg"
        # "@xl:tabs-lg"
        lg: "tabs-lg",
        # "sm:tabs-xl"
        # "@sm:tabs-xl"
        # "md:tabs-xl"
        # "@md:tabs-xl"
        # "lg:tabs-xl"
        # "@lg:tabs-xl"
        # "xl:tabs-xl"
        # "@xl:tabs-xl"
        xl: "tabs-xl"
      },
      placement: {
        # "sm:tabs-top"
        # "@sm:tabs-top"
        # "md:tabs-top"
        # "@md:tabs-top"
        # "lg:tabs-top"
        # "@lg:tabs-top"
        top: "tabs-top",
        # "sm:tabs-bottom"
        # "@sm:tabs-bottom"
        # "md:tabs-bottom"
        # "@md:tabs-bottom"
        # "lg:tabs-bottom"
        # "@lg:tabs-bottom"
        bottom: "tabs-bottom"
      }
    ).freeze
  end
end
