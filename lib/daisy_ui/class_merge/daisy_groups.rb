# frozen_string_literal: true

module DaisyUI
  module ClassMerge
    # Builds merger class groups for daisyUI classes from the components' own
    # `register_modifiers` data, so a new modifier is classified by its suffix
    # instead of a hand-maintained list.
    #
    # A modifier token `<component>-<suffix>` joins the group
    # `daisy:<component>-<family>` when its suffix belongs to a family below,
    # so `btn-sm btn-lg` conflicts while `btn-sm badge-lg` and `btn-wide btn-lg`
    # do not. Tokens Tailwind already classifies (`bg-primary`) are left to the
    # Tailwind groups. Every component base class (`btn`, `table`) gets a group
    # of its own and is never dropped, even where Tailwind has a utility of the
    # same name (`table`, `collapse`).
    module DaisyGroups
      FAMILIES = {
        "color" => %w[primary secondary accent neutral info success warning error],
        "size" => %w[xs sm md lg xl],
        "style" => %w[outline dash soft ghost link],
        "direction" => %w[horizontal vertical],
        # Placement is two axes: `toast-top toast-end` and
        # `dropdown-top dropdown-end` keep both classes.
        "placement" => %w[top middle bottom left right],
        "alignment" => %w[start center end]
      }.freeze

      FAMILY_BY_SUFFIX = FAMILIES.each_with_object({}) do |(family, suffixes), map|
        suffixes.each { |suffix| map[suffix] = family }
      end.freeze

      # Registered modifier tokens that belong to no family. They never
      # conflict with anything and are always kept.
      STANDALONE = Set.new(
        [
          # Aura effects combine freely
          "aura-dual", "aura-glow", "aura-gold", "aura-holo", "aura-rainbow", "aura-silver",
          # Avatar presence and placeholder states
          "avatar-offline", "avatar-online", "avatar-placeholder",
          # Button shapes and states combine with sizes and colors
          "btn-active", "btn-block", "btn-circle", "btn-disabled", "btn-square", "btn-wide",
          # Card layout options
          "card-border", "card-side", "image-full",
          # Collapse icons and forced open/close states
          "collapse-arrow", "collapse-close", "collapse-open", "collapse-plus",
          # Open/hover/active/focus/disabled states
          "dock-active", "drawer-open", "dropdown-hover", "dropdown-open", "link-hover",
          "menu-active", "menu-disabled", "menu-focus", "modal-open", "swap-active",
          "tab-active", "tab-disabled", "tooltip-open",
          # FAB layout
          "fab-flower",
          # Label wrappers and table row hover emit another component's base class
          "floating-label", "hover", "input", "select", "swap", "toggle",
          # List column behaviour
          "list-col-grow", "list-col-wrap",
          # Loading animations (one per element, but no size/color semantics)
          "loading-ball", "loading-bars", "loading-dots", "loading-infinity", "loading-ring", "loading-spinner",
          # Mask shapes, including numbered variants the suffix rule cannot read
          "mask-circle", "mask-decagon", "mask-diamond", "mask-half-1", "mask-half-2", "mask-heart",
          "mask-hexagon", "mask-hexagon-2", "mask-pentagon", "mask-square", "mask-squircle", "mask-star",
          "mask-star-2", "mask-triangle", "mask-triangle-2", "mask-triangle-3", "mask-triangle-4",
          # Megamenu widths
          "megamenu-full", "megamenu-wide",
          # OTP layout
          "otp-joined",
          # Rating half stars and the hidden clear input
          "rating-half", "rating-hidden",
          # Skeleton text variant
          "skeleton-text",
          # Swap animations
          "swap-flip", "swap-rotate",
          # Table options combine freely
          "table-pin-cols", "table-pin-rows", "table-zebra",
          # Tab styles
          "tabs-border", "tabs-box", "tabs-lift",
          # Timeline layout options
          "timeline-box", "timeline-compact", "timeline-snap-icon"
        ]
      ).freeze

      class << self
        # Returns { class_groups:, conflicting_class_groups: } for the merger.
        def build(prefix: DaisyUI.configuration.prefix)
          groups = {}

          component_classes.each do |base|
            groups["daisy:#{base}"] = ["#{prefix}#{base}"]
          end

          modifier_tokens.each_key do |token|
            next unless (group = family_group(token))

            (groups[group] ||= []) << "#{prefix}#{token}"
          end

          { class_groups: groups, conflicting_class_groups: {} }
        end

        # The family group for a token, or nil when it has none.
        def family_group(token)
          component, _, suffix = token.rpartition("-")
          return if component.empty?
          return if tailwind_class?(token)

          family = FAMILY_BY_SUFFIX[suffix]
          "daisy:#{component}-#{family}" if family
        end

        def tailwind_class?(token)
          !tailwind_utils.class_group_id(token).nil?
        end

        # { token => [component names] } for every class a gem component or
        # the configured modifiers can emit.
        def modifier_tokens
          tokens = Hash.new { |hash, key| hash[key] = [] }

          components.each do |component|
            (component.modifiers || {}).each_value do |classes|
              classes.split.each { |token| tokens[token] << component.name }
            end
          end

          DaisyUI.configuration.modifiers.all.each do |classes|
            classes.split.each { |token| tokens[token] << "DaisyUI.configuration" }
          end

          tokens
        end

        def components
          Zeitwerk::Loader.eager_load_namespace(DaisyUI)
          descendants(DaisyUI::Base).select { |klass| klass.name&.start_with?("DaisyUI::") }
        end

        private

        def component_classes
          components.filter_map { |component| component.component_class&.to_s }.uniq
        end

        def descendants(klass)
          klass.subclasses.flat_map { |subclass| [subclass, *descendants(subclass)] }
        end

        def tailwind_utils
          @tailwind_utils ||= ClassGroupUtils.new(TailwindConfig::DEFAULTS)
        end
      end
    end
  end
end
