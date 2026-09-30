# frozen_string_literal: true

require "securerandom"

module DaisyUI
  class Dropdown < Base
    self.component_class = :dropdown

    # Placement modifiers that, in :popover mode, must live on the popover
    # element itself (DaisyUI's `position-area` rule is on `.dropdown`).
    PLACEMENT_MODIFIERS = %i[start center end top bottom left right].freeze

    # Default Stimulus identifier for the opt-in popover controller. Namespaced
    # so it never collides with a consumer app's own `dropdown` controller.
    DEFAULT_STIMULUS_IDENTIFIER = "daisy-dropdown"

    def initialize(*modifiers, as: :div, id: nil, popover_id: nil, stimulus: false, **)
      @popover = modifiers.include?(:popover)
      @popover_id = popover_id if @popover
      # stimulus: true enables the controller; a String/Symbol enables AND
      # overrides the identifier. Only meaningful in :popover mode.
      @stimulus = stimulus
      super(*modifiers, as:, id:, **)
    end

    def view_template
      if popover?
        # DaisyUI's popover variant is a FLAT structure: the trigger button and
        # the popover menu are siblings, and `dropdown` + the placement class
        # ride the popover element (that is what carries `position-area`). The
        # wrapper here is a plain, non-positioning container.
        public_send(as, **popover_root_attributes) do
          yield self if block_given?
        end
      elsif tap_to_close?
        details(class: classes, **attributes) do
          yield self if block_given?
        end
      else
        public_send(as, class: classes, **attributes) do
          yield self if block_given?
        end
      end
    end

    def button(*modifiers, **options, &)
      if popover?
        render Button.new(*modifiers, as: :button, **popover_button_options(options), &)
      elsif tap_to_close?
        render Button.new(*modifiers, as: :summary, **options, &)
      else
        render Button.new(*modifiers, as: :div, role: :button, tabindex: 0, **options, &)
      end
    end

    def content(*modifiers, as: :div, **options, &)
      return render_as(*modifiers, as:, **popover_menu_options(options), &) if popover?

      content_classes = component_classes("dropdown-content", options:)

      if tap_to_close?
        render_as(*modifiers, as:, class: content_classes, **options, &)
      else
        render_as(*modifiers, as:, tabindex: 0, class: content_classes, **options, &)
      end
    end

    def menu(*modifiers, **options, &)
      if popover?
        options[:role] ||= "menu"
        return render Menu.new(*modifiers, **popover_menu_options(options), &)
      end

      menu_classes = component_classes("dropdown-content", options:)

      if tap_to_close?
        render Menu.new(*modifiers, class: menu_classes, **options, &)
      else
        render Menu.new(*modifiers, tabindex: 0, class: menu_classes, **options, &)
      end
    end

    def popover?
      modifiers.include?(:popover)
    end

    def tap_to_close?
      modifiers.include?(:tap_to_close)
    end

    private

    # Stable id shared by the trigger (`popovertarget`) and the popover element
    # (`id`); the matching CSS anchor pairs `anchor-name` with `position-anchor`.
    def popover_id
      @popover_id ||= "dropdown_#{SecureRandom.hex(8)}"
    end

    def anchor_name
      "#{popover_id}_anchor"
    end

    # Whether the opt-in Stimulus controller is enabled (popover mode only).
    def stimulus?
      @popover && @stimulus
    end

    # Resolved Stimulus identifier: the default, or a caller-supplied override.
    def stimulus_identifier
      return DEFAULT_STIMULUS_IDENTIFIER if @stimulus == true

      @stimulus.to_s
    end

    # Wrapper attributes; in opt-in Stimulus mode add `data-controller`, merged
    # with any caller-supplied controller token (space-joined, not clobbered).
    def popover_root_attributes
      attrs = attributes
      return attrs unless stimulus?

      data = (attrs[:data] || {}).dup
      data[:controller] = [data[:controller], stimulus_identifier].compact.join(" ")
      attrs.merge(data:)
    end

    # Trigger wiring: a real <button> (required for the Popover API invoker),
    # `popovertarget` pointing at the menu, an `anchor-name` for CSS anchor
    # positioning, and ARIA wiring. `aria-controls`/`aria-expanded` give assistive
    # tech the trigger<->menu relationship and open state (the native Popover API
    # does not mirror open state onto the invoker; the Stimulus controller keeps
    # `aria-expanded` in sync when enabled). Caller `style`/`aria` are merged.
    def popover_button_options(options)
      options[:popovertarget] = popover_id
      options[:style] = merge_style(options[:style], "anchor-name:--#{anchor_name}")
      options[:aria] = { haspopup: "menu", controls: popover_id, expanded: "false" }.merge(options[:aria] || {})
      merge_stimulus_data(options, target: "trigger") if stimulus?
      options
    end

    # Popover element wiring: `dropdown` + placement classes (so `position-area`
    # applies), `popover="auto"`, the shared id, and `position-anchor`. We strip
    # any `dropdown-content` — that descendant rule forces `position: absolute`,
    # which conflicts with the top-layer popover. (`role="menu"` is added by
    # `menu`, not here, so a non-menu `content` panel is not mislabeled.)
    def popover_menu_options(options)
      caller_classes = Array(options.delete(:class)).flat_map { |v| v.to_s.split }.reject { |c| c.empty? || c == "dropdown-content" }
      placement = PLACEMENT_MODIFIERS.select { |m| modifiers.include?(m) }.map { |m| apply_prefix("dropdown-#{m}") }

      options[:class] = merge_classes(apply_prefix("dropdown"), *placement, *caller_classes)
      options[:id] = popover_id
      options[:popover] = "auto"
      options[:style] = merge_style(options[:style], "position-anchor:--#{anchor_name}")
      merge_stimulus_data(options, target: "menu") if stimulus?
      options
    end

    # Add a `data-<identifier>-target` to a child element's options without
    # clobbering caller-supplied data.
    def merge_stimulus_data(options, target:)
      data = (options[:data] || {}).dup
      key = :"#{stimulus_identifier}_target"
      existing = data[key].to_s.split
      data[key] = (existing + [target]).uniq.join(" ")
      options[:data] = data
      options
    end

    def merge_style(existing, added)
      [existing&.chomp(";"), added].compact.join(";")
    end

    register_modifiers(
      align: {
        # "sm:dropdown-start"
        # "@sm:dropdown-start"
        # "md:dropdown-start"
        # "@md:dropdown-start"
        # "lg:dropdown-start"
        # "@lg:dropdown-start"
        # "xl:dropdown-start"
        # "@xl:dropdown-start"
        start: "dropdown-start",
        # "sm:dropdown-center"
        # "@sm:dropdown-center"
        # "md:dropdown-center"
        # "@md:dropdown-center"
        # "lg:dropdown-center"
        # "@lg:dropdown-center"
        # "xl:dropdown-center"
        # "@xl:dropdown-center"
        center: "dropdown-center",
        # "sm:dropdown-end"
        # "@sm:dropdown-end"
        # "md:dropdown-end"
        # "@md:dropdown-end"
        # "lg:dropdown-end"
        # "@lg:dropdown-end"
        # "xl:dropdown-end"
        # "@xl:dropdown-end"
        end: "dropdown-end"
      },
      placement: {
        # "sm:dropdown-top"
        # "@sm:dropdown-top"
        # "md:dropdown-top"
        # "@md:dropdown-top"
        # "lg:dropdown-top"
        # "@lg:dropdown-top"
        # "xl:dropdown-top"
        # "@xl:dropdown-top"
        top: "dropdown-top",
        # "sm:dropdown-bottom"
        # "@sm:dropdown-bottom"
        # "md:dropdown-bottom"
        # "@md:dropdown-bottom"
        # "lg:dropdown-bottom"
        # "@lg:dropdown-bottom"
        # "xl:dropdown-bottom"
        # "@xl:dropdown-bottom"
        bottom: "dropdown-bottom",
        # "sm:dropdown-left"
        # "@sm:dropdown-left"
        # "md:dropdown-left"
        # "@md:dropdown-left"
        # "lg:dropdown-left"
        # "@lg:dropdown-left"
        # "xl:dropdown-left"
        # "@xl:dropdown-left"
        left: "dropdown-left",
        # "sm:dropdown-right"
        # "@sm:dropdown-right"
        # "md:dropdown-right"
        # "@md:dropdown-right"
        # "lg:dropdown-right"
        # "@lg:dropdown-right"
        # "xl:dropdown-right"
        # "@xl:dropdown-right"
        right: "dropdown-right"
      },
      # "sm:dropdown-hover"
      # "@sm:dropdown-hover"
      # "md:dropdown-hover"
      # "@md:dropdown-hover"
      # "lg:dropdown-hover"
      # "@lg:dropdown-hover"
      # "xl:dropdown-hover"
      # "@xl:dropdown-hover"
      hover: "dropdown-hover",
      # "sm:dropdown-open"
      # "@sm:dropdown-open"
      # "md:dropdown-open"
      # "@md:dropdown-open"
      # "lg:dropdown-open"
      # "@lg:dropdown-open"
      # "xl:dropdown-open"
      # "@xl:dropdown-open"
      open: "dropdown-open"
    )
  end
end
