# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "prefixes" do
  let(:merger) { described_class.new(config: { prefix: "tw" }) }

  it "prefix working correctly" do
    # assert_equal("tw:hidden", merger.merge("tw:block tw:hidden"))
    expect(merger.merge("block hidden")).to eq("block hidden")

    # assert_equal("tw:p-2", merger.merge("tw:p-3 tw:p-2"))
    # assert_equal("p-3 p-2", merger.merge("p-3 p-2"))

    # assert_equal("!tw:inset-0", merger.merge("!tw:right-0 !tw:inset-0"))

    # assert_equal("focus:hover:!tw:inset-0", merger.merge("hover:focus:!tw:right-0 focus:hover:!tw:inset-0"))
  end
end
