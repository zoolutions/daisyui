# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "negative values" do
  let(:merger) { described_class.new }

  it "handles negative value conflicts correctly" do
    expect(merger.merge("-m-2 -m-5")).to eq("-m-5")
    expect(merger.merge("-top-12 -top-2000")).to eq("-top-2000")
  end

  it "handles conflicts between positive and negative values correctly" do
    expect(merger.merge("-m-2 m-auto")).to eq("m-auto")
    expect(merger.merge("top-12 -top-69")).to eq("-top-69")
  end

  it "handles conflicts across groups with negative values correctly" do
    expect(merger.merge("-right-1 inset-x-1")).to eq("inset-x-1")
    expect(merger.merge("hover:focus:-right-1 focus:hover:inset-x-1")).to eq("focus:hover:inset-x-1")
  end
end
