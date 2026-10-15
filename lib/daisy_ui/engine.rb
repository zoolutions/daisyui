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
    # The minified controllers config/importmap.rb pins, and their sourcemaps.
    MINIFIED_ASSETS = Dir[JAVASCRIPT_PATH.join("daisy_ui/controllers/*.min.js{,.map}").to_s]
      .map { |path| Pathname.new(path).relative_path_from(JAVASCRIPT_PATH).to_s }.sort.freeze

    initializer "daisy_ui.assets" do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.paths << JAVASCRIPT_PATH.to_s
      # Sprockets compiles only what is listed; Propshaft compiles every file in
      # paths. The list is nil unless Sprockets or another engine created it,
      # and OrderedOptions answers respond_to? for any name, so check the value.
      precompile = app.config.assets.precompile
      precompile.concat(MINIFIED_ASSETS) if precompile.is_a?(Array)
    end

    # Once the app's initializers have configured DaisyUI, freeze the
    # configuration and component registries so a non-main Ractor can merge
    # classes. DaisyUI.configure keeps working afterwards, on a copy.
    config.after_initialize { DaisyUI.finalize! }

    initializer "daisy_ui.importmap", before: "importmap" do |app|
      next unless app.config.respond_to?(:importmap)

      importmap = app.config.importmap
      importmap.paths << root.join("config/importmap.rb") if importmap.respond_to?(:paths)
      # Reload the gem's controller in development when it changes.
      importmap.cache_sweepers << JAVASCRIPT_PATH if importmap.respond_to?(:cache_sweepers)
    end
  end
end
