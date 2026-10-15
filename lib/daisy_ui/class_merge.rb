# frozen_string_literal: true

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

    # The merger (with its LRU) and the Tailwind class groups live in
    # DaisyUI::Store: one per Ractor, built on first use under the store's
    # reentrant lock, so a reset! triggered while the merger is being built
    # (e.g. a component file configuring DaisyUI as it loads) cannot deadlock.
    class << self
      # Accepts strings, nested arrays, nil and false (dropped, as Phlex does
      # for `class:`). Returns a frozen String, "" when empty.
      def merge(*parts)
        merger.merge(parts.flatten.select(&:itself).join(" "))
      end

      # Each Ractor's merger remembers the configuration it was built from
      # and is rebuilt once DaisyUI.configure publishes another, also in a
      # Ractor where reset! never ran.
      def merger
        configuration = DaisyUI.configuration
        built_for, merger = Store.fetch(:daisy_ui_class_merger) { build_merger(configuration) }
        return merger if built_for.equal?(configuration)

        Store.delete(:daisy_ui_class_merger)
        Store.fetch(:daisy_ui_class_merger) { build_merger(configuration) }.last
      end

      # @api private The stock Tailwind class groups, for classifying tokens.
      def tailwind_utils
        Store.fetch(:daisy_ui_tailwind_utils) { ClassGroupUtils.new(TailwindConfig::DEFAULTS) }
      end

      # Drops the current Ractor's merger so its next merge picks up
      # configuration changes.
      def reset!
        Store.delete(:daisy_ui_class_merger)
      end

      private

      def build_merger(configuration)
        [configuration, Merger.new(config: configuration.class_merge.merger_config)]
      end
    end
  end
end
