# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Link do
  subject(:output) { render described_class.new }

  it "is expected to match the formatted HTML" do
    expected_html = html <<~HTML
      <a class="link"></a>
    HTML

    expect(output).to eq(expected_html)
  end

  describe "modifiers" do
    {
      hover: "link-hover",
      primary: "link-primary",
      secondary: "link-secondary",
      accent: "link-accent",
      neutral: "link-neutral",
      info: "link-info",
      success: "link-success",
      warning: "link-warning",
      error: "link-error"
    }.each do |modifier, css|
      context "when given :#{modifier} modifier" do
        subject(:output) { render described_class.new(modifier) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <a class="link #{css}"></a>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end

    context "when given stale card modifiers", :ignore_unknown_modifiers do
      %i[bordered normal compact side glass image_full].each do |stale_modifier|
        context "when given :#{stale_modifier}" do
          subject(:output) { render described_class.new(stale_modifier) }

          it "ignores the unknown modifier" do
            expected_html = html <<~HTML
              <a class="link"></a>
            HTML

            expect(output).to eq(expected_html)
          end
        end
      end
    end

    context "when given multiple modifiers" do
      subject(:output) { render described_class.new(:primary, :hover) }

      it "renders them separately" do
        expected_html = html <<~HTML
          <a class="link link-primary link-hover"></a>
        HTML

        expect(output).to eq(expected_html)
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
            <a class="link link-neutral #{viewport}:link-primary"></a>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:neutral, responsive: { viewport => %i[primary hover] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <a class="link link-neutral #{viewport}:link-primary #{viewport}:link-hover"></a>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering a full link" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Link.new(
            :primary,
            href: "/test",
            class: "test",
            data: { my: "data" }
          ) do
            span do
              "Link text"
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <a class="link link-primary test" href="/test" data-my="data">
          <span>Link text</span>
        </a>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
