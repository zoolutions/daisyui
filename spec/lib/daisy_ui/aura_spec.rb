# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Aura do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <div class="aura"></div>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Styles
      dual: "aura-dual",
      rainbow: "aura-rainbow",
      holo: "aura-holo",
      gold: "aura-gold",
      silver: "aura-silver",
      glow: "aura-glow",
      # Sizes
      xs: "aura-xs",
      sm: "aura-sm",
      md: "aura-md",
      lg: "aura-lg",
      xl: "aura-xl"
    }.each do |condition, css|
      context "when given :#{condition} condition" do
        subject(:output) { render described_class.new(condition) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <div class="aura #{css}"></div>
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
      subject(:output) { render described_class.new(:dual, :lg) }

      it "renders them separately" do
        expected_html = html <<~HTML
          <div class="aura aura-dual aura-lg"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "data" do
    subject(:output) do
      render described_class.new(:dual, data: { foo: "bar" })
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <div class="aura aura-dual" data-foo="bar"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "prefix" do
    subject(:output) do
      render described_class.new(:dual)
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
        <div class="foo-aura foo-aura-dual"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "custom modifiers" do
    context "when there's a custom modifier for the component" do
      subject(:output) do
        render described_class.new(:my_modifier)
      end

      around do |example|
        DaisyUI.configure do |config|
          config.modifiers.add(
            :my_modifier,
            component: described_class,
            classes: "w-96 shadow-xl"
          )
        end

        example.run

        DaisyUI.configure do |config|
          config.modifiers.remove(:my_modifier, component: described_class)
        end
      end

      it "renders it correctly" do
        expected_html = html <<~HTML
          <div class="aura w-96 shadow-xl"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when there's a custom modifier without a specific component" do
      subject(:output) do
        render described_class.new(:my_modifier)
      end

      around do |example|
        DaisyUI.configure do |config|
          config.modifiers.add(
            :my_modifier,
            classes: "w-96 shadow-xl"
          )
        end

        example.run

        DaisyUI.configure do |config|
          config.modifiers.remove(:my_modifier)
        end
      end

      it "renders it correctly" do
        expected_html = html <<~HTML
          <div class="aura w-96 shadow-xl"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when there's no custom modifier", :ignore_unknown_modifiers do
      subject(:output) do
        render described_class.new(:my_modifier)
      end

      it "does not render it" do
        expected_html = html <<~HTML
          <div class="aura"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:dual, responsive: { viewport => :rainbow })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="
              aura#{' '}
              aura-dual#{' '}
              #{viewport}:aura-rainbow">
            </div>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:dual, responsive: { viewport => %i[rainbow lg] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="
              aura#{' '}
              aura-dual#{' '}
              #{viewport}:aura-rainbow#{' '}
              #{viewport}:aura-lg">
            </div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering via Kit" do
    subject(:output) do
      Aura(:dual)
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <div class="aura aura-dual"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "passing :as option" do
    subject(:output) { render described_class.new(as: :span) }

    it "renders the aura as the given tag" do
      expected_html = html <<~HTML
        <span class="aura"></span>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
