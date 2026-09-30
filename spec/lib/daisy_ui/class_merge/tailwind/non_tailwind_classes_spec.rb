# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "non tailwind classes" do
  let(:merger) { described_class.new }

  it "does not alter non tailwind classes" do
    expect(merger.merge("non-tailwind-class inline block")).to eq("non-tailwind-class block")
    expect(merger.merge("inline block inline-1")).to eq("block inline-1")
    expect(merger.merge("inline block i-inline")).to eq("block i-inline")
    expect(merger.merge("focus:inline focus:block focus:inline-1")).to eq("focus:block focus:inline-1")
  end
end
