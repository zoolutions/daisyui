# frozen_string_literal: true

require "securerandom"

module DaisyUI
  class Tooltip < Base
    self.component_class = :tooltip

    PLACEMENTS = %i[top bottom left right].freeze
    DEFAULT_STIMULUS_IDENTIFIER = "daisy-tooltip"
    POPOVER_STYLE = "position:fixed;inset:auto;margin:0;border:0;opacity:1;transform:none;overflow:visible;" \
                    "pointer-events:none;visibility:hidden"
    ARROW_STYLE = "position:absolute;width:.625rem;height:.25rem;background:var(--tt-bg);" \
                  "clip-path:polygon(0 0,100% 0,50% 100%);pointer-events:none"

    def initialize(*modifiers, tip: nil, as: :div, popover_id: nil, stimulus: true, **options)
      @popover = modifiers.include?(:popover)
      @popover_id = popover_id if @popover
      @stimulus = stimulus
      @tip = tip
      if popover?
        validate_stimulus!
        boolean_placements = PLACEMENTS.select { |candidate| options[candidate] == true }
        wire_controller(options, modifiers + boolean_placements)
      end
      super(*modifiers, as:, **options)
    end

    def view_template(&)
      if popover?
        public_send(as, class: merge_classes(classes, "after:hidden"), **attributes) do
          yield self if block_given?
          content { plain tip } if tip && !@content_rendered
        end
      else
        opts = { class: classes, **attributes }
        opts[:data_tip] = tip if tip
        public_send(as, **opts, &)
      end
    end

    def content(**options, &)
      if popover?
        @content_rendered = true
        options[:id] ||= popover_id
        options[:popover] = "manual"
        options[:role] ||= "tooltip"
        options[:style] = merge_style(options[:style], POPOVER_STYLE)
        merge_stimulus_target(options, "content")

        div(class: component_classes("tooltip-content", options:), **options) do
          span(
            aria_hidden: "true",
            data: { stimulus_target_key => "arrow" },
            style: ARROW_STYLE
          )
          yield if block_given?
        end
      else
        div(class: component_classes("tooltip-content", options:), **options, &)
      end
    end

    private

    attr_reader :tip

    def popover?
      @popover
    end

    def popover_id
      @popover_id ||= "tooltip_#{SecureRandom.hex(8)}"
    end

    def stimulus_identifier
      return DEFAULT_STIMULUS_IDENTIFIER if @stimulus == true

      @stimulus.to_s
    end

    def validate_stimulus!
      valid_identifier = (@stimulus.is_a?(String) || @stimulus.is_a?(Symbol)) && @stimulus.to_s.match?(/\A\S+\z/)
      return if @stimulus == true || valid_identifier

      raise ArgumentError, "stimulus must be true or a non-empty controller identifier in popover mode"
    end

    def stimulus_target_key
      :"#{stimulus_identifier}_target"
    end

    def placement(source_modifiers = modifiers)
      PLACEMENTS.find { |candidate| source_modifiers.include?(candidate) } || :top
    end

    def wire_controller(options, source_modifiers)
      data = (options[:data] || {}).dup
      controllers = data[:controller].to_s.split
      data[:controller] = (controllers + [stimulus_identifier]).uniq.join(" ")
      data[:"#{stimulus_identifier}_placement_value"] = placement(source_modifiers)
      options[:data] = data
    end

    def merge_stimulus_target(options, target)
      data = (options[:data] || {}).dup
      targets = data[stimulus_target_key].to_s.split
      data[stimulus_target_key] = (targets + [target]).uniq.join(" ")
      options[:data] = data
    end

    def merge_style(existing, added)
      [existing&.chomp(";"), added].compact.join(";")
    end

    register_modifiers(
      # "sm:tooltip-open"
      # "@sm:tooltip-open"
      # "md:tooltip-open"
      # "@md:tooltip-open"
      # "lg:tooltip-open"
      # "@lg:tooltip-open"
      open: "tooltip-open",
      placement: {
        # "sm:tooltip-top"
        # "@sm:tooltip-top"
        # "md:tooltip-top"
        # "@md:tooltip-top"
        # "lg:tooltip-top"
        # "@lg:tooltip-top"
        top: "tooltip-top",
        # "sm:tooltip-bottom"
        # "@sm:tooltip-bottom"
        # "md:tooltip-bottom"
        # "@md:tooltip-bottom"
        # "lg:tooltip-bottom"
        # "@lg:tooltip-bottom"
        bottom: "tooltip-bottom",
        # "sm:tooltip-left"
        # "@sm:tooltip-left"
        # "md:tooltip-left"
        # "@md:tooltip-left"
        # "lg:tooltip-left"
        # "@lg:tooltip-left"
        left: "tooltip-left",
        # "sm:tooltip-right"
        # "@sm:tooltip-right"
        # "md:tooltip-right"
        # "@md:tooltip-right"
        # "lg:tooltip-right"
        # "@lg:tooltip-right"
        right: "tooltip-right"
      },
      color: {
        # "sm:tooltip-neutral"
        # "@sm:tooltip-neutral"
        # "md:tooltip-neutral"
        # "@md:tooltip-neutral"
        # "lg:tooltip-neutral"
        # "@lg:tooltip-neutral"
        neutral: "tooltip-neutral",
        # "sm:tooltip-primary"
        # "@sm:tooltip-primary"
        # "md:tooltip-primary"
        # "@md:tooltip-primary"
        # "lg:tooltip-primary"
        # "@lg:tooltip-primary"
        primary: "tooltip-primary",
        # "sm:tooltip-secondary"
        # "@sm:tooltip-secondary"
        # "md:tooltip-secondary"
        # "@md:tooltip-secondary"
        # "lg:tooltip-secondary"
        # "@lg:tooltip-secondary"
        secondary: "tooltip-secondary",
        # "sm:tooltip-accent"
        # "@sm:tooltip-accent"
        # "md:tooltip-accent"
        # "@md:tooltip-accent"
        # "lg:tooltip-accent"
        # "@lg:tooltip-accent"
        accent: "tooltip-accent",
        # "sm:tooltip-info"
        # "@sm:tooltip-info"
        # "md:tooltip-info"
        # "@md:tooltip-info"
        # "lg:tooltip-info"
        # "@lg:tooltip-info"
        info: "tooltip-info",
        # "sm:tooltip-success"
        # "@sm:tooltip-success"
        # "md:tooltip-success"
        # "@md:tooltip-success"
        # "lg:tooltip-success"
        # "@lg:tooltip-success"
        success: "tooltip-success",
        # "sm:tooltip-warning"
        # "@sm:tooltip-warning"
        # "md:tooltip-warning"
        # "@md:tooltip-warning"
        # "lg:tooltip-warning"
        # "@lg:tooltip-warning"
        warning: "tooltip-warning",
        # "sm:tooltip-error"
        # "@sm:tooltip-error"
        # "md:tooltip-error"
        # "@md:tooltip-error"
        # "lg:tooltip-error"
        # "@lg:tooltip-error"
        error: "tooltip-error"
      },
      align: {
        # "sm:tooltip-start"
        # "@sm:tooltip-start"
        # "md:tooltip-start"
        # "@md:tooltip-start"
        # "lg:tooltip-start"
        # "@lg:tooltip-start"
        start: "tooltip-start",
        # "sm:tooltip-center"
        # "@sm:tooltip-center"
        # "md:tooltip-center"
        # "@md:tooltip-center"
        # "lg:tooltip-center"
        # "@lg:tooltip-center"
        center: "tooltip-center",
        # "sm:tooltip-end"
        # "@sm:tooltip-end"
        # "md:tooltip-end"
        # "@md:tooltip-end"
        # "lg:tooltip-end"
        # "@lg:tooltip-end"
        end: "tooltip-end"
      }
    )
  end
end
