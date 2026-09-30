# frozen_string_literal: true

require "rails_helper"

# A modern User-Agent so the `allow_browser versions: :modern` filter lets the
# request through (Rack::Test sends none by default).
MODERN_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"

RSpec.describe "Pages", type: :request do
  let(:headers) { { "HTTP_USER_AGENT" => MODERN_UA } }

  describe "GET /" do
    it "renders the landing page with the component reference" do
      get root_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("DaisyUI Ruby")
      expect(response.body).to include("Button")
    end
  end

  describe "GET /docs/:doc" do
    it "renders an authored guide page" do
      get doc_path("installation"), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Installation")
    end

    it "renders the class merging guide with live merge results" do
      get doc_path("class-merging"), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Class merging")
      expect(response.body).to include(">btn btn-sm btn-lg<")
      expect(response.body).to include(">btn btn-lg<")
      expect(response.body).to include("dropdown dropdown-top dropdown-end")
    end

    it "404s for an unknown slug" do
      get doc_path("nope"), headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "404s for a registered doc whose page class does not exist yet" do
      get doc_path("getting-started"), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /components/:component" do
    it "renders a component page with the reactive Preview/Source viewer" do
      get component_path("button"), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Button")
      # The example viewer is reactive: it carries the controller + signed token.
      expect(response.body).to include('data-controller="reactive"')
      expect(response.body).to include("data-reactive-token-value")
      expect(response.body).to include('data-testid="example-viewer"')
      # daisyUI tabs use `tabs-lift` (not the removed `tabs-lifted`).
      expect(response.body).to include("tabs-lift")
      expect(response.body).not_to include("tabs-lifted")
    end

    it "404s for an unknown component" do
      get component_path("nope"), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "the reactive example viewer" do
    it "toggles to the Source tab via a phlex-reactive action" do
      get component_path("button"), headers: headers
      token = response.body[/data-reactive-token-value="([^"]+)"/, 1]
      csrf = response.body[/name="csrf-token" content="([^"]+)"/, 1]
      expect(token).to be_present

      post "/reactive/actions",
           params: { token: token, act: "show_source", params: {} }.to_json,
           headers: headers.merge(
             "CONTENT_TYPE" => "application/json",
             "HTTP_ACCEPT" => "text/vnd.turbo-stream.html",
             "HTTP_X_CSRF_TOKEN" => csrf
           )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include('data-testid="tab-source"')
    end
  end

  describe "GET /up" do
    it "returns 200 for the health check" do
      get rails_health_check_path, headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
