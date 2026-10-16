# frozen_string_literal: true

RSpec.describe DaisyUI::Tailwind::Manifest do
  subject(:manifest) { described_class.load }

  describe "the committed data/daisyui/tailwind_manifest.json" do
    it "matches the components (run `bundle exec rake tailwind:manifest` after changing one)" do
      committed = File.read(DaisyUI::Tailwind::MANIFEST_PATH)

      expect(committed).to eq(DaisyUI::Tailwind::ManifestBuilder.generate),
        "data/daisyui/tailwind_manifest.json is stale: run `bundle exec rake tailwind:manifest` and commit it"
    end

    it "holds only classes Tailwind can read from @source inline(…)" do
      tokens = manifest.components.values.flat_map { |entry| entry["classes"] + entry["modifiers"] } +
               manifest.shared["classes"]

      expect(tokens.reject { |token| DaisyUI::Tailwind::Candidate.valid?(token) }).to be_empty
    end

    it "depends only on components it lists" do
      dependencies = manifest.components.values.flat_map { |entry| entry["depends_on"] }

      expect(dependencies - manifest.component_names).to be_empty
    end
  end

  describe "#resolve" do
    it "adds every component the given ones render, transitively, sorted" do
      expect(manifest.resolve(%w[Tabs])).to eq(%w[Tab TabWithContent TabWithoutContent Tabs])
      expect(manifest.resolve(%w[Dropdown])).to eq(%w[Button CollapsibleSubMenu Dropdown Menu MenuItem SubMenu])
    end

    it "accepts the namespaced class name" do
      expect(manifest.resolve(%w[DaisyUI::Badge Badge])).to eq(%w[Badge])
    end

    it "raises on a name the gem does not have, with suggestions" do
      expect { manifest.resolve(%w[Buton]) }
        .to raise_error(DaisyUI::Tailwind::UnknownComponentError, /Buton.*Did you mean\? Button/)
    end
  end

  describe "#files" do
    it "gives absolute paths under the gem" do
      expect(manifest.files(%w[Button])).to eq([File.join(DaisyUI::Tailwind::ROOT, "lib/daisy_ui/button.rb")])
      expect(manifest.shared_files).to eq([File.join(DaisyUI::Tailwind::ROOT, "lib/daisy_ui/base.rb")])
    end
  end
end
