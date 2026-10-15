# frozen_string_literal: true

RSpec.describe DaisyUI, ".finalize!", :finalizes do
  it_behaves_like "a boot-finalized configuration",
    readers: {
      "DaisyUI.configuration" => -> { described_class.configuration },
      "DaisyUI.configuration.class_merge" => -> { described_class.configuration.class_merge },
      "DaisyUI.configuration.modifiers" => -> { described_class.configuration.modifiers },
      # Every gem component's registries, e.g. "DaisyUI::Button.modifiers".
      **DaisyUI::ClassMerge::DaisyGroups.gem_components
        .product(%i[component_class modifiers modifier_groups flags])
        .to_h { |component, reader| ["#{component.name}.#{reader}", component.method(reader)] }
    },
    finalize: -> { described_class.finalize! }

  it "can run more than once" do
    described_class.finalize!

    expect { described_class.finalize! }.not_to raise_error
    expect(Ractor.shareable?(described_class.configuration)).to be(true)
  end

  it "keeps merging classes on the main Ractor" do
    described_class.finalize!

    expect(DaisyUI::ClassMerge.merge("btn btn-sm btn-lg p-2 p-4")).to eq("btn btn-lg p-4")
  end

  describe "DaisyUI.configure afterwards" do
    it "works on a copy and finalizes it again" do
      described_class.finalize!
      finalized = described_class.configuration

      described_class.configure { |config| config.prefix = "tw-" }

      expect(described_class.configuration).not_to be(finalized)
      expect(described_class.configuration.prefix).to eq("tw-")
      expect(finalized.prefix).to be_nil
      expect(Ractor.shareable?(described_class.configuration)).to be(true)
    end

    it "keeps configured modifiers and class-merge settings" do
      described_class.configure do |config|
        config.modifiers.add(:huge, classes: "btn-xl", component: DaisyUI::Button, group: :size)
        config.class_merge.theme(text: %w[display])
      end
      described_class.finalize!

      described_class.configure { |config| config.modifiers.add(:shiny, classes: "shadow-lg") }

      expect(described_class.configuration.modifiers.for(component: DaisyUI::Button)).to eq(huge: "btn-xl")
      expect(described_class.configuration.modifiers.for).to eq(shiny: "shadow-lg")
      expect(DaisyUI::ClassMerge.merge("text-display text-error btn-sm btn-xl")).to eq("text-display text-error btn-xl")
    end
  end

  it "leaves direct writes to the frozen configuration to raise, as frozen objects do" do
    described_class.finalize!

    expect { described_class.configuration.prefix = "tw-" }.to raise_error(FrozenError)
  end

  it "lets a finalized component register more modifiers" do
    widget = Class.new(DaisyUI::Base) { register_modifiers(size: { sm: "widget-sm" }) }
    stub_const("FinalizedWidget", widget)
    described_class.finalize!

    widget.register_modifiers(size: { lg: "widget-lg" }, wide: "widget-wide")

    expect(widget.modifiers).to eq(sm: "widget-sm", lg: "widget-lg", wide: "widget-wide")
    expect(widget.modifier_groups).to eq(size: %i[sm lg])
  end

  describe "an unknown_modifiers callable" do
    it "is made shareable when it is capture-free" do
      described_class.configuration.unknown_modifiers = described_class.instance_exec { ->(error) { error } }
      described_class.finalize!

      expect(Ractor.shareable?(described_class.configuration)).to be(true)
    end

    it "does not stop finalize! when it cannot be shareable" do
      reported = []
      described_class.configuration.unknown_modifiers = ->(error) { reported << error }

      expect { described_class.finalize! }.not_to raise_error
      expect(described_class.configuration).to be_frozen
      expect(Ractor.shareable?(described_class.configuration)).to be(false)
    end
  end
end
