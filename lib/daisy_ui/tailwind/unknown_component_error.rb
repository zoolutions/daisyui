# frozen_string_literal: true

require "did_you_mean"

module DaisyUI
  module Tailwind
    # A component name (`--component Buton`) the manifest does not have.
    class UnknownComponentError < ArgumentError
      def initialize(name, known)
        suggestions = DidYouMean::SpellChecker.new(dictionary: known).correct(name.to_s)
        message = "DaisyUI has no component #{name}"
        message = "#{message}. Did you mean? #{suggestions.join(', ')}" unless suggestions.empty?
        super(message)
      end
    end
  end
end
