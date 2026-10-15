# frozen_string_literal: true

module DaisyUI
  # @api private Deep-freezes a value so a non-main Ractor can read it from a
  # constant or a class ivar: `Ractor.make_shareable`, or, on engines without
  # Ractor (JRuby, TruffleRuby), a walk freezing Hash values and Array elements.
  module Shareable
    class << self
      def make(value)
        ractor? ? ::Ractor.make_shareable(value) : deep_freeze(value)
      end

      def ractor?
        defined?(::Ractor) ? ::Ractor.respond_to?(:make_shareable) : false
      end

      private

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
