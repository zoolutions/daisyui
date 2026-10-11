# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Megamenu do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <div class="megamenu"></div>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Modifiers
      wide: "megamenu-wide",
      full: "megamenu-full",
      vertical: "megamenu-vertical",
      # Sizes
      xs: "megamenu-xs",
      sm: "megamenu-sm",
      md: "megamenu-md",
      lg: "megamenu-lg",
      xl: "megamenu-xl"
    }.each do |condition, css|
      context "when given :#{condition} condition" do
        subject(:output) { render described_class.new(condition) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <div class="megamenu #{css}"></div>
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
      subject(:output) { render described_class.new(:wide, :vertical) }

      it "renders them separately" do
        expected_html = html <<~HTML
          <div class="megamenu megamenu-wide megamenu-vertical"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "data" do
    subject(:output) do
      render described_class.new(:wide, data: { foo: "bar" })
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <div class="megamenu megamenu-wide" data-foo="bar"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "prefix" do
    subject(:output) do
      render described_class.new(:wide)
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
        <div class="foo-megamenu foo-megamenu-wide"></div>
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
          <div class="megamenu w-96 shadow-xl"></div>
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
          <div class="megamenu w-96 shadow-xl"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when there\x27s no custom modifier", :ignore_unknown_modifiers do
      subject(:output) do
        render described_class.new(:my_modifier)
      end

      it "does not render it" do
        expected_html = html <<~HTML
          <div class="megamenu"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:wide, responsive: { viewport => :full })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="
              megamenu#{' '}
              megamenu-wide#{' '}
              #{viewport}:megamenu-full">
            </div>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:wide, responsive: { viewport => %i[vertical full] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="
              megamenu#{' '}
              megamenu-wide#{' '}
              #{viewport}:megamenu-vertical#{' '}
              #{viewport}:megamenu-full">
            </div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering via Kit" do
    subject(:output) do
      Megamenu(:wide)
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <div class="megamenu megamenu-wide"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "passing :as option" do
    subject(:output) { render described_class.new(as: :nav) }

    it "renders the megamenu as the given tag" do
      expected_html = html <<~HTML
        <nav class="megamenu"></nav>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering with active_indicator" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Megamenu.new(:wide) do |megamenu|
            megamenu.active_indicator class: "my-indicator", data: { my: "indicator" } do
              plain "Active"
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <div class="megamenu megamenu-wide">
          <span class="megamenu-active my-indicator" data-my="indicator">Active</span>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
