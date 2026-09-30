# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge do
  after { described_class.reset! }

  describe ".merge" do
    it "accepts strings, arrays and nils" do
      expect(described_class.merge("px-2", nil, ["py-1", [nil, "px-4"]])).to eq("py-1 px-4")
    end

    it "returns a frozen string" do
      expect(described_class.merge("px-2")).to be_frozen
    end

    it "returns an empty string for no classes" do
      expect(described_class.merge(nil, [], "")).to eq("")
    end

    it "keeps classes it does not know" do
      expect(described_class.merge("my-widget px-2", "another")).to eq("my-widget px-2 another")
    end

    it "resolves common Tailwind conflicts" do
      expect(described_class.merge("text-sm text-base-content/80 text-error")).to eq("text-sm text-error")
      expect(described_class.merge("bg-base-100 bg-base-200")).to eq("bg-base-200")
      expect(described_class.merge("ring-1 ring-base-300 ring-2 ring-primary")).to eq("ring-2 ring-primary")
    end
  end

  describe "configuration" do
    let(:config) { DaisyUI.configuration.class_merge }

    around do |example|
      original = DaisyUI.configuration.instance_variable_get(:@class_merge)
      DaisyUI.configuration.instance_variable_set(:@class_merge, nil)
      example.run
    ensure
      DaisyUI.configuration.instance_variable_set(:@class_merge, original)
      described_class.reset!
    end

    it "is enabled by default" do
      expect(config.enabled).to be(true)
    end

    it "does not know custom font sizes until they are registered" do
      expect(described_class.merge("text-display text-error")).to eq("text-error")
    end

    context "with a registered text size" do
      before { DaisyUI.configure { |c| c.class_merge.theme(text: %w[display]) } }

      it "keeps a custom size next to a color" do
        expect(described_class.merge("text-display text-error")).to eq("text-display text-error")
      end

      it "lets a custom size replace a built-in size" do
        expect(described_class.merge("text-sm text-display")).to eq("text-display")
      end
    end

    context "with a registered color" do
      before { DaisyUI.configure { |c| c.class_merge.theme(color: %w[brand]) } }

      it "treats the color as a color in every utility" do
        expect(described_class.merge("bg-primary bg-brand")).to eq("bg-brand")
        expect(described_class.merge("text-brand text-error")).to eq("text-error")
        expect(described_class.merge("text-brand text-sm")).to eq("text-brand text-sm")
      end
    end

    context "with custom class groups and conflicts" do
      before do
        DaisyUI.configure do |c|
          c.class_merge.class_groups("surface" => %w[surface-flat surface-raised])
          c.class_merge.conflicts("surface" => ["shadow"])
        end
      end

      it "resolves the custom group" do
        expect(described_class.merge("surface-flat surface-raised")).to eq("surface-raised")
      end

      it "drops conflicting Tailwind classes" do
        expect(described_class.merge("shadow-lg surface-raised")).to eq("surface-raised")
      end

      it "keeps Tailwind defaults intact" do
        expect(described_class.merge("px-2 px-4")).to eq("px-4")
      end
    end

    it "rebuilds the merger when the configuration changes" do
      first = described_class.merger
      DaisyUI.configure { |c| c.class_merge.theme(text: %w[display]) }

      expect(described_class.merger).not_to equal(first)
    end
  end
end
