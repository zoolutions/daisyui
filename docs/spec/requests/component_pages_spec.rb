# frozen_string_literal: true

require "rails_helper"

# Renders every component reference page. DaisyUI raises on unknown modifiers
# in the test environment, so an example passing a modifier its component does
# not register fails here.
RSpec.describe "Component pages", type: :request do
  let(:headers) do
    {
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                           "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36",
    }
  end

  it "raises on unknown modifiers in the test environment" do
    expect(DaisyUI.configuration.unknown_modifiers).to eq(:raise)
  end

  it "explains under the popover tooltip example that a tap toggles it" do
    get component_path("tooltip"), headers: headers

    section = response.parsed_body.at_css("section#viewport-aware-popover")
    expect(section.at_css("h2 + p").text).to eq(
      "On a touch screen a tap toggles the tooltip, and a tap anywhere else closes it."
    )
  end

  ComponentDoc.all.select { it.examples&.any? }.each do |component|
    it "renders /components/#{component.slug}" do
      get component_path(component.slug), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
