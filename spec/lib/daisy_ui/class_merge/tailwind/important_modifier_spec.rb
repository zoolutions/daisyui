# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "important modifier" do
  let(:merger) { described_class.new }

  it "merges tailwind classes with important modifier correctly" do
    expect(merger.merge("font-medium! font-bold!")).to eq("font-bold!")
    expect(merger.merge("font-medium! font-bold! font-thin")).to eq("font-bold! font-thin")
    expect(merger.merge("right-2! -inset-x-px!")).to eq("-inset-x-px!")
    expect(merger.merge("focus:inline! focus:block!")).to eq("focus:block!")
    expect(merger.merge("[--my-var:20px]! [--my-var:30px]!")).to eq("[--my-var:30px]!")

    # Tailwind CSS v3 legacy syntax
    expect(merger.merge("font-medium! !font-bold")).to eq("!font-bold")
    expect(merger.merge("!font-medium !font-bold")).to eq("!font-bold")
    expect(merger.merge("!font-medium !font-bold font-thin")).to eq("!font-bold font-thin")
    expect(merger.merge("!right-2 !-inset-x-px")).to eq("!-inset-x-px")
    expect(merger.merge("focus:!inline focus:!block")).to eq("focus:!block")
    expect(merger.merge("![--my-var:20px] ![--my-var:30px]")).to eq("![--my-var:30px]")
  end
end
