# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "conflicts across class groups" do
  let(:merger) { described_class.new }

  it "handles conflicts across class groups correctly" do
    expect(merger.merge("inset-1 inset-x-1")).to eq("inset-1 inset-x-1")
    expect(merger.merge("inset-x-1 inset-1")).to eq("inset-1")
    expect(merger.merge("inset-x-1 left-1 inset-1")).to eq("inset-1")
    expect(merger.merge("inset-x-1 inset-1 left-1")).to eq("inset-1 left-1")
    expect(merger.merge("inset-x-1 right-1 inset-1")).to eq("inset-1")
    expect(merger.merge("inset-x-1 right-1 inset-x-1")).to eq("inset-x-1")
    expect(merger.merge("inset-x-1 right-1 inset-y-1")).to eq("inset-x-1 right-1 inset-y-1")
    expect(merger.merge("right-1 inset-x-1 inset-y-1")).to eq("inset-x-1 inset-y-1")
    expect(merger.merge("inset-x-1 hover:left-1 inset-1")).to eq("hover:left-1 inset-1")
  end

  it "axis shorthands override logical sides" do
    # Since Tailwind CSS v4 the axis utilities compile to logical shorthand
    # properties (px → padding-inline), which fully override their logical-side
    # longhands (ps → padding-inline-start) in every writing mode.
    expect(merger.merge("ps-2 px-4")).to eq("px-4")
    expect(merger.merge("pe-2 px-4")).to eq("px-4")
    expect(merger.merge("px-4 ps-2")).to eq("px-4 ps-2")
    expect(merger.merge("pbs-2 py-4")).to eq("py-4")
    expect(merger.merge("ms-2 mx-4")).to eq("mx-4")
    expect(merger.merge("mbe-2 my-4")).to eq("my-4")
    expect(merger.merge("start-2 inset-x-4")).to eq("inset-x-4")
    expect(merger.merge("end-2 inset-x-4")).to eq("inset-x-4")
    expect(merger.merge("inset-bs-2 inset-y-4")).to eq("inset-y-4")
    expect(merger.merge("border-s-2 border-x-4")).to eq("border-x-4")
    expect(merger.merge("border-be-2 border-y-4")).to eq("border-y-4")
    expect(merger.merge("border-s-red-500 border-x-blue-500")).to eq("border-x-blue-500")
    expect(merger.merge("border-bs-red-500 border-y-blue-500")).to eq("border-y-blue-500")
    expect(merger.merge("scroll-ms-2 scroll-mx-4")).to eq("scroll-mx-4")
    expect(merger.merge("scroll-mbs-2 scroll-my-4")).to eq("scroll-my-4")
    expect(merger.merge("scroll-ps-2 scroll-px-4")).to eq("scroll-px-4")
    expect(merger.merge("scroll-pbe-2 scroll-py-4")).to eq("scroll-py-4")
  end

  it "ring and shadow classes do not create conflict" do
    expect(merger.merge("ring shadow")).to eq("ring shadow")
    expect(merger.merge("ring-2 shadow-md")).to eq("ring-2 shadow-md")
    expect(merger.merge("shadow ring")).to eq("shadow ring")
    expect(merger.merge("shadow-md ring-2")).to eq("shadow-md ring-2")
  end

  it "touch classes do create conflicts correctly" do
    expect(merger.merge("touch-pan-x touch-pan-right")).to eq("touch-pan-right")
    expect(merger.merge("touch-none touch-pan-x")).to eq("touch-pan-x")
    expect(merger.merge("touch-pan-x touch-none")).to eq("touch-none")
    expect(merger.merge("touch-pan-x touch-pan-y touch-pinch-zoom")).to eq("touch-pan-x touch-pan-y touch-pinch-zoom")
    expect(merger.merge("touch-manipulation touch-pan-x touch-pan-y touch-pinch-zoom")).to eq("touch-pan-x touch-pan-y touch-pinch-zoom")

    expect(merger.merge("touch-pan-x touch-pan-y touch-pinch-zoom touch-auto")).to eq("touch-auto")

    expect(merger.merge("overflow-auto inline line-clamp-1")).to eq("line-clamp-1")
    expect(merger.merge("line-clamp-1 overflow-auto inline")).to eq("line-clamp-1 overflow-auto inline")
  end
end
