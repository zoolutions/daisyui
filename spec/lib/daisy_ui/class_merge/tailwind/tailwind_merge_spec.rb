# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "tailwind merge" do
  let(:merger) { described_class.new }

  it "that it has a version number" do
    expect(DaisyUI::ClassMerge::TAILWIND_MERGE_VERSION).to eq("1.5.6")
  end

  it "works with single string" do
    expect(merger.merge("mix-blend-normal mix-blend-multiply")).to eq("mix-blend-multiply")
    expect(merger.merge("h-10 h-min")).to eq("h-min")
    expect(merger.merge("stroke-black stroke-1")).to eq("stroke-black stroke-1")
    expect(merger.merge("stroke-2 stroke-[3]")).to eq("stroke-[3]")
    expect(merger.merge("outline-black outline-1")).to eq("outline-black outline-1")
    expect(merger.merge("grayscale-0 grayscale-[50%]")).to eq("grayscale-[50%]")
    expect(merger.merge("grow grow-[2]")).to eq("grow-[2]")
  end

  it "with array" do
    expect(merger.merge(%w[mix-blend-normal mix-blend-multiply])).to eq("mix-blend-multiply")
    expect(merger.merge(%w[h-10 h-min])).to eq("h-min")
    expect(merger.merge(%w[stroke-black stroke-1])).to eq("stroke-black stroke-1")
    expect(merger.merge(["stroke-2", "stroke-[3]"])).to eq("stroke-[3]")
    expect(merger.merge(%w[outline-black outline-1])).to eq("outline-black outline-1")
    expect(merger.merge(["grayscale-0", "grayscale-[50%]"])).to eq("grayscale-[50%]")
    expect(merger.merge(["grow", "grow-[2]"])).to eq("grow-[2]")
  end

  it "removes duplicates" do
    original = "bg-red-500 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm border-indigo-500 text-indigo-600 bg-red-500 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm"
    merged = "bg-red-500 border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm"

    expect(merger.merge(original)).not_to eq(original)
    expect(merger.merge(original)).to eq(merged)
  end
end
