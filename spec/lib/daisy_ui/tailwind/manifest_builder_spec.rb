# frozen_string_literal: true

require "tmpdir"

RSpec.describe DaisyUI::Tailwind::ManifestBuilder do
  describe ".entry" do
    subject(:entry) { described_class.entry(widget, file:, names: %w[Button ManifestWidget Menu], root:) }

    let(:root) { Dir.mktmpdir("daisyui-manifest") }
    let(:file) { File.join(root, "lib", "daisy_ui", "manifest_widget.rb") }
    let(:widget) do
      component = Class.new(DaisyUI::Base) do
        self.component_class = :widget
        register_modifiers(
          size: { lg: "widget-lg" },
          round: "widget-round",
          **DaisyUI::Base::COLOR_MODIFIERS.slice(:primary)
        )
      end
      stub_const("ManifestWidget", component)
    end

    before do
      FileUtils.mkdir_p(File.dirname(file))
      File.write(file, <<~'RUBY')
        module DaisyUI
          class ManifestWidget < Base
            # Menu in a comment is not a dependency: "sm:widget-lg"
            def part(**options, &)
              div(class: component_classes("widget-part widget-part-#{1}", options:), &)
            end

            def trigger(...) = render Button.new(...)

            def style = "--size: 1;"
          end
        end
      RUBY
    end

    after { FileUtils.rm_rf(root) }

    it "names the class, its daisyUI component and its file relative to the gem root" do
      expect(entry).to include(
        "class" => "ManifestWidget",
        "name" => "widget",
        "files" => ["lib/daisy_ui/manifest_widget.rb"]
      )
    end

    it "lists the registered modifier classes, the ones `responsive:` can prefix" do
      expect(entry["modifiers"]).to eq(%w[bg-primary text-primary-content widget-lg widget-round])
    end

    it "lists every class: the Symbol component class, the modifiers and the Ruby's class strings" do
      expect(entry["classes"]).to eq(%w[bg-primary text-primary-content widget widget-lg widget-part widget-round])
    end

    it "keeps comments and strings that are not classes out" do
      expect(entry["classes"]).not_to include("sm:widget-lg", "--size:", "widget-part-")
    end

    it "depends on the other components its code (not its comments) references" do
      expect(entry["depends_on"]).to eq(%w[Button])
    end

    it "raises when a registered modifier is not a class Tailwind can read inline" do
      widget.register_modifiers(broken: "clip-path:polygon(0")

      expect { entry }.to raise_error(ArgumentError, /ManifestWidget.*"clip-path:polygon\(0"/)
    end
  end

  describe ".build" do
    subject(:manifest) { described_class.build }

    let(:component_files) do
      Dir[File.join(DaisyUI::Tailwind::ROOT, "lib/daisy_ui/*.rb")].select do |path|
        File.read(path).match?(/^\s*class \w+ < Base\b/)
      end
    end

    it "has an entry for every component file in the gem, and nothing else" do
      expect(manifest["components"].values.flat_map { |entry| entry["files"] })
        .to match_array(component_files.map { |path| path.delete_prefix("#{DaisyUI::Tailwind::ROOT}/") })
    end

    it "ignores components defined outside the gem's lib" do
      stub_const("DaisyUI::OutsideWidget", Class.new(DaisyUI::Base))

      expect(manifest["components"]).not_to have_key("OutsideWidget")
    end

    it "shares base.rb's classes, which every component can render (:skeleton, the colours)" do
      expect(manifest["shared"]).to include("files" => ["lib/daisy_ui/base.rb"])
      expect(manifest["shared"]["classes"]).to include("skeleton", "bg-primary", "text-primary-content")
    end

    it "carries the Symbol component classes Tailwind cannot see in the Ruby" do
      expect(manifest["components"]["Button"]).to include("class" => "DaisyUI::Button", "name" => "btn")
      expect(manifest["components"]["Button"]["classes"]).to include("btn", "btn-primary")
    end

    it "carries classes a component renders from its methods" do
      expect(manifest["components"]["Card"]["classes"]).to include("card-body", "card-title", "bg-primary")
      expect(manifest["components"]["Calendar"]["classes"]).to include("cally", "pika-single")
    end

    it "has no daisyUI name for a component whose class depends on its modifiers" do
      expect(manifest["components"]["Label"]["name"]).to be_nil
      expect(manifest["components"]["Label"]["classes"]).to include("floating-label")
    end

    it "records the components each one renders" do
      components = manifest["components"]

      expect(components["Dropdown"]["depends_on"]).to eq(%w[Button Menu])
      expect(components["Menu"]["depends_on"]).to eq(%w[CollapsibleSubMenu MenuItem SubMenu])
      expect(components["Tabs"]["depends_on"]).to eq(%w[Tab])
      expect(components["Tab"]["depends_on"]).to eq(%w[TabWithContent TabWithoutContent])
    end
  end

  describe ".generate" do
    it "is stable JSON ending in a newline" do
      json = described_class.generate

      expect(json).to end_with("}\n")
      expect(JSON.parse(json)).to eq(described_class.build)
      expect(described_class.generate).to eq(json)
    end
  end
end
