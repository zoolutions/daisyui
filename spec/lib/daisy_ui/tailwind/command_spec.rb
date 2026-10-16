# frozen_string_literal: true

require "json"
require "open3"
require "rbconfig"
require "stringio"
require "tmpdir"

RSpec.describe DaisyUI::Tailwind::Command do
  let(:out) { StringIO.new }
  let(:err) { StringIO.new }
  let(:dir) { Dir.mktmpdir("daisyui-command") }

  def run(*argv) = described_class.run(argv, out:, err:)

  before { File.write(File.join(dir, "home_view.rb"), "Dropdown(:end) { |d| d.button { \"Menu\" } }\n") }

  after { FileUtils.rm_rf(dir) }

  it "prints the CSS for the components the given paths use, with what they render" do
    expect(run(dir)).to eq(0)
    expect(out.string).to include("/* daisyUI components: Button, CollapsibleSubMenu, Dropdown, Menu, MenuItem, SubMenu */")
    expect(err.string).to be_empty
  end

  it "takes component names instead of, or as well as, paths" do
    expect(run("--component", "Badge,Card", "--component", "DaisyUI::Alert")).to eq(0)
    expect(out.string).to include("/* daisyUI components: Alert, Badge, Card */")
  end

  it "prints JSON for a build script" do
    expect(run("--format", "json", "--responsive", "sm,md", dir)).to eq(0)

    json = JSON.parse(out.string)
    expect(json["components"].keys).to include("Dropdown", "Button")
    expect(json["classes"]).to include("dropdown", "sm:dropdown-end", "md:btn-primary")
  end

  it "applies a prefix" do
    expect(run("--prefix", "d-", "--component", "Button")).to eq(0)
    expect(out.string).to include('@source inline("d-btn ')
  end

  describe "--output" do
    let(:output) { File.join(dir, "generated", "daisyui.css") }

    it "writes the file, creating its directory, and leaves it untouched when nothing changed" do
      expect(run("--output", output, dir)).to eq(0)
      expect(File.read(output)).to include("/* DaisyUI::Dropdown */")
      expect(err.string).to include("wrote #{output}")

      File.utime(Time.at(0), Time.at(0), output)
      expect(run("--output", output, dir)).to eq(0)
      expect(File.mtime(output)).to eq(Time.at(0))
      expect(err.string).to include("#{output} is up to date")
      expect(out.string).to be_empty
    end
  end

  describe "errors" do
    it "exits 1 with usage when given neither paths nor components" do
      expect(run).to eq(1)
      expect(err.string).to include("Usage: daisyui-tailwind")
    end

    it "exits 1 on an unknown component" do
      expect(run("--component", "Buton")).to eq(1)
      expect(err.string).to include("daisyui-tailwind: DaisyUI has no component Buton")
    end

    it "exits 1 on a path that does not exist" do
      expect(run(File.join(dir, "nope"))).to eq(1)
      expect(err.string).to include("nope")
    end

    it "exits 1 when it cannot write the output" do
      blocker = File.join(dir, "home_view.rb")

      expect(run("--output", File.join(blocker, "daisyui.css"), dir)).to eq(1)
      expect(err.string).to start_with("daisyui-tailwind: ")
    end

    it "exits 1 on an unknown format or option" do
      expect(run("--format", "yaml", dir)).to eq(1)
      expect(run("--frobnicate")).to eq(1)
    end
  end

  it "--help prints usage and exits 0" do
    expect(run("--help")).to eq(0)
    expect(out.string).to include("Usage: daisyui-tailwind [options] [PATH...]")
  end

  it "runs as exe/daisyui-tailwind" do
    exe = File.join(DaisyUI::Tailwind::ROOT, "exe", "daisyui-tailwind")
    stdout, _stderr, status = Open3.capture3(RbConfig.ruby, exe, "--component", "Button")

    expect(status).to be_success
    expect(stdout).to include("/* DaisyUI::Button */")
  end
end
