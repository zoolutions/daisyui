# frozen_string_literal: true

module DaisyUI
  module ClassMerge
    # Builds merger class groups from the modifier groups components declare:
    #
    #   register_modifiers(size: { sm: "btn-sm", lg: "btn-lg" })
    #
    # gives the group `daisy:group:btn-size` = ["btn-sm", "btn-lg"], so
    # `btn-sm btn-lg` merges to `btn-lg`. Ungrouped modifiers never conflict.
    #
    # A group holds only the component's own `<component_class>-*` classes.
    # Tokens Tailwind already classifies (`bg-primary text-primary-content`)
    # are left to the Tailwind groups, which resolve them per utility. Any
    # other class (a plugin utility such as `motion-duration-[400ms]`) is left
    # ungrouped, as a flag is: a group would make the classes of one member
    # knock each other out. A component without a component_class groups
    # nothing of its own.
    #
    # Every gem component base class (`btn`, `table`) also gets a group of its
    # own and is never dropped, even where Tailwind has a utility of the same
    # name (`table`, `collapse`).
    #
    # @api private
    module DaisyGroups
      class << self
        # Class groups for the merger: `{ "daisy:group:btn-size" => ["btn-xs", ...], ... }`,
        # from one configuration's prefix and modifiers.
        def build(configuration = DaisyUI.configuration, prefix: configuration.prefix)
          components = self.components
          groups = {}

          gem_components(components).each do |component|
            next unless (base = component.component_class)

            groups["daisy:base:#{base}"] = ["#{prefix}#{base}"]
          end

          components.each do |component|
            component.modifier_groups.each do |group, members|
              tokens = members.flat_map { |member| component.modifiers[member].to_s.split }
              add(groups, "daisy:group:#{component.component_class || component.name}-#{group}", own(tokens, component), prefix)
            end
          end

          # Configured modifiers join the component's own group of that name.
          # A global one has no component to own its classes: all are grouped.
          configuration.modifiers.groups.each do |(component, group), classes|
            owner = component ? component.component_class || component.name : "global"
            tokens = classes.flat_map(&:split)
            add(groups, "daisy:group:#{owner}-#{group}", component ? own(tokens, component) : tokens, prefix)
          end

          groups
        end

        def tailwind_class?(token)
          !ClassMerge.tailwind_utils.class_group_id(token).nil?
        end

        # Every named DaisyUI::Base subclass: the gem's components (eager
        # loaded) and any app component loaded so far. An app component that
        # loads later resets the merger through `register_modifiers`. Only the
        # main Ractor can eager-load; DaisyUI.finalize! did it there before
        # any other Ractor builds a merger.
        def components
          Zeitwerk::Loader.eager_load_namespace(DaisyUI) if Store.main_ractor?
          descendants(DaisyUI::Base).select(&:name)
        end

        # Only the gem's own base classes are protected: an app component's
        # derived name (`UI::Grid` -> "grid") may well be a Tailwind utility.
        def gem_components(components = self.components)
          components.select { |component| component.name.start_with?("DaisyUI::") }
        end

        private

        # The component's own modifier classes: `btn-sm` for `btn`.
        def own(tokens, component)
          return [] unless (base = component.component_class)

          tokens.select { |token| token.start_with?("#{base}-") }
        end

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
