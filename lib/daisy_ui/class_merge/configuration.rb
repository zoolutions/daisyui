# frozen_string_literal: true

module DaisyUI
  module ClassMerge
    # Settings for DaisyUI::ClassMerge, reached through
    # `DaisyUI.configure { |c| c.class_merge }`.
    #
    #   DaisyUI.configure do |c|
    #     c.class_merge.enabled = true
    #     c.class_merge.theme(text: %w[display], color: %w[brand])
    #     c.class_merge.class_groups("brand-shadow" => ["shadow-brand"])
    #     c.class_merge.conflicts("brand-shadow" => ["shadow"])
    #   end
    class Configuration
      DEFAULT_CACHE_SIZE = 500

      attr_accessor :enabled
      attr_reader :cache_size

      def initialize
        @enabled = true
        @cache_size = DEFAULT_CACHE_SIZE
        @theme = {}
        @class_groups = {}
        @conflicts = {}
      end

      def cache_size=(size)
        @cache_size = size
        ClassMerge.reset!
      end

      # Appends values to Tailwind theme scales, e.g. `text: %w[display]`
      # makes `text-display` a font size and `color: %w[brand]` makes
      # `bg-brand`, `text-brand` and `border-brand` colors.
      def theme(**scales)
        scales.each do |key, values|
          (@theme[key.to_s.tr("_", "-")] ||= []).concat(Array(values).map(&:to_s))
        end
        ClassMerge.reset!
      end

      # Adds class groups: `{ "group-id" => ["class", ...] }`. Classes in the
      # same group conflict with each other.
      def class_groups(groups)
        append(@class_groups, groups)
      end

      # Makes groups conflict: `{ "group-id" => ["other-group-id", ...] }`
      # removes earlier classes of the listed groups when a class of the key
      # group appears later.
      def conflicts(conflicts)
        append(@conflicts, conflicts)
      end

      # The config passed to Merger.new, including the daisyUI groups.
      def merger_config
        daisy = DaisyGroups.build

        {
          cache_size: cache_size,
          theme: @theme,
          class_groups: daisy[:class_groups].merge(@class_groups) { |_id, existing, added| existing + added },
          conflicting_class_groups: daisy[:conflicting_class_groups].merge(@conflicts) { |_id, existing, added| existing + added }
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
