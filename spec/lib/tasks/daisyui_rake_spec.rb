# frozen_string_literal: true

require "rake"
require "tmpdir"

RSpec.describe "rake daisyui:tailwind" do # rubocop:disable RSpec/DescribeClass -- a rake task
  let(:rake) { Rake::Application.new }
  let(:dir)  { Dir.mktmpdir("daisyui-rake") }

  before do
    Rake.application = rake
    rake.define_task(Rake::Task, :environment)
    load File.join(DaisyUI::Tailwind::ROOT, "lib", "tasks", "daisyui.rake")
  end

  after do
    Rake.application = Rake::Application.new
    FileUtils.rm_rf(dir)
  end

  it "writes the app's own components to the output, after the environment" do
    output = File.join(dir, "daisyui_app.css")

    expect { rake["daisyui:tailwind"].invoke(output) }.to output(/wrote #{Regexp.escape(output)}/).to_stderr
    expect(File.read(output)).to include("/* VariantsFixtures::Widget */")
    expect(rake["daisyui:tailwind"].prerequisites).to eq(%w[environment])
  end

  it "prints them without an output" do
    expect { rake["daisyui:tailwind"].invoke }.to output(%r{/\* VariantsFixtures::Thing \*/}).to_stdout
  end

  it "is left out of Zeitwerk, which manages the rest of lib/" do
    Zeitwerk::Loader.eager_load_namespace(DaisyUI)

    expect(Object.autoload?(:Tasks)).to be_nil
    expect(defined?(Tasks)).to be_nil
  end
end
