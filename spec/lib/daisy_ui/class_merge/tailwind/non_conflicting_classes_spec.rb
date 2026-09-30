# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "non conflicting classes" do
  let(:merger) { described_class.new }

  it "merges non conflicting classes correctly" do
    expect(merger.merge("border-t border-white/10")).to eq("border-t border-white/10")
    expect(merger.merge("border-t border-white")).to eq("border-t border-white")
    expect(merger.merge("text-3.5xl text-black")).to eq("text-3.5xl text-black")
  end
end
