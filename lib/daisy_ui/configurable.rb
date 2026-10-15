# frozen_string_literal: true

module DaisyUI
  module Configurable
    # Created when DaisyUI extends this module, at load, so `configuration` is
    # a plain read with no check-then-set race.
    def self.extended(base)
      base.instance_variable_set(:@configuration, Configuration.new)
    end

    # Yields the configuration. After finalize! it yields a writable copy,
    # swaps it in and finalizes it, so configure never meets a frozen object.
    def configure
      finalized = configuration.frozen?
      @configuration = configuration.dup if finalized
      yield(configuration) if block_given?
      ClassMerge.reset!
      finalize! if finalized
      configuration
    end

    def configuration
      @configuration
    end

    # Freezes what a non-main Ractor reads (this configuration and every
    # component's registries) so DaisyUI::ClassMerge.merge runs in any Ractor.
    # The Rails engine calls it once the app has booted; without Rails, call
    # it at the end of boot, after configure. Afterwards change settings only
    # through configure: writing to the frozen configuration raises.
    def finalize!
      ClassMerge::DaisyGroups.components.each(&:finalize!)
      configuration.finalize!
      ClassMerge.tailwind_utils
      self
    end

    class Modifiers
      def initialize
        @modifiers = {}
        @groups = {}
      end

      def initialize_copy(source)
        super
        @modifiers = @modifiers.transform_values(&:dup)
        @groups = @groups.dup
      end

      # @api private Called by DaisyUI.finalize!.
      def finalize!
        Shareable.make(@modifiers)
        Shareable.make(@groups)
        freeze
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
      end

      def initialize_copy(source)
        super
        @class_merge = @class_merge&.dup
        @modifiers = @modifiers&.dup
      end

      # @api private Called by DaisyUI.finalize!. A callable unknown_modifiers
      # that cannot be made shareable (it closes over unshareable state) is
      # kept: the configuration is then frozen but readable on the main
      # Ractor only.
      def finalize!
        class_merge.finalize!
        modifiers.finalize!
        Shareable.make(@prefix)
        share(@unknown_modifiers)
        freeze
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
        reported_unknown_modifiers.clear
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

      def first_report?(key)
        reported_unknown_modifiers.first?(key)
      end

      # What was already reported lives per Ractor, outside the configuration,
      # which stays shareable.
      def reported_unknown_modifiers
        Store.fetch(:daisy_ui_reported_unknown_modifiers) { ReportLog.new(REPORTED_UNKNOWN_MODIFIERS_LIMIT) }
      end

      def share(callable)
        Shareable.make(callable) if callable.is_a?(Proc)
      rescue ::Ractor::IsolationError, ArgumentError
        nil
      end

      def default_unknown_modifiers
        return :warn unless defined?(::Rails) && ::Rails.respond_to?(:env)

        %w[development test].include?(::Rails.env.to_s) ? :raise : :warn
      end
    end
  end
end
