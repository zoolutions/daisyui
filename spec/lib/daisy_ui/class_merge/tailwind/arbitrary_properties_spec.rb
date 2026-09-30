# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "arbitrary properties" do
  let(:merger) { described_class.new }

  it "handles arbitrary property conflicts correctly" do
    expect(merger.merge("[paint-order:markers] [paint-order:normal]")).to eq("[paint-order:normal]")
    expect(merger.merge("[paint-order:markers] [--my-var:2rem] [paint-order:normal] [--my-var:4px]")).to eq("[paint-order:normal] [--my-var:4px]")
  end

  it "handles arbitrary property conflicts with modifiers correctly" do
    expect(merger.merge("[paint-order:markers] hover:[paint-order:normal]")).to eq("[paint-order:markers] hover:[paint-order:normal]")

    expect(merger.merge("hover:[paint-order:markers] hover:[paint-order:normal]")).to eq("hover:[paint-order:normal]")

    expect(merger.merge("hover:focus:[paint-order:markers] focus:hover:[paint-order:normal]")).to eq("focus:hover:[paint-order:normal]")

    expect(merger.merge("[paint-order:markers] [paint-order:normal] [--my-var:2rem] lg:[--my-var:4px]")).to eq("[paint-order:normal] [--my-var:2rem] lg:[--my-var:4px]")

    expect(merger.merge("bg-[#B91C1C] bg-radial-[at_50%_75%] bg-radial-[at_25%_25%]")).to eq("bg-[#B91C1C] bg-radial-[at_25%_25%]")
  end

  it "handles complex arbitrary property conflicts correctly" do
    expect(merger.merge("[-unknown-prop:::123:::] [-unknown-prop:url(https://hi.com)]")).to eq("[-unknown-prop:url(https://hi.com)]")
  end

  it "handles important modifier correctly" do
    expect(merger.merge("![some:prop] [some:other]")).to eq("![some:prop] [some:other]")
    expect(merger.merge("![some:prop] [some:other] [some:one] ![some:another]")).to eq("[some:one] ![some:another]")
  end
end
