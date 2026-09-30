# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "theme" do
  it "theme scale can be extended" do
    merger = described_class.new(config: {
      theme: {
        "spacing" => ["my-space"],
        "leading" => ["my-leading"]
      }
    }
                                )

    expect(merger.merge("p-3 p-my-space p-my-margin")).to eq("p-my-space p-my-margin")
    expect(merger.merge("leading-3 leading-my-space leading-my-leading")).to eq("leading-my-leading")
  end

  it "leading none is independent of the leading theme scale" do
    # `leading-none` is a static Tailwind v4 utility (`line-height: 1`) that does not
    # come from the `--leading-*` theme namespace, so it must stay in the leading class
    # group even if the theme scale is replaced -- same as `rounded-none` / `shadow-none`
    # survive `theme.radius` / `theme.shadow` overrides. This port only supports
    # extending theme scales, so the invariant is pinned on the class group itself.
    leading_group = DaisyUI::ClassMerge::TailwindConfig::DEFAULTS[:class_groups]["leading"].first["leading"]

    expect(leading_group).to include("none")

    merger = described_class.new

    expect(merger.merge("leading-tight leading-none")).to eq("leading-none")
    expect(merger.merge("leading-none leading-tight")).to eq("leading-tight")
    expect(merger.merge("leading-4 leading-none")).to eq("leading-none")
  end

  # def test_theme_object_can_be_extended
  #   merger = DaisyUI::ClassMerge::Merger.new(config: {
  #     theme: {
  #       "spacing" => ["my-space"],
  #       "margin" => ["my-margin"],
  #     },
  #   })

  #   assert_equal("p-3 p-hello p-hallo", merger.merge("p-3 p-hello p-hallo"))
  #   assert_equal("px-hallo", merger.merge("px-3 px-hello px-hallo"))
  # end
end
