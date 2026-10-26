# frozen_string_literal: true

module DaisyUI
  # The declarative layer over `register_modifiers`: compound looks, defaults,
  # browser states and parts (slots), declared once in the class body.
  #
  #   class Widget < DaisyUI::Button
  #     variants do
  #       base "font-medium"
  #       variant :size, sm: "btn-sm [--fontsize:var(--text-sm)]"
  #       default :size, :md
  #       compound style: :outline, color: nil, class: "[--btn-bg:var(--color-base-100)]"
  #       state :hover, "hover"
  #       on :hover, style: %i[ghost link], class: "[--btn-bg:transparent]"
  #     end
  #   end
  #
  # `variant` and `flag` write through `register_modifiers` (so ClassMerge
  # groups, inheritance and finalize! stay as they are); everything else lands
  # in the class's `variant_definitions`, a frozen Hash replaced on every
  # write. `Widget.variants.schema` describes it all as plain data. Matching,
  # validation and rendering live in Variants::Match, Variants::Resolution and
  # Variants::Rendering.
  class Variants
    EMPTY = Shareable.make(
      { base: nil, defaults: {}, compounds: [], rules: [], states: {}, slots: {}, slot_classes: {} }
    )
    STATE_PREFIX = /\A[^\s"'`;{}\\]+\z/

    # The DSL for `klass`, with `block` evaluated against it.
    def self.build(klass, &block)
      new(klass).tap { |dsl| dsl.instance_exec(&block) if block }
    end

    def initialize(klass)
      @klass = klass
    end

    # Classes every instance gets, after the inherited base.
    def base(classes)
      write(base: [definitions[:base], classes].compact.join(" "))
    end

    # A group of alternatives: `variant :size, sm: "btn-sm", lg: "btn-lg"`. A
    # Hash value gives classes per slot (`sm: { root: "…", menu: "…" }`).
    def variant(group, **members)
      register(group => members.transform_values { |classes| root_classes(classes) })
      members.each { |member, classes| write_slot_classes(member, classes) }
      self
    end

    # An on/off modifier: `flag :wide, "btn-wide"`, or a flag with no class of
    # its own (`flag :collapsed`) that compounds and `on` rules can match.
    def flag(name, classes = nil)
      return tap { @klass.register_flags(name) } if classes.nil?

      register(name => root_classes(classes))
      write_slot_classes(name, classes)
      self
    end

    # The member used when the caller names no member of `group`.
    def default(group, member)
      check.member!(group, member)
      write(defaults: definitions[:defaults].merge(group => member))
    end

    # Adds `class:` and sets the variants in `set:` (members the caller did
    # not name) when every key of `match` holds. See Variants::Match.
    def compound(**match)
      classes = match.delete(:class)
      set = match.delete(:set) || {}
      raise ArgumentError, "#{owner}: compound #{match.inspect} needs class: or set:" if classes.nil? && set.empty?

      check.match!(match)
      set.each { |group, member| check.member!(group, member) }
      add(:compounds, match:, class: slot_hash(classes), set:)
    end

    # Names a Tailwind variant prefix once: `state :open, "[.dropdown[open]>&]"`.
    def state(name, prefix)
      raise ArgumentError, "#{owner}: state #{name.inspect} needs a Tailwind variant, got #{prefix.inspect}" unless STATE_PREFIX.match?(prefix.to_s)

      write(states: definitions[:states].merge(name => prefix.to_s))
    end

    # Like compound, with every class prefixed by each of the `states`.
    def on(states, **match)
      states = Array(states)
      classes = match.delete(:class)
      raise ArgumentError, "#{owner}: on #{states.inspect} needs class:" if classes.nil?

      states.each { |name| check.state!(name) }
      check.match!(match)
      add(:rules, states:, match:, class: slot_hash(classes))
    end

    # A part of the component (`root` is the component itself), with the
    # classes it always gets. Read with Base#slot_classes / #slot_options.
    def slot(name, classes = nil)
      raise ArgumentError, "#{owner}: :root is the component itself, not a slot to declare" if name == :root

      write(slots: definitions[:slots].merge(name => classes))
    end

    # Plain, frozen data describing the component, for docs pages, galleries
    # and design-tool parity checks.
    def schema
      Schema.new(@klass).to_h
    end

    # Every class the component's declarations can render, prefixed as
    # DaisyUI.configuration.prefix renders them: what Tailwind needs to see.
    def literal_classes(prefix: nil)
      Schema.new(@klass).literal_classes(prefix.to_s)
    end

    private

    def definitions = @klass.variant_definitions

    def owner = @klass.name || @klass.inspect

    def check = Match.new(@klass)

    def write(**changes)
      @klass.variant_definitions = definitions.merge(changes)
      self
    end

    def add(key, **entry)
      write(key => [*definitions[key], entry])
    end

    def register(modifiers)
      @klass.register_modifiers(modifiers)
    end

    def root_classes(classes)
      classes.is_a?(Hash) ? slot_hash(classes)[:root].to_s : classes.to_s
    end

    # Slot parts of a member, kept apart from `modifiers`, which only ever
    # holds the root's String.
    def write_slot_classes(member, classes)
      parts = classes.is_a?(Hash) ? slot_hash(classes).except(:root) : {}
      slot_classes = definitions[:slot_classes].except(member)
      write(slot_classes: parts.empty? ? slot_classes : slot_classes.merge(member => parts))
    end

    # `"a b"` or `{ root: "a", menu: "b" }` as `{ slot => classes }`.
    def slot_hash(classes)
      return {} if classes.nil?
      return { root: classes.to_s } unless classes.is_a?(Hash)

      classes.each_key { |slot| check.slot!(slot) }
      classes.transform_values(&:to_s)
    end
  end
end
