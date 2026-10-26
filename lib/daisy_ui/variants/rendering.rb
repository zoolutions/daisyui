# frozen_string_literal: true

module DaisyUI
  class Variants
    # The instance side of the Variants API, included in DaisyUI::Base. A
    # component without declarations (every gem component) skips it all.
    module Rendering
      private

      # The `base` classes a `variants` block declared.
      def variant_base_classes
        apply_prefix(self.class.variant_definitions[:base])
      end

      # For `slot` (:root is the component itself): the classes of the
      # members a default or compound selected (the root's given members are
      # modifier_classes already), of every compound that holds, and of every
      # `on` rule that holds, prefixed with its states.
      def variant_classes(slot = :root)
        definitions = self.class.variant_definitions
        return [] if definitions.equal?(EMPTY)

        resolution = variant_resolution
        [
          *variant_member_classes(resolution, slot, definitions),
          *resolution.compounds.map { |compound| apply_prefix(compound[:class][slot]) },
          *resolution.rules.flat_map { |rule| state_classes(rule, slot, definitions[:states]) }
        ].compact
      end

      # Classes for one of the component's parts: the slot's own, those its
      # variants, compounds and `on` rules give it, then `options[:class]`
      # (removed from `options`, as component_classes does).
      def slot_classes(name, options = self.options)
        slots = self.class.variant_definitions[:slots]
        raise ArgumentError, "#{self.class.name || self.class.inspect} has no slot #{name.inspect}" unless slots.key?(name)

        merge_classes(apply_prefix(slots[name]), *variant_classes(name), options.delete(:class))
      end

      # `options` with the slot's classes, to splat into the part.
      def slot_options(name, options = self.options)
        classes = slot_classes(name, options)
        classes ? options.merge(class: classes) : options
      end

      def variant_resolution
        @variant_resolution ||= Resolution.new(self.class, modifiers)
      end

      def variant_member_classes(resolution, slot, definitions)
        if slot == :root
          resolution.implied_members.map { |member| apply_prefix(modifier_map[member]) }
        else
          resolution.active.map { |member| apply_prefix(definitions[:slot_classes].dig(member, slot)) }
        end
      end

      def state_classes(rule, slot, states)
        return [] unless (classes = rule[:class][slot])

        rule[:states].flat_map do |state|
          classes.split.map { |token| "#{states.fetch(state)}:#{apply_prefix(token)}" }
        end
      end
    end
  end
end
