# frozen_string_literal: true

module DaisyUI
  module Configurable
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
      ClassMerge.reset!
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    class Modifiers
      def initialize
        @modifiers = {}
        @groups = {}
      end

      # `group:` makes the modifier an alternative to the component's other
      # modifiers in that group, e.g. `add(:huge, classes: "btn-xl",
      # component: DaisyUI::Button, group: :size)`.
      def add(modifier, classes:, component: nil, group: nil)
        @modifiers[component] ||= {}
        @modifiers[component][modifier] = classes
        @groups[[component, modifier]] = group
        ClassMerge.reset!
      end

      def remove(modifier, component: nil)
        @modifiers[component] ||= {}
        removed = @modifiers[component]&.delete(modifier)
        @groups.delete([component, modifier])
        ClassMerge.reset!
        removed
      end

      def for(component: nil)
        @modifiers[component] || {}
      end

      # @api private { [component, group] => [classes, ...] } for grouped modifiers.
      def groups
        @groups.each_with_object({}) do |((component, modifier), group), result|
          next unless group

          (result[[component, group]] ||= []) << @modifiers[component][modifier]
        end
      end
    end

    class Configuration
      attr_reader :prefix

      def initialize
        @prefix = nil
      end

      def prefix=(prefix)
        @prefix = prefix
        ClassMerge.reset!
      end

      def class_merge
        @class_merge ||= ClassMerge::Configuration.new
      end

      def modifiers
        @modifiers ||= Modifiers.new
      end
    end
  end
end
