# frozen_string_literal: true

module DaisyUI
  # Tailwind CSS sources for only the daisyUI components an app renders.
  #
  # Pointing Tailwind's `@source` at the whole gem hands it every class of
  # every component (and ClassMerge's catalogue of Tailwind utilities), yet
  # still misses what Tailwind v4 cannot see in Ruby: a Symbol component class
  # (`self.component_class = :btn`) and anything in a comment. The gem's
  # manifest (data/daisyui/tailwind_manifest.json, built from the components by
  # `rake tailwind:manifest`) lists each component's classes and the
  # components it renders, so an app's CSS build gets `@source inline(…)` for
  # just the components it uses:
  #
  #   DaisyUI::Tailwind.sources(scan: ["app/views", "app/components"])
  #   DaisyUI::Tailwind.sources(components: %w[Button Navbar], format: :json)
  #
  # `bundle exec daisyui-tailwind` (DaisyUI::Tailwind::Command) does the same
  # from a build script.
  module Tailwind
    ROOT = File.expand_path("../..", __dir__).freeze
    # In the gem's data/ dir, not lib/: an app that still points Tailwind at
    # the gem's lib/ must not start scanning it.
    MANIFEST_PATH = File.join(ROOT, "data", "daisyui", "tailwind_manifest.json").freeze

    class << self
      def manifest = Manifest.load

      # The components the Ruby and templates under `scan` reference, plus the
      # `components` named, plus every component those render. Sorted names.
      def used_components(scan: [], components: [], manifest: self.manifest)
        found = scan.empty? ? [] : Usage.new(manifest.component_names).scan(scan)
        manifest.resolve(found + components)
      end

      # CSS (`format: :css`, for Tailwind to @import) or JSON for those
      # components. `responsive:` adds breakpoint variants (`%w[sm md]`) of the
      # classes `responsive:` renders; `prefix:` defaults to the
      # DaisyUI.configuration.prefix the components render with.
      #
      # `app: true` gives the app's own components instead (app_components),
      # or `app: [Widget, …]` the ones named: see AppSources. Their file is
      # separate from the gem components' and meant to be committed.
      def sources(scan: [], components: [], app: false, format: :css, responsive: [], prefix: DaisyUI.configuration.prefix)
        return app_sources(app, scan:, components:).new(app == true ? app_components : app, responsive:, prefix:).render(format) if app

        manifest = self.manifest
        used = used_components(scan:, components:, manifest:)
        Sources.new(manifest, used, responsive:, prefix:).render(format)
      end

      # The app's DaisyUI::Base subclasses, sorted by name: every named one
      # defined outside the gem's lib/ whose constant still names it (a class
      # a code reload replaced is skipped). A Rails app is eager-loaded first.
      def app_components
        ::Rails.application.eager_load! if defined?(::Rails) && ::Rails.respond_to?(:application) && ::Rails.application
        gem_lib = File.join(ROOT, "lib", "")
        ClassMerge::DaisyGroups.components.select do |component|
          current?(component) && !Object.const_source_location(component.name)&.first.to_s.start_with?(gem_lib)
        end.sort_by(&:name)
      end

      # Whether the committed app sources at `path` differ from what the
      # declarations give now (or the file is missing): a spec can fail on it,
      # the way the gem's own manifest spec does.
      def stale?(path, app: true, **)
        !File.file?(path) || File.read(path) != sources(app:, **)
      end

      private

      def app_sources(app, scan:, components:)
        return AppSources if scan.empty? && components.empty?

        raise ArgumentError, "app: gives the app's own components, a file of its own; " \
                             "scan: and components: give the gem's (#{app.inspect} with #{(scan + components).inspect})"
      end

      def current?(component)
        Object.const_get(component.name).equal?(component)
      rescue NameError
        false
      end
    end
  end
end
