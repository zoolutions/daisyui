# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Which words can go into Tailwind's `@source inline("…")`. inline() is a
    # quoted string with brace expansion, and one unbalanced bracket in it
    # makes Tailwind drop every class after it, so a candidate starts and ends
    # like a utility or variant, has balanced () and [], and holds no quote,
    # brace, semicolon, backslash or backtick.
    #
    # A `/` before a digit or `[` is a fraction or an opacity (`w-1/2`,
    # `bg-base-100/50`). A `/` before anything else is a path, except one
    # trailing `/<name>` on a variant or utility: a named group or peer
    # (`group/item`, `group-hover/item:underline`, `peer-checked/field:block`)
    # or a plugin utility's named modifier (`motion-ease-in-out/opacity`).
    #
    # @api private
    module Candidate
      SHAPE = /\A[a-z@!\[*-][^\s"'`;{}\\]*[a-z0-9\])%!]\z/
      PATH = %r{/(?![0-9\[])}
      NAMED = %r{\A(?<head>.+)/[A-Za-z0-9_-]+\z}
      CLOSING = { ")" => "(", "]" => "[" }.freeze

      class << self
        def valid?(token)
          SHAPE.match?(token) && token.match?(/[a-z]/) && balanced?(token) && !paths?(token)
        end

        # The candidates among the whitespace-separated words of `classes`.
        def tokens(classes)
          classes.split.select { |token| valid?(token) }
        end

        private

        def balanced?(token)
          open = []
          token.each_char do |char|
            if CLOSING.value?(char)
              open << char
            elsif CLOSING.key?(char)
              return false unless open.pop == CLOSING[char]
            end
          end
          open.empty?
        end

        def paths?(token)
          parts(token).any? { |part| path?(part) }
        end

        def path?(part)
          return false unless PATH.match?(part)

          head = part[NAMED, :head]
          head.nil? || PATH.match?(head) || !named?(head)
        end

        # What may carry a `/<name>`: a group or a peer, or a utility with a
        # `-` in it. A bare word (`app`, `vendor`, `hover`) is a directory.
        def named?(head)
          %w[group peer].include?(head) || (head.include?("-") && SHAPE.match?(head))
        end

        # The token split on its top-level `:`, as Tailwind splits variants
        # from the utility; a `:` inside [] or () belongs to its part.
        def parts(token)
          depth = 0
          slices = token.each_char.slice_when do |char, _|
            depth += 1 if "[(".include?(char)
            depth -= 1 if "])".include?(char)
            char == ":" && depth.zero?
          end
          slices.map { |chars| chars.join.delete_suffix(":") }
        end
      end
    end
  end
end
