# frozen_string_literal: true

require "json"
require "stringio"

RSpec.describe DaisyUI::McpServer do
  def call(name, arguments = {})
    request = { jsonrpc: "2.0", id: 1, method: "tools/call", params: { name:, arguments: } }
    response = described_class.new.send(:handle_request, JSON.parse(JSON.generate(request)))
    response.dig(:result, :content, 0, :text)
  end

  describe "tools/list" do
    it "lists every tool, variants_guide included" do
      response = described_class.new.send(:handle_request, { "id" => 1, "method" => "tools/list" })

      expect(response.dig(:result, :tools).map { |tool| tool[:name] })
        .to eq(%w[list_components get_component search_components variants_guide])
    end
  end

  describe "get_component" do
    it "shows the variants schema of a component built on register_modifiers" do
      text = call("get_component", { "component" => "Dropdown" })

      expect(text).to include("## Variants schema")
      schema = JSON.parse(text[/```json\n(.*?)\n```/m, 1])
      expect(schema.keys).to eq(%w[base variants flags defaults compounds on states slots])
      expect(schema["variants"]).to include("placement" => %w[top bottom left right])
      expect(schema["flags"]).to include("hover", "open")
    end

    it "shows defaults, compounds, on rules, states and slots a component declares" do
      stub_const("DaisyUI::McpSpecPicker", Class.new(DaisyUI::Dropdown) do
        variants do
          slot :menu, "mt-2"
          default :placement, :bottom
          state :open, "[.dropdown[open]>&]"
          compound placement: :top, class: { menu: "mb-2" }
          on :open, class: { menu: "shadow-lg" }
        end
      end
      )

      text = described_class.new.send(:get_component, "McpSpecPicker")
      schema = JSON.parse(text[/```json\n(.*?)\n```/m, 1])

      expect(schema["defaults"]).to eq("placement" => "bottom")
      expect(schema["states"]).to eq("open" => "[.dropdown[open]>&]")
      expect(schema["compounds"].first).to include("match" => { "placement" => "top" }, "class" => { "menu" => "mb-2" })
      expect(schema["on"].first).to include("states" => ["open"], "class" => { "menu" => "shadow-lg" })
      expect(schema["slots"]).to include("menu" => "mt-2")
    end

    it "keeps the modifier list and usage examples" do
      text = call("get_component", { "component" => "button" })

      expect(text).to include("# Button Component", "## Available Modifiers", "## Usage Examples")
    end

    it "points at the guide" do
      expect(call("get_component", { "component" => "Button" })).to include("variants_guide")
    end
  end

  describe "variants_guide" do
    subject(:guide) { call("variants_guide") }

    it "explains each declaration" do
      expect(guide).to include("variant", "flag", "default", "compound", "state", "on(", "slot", "schema")
    end

    it "tells the match values" do
      expect(guide).to include("nil", "true", "[nil, :row]")
    end

    it "names the render order and the three pitfalls" do
      expect(guide).to include("Render order")
      expect(guide).to match(/default.*after the caller's modifiers/m)
      expect(guide).to match(/compound.*override/m)
      expect(guide).to match(/prefix is outermost|outermost/)
    end

    it "points at the Tailwind sources for on classes" do
      expect(guide).to include("daisyui-tailwind --app")
    end
  end

  describe "an unknown tool" do
    it "is an error" do
      response = described_class.new.send(:handle_request, { "id" => 1, "method" => "tools/call", "params" => { "name" => "nope" } })

      expect(response.dig(:result, :isError)).to be(true)
    end
  end
end
