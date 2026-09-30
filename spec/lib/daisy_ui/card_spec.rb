# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Card do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <section class="card"></section>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Modifiers
      image_full: "image-full",
      border: "card-border",
      bordered: "card-border",
      dash: "card-dash",
      side: "card-side",
      # Sizes
      xs: "card-xs",
      sm: "card-sm",
      md: "card-md",
      lg: "card-lg",
      xl: "card-xl",
      # Colors
      primary: "bg-primary text-primary-content",
      secondary: "bg-secondary text-secondary-content",
      accent: "bg-accent text-accent-content",
      neutral: "bg-neutral text-neutral-content",
      base_100: "bg-base-100 text-base-content",
      base_200: "bg-base-200 text-base-content",
      base_300: "bg-base-300 text-base-content",
      info: "bg-info text-info-content",
      success: "bg-success text-success-content",
      warning: "bg-warning text-warning-content",
      error: "bg-error text-error-content"
    }.each do |condition, css|
      context "when given :#{condition} condition" do
        subject(:output) { render described_class.new(condition) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <section class="card #{css}"></section>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end

    context "when condition doesn't exist" do
      it "does not raise an error" do
        expect { render described_class.new(:foo) }
          .not_to raise_error
      end
    end

    context "when given multiple conditions" do
      subject(:output) { render described_class.new(:border, :dash) }

      it "keeps only the last conflicting modifier" do
        expected_html = html <<~HTML
          <section class="card card-dash"></section>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "data" do
    subject(:output) do
      render described_class.new(:border, data: { foo: "bar" })
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <section class="card card-border" data-foo="bar"></section>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "prefix" do
    subject(:output) do
      render described_class.new(:border)
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
        <section class="foo-card foo-card-border"></section>
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
          <section class="card w-96 shadow-xl"></section>
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
          <section class="card w-96 shadow-xl"></section>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when there's no custom modifier" do
      subject(:output) do
        render described_class.new(:my_modifier)
      end

      it "does not render it" do
        expected_html = html <<~HTML
          <section class="card"></section>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:border, responsive: { viewport => :primary })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <section class="
              card#{' '}
              card-border#{' '}
              #{viewport}:bg-primary#{' '}
              #{viewport}:text-primary-content">
            </section>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:border, responsive: { viewport => %i[dash primary] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <section class="
              card#{' '}
              card-border#{' '}
              #{viewport}:card-dash#{' '}
              #{viewport}:bg-primary
              #{viewport}:text-primary-content">
            </section>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when it's prefixed" do
        subject(:output) do
          render described_class.new(:border, responsive: { viewport => %i[dash primary] })
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

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <section class="
              foo-card#{' '}
              foo-card-border
              #{viewport}:foo-card-dash
              #{viewport}:foo-bg-primary
              #{viewport}:foo-text-primary-content">
            </section>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when there are custom modifiers" do
        subject(:output) do
          render described_class.new(
            :my_modifier,
            responsive: { viewport => :my_other_modifier }
          )
        end

        around do |example|
          DaisyUI.configure do |config|
            config.modifiers.add(
              :my_modifier,
              component: described_class,
              classes: "w-96 shadow-xl"
            )

            config.modifiers.add(
              :my_other_modifier,
              classes: "p-4 rounded-box"
            )
          end

          example.run

          DaisyUI.configure do |config|
            config.modifiers.remove(:my_modifier, component: described_class)
            config.modifiers.remove(:my_other_modifier)
          end
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <section class="
              card
              w-96
              shadow-xl
              #{viewport}:p-4
              #{viewport}:rounded-box">
            </section>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering via Kit" do
    subject(:output) do
      Card(:border)
    end

    it "renders it correctly" do
      expected_html = html <<~HTML
        <section class="card card-border"></section>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "passing :as option" do
    subject(:output) { render described_class.new(as: :div) }

    it "renders the card as the given tag" do
      expected_html = html <<~HTML
        <div class="card"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering a full card" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Card.new(:border) do |card|
            card.body class: "my-body", data: { my: "bodies" }, style: "color: red;" do
              card.figure class: "my-figure", data: { my: "figures" } do
                card.img src: "image.jpg"
              end

              card.title class: "my-title", data: { my: "titles" } do
                h1 { "My title" }
              end

              card.actions class: "my-actions", data: { my: "actions" } do
                div { "My actions" }
              end
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <section class="card card-border">
          <div class="card-body my-body" data-my="bodies" style="color: red;">
            <figure class="my-figure" data-my="figures">
              <img src="image.jpg">
            </figure>
            <header class="card-title my-title" data-my="titles">
              <h1>My title</h1>
            </header>
            <footer class="card-actions my-actions" data-my="actions">
              <div>My actions</div>
            </footer>
          </div>
        </section>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
