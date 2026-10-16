# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Finds the components an app's Ruby and templates reference:
    #
    # - the constant: `DaisyUI::Card`, `class AppNavbar < DaisyUI::Navbar`
    # - an instance: `Card.new(…)`
    # - a kit call, with parentheses (`Button(:primary)`) or without
    #   (`Badge :primary do`, `Hero do`, `Modal { … }`, `Toast class: "…"`)
    #
    # Full-line comments are skipped, so "# Loading state…" is not a use of
    # Loading. A name is matched whole: `MyButton(` and `UI::Card(` are not
    # uses (an app wrapper `UI::Card < DaisyUI::Card` is found by its own
    # file). Matching on text over-reports rather than misses: a false hit
    # costs some CSS, a miss leaves a component unstyled.
    class Usage
      EXTENSIONS = %w[rb erb haml slim].freeze
      COMMENT = /^[ \t]*#.*$/
      CALL = /\(|\.new\b|[ \t]+do\b|[ \t]*\{|[ \t]+:[a-z_]|[ \t]+[a-z_]\w*:[ \t]/

      def initialize(names)
        names = names.sort_by { |name| -name.length }.map { |name| Regexp.escape(name) }.join("|")
        @pattern = /DaisyUI::(#{names})\b|(?<![A-Za-z0-9_:])(#{names})(?=#{CALL})/
      end

      # Sorted names referenced in the files under `paths` (directories or
      # files). A path that does not exist raises: a typo must not quietly
      # leave every component out.
      def scan(paths)
        files(paths).flat_map { |file| references(File.read(file).scrub) }.uniq.sort
      end

      def references(source)
        source.gsub(COMMENT, "").scan(@pattern).flat_map(&:compact).uniq.sort
      end

      private

      def files(paths)
        paths.flat_map do |path|
          path = path.to_s
          if File.directory?(path)
            Dir.glob(File.join(path, "**", "*.{#{EXTENSIONS.join(',')}}"))
          elsif File.file?(path)
            [path]
          else
            raise ArgumentError, "no such file or directory: #{path}"
          end
        end
      end
    end
  end
end
