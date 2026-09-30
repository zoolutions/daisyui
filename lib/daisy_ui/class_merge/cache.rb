# frozen_string_literal: true

require "monitor"

module DaisyUI
  module ClassMerge
    # Thread-safe LRU cache. Ruby hashes keep insertion order, so re-inserting
    # a key on every hit moves it to the end and the first key is always the
    # least recently used one.
    class Cache
      def initialize(max_size)
        @max_size = max_size
        @data = {}
        @monitor = Monitor.new
      end

      # Returns the cached value for key, or stores and returns the block's
      # result. A nil result is not stored.
      def getset(key)
        @monitor.synchronize do
          if @data.key?(key)
            value = @data.delete(key)
            @data[key] = value
            return value
          end

          value = yield
          return value if value.nil?

          @data.shift if @data.size >= @max_size
          @data[key] = value
        end
      end

      def size
        @monitor.synchronize { @data.size }
      end
    end
  end
end
