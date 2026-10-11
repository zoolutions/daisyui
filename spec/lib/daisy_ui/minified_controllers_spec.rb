# frozen_string_literal: true

require "json"

# The gem ships a minified twin of each Stimulus controller (`rake build:js`,
# via bun) and the importmap pins it. These guards assert the committed files
# are the real, shippable thing. The byte-for-byte "matches a fresh build"
# check is the CI `rake build:js_check` drift guard.
RSpec.describe "minified Stimulus controllers" do # rubocop:disable RSpec/DescribeClass
  let(:js_dir) { File.expand_path("../../../app/javascript/daisy_ui/controllers", __dir__) }

  %w[daisy_dropdown_controller daisy_tooltip_controller].each do |name|
    describe "#{name}.min.js" do
      let(:source_path) { File.join(js_dir, "#{name}.js") }
      let(:min_path) { File.join(js_dir, "#{name}.min.js") }
      let(:min)      { File.read(min_path) }
      let(:map_path) { "#{min_path}.map" }

      it "is committed alongside a linked sourcemap" do
        expect(File).to exist(map_path)
        expect(min.lines.last.strip).to eq("//# sourceMappingURL=#{name}.min.js.map")
      end

      it "is minified" do
        expect(File.size(min_path)).to be < File.size(source_path) * 0.7
        expect(min.lines.size).to be <= 4
        expect(min).not_to include("// daisy-")
      end

      it "has a sourcemap embedding the source" do
        map = JSON.parse(File.read(map_path))

        expect(map["version"]).to eq(3)
        expect(map["sources"]).to include(a_string_ending_with("#{name}.js"))
        expect(map["sourcesContent"]).to include(File.read(source_path))
      end

      it "keeps the default export and Stimulus as an external import" do
        expect(min).to match(/export\s*\{[^}]*\bas default\b|export default/)
        expect(min).to include('"@hotwired/stimulus"')
      end
    end
  end

  it "keeps @floating-ui/dom as a lazy external import in the dropdown controller" do
    expect(File.read(File.join(js_dir, "daisy_dropdown_controller.min.js"))).to include('import("@floating-ui/dom")')
  end
end
