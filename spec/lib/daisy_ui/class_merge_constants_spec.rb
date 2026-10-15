# frozen_string_literal: true

# A non-main Ractor can only read a constant whose value is Ractor-shareable,
# and the Tailwind engine reaches its validators and theme getters (lambdas)
# through constants.
RSpec.describe DaisyUI::ClassMerge do
  modules = [
    described_class,
    DaisyUI::ClassMerge::TailwindConfig,
    DaisyUI::ClassMerge::Validators,
    DaisyUI::ClassMerge::ParseClassName,
    DaisyUI::ClassMerge::ClassGroupUtils,
    DaisyUI::ClassMerge::Configuration
  ]

  modules.each do |mod|
    it "makes every constant of #{mod} Ractor-shareable" do
      unshareable = mod.constants(false).map { |name| "#{mod}::#{name}" }
        .reject { |name| Ractor.shareable?(Object.const_get(name)) }

      expect(unshareable).to be_empty
    end
  end
end
