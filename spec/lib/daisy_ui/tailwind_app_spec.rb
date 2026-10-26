# frozen_string_literal: true

require "tmpdir"

RSpec.describe DaisyUI::Tailwind do
  let(:dir) { Dir.mktmpdir("daisyui-app-stale") }

  after { FileUtils.rm_rf(dir) }

  describe ".app_components" do
    it "lists the app's named components, not the gem's" do
      expect(described_class.app_components).to include(VariantsFixtures::Widget, VariantsFixtures::Thing, VariantsFixtures::Picker)
      expect(described_class.app_components).not_to include(DaisyUI::Button, DaisyUI::Base)
      expect(described_class.app_components).to eq(described_class.app_components.sort_by(&:name))
    end

    it "skips a class its constant no longer names, as after a code reload" do
      stale = stub_const("ReloadedApp::Widget", Class.new(DaisyUI::Base))
      fresh = stub_const("ReloadedApp::Widget", Class.new(DaisyUI::Base))

      expect(described_class.app_components).to include(fresh)
      expect(described_class.app_components).not_to include(stale)
    end

    it "eager-loads a Rails app first, so every component is defined" do
      application = Class.new do
        attr_reader :eager_loaded

        def eager_load! = (@eager_loaded = true)
      end.new
      stub_const("Rails", Module.new { define_singleton_method(:application) { application } })

      described_class.app_components

      expect(application.eager_loaded).to be(true)
    end
  end

  describe ".sources(app:)" do
    it "renders the app's components" do
      expect(described_class.sources(app: [VariantsFixtures::Thing])).to include("/* VariantsFixtures::Thing */")
      expect(described_class.sources(app: true)).to include("/* VariantsFixtures::Widget */")
    end

    it "is a file of its own, apart from the scanned gem components" do
      expect { described_class.sources(app: true, components: %w[Button]) }.to raise_error(ArgumentError, /app:/)
    end
  end

  describe ".stale?" do
    let(:path) { File.join(dir, "daisyui_app.css") }
    let(:component) do
      stub_const("StaleWidget", Class.new(DaisyUI::Base) { variants { base "stale-before" } })
    end

    it "is false right after generating, true after a declaration changes, false again once regenerated" do
      File.write(path, described_class.sources(app: [component]))
      expect(described_class.stale?(path, app: [component])).to be(false)

      component.variants { base "stale-after" }
      expect(described_class.stale?(path, app: [component])).to be(true)

      File.write(path, described_class.sources(app: [component]))
      expect(described_class.stale?(path, app: [component])).to be(false)
    end

    it "is true for a file that is not there" do
      expect(described_class.stale?(File.join(dir, "missing.css"), app: [component])).to be(true)
    end
  end
end
