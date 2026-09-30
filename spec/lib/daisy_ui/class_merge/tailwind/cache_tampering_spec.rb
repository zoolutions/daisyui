# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "cache tampering" do
  let(:merger) { described_class.new }

  it "cached values are immutable" do
    classes = merger.merge("font-medium font-bold")
    expect do
      classes << " text-white"
    end.to raise_error(FrozenError)
  end
end
