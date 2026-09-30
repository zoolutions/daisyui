# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "per side border colors" do
  let(:merger) { described_class.new }

  it "merges classes with per side border colors correctly" do
    expect(merger.merge("border-t-some-blue border-t-other-blue")).to eq("border-t-other-blue")
    expect(merger.merge("border-t-some-blue border-some-blue")).to eq("border-some-blue")

    expect(merger.merge("border-some-blue border-s-some-blue")).to eq("border-some-blue border-s-some-blue")
    expect(merger.merge("border-e-some-blue border-some-blue")).to eq("border-some-blue")
  end
end
