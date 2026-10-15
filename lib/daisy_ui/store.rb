# frozen_string_literal: true

require "monitor"

module DaisyUI
  # @api private Per-Ractor lazy storage for caches that must not live in a
  # class ivar or a constant (the class-merge merger, the Tailwind class
  # groups, the unknown-modifier report log):
  #
  #   DaisyUI::Store.fetch(:daisy_ui_merger) { Merger.new(...) }
  #   DaisyUI::Store.delete(:daisy_ui_merger)
  #
  # Adapted from conformance-kit's ConformanceKit::Store (MIT, same author),
  # which daisyui cannot depend on at runtime, plus `delete`. Every Ractor has
  # its own Monitor-guarded table: reentrant, so an initializer may fetch or
  # delete other keys. On Ruby 3.4+ the table comes from
  # `Ractor.store_if_absent`. Below 3.4 the main Ractor's table is created at
  # load (never lazily, so there is no check-then-set race), and a non-main
  # Ractor keeps its own in Ractor-local storage.
  module Store
    # One Ractor's values. Reads skip the lock once a key is stored.
    class Table
      def initialize
        @monitor = Monitor.new
        @values = {}
      end

      def fetch(key)
        @values.fetch(key) do
          @monitor.synchronize { @values.fetch(key) { @values[key] = yield } }
        end
      end

      def delete(key)
        @monitor.synchronize { @values.delete(key) }
      end
    end

    class << self
      def fetch(key, &init)
        raise ArgumentError, "DaisyUI::Store.fetch(#{key.inspect}) needs an initializer block" unless init

        table.fetch(key, &init)
      end

      def delete(key)
        table.delete(key)
      end

      def main_ractor?
        !defined?(::Ractor) || ::Ractor.current == ::Ractor.main
      end

      def native?
        defined?(::Ractor) ? ::Ractor.respond_to?(:store_if_absent) : false
      end

      private

      def table
        return ::Ractor.store_if_absent(:daisy_ui_store) { Table.new } if native?
        return ::Ractor.current[:daisy_ui_store] ||= Table.new unless main_ractor?

        # Set once below, at load, below Ruby 3.4; only the main Ractor reads it.
        @main_table # rubocop:disable ThreadSafety/ClassInstanceVariable
      end
    end

    @main_table = Table.new unless native?
  end
end
