# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Otp do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <label class="otp">
        <span></span><span></span><span></span><span></span>
        <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
      </label>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Modifiers
      joined: "otp-joined",
      # Sizes
      xs: "otp-xs",
      sm: "otp-sm",
      md: "otp-md",
      lg: "otp-lg",
      xl: "otp-xl",
      # Colors
      neutral: "otp-neutral",
      primary: "otp-primary",
      secondary: "otp-secondary",
      accent: "otp-accent",
      success: "otp-success",
      info: "otp-info",
      warning: "otp-warning",
      error: "otp-error"
    }.each do |condition, css|
      context "when given :#{condition} condition" do
        subject(:output) { render described_class.new(condition) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <label class="otp #{css}">
              <span></span><span></span><span></span><span></span>
              <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
            </label>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end

    context "when condition doesn't exist" do
      it "raises UnknownModifierError" do
        expect { render described_class.new(:foo) }
          .to raise_error(DaisyUI::UnknownModifierError, /:foo/)
      end
    end

    context "when given multiple conditions" do
      subject(:output) { render described_class.new(:joined, :primary) }

      it "renders them separately" do
        expected_html = html <<~HTML
          <label class="otp otp-joined otp-primary">
            <span></span><span></span><span></span><span></span>
            <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
          </label>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "custom digits" do
    subject(:output) { render described_class.new(digits: 6) }

    it "renders 6 spans and adjusts input attributes" do
      expected_html = html <<~HTML
        <label class="otp">
          <span></span><span></span><span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="6" pattern="[0-9]{6}" required>
        </label>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "data" do
    subject(:output) do
      render described_class.new(:primary, data: { foo: "bar" })
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <label class="otp otp-primary" data-foo="bar">
          <span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
        </label>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "prefix" do
    subject(:output) do
      render described_class.new(:primary)
    end

    around do |example|
      original_prefix = DaisyUI.configuration.prefix

      DaisyUI.configure do |config|
        config.prefix = "foo-"
      end

      example.run

      DaisyUI.configure do |config|
        config.prefix = original_prefix
      end
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <label class="foo-otp foo-otp-primary">
          <span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
        </label>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:joined, responsive: { viewport => :primary })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <label class="
              otp#{' '}
              otp-joined#{' '}
              #{viewport}:otp-primary">
              <span></span><span></span><span></span><span></span>
              <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
            </label>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "input_attributes" do
    subject(:output) do
      render described_class.new(:primary, input_attributes: { name: "otp_code", id: "otp-input", value: "1234" })
    end

    it "passes attributes to the input element" do
      expected_html = html <<~HTML
        <label class="otp otp-primary">
          <span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required name="otp_code" id="otp-input" value="1234">
        </label>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering via Kit" do
    subject(:output) do
      Otp(:primary)
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <label class="otp otp-primary">
          <span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
        </label>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "passing :as option" do
    subject(:output) { render described_class.new(as: :div) }

    it "renders the otp as the given tag" do
      expected_html = html <<~HTML
        <div class="otp">
          <span></span><span></span><span></span><span></span>
          <input type="text" autocomplete="one-time-code" inputmode="numeric" maxlength="4" pattern="[0-9]{4}" required>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
