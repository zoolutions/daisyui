# frozen_string_literal: true

RSpec.describe DaisyUI::UnknownModifierError do
  around do |example|
    original = DaisyUI.configuration.instance_variable_get(:@unknown_modifiers)
    DaisyUI.configuration.reset_reported_unknown_modifiers!
    example.run
  ensure
    DaisyUI.configuration.unknown_modifiers = original
    DaisyUI.configuration.reset_reported_unknown_modifiers!
  end

  describe "the default" do
    before { DaisyUI.configuration.unknown_modifiers = nil }

    context "without Rails" do
      before { hide_const("Rails") }

      it "warns" do
        expect(DaisyUI.configuration.unknown_modifiers).to eq(:warn)
      end
    end

    context "with Rails in development or test" do
      %w[development test].each do |env|
        it "raises in #{env}" do
          stub_const("Rails", Module.new { define_singleton_method(:env) { env } })

          expect(DaisyUI.configuration.unknown_modifiers).to eq(:raise)
        end
      end
    end

    context "with Rails in production" do
      it "warns" do
        stub_const("Rails", Module.new { def self.env = "production" })

        expect(DaisyUI.configuration.unknown_modifiers).to eq(:warn)
      end
    end
  end

  describe "setting an invalid mode" do
    it "raises ArgumentError" do
      expect { DaisyUI.configuration.unknown_modifiers = :explode }
        .to raise_error(ArgumentError, /:raise, :warn, :ignore or a callable/)
    end
  end

  context "when set to :raise" do
    before { DaisyUI.configuration.unknown_modifiers = :raise }

    it "raises UnknownModifierError naming the component, the modifier and a suggestion" do
      expect { DaisyUI::Toggle.new(:primray) }.to raise_error(described_class) do |error|
        expect(error).to be_a(ArgumentError)
        expect(error.message).to include("DaisyUI::Toggle", ":primray", ":primary")
        expect(error.component).to eq(DaisyUI::Toggle)
        expect(error.modifier).to eq(:primray)
      end
    end

    it "accepts registered modifiers" do
      expect(DaisyUI::Toggle.new(:primary, :lg).call).to eq('<input type="checkbox" class="toggle toggle-primary toggle-lg">')
    end

    it "validates responsive modifiers" do
      expect { DaisyUI::Toggle.new(responsive: { sm: :primray }) }
        .to raise_error(described_class, /:primray/)
    end

    it "validates every modifier in a responsive array" do
      expect { DaisyUI::Toggle.new(responsive: { sm: %i[primary lgg] }) }
        .to raise_error(described_class, /:lgg/)
    end

    it "accepts `true` in responsive options" do
      expect(DaisyUI::Toggle.new(responsive: { sm: [true, :primary] }).call)
        .to eq('<input type="checkbox" class="sm:toggle sm:toggle-primary">')
    end

    it "accepts the skeleton modifier every component has" do
      expect { DaisyUI::Toggle.new(:skeleton) }.not_to raise_error
    end

    it "accepts modifiers a subclass registers" do
      subclass = Class.new(DaisyUI::Toggle) do
        register_modifiers(custom: "x-custom")
      end

      expect(subclass.new(:custom).call).to eq('<input type="checkbox" class="toggle x-custom">')
    end

    it "accepts flags a subclass registers without emitting a class" do
      subclass = Class.new(DaisyUI::Toggle) do
        register_flags(:fancy)
      end

      expect(subclass.new(:fancy).call).to eq('<input type="checkbox" class="toggle">')
    end

    it "does not leak flags into the parent class" do
      Class.new(DaisyUI::Toggle) { register_flags(:fancy) }

      expect { DaisyUI::Toggle.new(:fancy) }.to raise_error(described_class)
    end

    context "with a modifier added through the configuration" do
      after do
        DaisyUI.configuration.modifiers.remove(:huge, component: DaisyUI::Toggle)
        DaisyUI.configuration.modifiers.remove(:shiny)
      end

      it "accepts component and global modifiers" do
        DaisyUI.configure do |config|
          config.modifiers.add(:huge, classes: "toggle-xl", component: DaisyUI::Toggle)
          config.modifiers.add(:shiny, classes: "shadow-lg")
        end

        expect(DaisyUI::Toggle.new(:huge, :shiny).call)
          .to eq('<input type="checkbox" class="toggle toggle-xl shadow-lg">')
      end
    end

    it "keeps unknown keyword booleans as HTML attributes" do
      expect(DaisyUI::Toggle.new(primray: true).call).to eq('<input type="checkbox" class="toggle" primray>')
    end
  end

  context "when set to :warn" do
    before { DaisyUI.configuration.unknown_modifiers = :warn }

    it "renders without the unknown modifier and warns once per component and modifier" do
      html = nil
      expect do
        html = DaisyUI::Toggle.new(:primray).call
        DaisyUI::Toggle.new(:primray).call
      end.to output(/DaisyUI::Toggle.*:primray/).to_stderr

      expect(html).to eq('<input type="checkbox" class="toggle">')
    end

    it "warns only once for a repeated modifier" do
      expect do
        DaisyUI::Toggle.new(:primray)
        DaisyUI::Toggle.new(:primray)
      end.to output(satisfy { |err| err.scan(":primray").size == 1 }).to_stderr
    end
  end

  context "when set to :ignore" do
    before { DaisyUI.configuration.unknown_modifiers = :ignore }

    it "renders as before, silently" do
      html = nil
      expect { html = DaisyUI::Toggle.new(:primray).call }.not_to output.to_stderr
      expect(html).to eq('<input type="checkbox" class="toggle">')
    end
  end

  context "when set to a callable" do
    it "passes the error to it, once per component and modifier" do
      reported = []
      DaisyUI.configuration.unknown_modifiers = ->(error) { reported << error }

      html = DaisyUI::Toggle.new(:primray).call
      DaisyUI::Toggle.new(:primray)

      expect(html).to eq('<input type="checkbox" class="toggle">')
      expect(reported.size).to eq(1)
      expect(reported.first).to be_a(described_class)
      expect(reported.first.modifier).to eq(:primray)
    end
  end

  context "when a tab or submenu is given :open without the part that uses it" do
    before { DaisyUI.configuration.unknown_modifiers = :raise }

    it "accepts :open and :closed on a tab without content" do
      expect(DaisyUI::Tabs.new.call { |tabs| tabs.tab(:open, label: "A") })
        .to include(%(class="tab"))
      expect { DaisyUI::Tabs.new.call { |tabs| tabs.tab(:closed, label: "A") } }.not_to raise_error
    end

    it "accepts :open on a non-collapsible submenu" do
      expect { DaisyUI::Menu.new.call { |menu| menu.submenu(:open) { |sub| sub.title { "T" } } } }
        .not_to raise_error
    end
  end
end
