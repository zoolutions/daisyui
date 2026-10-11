# frozen_string_literal: true

# config/importmap.rb is evaluated by importmap-rails in the host app, which the
# gem's bundle does not load, so this reads it as text. The docs app's
# spec/requests/importmap_spec.rb checks the resolved import map end to end.
RSpec.describe "config/importmap.rb" do # rubocop:disable RSpec/DescribeClass
  subject(:config) { File.read(File.expand_path("../../../config/importmap.rb", __dir__)) }

  it "pins each controller explicitly, not the directory (it also holds the .min.js twins)" do
    expect(config).not_to match(/^\s*pin_all_from/)
  end

  %w[daisy_dropdown_controller daisy_tooltip_controller].each do |name|
    it "pins daisy_ui/controllers/#{name} to its minified build without preloading it" do
      expect(config).to match(
        %r{^pin "daisy_ui/controllers/#{name}",\s+to: "daisy_ui/controllers/#{name}\.min\.js",\s+preload: false$}
      )
    end
  end
end
