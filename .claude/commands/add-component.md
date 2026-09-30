---
description: "Add a new DaisyUI component with full test coverage and documentation. Use when creating a component that doesn't exist yet."
model: sonnet
argument-hint: "component name in snake_case (e.g., floating_label, bottom_nav)"
---

# Add New Component

Create a new DaisyUI component with full test coverage and documentation.

## Arguments
- `$ARGUMENTS` - Component name in snake_case (e.g., "floating_label", "bottom_nav")

## Instructions

1. Get the official DaisyUI snippet:
   ```
   Use mcp__daisyui__daisyUI-Snippets with {"components": {"$ARGUMENTS": true}}
   ```

2. Create the gem component at `lib/daisy_ui/$ARGUMENTS.rb`:
   - Inherit from `DaisyUI::Base`
   - Set `self.component_class` to the DaisyUI class name
   - Use `register_modifiers` with ALL modifiers from the snippet
   - Include responsive comments (sm:, md:, lg:) for EVERY modifier
   - Nest mutually exclusive modifiers under a group (`size: {...}`, `color: {...}`, `placement: {...}`); leave combinable ones ungrouped
   - Implement `initialize` and `view_template` methods

3. Create the spec at `spec/lib/daisy_ui/$ARGUMENTS_spec.rb`:
   - Test default rendering
   - Test each modifier
   - Test responsive modifiers
   - Test custom classes and attributes

4. Run gem tests to verify:
   ```bash
   bundle exec rspec spec/lib/daisy_ui/$ARGUMENTS_spec.rb
   ```

5. Add docs example (from docs/ directory):
   ```bash
   bin/rails generate example_view $ARGUMENTS Components
   ```

6. Run docs tests:
   ```bash
   cd docs && bundle exec rspec spec/system/components_spec.rb
   ```

7. Report what was created and test results.
