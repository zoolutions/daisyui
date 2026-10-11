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
      REPORTED_UNKNOWN_MODIFIERS_LIMIT = 1_000

      attr_reader :prefix

      def initialize
        @prefix = nil
        @reported_unknown_modifiers = Set.new
        @reported_unknown_modifiers_lock = Mutex.new
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

      # @api private Builds the error only when it will be raised or reported.
      def report_unknown_modifier(component:, modifier:, known:, part: nil)
        mode = unknown_modifiers
        return if mode == :ignore

        error = -> { UnknownModifierError.new(component:, modifier:, known:, part:) }
        raise error.call if mode == :raise
        return unless first_report?([component, part, modifier])

        mode == :warn ? warn("[DaisyUI] #{error.call.message}") : mode.call(error.call)
      end

      # @api private
      def reset_reported_unknown_modifiers!
        @reported_unknown_modifiers_lock.synchronize { @reported_unknown_modifiers.clear }
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

      # Remembers up to REPORTED_UNKNOWN_MODIFIERS_LIMIT keys, then starts over,
      # so modifiers built from user input cannot grow it without bound.
      def first_report?(key)
        @reported_unknown_modifiers_lock.synchronize do
          return false if @reported_unknown_modifiers.include?(key)

          @reported_unknown_modifiers.clear if @reported_unknown_modifiers.size >= REPORTED_UNKNOWN_MODIFIERS_LIMIT
          @reported_unknown_modifiers.add(key)
          true
        end
      end

      def default_unknown_modifiers
        return :warn unless defined?(::Rails) && ::Rails.respond_to?(:env)

        %w[development test].include?(::Rails.env.to_s) ? :raise : :warn
      end
    end
  end
end
