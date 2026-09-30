# frozen_string_literal: true

require "monitor"

module DaisyUI
  # Merges CSS class lists so that later classes win over earlier conflicting
  # ones, for Tailwind utilities and daisyUI modifiers alike:
  #
  #   DaisyUI::ClassMerge.merge("btn btn-sm", "btn-lg px-2", "px-4")
  #   # => "btn btn-lg px-4"
  #
  # The Tailwind engine is a port of tailwind_merge (see TAILWIND_MERGE_VERSION);
  # daisyUI groups come from DaisyGroups. The public surface is `merge` and
  # `DaisyUI.configure { |c| c.class_merge }`; `Merger.new(config:)` takes a raw
  # tailwind_merge config for an isolated instance. Everything else is internal.
  module ClassMerge
    TAILWIND_MERGE_VERSION = "1.5.6"

    # Reentrant, so a reset! triggered while the merger is being built (e.g. a
    # component file configuring DaisyUI as it loads) cannot deadlock.
    @monitor = Monitor.new

    class << self
      # Accepts strings, nested arrays, nil and false (dropped, as Phlex does
      # for `class:`). Returns a frozen String, "" when empty.
      def merge(*parts)
        merger.merge(parts.flatten.select(&:itself).join(" "))
      end

      def merger
        @merger || @monitor.synchronize do
          @merger ||= Merger.new(config: DaisyUI.configuration.class_merge.merger_config)
        end
      end

      # @api private The stock Tailwind class groups, for classifying tokens.
      def tailwind_utils
        @tailwind_utils ||= ClassGroupUtils.new(TailwindConfig::DEFAULTS)
      end

      # Drops the memoized merger so the next merge picks up configuration changes.
      def reset!
        @monitor.synchronize { @merger = nil }
      end
    end
  end
end
