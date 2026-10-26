# frozen_string_literal: true

require "did_you_mean"

module DaisyUI
  # Raised (or warned, or reported) when a component is given a positional
  # modifier it does not know. See `DaisyUI.configuration.unknown_modifiers`.
  class UnknownModifierError < ArgumentError
    attr_reader :component, :modifier, :part

    # `part` names the sub-component method (e.g. :bubble for Chat#bubble).
    def initialize(component:, modifier:, known:, part: nil)
      @component = component
      @modifier = modifier
      @part = part
      super(build_message(known))
    end

    private

    def build_message(known)
      name = component.name || component.inspect
      name = "#{name}##{part}" if part
      message = "#{name} has no modifier #{modifier.inspect}"
      suggestions = DidYouMean::SpellChecker.new(dictionary: known.map(&:to_s)).correct(modifier.to_s)
      message = "#{message}. Did you mean? #{suggestions.map { |s| ":#{s}" }.join(', ')}" unless suggestions.empty?
      groups.empty? ? message : "#{message}. Variants: #{groups}"
    end

    # The component's groups and their members, "size: sm, lg; color: …";
    # a sub-component part has modifiers of its own, so none for it.
    def groups
      return "" if part || !component.respond_to?(:modifier_groups)

      component.modifier_groups.map { |group, members| "#{group}: #{members.join(', ')}" }.join("; ")
    end
  end
end
