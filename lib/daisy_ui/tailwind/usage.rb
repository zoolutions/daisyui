# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Finds the components an app's Ruby and templates reference:
    #
    # - the constant: `DaisyUI::Card`, `class AppNavbar < DaisyUI::Navbar`
    # - an instance: `Card.new(…)`
    # - a kit call, with parentheses (`Button(:primary)`) or without
    #   (`Badge :primary do`, `Hero do`, `Modal { … }`, `Toast class: "…"`,
    #   `Button variant do`)
    #
    # Comments are skipped (each file's own kind: `#` lines in Ruby, `<%# %>`
    # in ERB, `-#` in HAML, `/` in Slim), so "# Loading state…" is not a use
    # of Loading, while a HAML `#sidebar= …` line still counts. A name is matched whole: `MyButton(` and `UI::Card(` are not
    # uses (an app wrapper `UI::Card < DaisyUI::Card` is found by its own
    # file). Matching on text over-reports rather than misses: a false hit
    # costs some CSS, a miss leaves a component unstyled.
    class Usage
      COMMENTS = {
        "rb" => /^[ \t]*#.*$/,
        "erb" => /<%#.*?%>/m,
        "haml" => /^[ \t]*-#.*$/,
        "slim" => %r{^[ \t]*/.*$}
      }.freeze
      EXTENSIONS = COMMENTS.keys.freeze
      # What follows a name in a call: `(`, `.new`, a block, or arguments
      # without parentheses: `:primary`, `class: …`, `"…"`, or a variable that
      # ends the line or is followed by `,`, `do` or `{` (`Button variant do`),
      # which keeps "Join thousands of…" in a string from counting.
      CALL = /
        \( | \.new\b | [ \t]*\{ |
        [ \t]+ (?: do\b | :[a-z_] | ["'] | [a-z_]\w*:[ \t] | [a-z_@][\w@]* (?: \.[a-z_]\w* )* [ \t]* (?: , | do\b | \{ | $ ) )
      /x

      def initialize(names)
        names = names.sort_by { |name| -name.length }.map { |name| Regexp.escape(name) }.join("|")
        @pattern = /DaisyUI::(#{names})\b|(?<![A-Za-z0-9_:])(#{names})(?=#{CALL})/
      end

      # Sorted names referenced in the files under `paths` (directories or
      # files). A path that does not exist raises: a typo must not quietly
      # leave every component out.
      def scan(paths)
        files(paths).flat_map { |file| references(File.read(file).scrub, kind: File.extname(file).delete_prefix(".")) }
          .uniq.sort
      end

      # Sorted names referenced in `source`, a file of `kind` (its extension).
      def references(source, kind: "rb")
        source.gsub(COMMENTS.fetch(kind, COMMENTS["rb"]), "").scan(@pattern).flat_map(&:compact).uniq.sort
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
