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
      UNKNOWN_MODIFIER_MODES = %i[raise warn ignore].freeze

      attr_reader :prefix

      def initialize
        @prefix = nil
        @reported_unknown_modifiers = Set.new
      end

      # What a component does with a positional modifier it does not know:
      # :raise, :warn (once per component and modifier), :ignore, or a callable
      # that receives the DaisyUI::UnknownModifierError (once per component and
      # modifier), e.g. `->(error) { Appsignal.report_error(error) }`.
      #
      # Defaults to :raise under Rails in development and test, :warn otherwise.
      def unknown_modifiers
        @unknown_modifiers || default_unknown_modifiers
      end

      def unknown_modifiers=(mode)
        valid = mode.nil? || mode.respond_to?(:call) || UNKNOWN_MODIFIER_MODES.include?(mode)
        raise ArgumentError, "unknown_modifiers must be :raise, :warn, :ignore or a callable, got #{mode.inspect}" unless valid

        @unknown_modifiers = mode
      end

      # @api private
      def report_unknown_modifier(error)
        mode = unknown_modifiers
        raise error if mode == :raise
        return if mode == :ignore
        return unless @reported_unknown_modifiers.add?([error.component, error.modifier])

        mode == :warn ? warn("[DaisyUI] #{error.message}") : mode.call(error)
      end

      # @api private
      def reset_reported_unknown_modifiers!
        @reported_unknown_modifiers.clear
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

      private

      def default_unknown_modifiers
        return :warn unless defined?(::Rails) && ::Rails.respond_to?(:env)

        %w[development test].include?(::Rails.env.to_s) ? :raise : :warn
      end
    end
  end
end
