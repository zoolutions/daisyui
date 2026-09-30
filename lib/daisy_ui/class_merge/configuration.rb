# frozen_string_literal: true

module DaisyUI
  module ClassMerge
    # Settings for DaisyUI::ClassMerge, reached through
    # `DaisyUI.configure { |c| c.class_merge }`.
    #
    #   DaisyUI.configure do |c|
    #     c.class_merge.enabled = true
    #     c.class_merge.utility("text-display", "text-hero", like: "text-lg")
    #     c.class_merge.theme(spacing: %w[gutter])
    #   end
    #
    # Custom colors (`bg-brand`, `text-brand`) need no registration.
    class Configuration
      THEME_KEYS = TailwindConfig::DEFAULTS[:theme].keys.freeze

      attr_accessor :enabled

      def initialize
        @enabled = true
        @theme = {}
        @class_groups = {}
        @conflicts = {}
      end

      # Registers utilities that behave like an existing one:
      # `utility("text-display", like: "text-lg")` makes `text-display` a font
      # size, so it replaces `text-sm` and sits next to `text-error`.
      def utility(*names, like:)
        group = ClassMerge.tailwind_utils.class_group_id(like) or
          raise ArgumentError, "#{like.inspect} is not a known utility to model #{names.join(', ')} on"

        class_groups(group => names.map(&:to_s))
      end

      # Appends values to Tailwind theme scales, which feed every utility using
      # the scale: `spacing: %w[gutter]` covers `p-gutter`, `m-gutter`, `gap-gutter`.
      def theme(**scales)
        scales = scales.transform_keys { |key| key.to_s.tr("_", "-") }
        unknown = scales.keys - THEME_KEYS
        raise ArgumentError, "unknown theme key #{unknown.map(&:inspect).join(', ')}; use one of #{THEME_KEYS.join(', ')}" if unknown.any?

        append(@theme, scales.transform_values { |values| Array(values).map(&:to_s) })
      end

      # Raw tailwind_merge class groups: `{ "group-id" => ["class", ...] }`.
      # Classes in the same group conflict with each other.
      def class_groups(groups)
        append(@class_groups, groups)
      end

      # Raw tailwind_merge conflicts: `{ "group-id" => ["other-group-id", ...] }`
      # removes earlier classes of the listed groups when a class of the key
      # group appears later.
      def conflicts(conflicts)
        append(@conflicts, conflicts)
      end

      # @api private The config passed to Merger.new, including the daisyUI groups.
      def merger_config
        {
          theme: @theme,
          class_groups: DaisyGroups.build.merge(@class_groups) { |_id, existing, added| existing + added },
          conflicting_class_groups: @conflicts
        }
      end

      private

      def append(target, entries)
        entries.each { |id, values| (target[id.to_s] ||= []).concat(Array(values)) }
        ClassMerge.reset!
      end
    end
  end
end
