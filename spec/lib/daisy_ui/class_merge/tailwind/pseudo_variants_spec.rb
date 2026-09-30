# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "pseudo variants" do
  let(:merger) { described_class.new }

  it "handles pseudo variants conflicts properly" do
    expect(merger.merge("empty:p-2 empty:p-3")).to eq("empty:p-3")
    # assert_equal("hover:empty:p-3", merger.merge("hover:empty:p-2 hover:empty:p-3"))
    # assert_equal("read-only:p-3", merger.merge("read-only:p-2 read-only:p-3"))
  end

  it "handles pseudo variant group conflicts properly" do
    expect(merger.merge("group-empty:p-2 group-empty:p-3")).to eq("group-empty:p-3")
    expect(merger.merge("peer-empty:p-2 peer-empty:p-3")).to eq("peer-empty:p-3")
    expect(merger.merge("group-empty:p-2 peer-empty:p-3")).to eq("group-empty:p-2 peer-empty:p-3")
    expect(merger.merge("hover:group-empty:p-2 hover:group-empty:p-3")).to eq("hover:group-empty:p-3")
    expect(merger.merge("group-read-only:p-2 group-read-only:p-3")).to eq("group-read-only:p-3")
  end
end
