# frozen_string_literal: true

require "json"

module DaisyUI
  # MCP (Model Context Protocol) server for DaisyUI components.
  # Provides component information to AI assistants via JSON-RPC over stdio.
  class McpServer
    PROTOCOL_VERSION = "2024-11-05"
    SERVER_NAME = "daisyui"
    SERVER_VERSION = DaisyUI::VERSION

    TOOLS = [
      {
        name: "list_components",
        description: "List all available DaisyUI Ruby/Phlex components with their CSS classes and modifiers",
        inputSchema: { type: "object", properties: {}, required: [] }
      },
      {
        name: "get_component",
        description: "Get detailed information about a specific DaisyUI component including all modifiers and usage examples",
        inputSchema: {
          type: "object",
          properties: {
            component: { type: "string", description: "Component name (e.g., 'Button', 'Card', 'Modal')" }
          },
          required: ["component"]
        }
      },
      {
        name: "search_components",
        description: "Search for components by name or modifier",
        inputSchema: {
          type: "object",
          properties: {
            query: { type: "string", description: "Search query (component name or modifier)" }
          },
          required: ["query"]
        }
      }
    ].freeze
    Shareable.make(TOOLS) # the Hashes inside too

    EXCLUDED_CONSTANTS = %i[Base Configurable Configuration Modifiers VERSION UPDATED_AT McpServer].freeze

    class << self
      def run
        new.run
      end
    end

    def run
      warn "DaisyUI MCP Server v#{SERVER_VERSION} starting..."

      loop do
        line = $stdin.gets
        break if line.nil?

        request = JSON.parse(line)
        response = handle_request(request)
        $stdout.puts JSON.generate(response)
        $stdout.flush
      rescue JSON::ParserError => e
        warn "JSON parse error: #{e.message}"
      end
    end

    private

    def handle_request(request)
      id = request["id"]
      method = request["method"]
      params = request["params"] || {}

      result = case method
      when "initialize"
        handle_initialize(params)
      when "tools/list"
        handle_tools_list
      when "tools/call"
        handle_tools_call(params)
      when "notifications/initialized"
        return nil # No response for notifications
      else
        return error_response(id, -32_601, "Method not found: #{method}")
      end

      { jsonrpc: "2.0", id: id, result: result }
    rescue StandardError => e
      error_response(id, -32_603, "Internal error: #{e.message}")
    end

    def handle_initialize(_params)
      {
        protocolVersion: PROTOCOL_VERSION,
        capabilities: { tools: {} },
        serverInfo: { name: SERVER_NAME, version: SERVER_VERSION }
      }
    end

    def handle_tools_list
      { tools: TOOLS }
    end

    def handle_tools_call(params)
      tool_name = params["name"]
      arguments = params["arguments"] || {}

      content = case tool_name
      when "list_components"
        list_components
      when "get_component"
        get_component(arguments["component"])
      when "search_components"
        search_components(arguments["query"])
      else
        return { content: [{ type: "text", text: "Unknown tool: #{tool_name}" }], isError: true }
      end

      { content: [{ type: "text", text: content }] }
    end

    def list_components
      components = component_classes.map do |name, klass|
        css_class = klass.respond_to?(:component_class) ? klass.component_class : name.downcase
        modifier_count = klass.respond_to?(:modifiers) && klass.modifiers ? klass.modifiers.size : 0
        "- #{name} (#{css_class}) - #{modifier_count} modifiers"
      end

      <<~TEXT
        # DaisyUI Ruby/Phlex Components

        #{components.join("\n")}

        Total: #{components.size} components

        Use `get_component` for detailed information about a specific component.
      TEXT
    end

    def get_component(name)
      return "Error: Component name required" if name.nil? || name.empty?

      # Try exact match first, then case-insensitive
      klass = find_component_class(name)
      return "Component '#{name}' not found. Use `list_components` to see available components." unless klass

      component_name = klass.name.split("::").last
      css_class = klass.respond_to?(:component_class) ? klass.component_class : component_name.downcase
      modifiers = klass.respond_to?(:modifiers) && klass.modifiers ? klass.modifiers : {}

      # Group modifiers by category
      modifier_list = modifiers.keys.map(&:to_s).sort.join(", ")

      <<~TEXT
        # #{component_name} Component

        **CSS Class:** `#{css_class}`

        ## Available Modifiers
        #{modifier_list.empty? ? 'No modifiers' : modifier_list}

        ## Usage Examples

        ```ruby
        # Basic usage
        #{component_name}() { "Content" }

        # With modifiers
        #{component_name}(:primary) { "Primary styled" }
        #{component_name}(:lg, :outline) { "Large outline" }

        # With HTML attributes
        #{component_name}(id: "my-#{css_class}", class: "custom") { "Custom" }

        # As different element
        #{component_name}(as: :a, href: "/path") { "Link" }
        ```
      TEXT
    end

    def search_components(query)
      return "Error: Search query required" if query.nil? || query.empty?

      query_downcase = query.downcase
      matches = []

      component_classes.each do |name, klass|
        # Match component name
        if name.downcase.include?(query_downcase)
          matches << { name: name, match_type: "name" }
          next
        end

        # Match modifiers
        next unless klass.respond_to?(:modifiers) && klass.modifiers

        matching_mods = klass.modifiers.keys.select { |m| m.to_s.include?(query_downcase) }
        matches << { name: name, match_type: "modifier", modifiers: matching_mods } unless matching_mods.empty?
      end

      if matches.empty?
        "No components found matching '#{query}'"
      else
        results = matches.map do |m|
          if m[:match_type] == "name"
            "- #{m[:name]} (name match)"
          else
            "- #{m[:name]} (modifiers: #{m[:modifiers].join(', ')})"
          end
        end

        <<~TEXT
          # Search Results for "#{query}"

          #{results.join("\n")}

          Found #{matches.size} component(s).
        TEXT
      end
    end

    def component_classes
      @component_classes ||= DaisyUI.constants.each_with_object({}) do |const_name, hash|
        next if EXCLUDED_CONSTANTS.include?(const_name)

        klass = DaisyUI.const_get(const_name)
        next unless klass.is_a?(Class) && klass < DaisyUI::Base

        hash[const_name.to_s] = klass
      end
    end

    def find_component_class(name)
      # Exact match
      return component_classes[name] if component_classes.key?(name)

      # Case-insensitive match
      component_classes.find { |k, _| k.downcase == name.downcase }&.last
    end

    def error_response(id, code, message)
      { jsonrpc: "2.0", id: id, error: { code: code, message: message } }
    end
  end
end
