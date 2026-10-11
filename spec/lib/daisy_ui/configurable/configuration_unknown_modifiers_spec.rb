# frozen_string_literal: true

RSpec.describe DaisyUI::Configurable::Configuration, "#unknown_modifiers" do
  let(:config) { DaisyUI.configuration }

  around do |example|
    original = config.instance_variable_get(:@unknown_modifiers)
    config.reset_reported_unknown_modifiers!
    example.run
  ensure
    config.unknown_modifiers = original
    config.reset_reported_unknown_modifiers!
  end

  context "when set to :raise" do
    before { config.unknown_modifiers = :raise }

    it "rejects a registered flag in responsive options, where it has no class" do
      expect { DaisyUI::Dropdown.new(responsive: { sm: :popover }) }
        .to raise_error(DaisyUI::UnknownModifierError, /:popover/)
    end

    it "still accepts a registered flag as a positional modifier" do
      expect { DaisyUI::Dropdown.new(:popover) }.not_to raise_error
    end

    it "validates Chat#bubble modifiers" do
      expect { DaisyUI::Chat.new.call { |chat| chat.bubble(:primray) } }
        .to raise_error(DaisyUI::UnknownModifierError, /DaisyUI::Chat#bubble.*:primray.*:primary/)
    end

    it "accepts known Chat#bubble modifiers" do
      expect(DaisyUI::Chat.new.call { |chat| chat.bubble(:primary) { "hi" } })
        .to include('class="chat-bubble chat-bubble-primary"')
    end

    it "validates Steps#step modifiers" do
      expect { DaisyUI::Steps.new.call { |steps| steps.step(:primray) } }
        .to raise_error(DaisyUI::UnknownModifierError, /DaisyUI::Steps#step.*:primray/)
    end

    it "accepts known Steps#step modifiers" do
      expect(DaisyUI::Steps.new.call { |steps| steps.step(:primary) { "1" } })
        .to include('class="step step-primary"')
    end

    it "validates Indicator#item modifiers" do
      expect { DaisyUI::Indicator.new.call { |indicator| indicator.item(:topp) } }
        .to raise_error(DaisyUI::UnknownModifierError, /DaisyUI::Indicator#item.*:topp/)
    end

    it "accepts known Indicator#item modifiers" do
      expect(DaisyUI::Indicator.new.call { |indicator| indicator.item(:top, :end) { "1" } })
        .to include('class="indicator-item indicator-top indicator-end"')
    end

    context "with a modifier configured for a parent component" do
      let(:subclass) { Class.new(DaisyUI::Toggle) }

      after { config.modifiers.remove(:huge, component: DaisyUI::Toggle) }

      it "applies it to subclasses too" do
        config.modifiers.add(:huge, classes: "toggle-xl", component: DaisyUI::Toggle)

        expect(subclass.new(:huge).call).to eq('<input type="checkbox" class="toggle toggle-xl">')
      end
    end
  end

  context "when set to :ignore" do
    before { config.unknown_modifiers = :ignore }

    it "does not build the error" do
      allow(DaisyUI::UnknownModifierError).to receive(:new).and_call_original

      DaisyUI::Toggle.new(:primray)

      expect(DaisyUI::UnknownModifierError).not_to have_received(:new)
    end
  end

  context "when set to a callable" do
    let(:reported) { [] }

    before { config.unknown_modifiers = ->(error) { reported << error } }

    it "does not build the error again for a modifier already reported" do
      DaisyUI::Toggle.new(:primray)
      allow(DaisyUI::UnknownModifierError).to receive(:new).and_call_original

      DaisyUI::Toggle.new(:primray)

      expect(DaisyUI::UnknownModifierError).not_to have_received(:new)
    end

    it "keeps the set of reported modifiers bounded" do
      limit = described_class::REPORTED_UNKNOWN_MODIFIERS_LIMIT
      (limit + 1).times { |i| DaisyUI::Toggle.new(:"bogus_#{i}") }

      expect(config.instance_variable_get(:@reported_unknown_modifiers).size).to be <= limit
      expect(reported.size).to eq(limit + 1)
    end

    it "reports each modifier once across threads" do
      Array.new(8) { Thread.new { 50.times { DaisyUI::Toggle.new(:primray) } } }.each(&:join)

      expect(reported.size).to eq(1)
    end
  end
end
