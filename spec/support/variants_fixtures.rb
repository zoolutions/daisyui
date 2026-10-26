# frozen_string_literal: true

# Components for spec/lib/daisy_ui/variants_spec.rb and the Tailwind app-sources
# specs. Named, so error messages, schemas and Tailwind blocks read as they would
# in an app.
module VariantsFixtures
  OPEN = "[.dropdown:is(:focus-within,[open],:has(:popover-open))>&]"
  QUIET = "[--btn-bg:var(--color-base-100)] [--btn-border:color-mix(in_oklab,var(--color-base-content)_20%,transparent)]"
  FILL = "[--btn-bg:color-mix(in_oklab,var(--btn-color,var(--color-base-200)),var(--color-base-content)_8%)]"
  OUTLINE = "[--btn-bg:color-mix(in_oklab,var(--color-base-100),var(--color-base-content)_8%)]"
  CLEAR = "[--btn-bg:color-mix(in_oklab,var(--color-base-content)_8%,transparent)]"

  # The issue's reproduction, as an app writes it without the Variants API.
  class LegacyWidget < DaisyUI::Button
    register_modifiers(size: { sm: "btn-sm [--fontsize:var(--text-sm)]", md: "btn-md [--fontsize:var(--text-base)]" })

    HOVER = { fill: "hover:#{FILL}", outline: "hover:#{OUTLINE}", clear: "hover:#{CLEAR}" }.freeze
    OPENED = { fill: "#{OPEN}:#{FILL}", outline: "#{OPEN}:#{OUTLINE}", clear: "#{OPEN}:#{CLEAR}" }.freeze
    QUIET_PARTS = QUIET.split.freeze

    def initialize(*, trigger: false, **)
      @trigger = trigger
      super(*, **)
    end

    def base_class
      quiet = QUIET if modifiers.include?(:outline) && !colour?
      "#{super} font-medium #{HOVER.fetch(kind)} #{OPENED.fetch(kind) if @trigger} #{quiet}".squeeze(" ").strip
    end

    private

    def colour? = modifiers.intersect?(%i[primary secondary accent neutral info success warning error])

    def kind
      return :clear if modifiers.include?(:link) || modifiers.include?(:ghost)

      modifiers.include?(:outline) && !colour? ? :outline : :fill
    end
  end

  # The same design, declared once.
  class Widget < DaisyUI::Button
    variants do
      base "font-medium"
      variant :size, sm: "btn-sm [--fontsize:var(--text-sm)]", md: "btn-md [--fontsize:var(--text-base)]"
      default :size, :md

      compound style: :outline, color: nil, class: QUIET

      state :hover, "hover"
      state :open, OPEN

      on %i[hover open], style: [nil, :dash, :soft], class: FILL
      on %i[hover open], style: :outline, color: true, class: FILL
      on %i[hover open], style: :outline, color: nil, class: OUTLINE
      on %i[hover open], style: %i[ghost link], class: CLEAR
    end
  end

  # Every matching rule, on a component of its own.
  class Thing < DaisyUI::Base
    self.component_class = :thing

    def view_template(&) = div(class: classes, **attributes, &)

    variants do
      variant :size, sm: "thing-sm", md: "thing-md", lg: "thing-lg"
      variant :tone, calm: "thing-calm", loud: "thing-loud"
      variant :shape, row: "thing-row", box: "thing-box"
      flag :round, "thing-round"
      flag :collapsed
      default :size, :md

      compound size: :lg, class: "c-lg"
      compound size: %i[sm md], class: "c-small"
      compound tone: nil, class: "c-untoned"
      compound round: true, class: "c-round"
      compound round: false, tone: :loud, class: "c-loud-square"
      compound shape: [nil, :row], class: "c-not-box"
      compound collapsed: true, set: { shape: :row }, class: "c-collapsed"
      compound shape: :row, class: "c-row"

      state :hover, "hover"
      state :focus, "focus-visible"
      on :hover, class: "tint-a tint-b"
      on %i[hover focus], size: :lg, class: "tint-lg"
    end
  end

  # A component with parts: the trigger and the menu follow its variants.
  class Picker < DaisyUI::Dropdown
    variants do
      slot :trigger, "picker-trigger"
      slot :menu, "mt-2"
      variant :reach, wide: { root: "picker-wide", menu: "w-96" }, narrow: { menu: "w-48" }
      compound reach: :wide, class: { trigger: "btn-block" }
      state :open, OPEN
      on :open, class: { root: "z-10", menu: "shadow-lg" }
    end

    def trigger(*modifiers, **options, &) = render DaisyUI::Button.new(*modifiers, **slot_options(:trigger, options), &)

    def list(*modifiers, **options, &) = render DaisyUI::Menu.new(*modifiers, class: slot_classes(:menu, options), **options, &)
  end
end
