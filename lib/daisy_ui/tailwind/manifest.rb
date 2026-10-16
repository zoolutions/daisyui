# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # The committed tailwind_manifest.json: per component (by short name, "Button"),
    # its class, daisyUI name, files, the components it renders and its
    # classes; `shared` is base.rb, which every component draws on. The JSON
    # is the contract for build scripts in other languages, so its keys are
    # documented in the README.
    class Manifest
      def self.load(path = MANIFEST_PATH, root: ROOT)
        require "json"

        new(JSON.parse(File.read(path)), root:)
      end

      attr_reader :components, :shared, :root

      def initialize(data, root: ROOT)
        @components = data.fetch("components")
        @shared = data.fetch("shared")
        @root = root
      end

      def component_names = components.keys

      # `names` ("Button" or "DaisyUI::Button") plus every component they
      # render, transitively. Sorted.
      def resolve(names)
        resolved = []
        pending = names.map { |name| canonical(name) }
        until pending.empty?
          name = pending.pop
          next if resolved.include?(name)

          resolved << name
          pending.concat(components.fetch(name)["depends_on"])
        end
        resolved.sort
      end

      # Absolute paths of the components' files, for a literal `@source`.
      def files(names) = names.flat_map { |name| absolute(components.fetch(name)["files"]) }

      def shared_files = absolute(shared["files"])

      private

      def canonical(name)
        short = name.to_s.delete_prefix("DaisyUI::")
        return short if components.key?(short)

        raise UnknownComponentError.new(name, component_names)
      end

      def absolute(paths) = paths.map { |path| File.join(root, path) }
    end
  end
end
