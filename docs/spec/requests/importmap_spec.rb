# frozen_string_literal: true

require "rails_helper"

# The daisyui gem pins its Stimulus controllers to minified builds with linked
# sourcemaps, and does not preload them. This checks what a real
# importmap-rails + Propshaft host (this app) resolves and serves.
RSpec.describe "DaisyUI controller import map", type: :request do
  let(:headers) do
    {
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                           "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36",
    }
  end
  let(:gem_controllers) { Rails.root.join("..", "app", "javascript", "daisy_ui", "controllers") }

  let(:page_body) do
    get component_path("tooltip"), headers: headers
    response.body
  end
  let(:imports) do
    JSON.parse(page_body[%r{<script type="importmap"[^>]*>(.*?)</script>}m, 1]).fetch("imports")
  end

  it "does not pin the minified twins as modules of their own" do
    expect(imports.keys.grep(%r{\Adaisy_ui/controllers/})).to contain_exactly(
      "daisy_ui/controllers/daisy_dropdown_controller",
      "daisy_ui/controllers/daisy_tooltip_controller"
    )
  end

  it "does not preload the controllers" do
    expect(page_body.scan(/<link rel="modulepreload"[^>]*>/).grep(%r{daisy_ui/controllers})).to be_empty
  end

  %w[daisy_dropdown_controller daisy_tooltip_controller].each do |name|
    describe name do
      let(:url) { imports.fetch("daisy_ui/controllers/#{name}") }

      it "resolves to the digested minified build" do
        expect(url).to match(%r{/assets/daisy_ui/controllers/#{name}\.min-\h+\.js\z})
      end

      it "serves the minified build with a sourcemap devtools can load" do
        get url, headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.body.bytesize).to be < gem_controllers.join("#{name}.js").size
        expect(response.body).to include('"@hotwired/stimulus"')

        map_url = response.body[/sourceMappingURL=(\S+)/, 1]
        expect(map_url).to match(%r{\A/assets/daisy_ui/controllers/#{name}\.min-\h+\.js\.map\z})

        get map_url, headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include("sourcesContent")
      end
    end
  end
end
