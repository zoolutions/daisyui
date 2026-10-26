# frozen_string_literal: true

module DaisyUI
  class Variants
    # `Component.variants.schema`: a component's declarations as plain,
    # frozen data. A component that only calls `register_modifiers` gets its
    # variants and flags, with the rest empty.
    #
    # @api private
    class Schema
      # Ungrouped modifiers and the flags registered without a class.
      def self.flags(klass)
        grouped = klass.modifier_groups.values.flatten
        ((klass.modifiers || {}).keys - grouped) | klass.flags
      end

      def initialize(klass)
        @klass = klass
        @definitions = klass.variant_definitions
      end

      def to_h
        Shareable.share(
          base:,
          variants: @klass.modifier_groups.transform_values(&:dup),
          flags: self.class.flags(@klass),
          defaults: @definitions[:defaults].dup,
          compounds: @definitions[:compounds].map { |entry| { match: entry[:match], class: shown(entry[:class]), set: entry[:set] } },
          on: @definitions[:rules].map { |entry| { states: entry[:states], match: entry[:match], class: shown(entry[:class]) } },
          states: @definitions[:states].dup,
          slots: { root: base, **@definitions[:slots] }
        )
      end

      # Every class token the declarations can render, `prefix` included the
      # way Base#apply_prefix adds it (after any state), sorted.
      def literal_classes(prefix)
        plain = [base, *modifier_classes, *@definitions[:slots].values, *slot_member_classes, *compound_classes]
        plain = plain.compact.flat_map(&:split).map { |token| "#{prefix}#{token}" }
        (plain + state_classes(prefix)).uniq.sort
      end

      private

      def base
        classes = [@klass.component_class&.to_s, @definitions[:base]].compact.join(" ")
        classes.empty? ? nil : classes
      end

      def modifier_classes = (@klass.modifiers || {}).values

      def slot_member_classes = @definitions[:slot_classes].values.flat_map(&:values)

      def compound_classes = @definitions[:compounds].flat_map { |entry| entry[:class].values }

      def state_classes(prefix)
        @definitions[:rules].flat_map do |rule|
          tokens = rule[:class].values.flat_map(&:split)
          rule[:states].flat_map do |state|
            tokens.map { |token| "#{@definitions[:states].fetch(state)}:#{prefix}#{token}" }
          end
        end
      end

      # A root-only class shows as its String, per-slot classes as the Hash.
      def shown(classes)
        return nil if classes.empty?

        classes.keys == [:root] ? classes[:root] : classes
      end
    end
  end
end
