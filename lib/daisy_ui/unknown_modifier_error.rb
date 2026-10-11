# frozen_string_literal: true

require "did_you_mean"

module DaisyUI
  # Raised (or warned, or reported) when a component is given a positional
  # modifier it does not know. See `DaisyUI.configuration.unknown_modifiers`.
  class UnknownModifierError < ArgumentError
    attr_reader :component, :modifier

    def initialize(component:, modifier:, known:)
      @component = component
      @modifier = modifier
      super(build_message(known))
    end

    private

    def build_message(known)
      message = "#{component.name || component.inspect} has no modifier #{modifier.inspect}"
      suggestions = DidYouMean::SpellChecker.new(dictionary: known.map(&:to_s)).correct(modifier.to_s)
      return message if suggestions.empty?

      "#{message}. Did you mean? #{suggestions.map { |s| ":#{s}" }.join(', ')}"
    end
  end
end
