# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "standalone classes" do
  let(:merger) { described_class.new }

  it "merges standalone classes from same group correctly" do
    expect(merger.merge("inline block")).to eq("block")
    expect(merger.merge("hover:block hover:inline")).to eq("hover:inline")
    expect(merger.merge("hover:block hover:block")).to eq("hover:block")
    expect(merger.merge("inline hover:inline focus:inline hover:block hover:focus:block")).to eq("inline focus:inline hover:block hover:focus:block")
    expect(merger.merge("underline line-through")).to eq("line-through")
    expect(merger.merge("line-through no-underline")).to eq("no-underline")
  end
end
