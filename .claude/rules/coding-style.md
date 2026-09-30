# Coding Style Rules

## File Organization

**MANY SMALL FILES > FEW LARGE FILES**

- High cohesion, low coupling
- 200-400 lines typical
- 800 lines maximum per file
- Extract complex logic to dedicated classes
- One component per file

## Ruby Style

### Component Classes

```ruby
# Good: Small, focused component
class DaisyUI::Button < DaisyUI::Base
  self.component_class = :btn

  def initialize(*, as: :button, **)
    super
  end

  def view_template(&)
    public_send(as, class: classes, **attributes, &)
  end

  register_modifiers(
    # "sm:btn-primary" "md:btn-primary" "lg:btn-primary"
    primary: "btn-primary"
  )
end
```

### Modifier Registration

```ruby
# Good: responsive comments for Tailwind CSS content detection, and
# mutually exclusive modifiers grouped so ClassMerge keeps only the last one
register_modifiers(
  color: {
    # "sm:btn-primary" "md:btn-primary" "lg:btn-primary"
    primary: "btn-primary"
  },
  size: {
    # "sm:btn-lg" "md:btn-lg" "lg:btn-lg"
    lg: "btn-lg"
  }
)

# Bad: Missing responsive comments (Tailwind won't generate responsive classes)
register_modifiers(
  primary: "btn-primary",
  lg: "btn-lg"
)
```

### Sub-component Methods

```ruby
# Good: Consistent sub-component pattern
def body(**options, &)
  div(class: component_classes("card-body", options:), **options, &)
end

# Bad: Inconsistent or overly complex
def body(as: :div, variant: nil, **opts, &block)
  # 30 lines of logic...
end
```

### DaisyUI MCP Server

Always use `mcp__daisyui__daisyUI-Snippets` to verify correct DaisyUI class names before creating or modifying components.

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Methods are small (<30 lines ideal, <50 max)
- [ ] Files are focused (<800 lines)
- [ ] Responsive comments present for all modifiers
- [ ] Component class matches DaisyUI 5 spec
- [ ] Rubocop passes
