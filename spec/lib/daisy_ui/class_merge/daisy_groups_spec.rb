# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge::DaisyGroups do
  def merge(*parts)
    DaisyUI::ClassMerge.merge(*parts)
  end

  describe "conflicts within a family" do
    it "keeps the last size" do
      expect(merge("btn btn-sm btn-lg")).to eq("btn btn-lg")
    end

    it "keeps the last color" do
      expect(merge("badge-primary badge-error")).to eq("badge-error")
    end

    it "keeps the last style" do
      expect(merge("btn-outline btn-soft")).to eq("btn-soft")
    end

    it "keeps the last direction" do
      expect(merge("alert-vertical alert-horizontal")).to eq("alert-horizontal")
    end

    it "keeps the last placement" do
      expect(merge("dropdown-top dropdown-bottom")).to eq("dropdown-bottom")
    end

    it "keeps the last alignment" do
      expect(merge("dropdown-start dropdown-end")).to eq("dropdown-end")
    end

    it "handles multi-word component names" do
      expect(merge("file-input-xs file-input-lg")).to eq("file-input-lg")
    end
  end

  describe "classes that do not conflict" do
    it "keeps a responsive variant next to a plain one" do
      expect(merge("sm:btn-lg btn-sm")).to eq("sm:btn-lg btn-sm")
    end

    it "keeps a state variant next to a plain one" do
      expect(merge("hover:btn-primary btn-error")).to eq("hover:btn-primary btn-error")
    end

    it "keeps modifiers of different components" do
      expect(merge("btn-primary badge-error")).to eq("btn-primary badge-error")
    end

    it "keeps modifiers of different families" do
      expect(merge("btn-wide btn-lg")).to eq("btn-wide btn-lg")
    end

    it "keeps placement and alignment together" do
      expect(merge("toast-top toast-end")).to eq("toast-top toast-end")
      expect(merge("dropdown-top dropdown-end")).to eq("dropdown-top dropdown-end")
    end

    it "keeps standalone modifiers" do
      expect(merge("btn-square btn-circle")).to eq("btn-square btn-circle")
    end
  end

  describe "component base classes" do
    it "never drops a base class that shares a name with a Tailwind utility" do
      expect(merge("table hidden")).to eq("table hidden")
      expect(merge("collapse invisible")).to eq("collapse invisible")
    end
  end

  describe "Tailwind classes mixed in" do
    it "resolves Tailwind conflicts around daisyUI classes" do
      expect(merge("px-4 btn-sm px-2")).to eq("btn-sm px-2")
    end
  end

  context "with a prefix" do
    around do |example|
      original_prefix = DaisyUI.configuration.prefix
      DaisyUI.configure { |config| config.prefix = "d-" }
      example.run
    ensure
      DaisyUI.configure { |config| config.prefix = original_prefix }
    end

    it "resolves prefixed modifiers" do
      expect(merge("d-btn-sm d-btn-lg")).to eq("d-btn-lg")
    end

    it "treats unprefixed daisyUI classes as unknown" do
      expect(merge("btn-sm btn-lg")).to eq("btn-sm btn-lg")
    end
  end

  context "with a configured modifier" do
    around do |example|
      DaisyUI.configuration.modifiers.add(:huge, classes: "btn-xl", component: DaisyUI::Button)
      example.run
    ensure
      DaisyUI.configuration.modifiers.remove(:huge, component: DaisyUI::Button)
    end

    it "includes configured modifier classes in the registry" do
      expect(described_class.modifier_tokens["btn-xl"]).to include("DaisyUI.configuration")
    end
  end

  describe ".family_group" do
    it "returns nil for Tailwind classes" do
      expect(described_class.family_group("bg-primary")).to be_nil
    end

    it "returns nil for suffixes outside every family" do
      expect(described_class.family_group("mask-star-2")).to be_nil
    end

    it "names the component and family" do
      expect(described_class.family_group("btn-lg")).to eq("daisy:btn-size")
    end
  end
end
