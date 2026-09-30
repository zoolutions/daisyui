# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "colors" do
  let(:merger) { described_class.new }

  it "handles color conflicts properly" do
    expect(merger.merge("bg-grey-5 bg-hotpink")).to eq("bg-hotpink")
    expect(merger.merge("hover:bg-grey-5 hover:bg-hotpink")).to eq("hover:bg-hotpink")
    expect(merger.merge("stroke-[hsl(350_80%_0%)] stroke-[10px]")).to eq("stroke-[hsl(350_80%_0%)] stroke-[10px]")
  end

  it "handles color functions with percentages correctly" do
    expect(merger.merge("text-sm text-[color(display-p3_1_0_0/50%)]")).to eq("text-sm text-[color(display-p3_1_0_0/50%)]")
    expect(merger.merge("text-[color(display-p3_1_0_0/50%)] text-sm")).to eq("text-[color(display-p3_1_0_0/50%)] text-sm")
    expect(merger.merge("text-red-500 text-[color(display-p3_1_0_0/50%)]")).to eq("text-[color(display-p3_1_0_0/50%)]")
    expect(merger.merge("text-[color(display-p3_1_0_0/50%)] text-red-500")).to eq("text-red-500")
    expect(merger.merge("border-2 border-[color(display-p3_1_0_0/50%)]")).to eq("border-2 border-[color(display-p3_1_0_0/50%)]")
    expect(merger.merge("border-[color(display-p3_1_0_0/50%)] border-2")).to eq("border-[color(display-p3_1_0_0/50%)] border-2")
    expect(merger.merge("stroke-2 stroke-[color(display-p3_1_0_0/50%)]")).to eq("stroke-2 stroke-[color(display-p3_1_0_0/50%)]")
    expect(merger.merge("stroke-[color(display-p3_1_0_0/50%)] stroke-2")).to eq("stroke-[color(display-p3_1_0_0/50%)] stroke-2")
  end

  it "handles light dark functions with percentages correctly" do
    expect(merger.merge("text-sm text-[light-dark(white,rgb(0_0_0/50%))]")).to eq("text-sm text-[light-dark(white,rgb(0_0_0/50%))]")
    expect(merger.merge("text-[light-dark(white,rgb(0_0_0/50%))] text-sm")).to eq("text-[light-dark(white,rgb(0_0_0/50%))] text-sm")
    expect(merger.merge("text-red-500 text-[light-dark(white,rgb(0_0_0/50%))]")).to eq("text-[light-dark(white,rgb(0_0_0/50%))]")
    expect(merger.merge("text-[light-dark(white,rgb(0_0_0/50%))] text-red-500")).to eq("text-red-500")
    expect(merger.merge("border-2 border-[light-dark(white,rgb(0_0_0/50%))]")).to eq("border-2 border-[light-dark(white,rgb(0_0_0/50%))]")
    expect(merger.merge("border-[light-dark(white,rgb(0_0_0/50%))] border-2")).to eq("border-[light-dark(white,rgb(0_0_0/50%))] border-2")
    expect(merger.merge("stroke-2 stroke-[light-dark(white,rgb(0_0_0/50%))]")).to eq("stroke-2 stroke-[light-dark(white,rgb(0_0_0/50%))]")
    expect(merger.merge("stroke-[light-dark(white,rgb(0_0_0/50%))] stroke-2")).to eq("stroke-[light-dark(white,rgb(0_0_0/50%))] stroke-2")
  end
end
