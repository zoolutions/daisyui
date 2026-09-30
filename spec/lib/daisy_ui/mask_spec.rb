# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Mask do
  subject(:output) { render described_class.new }

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:squircle, responsive: { viewport => :heart })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="mask mask-squircle #{viewport}:mask-heart"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:squircle, responsive: { viewport => %i[heart circle] })
        end

        it "keeps only the last conflicting responsive modifier" do
          expected_html = html <<~HTML
            <div class="mask mask-squircle #{viewport}:mask-circle"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "rendering a full mask" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Mask.new(:squircle, heart: false, hexagon: true) do # rubocop:disable Lint/EmptyBlock
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <div class="mask mask-hexagon"></div>
      HTML

      expect(output).to eq(expected_html)
    end
  end
end
