# frozen_string_literal: true

# A non-main Ractor can only read a constant whose value is Ractor-shareable,
# and the Tailwind engine reaches its validators and theme getters (lambdas)
# through constants.
RSpec.describe DaisyUI::ClassMerge do
  # Every module under DaisyUI::ClassMerge, found by walking its constants: a
  # Class or Module constant is always shareable, so each nested module's own
  # constants are checked, including one added later.
  walk = lambda do |mod|
    nested = mod.constants(false).map { |name| mod.const_get(name) }
      .grep(Module).select { |constant| constant.name&.start_with?("#{mod.name}::") }
    [mod, *nested.flat_map(&walk)]
  end

  walk.call(described_class).each do |mod|
    it "makes every constant of #{mod} Ractor-shareable" do
      unshareable = mod.constants(false).map { |name| "#{mod}::#{name}" }
        .reject { |name| Ractor.shareable?(Object.const_get(name)) }

      expect(unshareable).to be_empty
    end
  end
end
