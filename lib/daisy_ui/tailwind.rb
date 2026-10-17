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
      def sources(scan: [], components: [], format: :css, responsive: [], prefix: DaisyUI.configuration.prefix)
        manifest = self.manifest
        used = used_components(scan:, components:, manifest:)
        Sources.new(manifest, used, responsive:, prefix:).render(format)
      end
    end
  end
end
