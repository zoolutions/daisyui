# frozen_string_literal: true

module DaisyUI
  # Merges CSS class lists so that later classes win over earlier conflicting
  # ones, for Tailwind utilities and daisyUI modifiers alike:
  #
  #   DaisyUI::ClassMerge.merge("btn btn-sm", "btn-lg px-2", "px-4")
  #   # => "btn btn-lg px-4"
  #
  # The Tailwind engine is a port of tailwind_merge (see TAILWIND_MERGE_VERSION);
  # daisyUI groups come from DaisyGroups.
  module ClassMerge
    TAILWIND_MERGE_VERSION = "1.5.6"

    @mutex = Mutex.new

    class << self
      # Accepts strings, arrays and nils. Returns a frozen String, "" when empty.
      def merge(*parts)
        merger.merge(parts.flatten.compact.join(" "))
      end

      def merger
        @merger || @mutex.synchronize do
          @merger ||= Merger.new(config: DaisyUI.configuration.class_merge.merger_config)
        end
      end

      # Drops the memoized merger so the next merge picks up configuration changes.
      def reset!
        @mutex.synchronize { @merger = nil }
      end
    end
  end
end
