# frozen_string_literal: true

module DaisyUI
  # Base class for all DaisyUI components.
  #
  # ## Architecture Overview
  #
  # Components accept three types of arguments:
  # 1. **Modifiers** - Positional symbol arguments that map to DaisyUI CSS classes
  #    Example: Dropdown.new(:top, :hover) → "dropdown-top dropdown-hover"
  #
  # 2. **Options** - Keyword arguments for the component (as:, id:)
  #    Example: Dropdown.new(as: :div, id: "my-dropdown")
  #
  # 3. **Attributes** - Additional keyword arguments for HTML attributes (data:, aria:, class:)
  #    Example: Dropdown.new(data: {controller: "dropdown"}, class: "my-custom-class")
  #
  # ## Key Methods
  #
  # - `classes` - Builds the final CSS class string by combining base class,
  #   modifiers, responsive classes, and user-provided classes. DESTRUCTIVELY
  #   removes :class from options.
  #
  # - `attributes` - Returns the hash of HTML attributes to splat into the element.
  #   By default includes all remaining options (after :class was removed) plus :id.
  #   Override in subclasses if different behavior is needed.
  #
  # ## Typical Usage Pattern
  #
  # In a component's view_template:
  #   def view_template(&)
  #     div(class: classes, **attributes, &)
  #   end
  #
  # This renders: <div class="[generated classes]" id="..." data-...="..." ...>
  #
  class Base < Phlex::HTML
    BOOLS = [true, false].freeze
    # Shared color modifiers used across multiple components
    # Maps color names to their DaisyUI background/text class combinations
    COLOR_MODIFIERS = {
      # "sm:bg-primary sm:text-primary-content"
      # "@sm:bg-primary @sm:text-primary-content"
      # "md:bg-primary md:text-primary-content"
      # "@md:bg-primary @md:text-primary-content"
      # "lg:bg-primary lg:text-primary-content"
      # "@lg:bg-primary @lg:text-primary-content"
      primary: "bg-primary text-primary-content",
      # "sm:bg-secondary sm:text-secondary-content"
      # "@sm:bg-secondary @sm:text-secondary-content"
      # "md:bg-secondary md:text-secondary-content"
      # "@md:bg-secondary @md:text-secondary-content"
      # "lg:bg-secondary lg:text-secondary-content"
      # "@lg:bg-secondary @lg:text-secondary-content"
      secondary: "bg-secondary text-secondary-content",
      # "sm:bg-accent sm:text-accent-content"
      # "@sm:bg-accent @sm:text-accent-content"
      # "md:bg-accent md:text-accent-content"
      # "@md:bg-accent @md:text-accent-content"
      # "lg:bg-accent lg:text-accent-content"
      # "@lg:bg-accent @lg:text-accent-content"
      accent: "bg-accent text-accent-content",
      # "sm:bg-neutral sm:text-neutral-content"
      # "@sm:bg-neutral @sm:text-neutral-content"
      # "md:bg-neutral md:text-neutral-content"
      # "@md:bg-neutral @md:text-neutral-content"
      # "lg:bg-neutral lg:text-neutral-content"
      # "@lg:bg-neutral @lg:text-neutral-content"
      neutral: "bg-neutral text-neutral-content",
      # "sm:bg-base-100 sm:text-base-content"
      # "@sm:bg-base-100 @sm:text-base-content"
      # "md:bg-base-100 md:text-base-content"
      # "@md:bg-base-100 @md:text-base-content"
      # "lg:bg-base-100 lg:text-base-content"
      # "@lg:bg-base-100 @lg:text-base-content"
      base_100: "bg-base-100 text-base-content",
      # "sm:bg-base-200 sm:text-base-content"
      # "@sm:bg-base-200 @sm:text-base-content"
      # "md:bg-base-200 md:text-base-content"
      # "@md:bg-base-200 @md:text-base-content"
      # "lg:bg-base-200 lg:text-base-content"
      # "@lg:bg-base-200 @lg:text-base-content"
      base_200: "bg-base-200 text-base-content",
      # "sm:bg-base-300 sm:text-base-content"
      # "@sm:bg-base-300 @sm:text-base-content"
      # "md:bg-base-300 md:text-base-content"
      # "@md:bg-base-300 @md:text-base-content"
      # "lg:bg-base-300 lg:text-base-content"
      # "@lg:bg-base-300 @lg:text-base-content"
      base_300: "bg-base-300 text-base-content",
      # "sm:bg-info sm:text-info-content"
      # "@sm:bg-info @sm:text-info-content"
      # "md:bg-info md:text-info-content"
      # "@md:bg-info @md:text-info-content"
      # "lg:bg-info lg:text-info-content"
      # "@lg:bg-info @lg:text-info-content"
      info: "bg-info text-info-content",
      # "sm:bg-success sm:text-success-content"
      # "@sm:bg-success @sm:text-success-content"
      # "md:bg-success md:text-success-content"
      # "@md:bg-success @md:text-success-content"
      # "lg:bg-success lg:text-success-content"
      # "@lg:bg-success @lg:text-success-content"
      success: "bg-success text-success-content",
      # "sm:bg-warning sm:text-warning-content"
      # "@sm:bg-warning @sm:text-warning-content"
      # "md:bg-warning md:text-warning-content"
      # "@md:bg-warning @md:text-warning-content"
      # "lg:bg-warning lg:text-warning-content"
      # "@lg:bg-warning @lg:text-warning-content"
      warning: "bg-warning text-warning-content",
      # "sm:bg-error sm:text-error-content"
      # "@sm:bg-error @sm:text-error-content"
      # "md:bg-error md:text-error-content"
      # "@md:bg-error @md:text-error-content"
      # "lg:bg-error lg:text-error-content"
      # "@lg:bg-error @lg:text-error-content"
      error: "bg-error text-error-content"
    }.freeze

    class << self
      attr_writer :component_class, :modifier_groups
      attr_accessor :modifiers

      # { group => [modifier, ...] }: modifiers in one group are alternatives
      # (sizes, colors, ...), so ClassMerge keeps only the last one.
      def modifier_groups
        @modifier_groups ||= {}
      end

      def component_class
        return @component_class if instance_variable_defined?(:@component_class)

        @component_class = begin
          # Convert "DaisyUI::Button" -> "button"
          class_name = name.split("::").last # demodulize
          class_name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("_", "-")
            .downcase
        end
      end

      def inherited(subclass)
        super
        subclass.modifiers = (modifiers || {}).dup
        subclass.modifier_groups = modifier_groups.transform_values(&:dup)
        # Inherit component_class if it was explicitly set
        return unless instance_variable_defined?(:@component_class)

        subclass.component_class = @component_class
      end

      # Registers modifiers. A Hash value declares a group of alternatives:
      #
      #   register_modifiers(
      #     size: { sm: "btn-sm", lg: "btn-lg" }, # btn-sm btn-lg merges to btn-lg
      #     wide: "btn-wide"                      # ungrouped, never conflicts
      #   )
      def register_modifiers(mods)
        flat = {}
        mods.each do |key, value|
          if value.is_a?(Hash)
            flat.merge!(value)
          else
            flat[key] = value
          end
        end

        modifier_groups.each_value { |members| members.delete_if { |member| flat.key?(member) } }
        mods.each do |group, value|
          (modifier_groups[group] ||= []).concat(value.keys) if value.is_a?(Hash)
        end
        modifier_groups.delete_if { |_group, members| members.empty? }

        self.modifiers = (modifiers || {}).merge(flat)
        ClassMerge.reset!
      end
    end

    def initialize(*modifiers, as: :div, id: nil, **options)
      # Extract boolean modifiers from options (e.g., primary: true, secondary: false)
      boolean_modifiers = extract_boolean_modifiers(options)

      @modifiers = modifiers + boolean_modifiers
      @as = as
      @id = id
      # Store all keyword arguments (class, data, aria, etc.)
      # This will be processed by `classes` and `attributes` methods
      @options = options
      super()
    end

    private

    attr_reader :modifiers, :options, :as, :id

    # Main extension points - override these in your project!

    # Builds the final CSS class string from:
    # 1. Component base class (e.g., "dropdown")
    # 2. Modifier classes (e.g., "dropdown-top")
    # 3. Responsive classes (e.g., "sm:dropdown-hover")
    # 4. User-provided classes via `class:` option
    #
    # Note: This method DESTRUCTIVELY removes :class from options
    # so it won't appear again in attributes
    def classes
      merge_classes(
        base_class,
        *modifier_classes,
        *responsive_classes,
        options.delete(:class)
      )
    end

    # Returns the hash of HTML attributes to splat into the element.
    # By default, includes all options (except :class which was removed by `classes`)
    # and adds :id if provided.
    #
    # Override this method in subclasses if you need different behavior.
    # For example, Drawer overrides this to exclude :id because it uses
    # id internally for toggle/overlay elements.
    def attributes
      options.dup.merge(id: id).compact
    end

    # Later classes win over earlier conflicting ones (see DaisyUI::ClassMerge),
    # unless `DaisyUI.configure { |c| c.class_merge.enabled = false }`.
    def merge_classes(*parts)
      result = if DaisyUI.configuration.class_merge.enabled
        ClassMerge.merge(*parts)
      else
        parts.compact.join(" ")
      end
      result.empty? ? nil : result
    end

    # Core functionality
    def base_class
      # If responsive option includes `true`, base class should only appear with responsive prefix
      return nil if options[:responsive]&.values&.any? { |mods| Array(mods).include?(true) }

      apply_prefix(self.class.component_class&.to_s)
    end

    def modifier_classes
      modifiers.filter_map { |m| apply_prefix(modifier_map[m]) }
    end

    def responsive_classes
      return [] unless (resp = options.delete(:responsive))

      resp.flat_map do |breakpoint, mods|
        Array(mods).flat_map do |mod|
          # Handle `true` as a special value to apply responsive to base class
          if mod == true
            base_class_value = self.class.component_class
            next unless base_class_value

            "#{breakpoint}:#{apply_prefix(base_class_value.to_s)}"
          else
            # Get the modifier classes (may be multiple like "bg-primary text-primary-content")
            modifier_classes = modifier_map[mod]
            next unless modifier_classes

            # Split and apply breakpoint prefix to each class
            modifier_classes.split.map do |css_class|
              "#{breakpoint}:#{apply_prefix(css_class)}"
            end
          end
        end
      end.compact
    end

    def modifier_map
      {
        skeleton: "skeleton",
        **(self.class.modifiers || {}),
        **DaisyUI.configuration.modifiers.for(component: self.class),
        **DaisyUI.configuration.modifiers.for(component: nil)
      }
    end

    def extract_boolean_modifiers(options)
      modifier_keys = modifier_map.keys
      boolean_mods = []

      modifier_keys.each do |key|
        boolean_mods << key if options.key?(key) && BOOLS.include?(options[key]) && (options.delete(key) == true)
      end

      boolean_mods
    end

    def apply_prefix(css_class)
      return css_class unless css_class
      return css_class unless (prefix = DaisyUI.configuration.prefix)

      css_class.split.map { |c| "#{prefix}#{c}" }.join(" ")
    end

    # Helper for sub-components
    # Builds CSS classes for sub-components, merging with any custom classes
    def component_classes(*base_classes, options: self.options)
      prefixed_classes = base_classes.map { |c| apply_prefix(c) }
      merge_classes(*prefixed_classes, options.delete(:class))
    end

    def render_as(*, as:, **, &)
      if as.is_a?(Symbol)
        public_send(as, *, **, &)
      else
        render as.new(*, **, &)
      end
    end
  end
end
