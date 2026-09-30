# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Badge do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <span class="badge"></span>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Styles
      outline: "badge-outline",
      dash: "badge-dash",
      soft: "badge-soft",
      ghost: "badge-ghost",
      # Colors
      neutral: "badge-neutral",
      primary: "badge-primary",
      secondary: "badge-secondary",
      accent: "badge-accent",
      info: "badge-info",
      success: "badge-success",
      warning: "badge-warning",
      error: "badge-error",
      # Sizes
      xs: "badge-xs",
      sm: "badge-sm",
      md: "badge-md",
      lg: "badge-lg",
      xl: "badge-xl"
    }.each do |modifier, css|
      context "when given :#{modifier} modifier" do
        subject(:output) { render described_class.new(modifier) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <span class="badge #{css}"></span>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:neutral, responsive: { viewport => :primary })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <span class="badge badge-neutral #{viewport}:badge-primary"></span>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:neutral, responsive: { viewport => %i[primary lg] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <span class="badge badge-neutral #{viewport}:badge-primary #{viewport}:badge-lg"></span>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering a full badge" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Badge.new(:neutral, primary: false, secondary: true) do
            div do
              "+"
            end

            plain "Badge"
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <span class="badge badge-secondary"><div>+</div>Badge</span>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
