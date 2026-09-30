# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "class group conflicts" do
  let(:merger) { described_class.new }

  it "merge classes from same group correctly" do
    expect(merger.merge("overflow-x-auto overflow-x-hidden")).to eq("overflow-x-hidden")
    expect(merger.merge("basis-full basis-auto")).to eq("basis-auto")
    expect(merger.merge("w-full w-fit")).to eq("w-fit")
    expect(merger.merge("overflow-x-auto overflow-x-hidden overflow-x-scroll")).to eq("overflow-x-scroll")
    expect(merger.merge("overflow-x-auto hover:overflow-x-hidden overflow-x-scroll")).to eq("hover:overflow-x-hidden overflow-x-scroll")
    expect(merger.merge("overflow-x-auto hover:overflow-x-hidden hover:overflow-x-auto overflow-x-scroll")).to eq("hover:overflow-x-auto overflow-x-scroll")
    expect(merger.merge("col-span-1 col-span-full")).to eq("col-span-full")
    expect(merger.merge("columns-12 columns-auto")).to eq("columns-auto")
    expect(merger.merge("columns-auto columns-2xl")).to eq("columns-2xl")
    expect(merger.merge("gap-2 gap-px basis-px basis-3")).to eq("gap-px basis-3")
  end

  it "merges none values in sizing groups correctly" do
    expect(merger.merge("max-w-lg max-w-none")).to eq("max-w-none")
    expect(merger.merge("max-w-none max-w-lg")).to eq("max-w-lg")
    expect(merger.merge("max-h-96 max-h-none")).to eq("max-h-none")
    expect(merger.merge("max-h-none max-h-96")).to eq("max-h-96")
    expect(merger.merge("max-h-[300px] max-h-none")).to eq("max-h-none")
    expect(merger.merge("max-h-none max-h-screen")).to eq("max-h-screen")
  end

  it "merges classes from font variant numeric section correctly" do
    expect(merger.merge("lining-nums tabular-nums diagonal-fractions")).to eq("lining-nums tabular-nums diagonal-fractions")
    expect(merger.merge("normal-nums tabular-nums diagonal-fractions")).to eq("tabular-nums diagonal-fractions")
    expect(merger.merge("tabular-nums diagonal-fractions normal-nums")).to eq("normal-nums")
    expect(merger.merge("tabular-nums proportional-nums")).to eq("proportional-nums")
  end
end
