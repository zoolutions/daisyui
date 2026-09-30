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
    # Tailwind groups. Every gem component base class (`btn`, `table`) gets a
    # group of its own and is never dropped, even where Tailwind has a utility
    # of the same name (`table`, `collapse`). App components subclassing
    # DaisyUI::Base get families for their modifiers too.
    #
    # @api private
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

      class << self
        # Class groups for the merger: `{ "daisy:btn-size" => ["btn-xs", ...], ... }`.
        def build(prefix: DaisyUI.configuration.prefix)
          components = self.components
          groups = {}

          gem_components(components).each do |component|
            next unless (base = component.component_class)

            groups["daisy:#{base}"] = ["#{prefix}#{base}"]
          end

          modifier_tokens(components).each_key do |token|
            next unless (group = family_group(token))

            (groups[group] ||= []) << "#{prefix}#{token}"
          end

          groups
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
          !ClassMerge.tailwind_utils.class_group_id(token).nil?
        end

        # { token => [component names] } for every class a component or the
        # configured modifiers can emit.
        def modifier_tokens(components = self.components)
          tokens = Hash.new { |hash, key| hash[key] = [] }

          components.each do |component|
            component.modifiers.each_value do |classes|
              classes.split.each { |token| tokens[token] << component.name }
            end
          end

          DaisyUI.configuration.modifiers.all.each do |classes|
            classes.split.each { |token| tokens[token] << "DaisyUI.configuration" }
          end

          tokens
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

        def descendants(klass)
          klass.subclasses.flat_map { |subclass| [subclass, *descendants(subclass)] }
        end
      end
    end
  end
end
