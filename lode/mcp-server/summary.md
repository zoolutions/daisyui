# The bundled MCP server (`exe/daisyui-mcp`)

The gem ships a Model Context Protocol server so an agent can ask the installed
gem what components it has, rather than guessing. It is a hand-written JSON-RPC
loop over stdio in `lib/daisy_ui/mcp_server.rb` (245 lines) — no MCP SDK, no
runtime dependency beyond `json`.

`exe/daisyui-mcp` (7 lines) is the whole executable: `require "daisyui"`,
`require "daisy_ui/mcp_server"`, `DaisyUI::McpServer.run`. The gemspec derives
`s.executables` from the file list's `exe/` entries, so the binstub is installed
with the gem.

## The loop

`#run` (`mcp_server.rb:51-65`) reads a line from `$stdin`, parses it, writes the
response to `$stdout` and flushes. `JSON::ParserError` is caught per iteration
and only `warn`ed, so a malformed line does not end the session; `nil` from
`gets` (EOF) breaks the loop. Startup logging goes to stderr (`warn`) because
stdout is the protocol channel.

`#handle_request` (`mcp_server.rb:69-90`) dispatches four methods and rescues
`StandardError` into a JSON-RPC error, so no tool bug can kill the server:

| `method` | Handler | Response |
|---|---|---|
| `initialize` | `handle_initialize` | `PROTOCOL_VERSION` `"2024-11-05"`, `capabilities.tools`, `serverInfo` `{name: "daisyui", version: DaisyUI::VERSION}` |
| `tools/list` | `handle_tools_list` | the frozen `TOOLS` array |
| `tools/call` | `handle_tools_call` | `{content: [{type: "text", text: …}]}` |
| `notifications/initialized` | — | returns `nil`: notifications get no response |
| anything else | — | error `-32601`, "Method not found: …" |

An unknown tool name returns `isError: true` with a text body rather than a
JSON-RPC error; an internal exception returns code `-32603`.

## The three tools

`TOOLS` (`mcp_server.rb:13-41`) declares exactly three:

- `list_components` — every component as `- Name (css-class) - N modifiers`,
  plus a total.
- `get_component` (requires `component`) — CSS class, the sorted modifier names,
  and a canned usage block. Falls back to a case-insensitive match
  (`find_component_class`, `mcp_server.rb:233-239`) before reporting "not found".
- `search_components` (requires `query`) — matches the component name first
  (`next` on a hit, so a name match never also reports modifiers), then any
  modifier key containing the downcased query.

## What counts as a component

`#component_classes` (`mcp_server.rb:222-231`) memoises a walk of
`DaisyUI.constants`, skipping `EXCLUDED_CONSTANTS`
(`%i[Base Configurable Configuration Modifiers VERSION UPDATED_AT McpServer]`,
7 entries) and keeping only constants that are a `Class` **and** `< DaisyUI::Base`.
The `< Base` test is what does the real filtering — it is what drops `Engine`,
and `Configuration`/`Modifiers` are nested under `Configurable` so they never
appear in `DaisyUI.constants` at all.

`DaisyUI.constants` lists Zeitwerk's autoload entries too (Zeitwerk registers
them with `Module#autoload`, and Ruby counts an autoload name as a constant),
so `const_get` on each one loads the file: the walk sees all 77 components in a
process that has referenced none of them. The memoisation in `@component_classes`
means a component defined *after* the first tool call is invisible for the rest
of the session — harmless for a stdio server whose library is frozen at boot.

There is no spec for this file: `spec/lib/daisy_ui/` has no `mcp_server_spec.rb`.

## Related

- The repo's own `.claude/settings.local.json` allows a *different*, external
  MCP tool (`mcp__daisyui__daisyUI-Snippets`) for looking up daisyUI class
  names; that server is not this file. See `../workflow.md` → Commands.
