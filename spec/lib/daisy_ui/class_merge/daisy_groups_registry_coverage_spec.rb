# frozen_string_literal: true

# Every class a gem component can emit through `register_modifiers` must be
# understood by the merger: a Tailwind utility, a member of a daisyUI family,
# or explicitly listed in ClassMergeCoverage::STANDALONE_MODIFIERS. A new modifier that is none
# of these fails here until it is classified.
RSpec.describe DaisyUI::ClassMerge::DaisyGroups do
  describe "registry coverage" do
    let(:tokens) { described_class.modifier_tokens(described_class.gem_components) }

    it "classifies every registered modifier token" do
      unclassified = tokens.reject do |token, _components|
        described_class.tailwind_class?(token) ||
          described_class.family_group(token) ||
          ClassMergeCoverage::STANDALONE_MODIFIERS.include?(token)
      end

      messages = unclassified.map { |token, components| "#{components.uniq.join(', ')}: #{token}" }

      expect(messages).to be_empty, <<~MSG
        Unclassified daisyUI modifier tokens. Give the token a family suffix
        (#{described_class::FAMILIES.keys.join(', ')}) or add it to ClassMergeCoverage::STANDALONE_MODIFIERS (spec/support):
          #{messages.join("\n  ")}
      MSG
    end

    it "lists only registered tokens as standalone" do
      stale = ClassMergeCoverage::STANDALONE_MODIFIERS.reject { |token| tokens.key?(token) }

      expect(stale).to be_empty, "STANDALONE lists tokens no component registers: #{stale.join(', ')}"
    end

    it "does not list family members as standalone" do
      misplaced = ClassMergeCoverage::STANDALONE_MODIFIERS.select { |token| described_class.family_group(token) }

      expect(misplaced).to be_empty
    end
  end
end
