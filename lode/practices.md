# Practices

Patterns this repository follows that `.claude/rules/` does not already state.
Style, file size, commit format, agent use and the TDD loop live there:
`../.claude/rules/coding-style.md`, `../.claude/rules/testing.md`,
`../.claude/rules/git-workflow.md`, `../.claude/rules/agents.md`.

## A class name is not a class name until Tailwind can read it

Anything that ends up in a `class=` attribute must exist as a literal string in
a file Tailwind scans. Three consequences the code relies on:

- `register_modifiers` values are literal (`primary: "btn-primary"`), never
  built by interpolation.
- Breakpoint variants exist **only** in the comments above each entry. The
  established shape is six variants per modifier — `sm:`, `@sm:`, `md:`, `@md:`,
  `lg:`, `@lg:` — written one per line (427 of the 472 comment blocks). Eight
  files add `xl:`/`@xl:` for a total of eight (`badge`, `drawer`, `dropdown`,
  `loading`, `menu`, `modal`, `table`, `tabs`: 42 blocks), and three blocks
  (`card.rb` `bordered`, `carousel.rb` `horizontal`, `skeleton.rb` `text`) pack
  the same six variants two to a line. What matters is the set of variants, not
  the line count. Copy the neighbouring modifier's set rather than inventing
  one; a missing variant is dropped from the built CSS with no error anywhere.
- A modifier mapping to several classes (`"bg-primary text-primary-content"`)
  needs each *token* spelled out in the comment, because `responsive_classes`
  splits and prefixes them one at a time.

## Merge into caller-supplied attributes; never overwrite

Every place a component adds to something the caller may also have set,
it merges. `data-controller` and `data-<identifier>-target` are space-joined
and `uniq`'d; `style` is joined after chomping a trailing `;`; `class` goes
through `merge_classes`/`component_classes`. Before writing `options[:x] = …`,
check whether `x` is caller-visible — `review/interactive.md` records the
clobbered-target bug that was exactly this.

The exception is `Dropdown#popover_menu_options` (`dropdown.rb:145-155`), which
rebuilds the panel's class list rather than merging: it has to strip
`dropdown-content`, whose descendant rule would force `position: absolute` onto a
top-layer popover. It still preserves the caller's other classes.

Coerce before you split: `apply_prefix` calls `String#split`, and
`component_class` is a Symbol in 58 of the 77 components.

## Options are destroyed as they are consumed

`classes` deletes `:class` and `:responsive` from `@options` so `attributes`
can splat the remainder straight onto the element. Anything a component
consumes as configuration must be deleted, or it is rendered as an HTML
attribute; anything it does *not* consume is passed through on purpose. This is
also why the argument order inside `classes` is load-bearing — `base_class`
reads `:responsive` before `responsive_classes` deletes it.

## Route caller attributes to the element they belong on

A component that renders a wrapper plus an inner control needs a named path for
the inner one. `Otp` takes `input_attributes:` for the `<input>`; without it
`name`/`id`/`value` land on the outer `<label>` and the component cannot be
submitted in a form. When adding a component with a hidden inner input, provide
the keyword from the start.

## Reject invalid configuration at construction

`Tooltip#validate_stimulus!` raises `ArgumentError` rather than rendering
`data-controller=""`. Prefer a raise at initialize time over markup that looks
wired and silently does nothing — a Phlex component has no other place to
report a problem.

## Empty string is not nil

Guards written as `if size` treat `""` as present and emit `--size: ;`.
`RadialProgress` uses `if size && !size.to_s.empty?`, which keeps the
empty-string suppression while tolerating a non-String. Use the same shape for
any optional value interpolated into a style or attribute.

## Specs assert the whole rendered string

`spec/support/html_helpers.rb#html` normalises an expected HTML heredoc so it
can be compared with `eq`. A spec that only checks a substring hides attribute
regressions; match the file you are editing.

## Restore global configuration in an `around` hook

`DaisyUI.configuration` is process-global. Every spec that changes it restores
it after `example.run`. See `review/testing-and-ci.md` for why the suite deliberately
does not use `ensure`.

## Docs examples are part of the component

`docs/app/views/components/examples/<component>/` is where a modifier is
demonstrated. Removing or renaming a modifier without updating those classes
leaves an example that renders a class daisyUI no longer defines, and the docs
build will not complain. Grep the examples directory for the modifier before
deleting it.

## Two RuboCop configurations

The gem root and `docs/` have separate `.rubocop.yml` files that disagree (most
visibly on multiline trailing commas). Lint the tree you edited, from its own
directory: `bundle exec rubocop` at the root, `bin/rubocop` in `docs/`.
