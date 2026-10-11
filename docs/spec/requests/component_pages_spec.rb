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

  ComponentDoc.all.select { it.examples&.any? }.each do |component|
    it "renders /components/#{component.slug}" do
      get component_path(component.slug), headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
