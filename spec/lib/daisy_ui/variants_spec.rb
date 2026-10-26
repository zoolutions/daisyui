# frozen_string_literal: true

RSpec.describe DaisyUI::Variants do
  def class_list(component) = component.call[/class="([^"]*)"/, 1].to_s.split

  describe "the issue's Widget, declared with variants" do
    let(:widget) { VariantsFixtures::Widget }
    let(:legacy) { VariantsFixtures::LegacyWidget }

    [[:ghost], [:outline], %i[outline primary], [:link], [], [:soft]].each do |modifiers|
      it "renders what the hand-written Widget renders as a dropdown trigger for #{modifiers.inspect}" do
        expect(class_list(widget.new(*modifiers)))
          .to match_array(class_list(legacy.new(*modifiers, :md, trigger: true)))
      end
    end

    it "carries the open-dropdown forms inside a dropdown, with no keyword to pass" do
      html = DaisyUI::Dropdown.new.call { |dropdown| dropdown.render(widget.new(:ghost)) }

      expect(html).to include("#{VariantsFixtures::OPEN}:#{VariantsFixtures::CLEAR}", "hover:#{VariantsFixtures::CLEAR}")
    end

    it "gives Widget() the default size and Widget(:sm) the size it names, and nothing else differs" do
      default = class_list(widget.new)
      small = class_list(widget.new(:sm))

      expect(default).to include("btn-md", "[--fontsize:var(--text-base)]")
      expect(small).to include("btn-sm", "[--fontsize:var(--text-sm)]")
      expect(small).not_to include("btn-md")
      expect(default - small).to contain_exactly("btn-md", "[--fontsize:var(--text-base)]")
      expect(small - default).to contain_exactly("btn-sm", "[--fontsize:var(--text-sm)]")
    end

    it "leaves the parent's members and rendering alone" do
      expect(DaisyUI::Button.modifiers[:sm]).to eq("btn-sm")
      expect(DaisyUI::Button.new(:sm).call).to eq('<button class="btn btn-sm"></button>')
    end
  end

  describe "defaults" do
    it "applies the default when no member of the group is given" do
      expect(class_list(VariantsFixtures::Thing.new)).to include("thing-md")
    end

    it "leaves the default out when a member is given, also with class merging off" do
      expect(class_list(VariantsFixtures::Thing.new(:lg))).not_to include("thing-md")

      DaisyUI.configure { |config| config.class_merge.enabled = false }
      expect(class_list(VariantsFixtures::Thing.new(:lg))).not_to include("thing-md")
    ensure
      DaisyUI.configure { |config| config.class_merge.enabled = true }
    end

    it "keeps the default beside a responsive member, which only applies at a breakpoint" do
      expect(class_list(VariantsFixtures::Thing.new(responsive: { sm: :lg }))).to include("thing-md", "sm:thing-lg")
    end
  end

  describe "compound" do
    def classes_for(*modifiers) = class_list(VariantsFixtures::Thing.new(*modifiers))

    it "matches a member, given or defaulted" do
      expect(classes_for(:lg)).to include("c-lg")
      expect(classes_for).to include("c-small")
      expect(classes_for(:lg)).not_to include("c-small")
    end

    it "matches any member of an Array" do
      expect(classes_for(:sm)).to include("c-small")
    end

    it "matches nil when no member of the group is given" do
      expect(classes_for).to include("c-untoned")
      expect(classes_for(:calm)).not_to include("c-untoned")
    end

    it "matches nil inside an Array as 'none, or one of these'" do
      expect(classes_for).to include("c-not-box")
      expect(classes_for(:row)).to include("c-not-box")
      expect(classes_for(:box)).not_to include("c-not-box")
    end

    it "matches a flag that is on, or off" do
      expect(classes_for(:round)).to include("thing-round", "c-round")
      expect(classes_for(:loud)).to include("c-loud-square")
      expect(classes_for(:loud, :round)).not_to include("c-loud-square")
    end

    it "sets a variant that a later compound reads, and renders the member it set" do
      expect(classes_for(:collapsed)).to include("c-collapsed", "thing-row", "c-row")
    end

    it "never overrides a member the caller gave" do
      expect(classes_for(:collapsed, :box)).to include("c-collapsed", "thing-box")
      expect(classes_for(:collapsed, :box)).not_to include("thing-row", "c-row", "c-not-box")
    end

    it "renders in declaration order after the modifiers, before the caller's class" do
      html = VariantsFixtures::Thing.new(:lg, class: "extra").call

      expect(html).to eq('<div class="thing thing-lg c-lg c-untoned c-not-box hover:tint-a hover:tint-b hover:tint-lg focus-visible:tint-lg extra"></div>')
    end
  end

  describe "on" do
    it "writes a declaration once and prefixes it with each state" do
      classes = class_list(VariantsFixtures::Thing.new(:lg))

      expect(classes).to include("hover:tint-a", "hover:tint-b", "hover:tint-lg", "focus-visible:tint-lg")
      expect(class_list(VariantsFixtures::Thing.new(:sm))).not_to include("hover:tint-lg")
    end
  end

  describe "slots" do
    let(:html) do
      VariantsFixtures::Picker.new(:wide).call do |picker|
        picker.trigger(:ghost, class: "mine") { "Open" }
        picker.list(class: "p-2")
      end
    end

    it "gives the root its variant, compound and state classes" do
      expect(html).to start_with(%(<div class="dropdown picker-wide #{VariantsFixtures::OPEN}:z-10">))
    end

    it "gives each part its base, variant, compound and state classes, then the caller's" do
      expect(html).to include(%(<button class="btn btn-ghost picker-trigger btn-block mine">Open</button>))
      expect(html).to include(%(<ul class="menu mt-2 w-96 #{VariantsFixtures::OPEN}:shadow-lg p-2"></ul>))
    end

    it "follows the variant the caller picks" do
      html = VariantsFixtures::Picker.new(:narrow).call(&:list)

      expect(html).to include(%(<ul class="menu mt-2 w-48 #{VariantsFixtures::OPEN}:shadow-lg"></ul>))
    end

    it "raises for a slot the component does not declare" do
      expect { VariantsFixtures::Picker.new.call { |picker| picker.send(:slot_classes, :footer, {}) } }
        .to raise_error(ArgumentError, /VariantsFixtures::Picker has no slot :footer/)
    end
  end

  describe "base" do
    it "appends to the inherited base" do
      child = Class.new(VariantsFixtures::Widget) { variants { base "tracking-tight" } }

      expect(child.variants.schema[:base]).to eq("btn font-medium tracking-tight")
      expect(VariantsFixtures::Widget.variants.schema[:base]).to eq("btn font-medium")
      expect(class_list(child.new)).to include("btn", "font-medium", "tracking-tight")
    end
  end

  describe "inheritance" do
    let(:child) do
      Class.new(VariantsFixtures::Thing) do
        variants do
          variant :size, lg: "thing-huge"
          compound size: :lg, class: "c-huge"
        end
      end
    end

    it "overrides one inherited member and adds compounds after the parent's" do
      expect(class_list(child.new(:lg))).to include("thing-huge", "c-lg", "c-huge")
      expect(class_list(VariantsFixtures::Thing.new(:lg))).not_to include("thing-huge", "c-huge")
      expect(child.modifier_groups[:size]).to eq(%i[sm md lg])
    end
  end

  describe "class merging" do
    it "groups a variant's members, so the caller's class replaces the member" do
      expect(class_list(VariantsFixtures::Thing.new(:sm, class: "thing-lg"))).to include("thing-lg")
      expect(class_list(VariantsFixtures::Thing.new(:sm, class: "thing-lg"))).not_to include("thing-sm")
    end
  end

  describe "with a configured prefix", :finalizes do
    before { DaisyUI.configure { |config| config.prefix = "d-" } }

    it "prefixes every declared class, after the state" do
      expect(VariantsFixtures::Thing.new(:lg).call)
        .to eq('<div class="d-thing d-thing-lg d-c-lg d-c-untoned d-c-not-box hover:d-tint-a hover:d-tint-b hover:d-tint-lg focus-visible:d-tint-lg"></div>')
    end
  end

  describe "unknown modifiers" do
    it "names the groups' members" do
      expect { VariantsFixtures::Thing.new(:huge) }
        .to raise_error(DaisyUI::UnknownModifierError, /Thing has no modifier :huge.*size: sm, md, lg; tone: calm, loud; shape: row, box/)
    end

    it "accepts members, flags with classes and flags without" do
      expect { VariantsFixtures::Thing.new(:sm, :loud, :row, :round, :collapsed) }.not_to raise_error
    end
  end

  describe ".schema" do
    subject(:schema) { VariantsFixtures::Thing.variants.schema }

    it "is plain data listing every variant, flag, default, compound, on rule, state and slot" do
      expect(schema).to eq(
        base: "thing",
        variants: { size: %i[sm md lg], tone: %i[calm loud], shape: %i[row box] },
        flags: %i[round collapsed],
        defaults: { size: :md },
        compounds: [
          { match: { size: :lg }, class: "c-lg", set: {} },
          { match: { size: %i[sm md] }, class: "c-small", set: {} },
          { match: { tone: nil }, class: "c-untoned", set: {} },
          { match: { round: true }, class: "c-round", set: {} },
          { match: { round: false, tone: :loud }, class: "c-loud-square", set: {} },
          { match: { shape: [nil, :row] }, class: "c-not-box", set: {} },
          { match: { collapsed: true }, class: "c-collapsed", set: { shape: :row } },
          { match: { shape: :row }, class: "c-row", set: {} }
        ],
        on: [
          { states: %i[hover], match: {}, class: "tint-a tint-b" },
          { states: %i[hover focus], match: { size: :lg }, class: "tint-lg" }
        ],
        states: { hover: "hover", focus: "focus-visible" },
        slots: { root: "thing" }
      )
    end

    it "is frozen and Ractor-shareable" do
      expect(schema).to be_frozen
      expect(Ractor.shareable?(schema)).to be(true)
    end

    it "keys a per-slot class by slot" do
      expect(VariantsFixtures::Picker.variants.schema).to include(
        slots: { root: "dropdown", trigger: "picker-trigger", menu: "mt-2" },
        compounds: [{ match: { reach: :wide }, class: { trigger: "btn-block" }, set: {} }],
        on: [{ states: %i[open], match: {}, class: { root: "z-10", menu: "shadow-lg" } }]
      )
    end

    it "describes a component that only registers modifiers" do
      schema = DaisyUI::Button.variants.schema

      expect(schema[:variants]).to include(size: %i[lg md sm xs xl], color: include(:primary))
      expect(schema[:flags]).to eq(%i[active disabled wide block])
      expect(schema).to include(base: "btn", defaults: {}, compounds: [], on: [], states: {}, slots: { root: "btn" })
    end
  end

  describe "declaration errors" do
    def declare(&) = Class.new(VariantsFixtures::Thing) { variants(&) }

    it "raises for a match on a group or flag the component does not have" do
      expect { declare { compound sizes: :lg, class: "x" } }.to raise_error(ArgumentError, /no variant or flag :sizes/)
      expect { declare { on :hover, tones: nil, class: "x" } }.to raise_error(ArgumentError, /no variant or flag :tones/)
    end

    it "raises for a member the group does not have" do
      expect { declare { compound size: :xl, class: "x" } }.to raise_error(ArgumentError, /:size has no member :xl; size: sm, md, lg/)
      expect { declare { compound size: [nil, :xl], class: "x" } }.to raise_error(ArgumentError, /no member :xl/)
    end

    it "raises for a flag matched with anything but true or false" do
      expect { declare { compound round: :yes, class: "x" } }.to raise_error(ArgumentError, /flag :round matches true or false/)
    end

    it "raises for a default or a set outside the groups" do
      expect { declare { default :size, :xl } }.to raise_error(ArgumentError, /no member :xl/)
      expect { declare { default :weight, :bold } }.to raise_error(ArgumentError, /no variant :weight/)
      expect { declare { compound size: :lg, set: { round: true } } }.to raise_error(ArgumentError, /no variant :round/)
    end

    it "raises for a state that was never declared" do
      expect { declare { on :active, class: "x" } }.to raise_error(ArgumentError, /no state :active/)
    end

    it "raises for a slot that was never declared" do
      expect { declare { variant :size, sm: { root: "x", letters: "text-xs" } } }
        .to raise_error(ArgumentError, /no slot :letters: declare it with `slot :letters` first/)
      expect { declare { compound size: :lg, class: { footer: "x" } } }.to raise_error(ArgumentError, /no slot :footer/)
    end

    it "raises for a compound with neither class nor set, an on rule without class, and a bad state prefix" do
      expect { declare { compound size: :lg } }.to raise_error(ArgumentError, /needs class: or set:/)
      expect { declare { on :hover, size: :lg } }.to raise_error(ArgumentError, /needs class:/)
      expect { declare { state :wide, "hover focus" } }.to raise_error(ArgumentError, /state :wide/)
      expect { declare { slot :root } }.to raise_error(ArgumentError, /root is the component itself/)
    end
  end
end
