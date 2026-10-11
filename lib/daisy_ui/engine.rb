# frozen_string_literal: true

module DaisyUI
  # Optional Rails integration. Loaded only when Rails::Engine is defined (see
  # lib/daisy_ui.rb), so the gem stays a plain Phlex library outside Rails.
  #
  # It exposes the gem's bundled Stimulus controllers (`daisy-dropdown`,
  # `daisy-tooltip`) to the host app:
  #   * adds config/importmap.rb to importmap-rails' paths, which pins each
  #     `daisy_ui/controllers/<name>` to its minified build (no manual pin);
  #   * appends the JS dir to the asset load path so Propshaft/Sprockets serve
  #     the .min.js and its sourcemap (Sprockets also needs them precompiled).
  #
  # The controllers are opt-in at the markup level (`Dropdown(:popover, stimulus:
  # true)`, `Tooltip(:popover)`) and not preloaded, so a page that never uses
  # one never fetches it.
  # Asset-only engine: no isolate_namespace, since it exposes no routes, models,
  # or helpers — only static JavaScript — and namespacing would risk surprises in
  # the host app for no benefit.
  class Engine < ::Rails::Engine
    JAVASCRIPT_PATH = root.join("app/javascript")
    # The files config/importmap.rb pins, and their sourcemaps.
    MINIFIED_ASSETS = %w[daisy_dropdown_controller daisy_tooltip_controller].flat_map do |name|
      ["daisy_ui/controllers/#{name}.min.js", "daisy_ui/controllers/#{name}.min.js.map"]
    end.freeze

    initializer "daisy_ui.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << JAVASCRIPT_PATH.to_s
      # Sprockets compiles only what is listed. Propshaft has no precompile
      # list (it compiles every file in paths), and its OrderedOptions answers
      # respond_to? for any name, so check the value.
      precompile = app.config.assets.precompile
      precompile.concat(MINIFIED_ASSETS) if precompile.is_a?(Array)
    end

    initializer "daisy_ui.importmap", before: "importmap" do |app|
      next unless app.config.respond_to?(:importmap)

      importmap = app.config.importmap
      importmap.paths << root.join("config/importmap.rb") if importmap.respond_to?(:paths)
      # Reload the gem's controller in development when it changes.
      importmap.cache_sweepers << JAVASCRIPT_PATH if importmap.respond_to?(:cache_sweepers)
    end
  end
end
