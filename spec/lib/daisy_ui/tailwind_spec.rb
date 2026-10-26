# frozen_string_literal: true

require "json"
require "tmpdir"

RSpec.describe DaisyUI::Tailwind do
  let(:dir) { Dir.mktmpdir("daisyui-tailwind") }

  before { File.write(File.join(dir, "nav.rb"), "render DaisyUI::Menu.new\n") }

  after { FileUtils.rm_rf(dir) }

  describe ".used_components" do
    it "finds the components the paths use and adds the ones those render" do
      expect(described_class.used_components(scan: [dir])).to eq(%w[CollapsibleSubMenu Menu MenuItem SubMenu])
    end

    it "adds named components" do
      expect(described_class.used_components(scan: [dir], components: %w[Badge])).to include("Badge", "Menu")
    end
  end

  describe ".sources" do
    it "gives the CSS for the used components" do
      expect(described_class.sources(scan: [dir])).to include("/* DaisyUI::MenuItem */\n@source inline(")
    end

    it "prefixes classes with DaisyUI.configuration.prefix unless told otherwise", :finalizes do
      DaisyUI.configure { |config| config.prefix = "d-" }

      expect(described_class.sources(components: %w[Badge])).to include('@source inline("d-badge ')
      expect(described_class.sources(components: %w[Badge], prefix: nil)).to include('@source inline("badge ')
    end

    it "gives JSON" do
      expect(JSON.parse(described_class.sources(components: %w[Badge], format: :json))["components"].keys).to eq(%w[Badge])
    end
  end

  # An app that still points Tailwind at the gem's lib/ (or its **/*.rb) must
  # not start seeing every component's classes in the manifest.
  it "keeps the manifest in the gem's data/ dir, out of lib/" do
    expect(described_class::MANIFEST_PATH).to eq(File.join(described_class::ROOT, "data/daisyui/tailwind_manifest.json"))
    expect(described_class::MANIFEST_PATH).not_to start_with(File.join(described_class::ROOT, "lib"))
  end

  it "ships the manifest, the executable and the rake task in the gem, with or without git" do
    gemspec = File.join(described_class::ROOT, "daisyui.gemspec")
    from_git = Gem::Specification.load(gemspec)
    # The gemspec falls back to a Dir glob where there is no .git (the docs
    # Docker image builds the gem from copied source).
    allow(IO).to receive(:popen).and_raise(Errno::ENOENT)
    without_git = eval(File.read(gemspec), TOPLEVEL_BINDING, gemspec) # rubocop:disable Security/Eval -- how RubyGems loads a gemspec

    [from_git, without_git].each do |spec|
      expect(spec.files).to include("data/daisyui/tailwind_manifest.json", "exe/daisyui-tailwind", "lib/tasks/daisyui.rake")
      expect(spec.executables).to include("daisyui-tailwind")
    end
  end
end
