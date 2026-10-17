# frozen_string_literal: true

module DaisyUI
  module Tailwind
    # Reads a component's Ruby the way the manifest needs it: the words of its
    # string literals (where its sub-part classes live, e.g. "card-body") and
    # the constants its code references (the components it renders). Ripper
    # keeps comments out of both.
    #
    # @api private
    module Lexer
      class << self
        def strings(source)
          tokens(source, :on_tstring_content).flat_map(&:split)
        end

        def constants(source)
          tokens(source, :on_const).uniq
        end

        private

        def tokens(source, type)
          require "ripper"

          ::Ripper.lex(source).filter_map { |(_position, kind, token)| token if kind == type }
        end
      end
    end
  end
end
