# frozen_string_literal: true

# Each Stimulus controller is named in the build script and in the importmap.
# A controller added to one and not the other would ship unminified or unpinned.
RSpec.describe "Stimulus controller lists" do # rubocop:disable RSpec/DescribeClass
  let(:root) { File.expand_path("../../..", __dir__) }
  let(:sources) do
    Dir[File.join(root, "app/javascript/daisy_ui/controllers/*_controller.js")].map { |f| File.basename(f, ".js") }.sort
  end
  let(:built) do
    File.read(File.join(root, "scripts/build_controllers.js"))[/const ENTRIES = \[([^\]]*)\]/, 1].scan(/"(\w+)"/).flatten.sort
  end
  let(:pinned) do
    File.read(File.join(root, "config/importmap.rb")).scan(%r{^pin "daisy_ui/controllers/(\w+)"}).flatten.sort
  end

  it "builds every controller source" do
    expect(built).to eq(sources)
  end

  it "pins every controller source" do
    expect(pinned).to eq(sources)
  end
end
