# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Which words can go into Tailwind's `@source inline("…")`. inline() is a
    # quoted string with brace expansion, and one unbalanced bracket in it
    # makes Tailwind drop every class after it, so a candidate starts and ends
    # like a utility or variant, has balanced () and [], and holds no quote,
    # brace, semicolon, backslash or backtick. A `/` only introduces a
    # fraction or an opacity (`w-1/2`, `bg-base-100/50`), never a path.
    #
    # @api private
    module Candidate
      SHAPE = /\A[a-z@!\[*-][^\s"'`;{}\\]*[a-z0-9\])%!]\z/
      PATH = %r{/(?![0-9\[])}
      CLOSING = { ")" => "(", "]" => "[" }.freeze

      class << self
        def valid?(token)
          SHAPE.match?(token) && token.match?(/[a-z]/) && !PATH.match?(token) && balanced?(token)
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
      end
    end
  end
end
