# frozen_string_literal: true

module DaisyUI
  module Configurable
    # @api private The unknown modifiers already reported, so :warn and a
    # callable fire once per key. Remembers up to `limit` keys, then starts
    # over, so modifiers built from user input cannot grow it without bound.
    # One per Ractor (DaisyUI::Store), so its Mutex is never shared.
    class ReportLog
      def initialize(limit)
        @limit = limit
        @keys = Set.new
        @lock = Mutex.new
      end

      # True the first time a key is seen.
      def first?(key)
        @lock.synchronize do
          return false if @keys.include?(key)

          @keys.clear if @keys.size >= @limit
          @keys.add(key)
          true
        end
      end

      def clear
        @lock.synchronize { @keys.clear }
      end

      def size
        @lock.synchronize { @keys.size }
      end
    end
  end
end
