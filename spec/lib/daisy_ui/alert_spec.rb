# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Alert do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <div role="alert" class="alert"></div>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      # Styles
      outline: "alert-outline",
      dash: "alert-dash",
      soft: "alert-soft",
      # Directions
      vertical: "alert-vertical",
      horizontal: "alert-horizontal",
      # Colors
      info: "alert-info",
      success: "alert-success",
      warning: "alert-warning",
      error: "alert-error",
      neutral: "alert-neutral",
      primary: "alert-primary",
      secondary: "alert-secondary",
      accent: "alert-accent"
    }.each do |modifier, css|
      context "when given :#{modifier} modifier" do
        subject(:output) { render described_class.new(modifier) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <div role="alert" class="alert #{css}"></div>
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
            <div role="alert" class="alert alert-neutral #{viewport}:alert-primary"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:neutral, responsive: { viewport => %i[primary info] })
        end

        it "keeps only the last conflicting responsive modifier" do
          expected_html = html <<~HTML
            <div role="alert" class="alert alert-neutral #{viewport}:alert-info"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering a full alert" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Alert.new(
            :neutral,
            primary: false,
            secondary: true,
            as: :div,
            data: {
              my: :alert
            }
          ) do
            "Alert"
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <div role="alert" class="alert alert-secondary" data-my="alert">Alert</div>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
