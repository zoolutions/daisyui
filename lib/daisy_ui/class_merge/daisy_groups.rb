# frozen_string_literal: true

module DaisyUI
  module ClassMerge
    # Builds merger class groups from the modifier groups components declare:
    #
    #   register_modifiers(size: { sm: "btn-sm", lg: "btn-lg" })
    #
    # gives the group `daisy:group:btn-size` = ["btn-sm", "btn-lg"], so
    # `btn-sm btn-lg` merges to `btn-lg`. Ungrouped modifiers never conflict.
    # Tokens Tailwind already classifies (`bg-primary text-primary-content`)
    # are left to the Tailwind groups, which resolve them per utility.
    #
    # Every gem component base class (`btn`, `table`) also gets a group of its
    # own and is never dropped, even where Tailwind has a utility of the same
    # name (`table`, `collapse`).
    #
    # @api private
    module DaisyGroups
      class << self
        # Class groups for the merger: `{ "daisy:group:btn-size" => ["btn-xs", ...], ... }`.
        def build(prefix: DaisyUI.configuration.prefix)
          components = self.components
          groups = {}

          gem_components(components).each do |component|
            next unless (base = component.component_class)

            groups["daisy:base:#{base}"] = ["#{prefix}#{base}"]
          end

          components.each do |component|
            component.modifier_groups.each do |group, members|
              tokens = members.flat_map { |member| component.modifiers[member].to_s.split }
              add(groups, "daisy:group:#{component.component_class || component.name}-#{group}", tokens, prefix)
            end
          end

          # Configured modifiers join the component's own group of that name.
          DaisyUI.configuration.modifiers.groups.each do |(component, group), classes|
            owner = component ? component.component_class || component.name : "global"
            add(groups, "daisy:group:#{owner}-#{group}", classes.flat_map(&:split), prefix)
          end

          groups
        end

        def tailwind_class?(token)
          !ClassMerge.tailwind_utils.class_group_id(token).nil?
        end

        # Every named DaisyUI::Base subclass: the gem's components (eager
        # loaded) and any app component loaded so far. An app component that
        # loads later resets the merger through `register_modifiers`.
        def components
          Zeitwerk::Loader.eager_load_namespace(DaisyUI)
          descendants(DaisyUI::Base).select(&:name)
        end

        # Only the gem's own base classes are protected: an app component's
        # derived name (`UI::Grid` -> "grid") may well be a Tailwind utility.
        def gem_components(components = self.components)
          components.select { |component| component.name.start_with?("DaisyUI::") }
        end

        private

        # Subclasses share their parent's component_class and group names, so
        # their tokens land in the same group id and are unioned.
        def add(groups, id, tokens, prefix)
          tokens = tokens.reject { |token| tailwind_class?(token) }.map { |token| "#{prefix}#{token}" }
          return if tokens.empty?

          groups[id] = (groups[id] || []) | tokens
        end

        def descendants(klass)
          klass.subclasses.flat_map { |subclass| [subclass, *descendants(subclass)] }
        end
      end
    end
  end
end
