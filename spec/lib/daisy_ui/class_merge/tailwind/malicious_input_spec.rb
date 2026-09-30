# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "malicious input" do
  let(:merger) { described_class.new }

  it "handles wonky input" do
    expect(merger.merge(" block")).to eq("block")
    expect(merger.merge("block ")).to eq("block")
    expect(merger.merge(" block ")).to eq("block")

    expect(merger.merge("  block  px-2     py-4  ")).to eq("block px-2 py-4")
    expect(merger.merge(["  block  px-2", " ", "     py-4  "])).to eq("block px-2 py-4")

    expect(merger.merge("block\npx-2")).to eq("block px-2")
    expect(merger.merge("\nblock\npx-2\n")).to eq("block px-2")
    expect(merger.merge("  block\n        \n        px-2   \n          py-4  ")).to eq("block px-2 py-4")
    expect(merger.merge("\r  block\n\r        \n        px-2   \n          py-4  ")).to eq("block px-2 py-4")
  end
end
