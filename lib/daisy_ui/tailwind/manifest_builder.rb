# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Builds data/daisyui/tailwind_manifest.json from the components
    # themselves (`bundle exec rake tailwind:manifest`); the manifest spec
    # fails while the committed file differs. Per component:
    #
    # - `classes`: its component class (a Symbol Tailwind cannot see), its
    #   registered modifiers and the class words in its Ruby's strings
    # - `modifiers`: the registered modifier classes, which `responsive:`
    #   can prefix with a breakpoint
    # - `depends_on`: the other components its code references
    #
    # @api private
    module ManifestBuilder
      SCHEMA = 1
      SHARED_FILE = "lib/daisy_ui/base.rb"

      class << self
        def build(root: ROOT)
          components = gem_components(File.join(root, "lib", "daisy_ui"))
          names = components.map(&:first)
          {
            "schema" => SCHEMA,
            "shared" => shared(root),
            "components" => components.to_h { |name, klass, file| [name, entry(klass, file:, names:, root:)] }
          }
        end

        def generate(root: ROOT)
          require "json"

          "#{JSON.pretty_generate(build(root:))}\n"
        end

        def write(path = MANIFEST_PATH, root: ROOT)
          json = generate(root:)
          File.write(path, json) unless File.exist?(path) && File.read(path) == json
          path
        end

        def entry(klass, file:, names:, root:)
          source = File.read(file)
          name = klass.component_class&.to_s
          modifiers = modifier_classes(klass)
          {
            "class" => klass.name,
            "name" => name,
            "files" => [file.delete_prefix("#{root}/")],
            "depends_on" => ((Lexer.constants(source) & names) - [short_name(klass)]).sort,
            "modifiers" => modifiers,
            "classes" => ([name, *modifiers].compact | Candidate.tokens(Lexer.strings(source).join(" "))).sort
          }
        end

        private

        # The gem's own components, by short name: a DaisyUI:: class defined
        # in a file under lib/daisy_ui (not one a spec or an app defined).
        def gem_components(lib)
          ClassMerge::DaisyGroups.gem_components.filter_map do |klass|
            file = Object.const_source_location(klass.name)&.first
            [short_name(klass), klass, file] if file&.start_with?("#{lib}/")
          end.sort_by(&:first)
        end

        def shared(root)
          source = File.read(File.join(root, SHARED_FILE))
          { "files" => [SHARED_FILE], "classes" => Candidate.tokens(Lexer.strings(source).join(" ")).uniq.sort }
        end

        def modifier_classes(klass)
          classes = (klass.modifiers || {}).values.flat_map { |value| value.to_s.split }.uniq.sort
          invalid = classes.reject { |token| Candidate.valid?(token) }
          return classes if invalid.empty?

          raise ArgumentError, "#{klass.name} registers #{invalid.map(&:inspect).join(', ')}, " \
                               "which Tailwind cannot read from @source inline(…)"
        end

        def short_name(klass) = klass.name.split("::").last
      end
    end
  end
end
