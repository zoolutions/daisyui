# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge::DaisyGroups do
  def merge(*parts)
    DaisyUI::ClassMerge.merge(*parts)
  end

  describe "conflicts within a group" do
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

    it "resolves groups that are not size or color" do
      expect(merge("loading loading-spinner loading-dots")).to eq("loading loading-dots")
      expect(merge("mask mask-squircle mask-heart")).to eq("mask mask-heart")
      expect(merge("stack stack-top stack-end")).to eq("stack stack-end")
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

    it "keeps modifiers of different groups" do
      expect(merge("btn-wide btn-lg")).to eq("btn-wide btn-lg")
    end

    it "keeps both axes of two-axis placements" do
      expect(merge("toast-top toast-end")).to eq("toast-top toast-end")
      expect(merge("dropdown-top dropdown-end")).to eq("dropdown-top dropdown-end")
      expect(merge("modal-bottom modal-start")).to eq("modal-bottom modal-start")
    end

    it "keeps ungrouped modifiers" do
      expect(merge("btn-wide btn-block btn-active")).to eq("btn-wide btn-block btn-active")
    end

    it "keeps a mask shape next to a half mask" do
      expect(merge("mask mask-star-2 mask-half-1")).to eq("mask mask-star-2 mask-half-1")
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

  context "with a configured modifier in a group" do
    around do |example|
      DaisyUI.configuration.modifiers.add(:huge, classes: "btn-huge", component: DaisyUI::Button, group: :size)
      example.run
    ensure
      DaisyUI.configuration.modifiers.remove(:huge, component: DaisyUI::Button)
    end

    it "joins the component's group of that name" do
      expect(merge("btn-lg btn-huge")).to eq("btn-huge")
      expect(merge("btn-huge btn-sm")).to eq("btn-sm")
    end
  end

  context "with a configured modifier without a group" do
    around do |example|
      DaisyUI.configuration.modifiers.add(:huge, classes: "btn-huge", component: DaisyUI::Button)
      example.run
    ensure
      DaisyUI.configuration.modifiers.remove(:huge, component: DaisyUI::Button)
    end

    it "never conflicts" do
      expect(merge("btn-lg btn-huge")).to eq("btn-lg btn-huge")
    end
  end

  context "with an app component outside the DaisyUI namespace" do
    let(:widget) do
      Class.new(DaisyUI::Base) do
        self.component_class = :widget
        register_modifiers(size: { sm: "widget-sm", lg: "widget-lg" }, round: "widget-round")

        def view_template = div(class: classes)
      end
    end

    before { stub_const("Widget", widget) }

    it "resolves its declared groups" do
      expect(render(Widget.new(:sm, class: "widget-lg"))).to eq('<div class="widget widget-lg"></div>')
    end

    it "keeps ungrouped modifiers" do
      expect(render(Widget.new(:round, class: "widget-lg"))).to eq('<div class="widget widget-round widget-lg"></div>')
    end
  end

  context "with a group of Tailwind utilities" do
    let(:swatch) do
      Class.new(DaisyUI::Base) do
        self.component_class = :swatch
        register_modifiers(
          color: {
            primary: "bg-primary text-primary-content",
            secondary: "bg-secondary text-secondary-content"
          }
        )
      end
    end

    before { stub_const("Swatch", swatch) }

    it "leaves the utilities to Tailwind's own groups" do
      expect(merge("bg-primary text-secondary-content")).to eq("bg-primary text-secondary-content")
      expect(merge("bg-primary bg-secondary")).to eq("bg-secondary")
    end
  end

  describe ".build" do
    subject(:groups) { described_class.build }

    it "has no empty group" do
      expect(groups.select { |_id, tokens| tokens.empty? }).to be_empty
    end

    it "puts every token in exactly one group" do
      owners = Hash.new { |hash, key| hash[key] = [] }
      groups.each { |id, tokens| tokens.each { |token| owners[token] << id } }

      expect(owners.select { |_token, ids| ids.size > 1 }).to be_empty
    end
  end
end
