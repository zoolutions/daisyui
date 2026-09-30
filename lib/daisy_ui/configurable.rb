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
      end

      def add(modifier, classes:, component: nil)
        @modifiers[component] ||= {}
        @modifiers[component][modifier] = classes
        ClassMerge.reset!
      end

      def remove(modifier, component: nil)
        @modifiers[component] ||= {}
        removed = @modifiers[component]&.delete(modifier)
        ClassMerge.reset!
        removed
      end

      def for(component: nil)
        @modifiers[component] || {}
      end

      # Every class string registered, for any component.
      def all
        @modifiers.values.flat_map(&:values)
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
