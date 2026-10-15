# frozen_string_literal: true

module DaisyUI
  # @api private Deep-freezes a value so a non-main Ractor can read it from a
  # constant or a class ivar: `Ractor.make_shareable`, or, on engines without
  # Ractor (JRuby, TruffleRuby), a walk freezing Hash values and Array elements.
  module Shareable
    class << self
      # For the gem's own literals, which must all be shareable: raises if one
      # is not.
      def make(value)
        ractor? ? ::Ractor.make_shareable(value) : deep_freeze(value)
      end

      # For what an app configures. Freezes Hashes, Arrays and Strings all the
      # way down, makes a capture-free Proc shareable, and keeps anything else
      # (a Proc that closes over app state, a logger) as it is, so whatever
      # holds it is readable on the main Ractor only. Never raises, and never
      # hands an object it does not know to Ractor.make_shareable, which
      # freezes as it goes and would leave a logger frozen before failing.
      def share(value)
        case value
        when Hash
          value.each do |key, member|
            share(key)
            share(member)
          end.freeze
        when Array then value.each { |member| share(member) }.freeze
        when String then value.freeze
        when Proc then share_proc(value)
        else value
        end
      end

      def ractor?
        defined?(::Ractor) ? ::Ractor.respond_to?(:make_shareable) : false
      end

      private

      def share_proc(callable)
        ractor? ? ::Ractor.make_shareable(callable) : callable
      rescue ::Ractor::Error, ArgumentError
        callable
      end

      def deep_freeze(value)
        case value
        when Hash then value.each_value { |member| deep_freeze(member) }
        when Array then value.each { |member| deep_freeze(member) }
        end
        value.freeze
      end
    end
  end
end
