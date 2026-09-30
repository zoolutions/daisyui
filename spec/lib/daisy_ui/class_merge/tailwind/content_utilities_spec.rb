# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "content utilities" do
  let(:merger) { described_class.new }

  it "merges content utilities correctly" do
    expect(merger.merge("content-['hello'] content-[attr(data-content)]")).to eq("content-[attr(data-content)]")
  end
end
