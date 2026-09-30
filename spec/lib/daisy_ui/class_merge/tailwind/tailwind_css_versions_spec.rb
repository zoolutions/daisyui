# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "tailwind css versions" do
  let(:merger) { described_class.new }

  it "tailwind 3 3 features" do
    expect(merger.merge("text-red text-lg/7 text-lg/8")).to eq("text-red text-lg/8")

    expect(merger.merge("start-0 start-1 end-0 end-1 ps-0 ps-1 pe-0 pe-1 ms-0 ms-1 me-0 me-1 rounded-s-sm rounded-s-md rounded-e-sm rounded-e-md rounded-ss-sm rounded-ss-md rounded-ee-sm rounded-ee-md")).to eq("start-1 end-1 ps-1 pe-1 ms-1 me-1 rounded-s-md rounded-e-md rounded-ss-md rounded-ee-md")

    expect(merger.merge("start-0 end-0 inset-0 ps-0 pe-0 p-0 ms-0 me-0 m-0 rounded-ss rounded-es rounded-s")).to eq("inset-0 p-0 m-0 rounded-s")

    expect(merger.merge("hyphens-auto hyphens-manual")).to eq("hyphens-manual")

    expect(merger.merge("from-0% from-10% from-[12.5%] via-0% via-10% via-[12.5%] to-0% to-10% to-[12.5%]")).to eq("from-[12.5%] via-[12.5%] to-[12.5%]")

    expect(merger.merge("from-0% from-red")).to eq("from-0% from-red")

    expect(merger.merge("list-image-none list-image-[url(./my-image.png)] list-image-[var(--value)]")).to eq("list-image-[var(--value)]")

    expect(merger.merge("caption-top caption-bottom")).to eq("caption-bottom")
    expect(merger.merge("line-clamp-2 line-clamp-none line-clamp-[10]")).to eq("line-clamp-[10]")
    expect(merger.merge("delay-150 delay-0 duration-150 duration-0")).to eq("delay-0 duration-0")
    expect(merger.merge("justify-normal justify-center justify-stretch")).to eq("justify-stretch")
    expect(merger.merge("content-normal content-center content-stretch")).to eq("content-stretch")
    expect(merger.merge("whitespace-nowrap whitespace-break-spaces")).to eq("whitespace-break-spaces")
  end

  it "tailwind 3 4 features" do
    expect(merger.merge("h-svh h-dvh w-svw w-dvw")).to eq("h-dvh w-dvw")

    expect(merger.merge("has-[[data-potato]]:p-1 has-[[data-potato]]:p-2 group-has-[:checked]:grid group-has-[:checked]:flex")).to eq("has-[[data-potato]]:p-2 group-has-[:checked]:flex")

    expect(merger.merge("text-wrap text-pretty")).to eq("text-pretty")
    expect(merger.merge("w-5 h-3 size-10 w-12")).to eq("size-10 w-12")

    expect(merger.merge("grid-cols-2 grid-cols-subgrid grid-rows-5 grid-rows-subgrid")).to eq("grid-cols-subgrid grid-rows-subgrid")

    expect(merger.merge("min-w-0 min-w-50 min-w-px max-w-0 max-w-50 max-w-px")).to eq("min-w-px max-w-px")

    expect(merger.merge("forced-color-adjust-none forced-color-adjust-auto")).to eq("forced-color-adjust-auto")

    expect(merger.merge("appearance-none appearance-auto")).to eq("appearance-auto")
    expect(merger.merge("float-start float-end clear-start clear-end")).to eq("float-end clear-end")
    expect(merger.merge("*:p-10 *:p-20 hover:*:p-10 hover:*:p-20")).to eq("*:p-20 hover:*:p-20")
  end

  it "tailwind 4 0 features" do
    expect(merger.merge("transform-3d transform-flat")).to eq("transform-flat")
    expect(merger.merge("rotate-12 rotate-x-2 rotate-none rotate-y-3")).to eq("rotate-x-2 rotate-none rotate-y-3")
    expect(merger.merge("perspective-dramatic perspective-none perspective-midrange")).to eq("perspective-midrange")
    expect(merger.merge("perspective-origin-center perspective-origin-top-left")).to eq("perspective-origin-top-left")
    expect(merger.merge("bg-linear-to-r bg-linear-45")).to eq("bg-linear-45")
    expect(merger.merge("bg-linear-to-r bg-radial-[something] bg-conic-10")).to eq("bg-conic-10")
    expect(merger.merge("bg-conic bg-conic-10")).to eq("bg-conic-10")
    expect(merger.merge("bg-conic-10 bg-conic")).to eq("bg-conic")
    expect(merger.merge("bg-radial bg-conic/decreasing")).to eq("bg-conic/decreasing")
    expect(merger.merge("bg-red-500 bg-conic")).to eq("bg-red-500 bg-conic")
    expect(merger.merge("ring-4 ring-orange inset-ring inset-ring-3 inset-ring-blue")).to eq("ring-4 ring-orange inset-ring-3 inset-ring-blue")
    expect(merger.merge("field-sizing-content field-sizing-fixed")).to eq("field-sizing-fixed")
    expect(merger.merge("scheme-normal scheme-dark")).to eq("scheme-dark")
    expect(merger.merge("font-stretch-expanded font-stretch-[66.66%] font-stretch-50%")).to eq("font-stretch-50%")
    expect(merger.merge("col-span-full col-2 row-span-3 row-4")).to eq("col-2 row-4")

    expect(merger.merge("via-red-500 via-(--mobile-header-gradient)")).to eq("via-(--mobile-header-gradient)")
    expect(merger.merge("via-red-500 via-(length:--mobile-header-gradient)")).to eq("via-red-500 via-(length:--mobile-header-gradient)")

    # shadow-inner is deprecated in v4 but still sets --tw-shadow, so it conflicts
    # with other shadow utilities and not with shadow color utilities.
    expect(merger.merge("shadow-inner shadow-lg")).to eq("shadow-lg")
    expect(merger.merge("shadow-lg shadow-inner")).to eq("shadow-inner")
    expect(merger.merge("shadow-initial shadow-inner")).to eq("shadow-initial shadow-inner")
  end

  it "tailwind 4 1 features" do
    expect(merger.merge("items-baseline items-baseline-last")).to eq("items-baseline-last")
    expect(merger.merge("self-baseline self-baseline-last")).to eq("self-baseline-last")
    expect(merger.merge("place-content-center place-content-end-safe place-content-center-safe")).to eq("place-content-center-safe")
    expect(merger.merge("items-center-safe items-baseline items-end-safe")).to eq("items-end-safe")
    expect(merger.merge("wrap-break-word wrap-normal wrap-anywhere")).to eq("wrap-anywhere")
    expect(merger.merge("text-shadow-none text-shadow-2xl")).to eq("text-shadow-2xl")
    expect(merger.merge("text-shadow-none text-shadow-md text-shadow-red text-shadow-red-500 shadow-red shadow-3xs")).to eq("text-shadow-md text-shadow-red-500 shadow-red shadow-3xs")
    expect(merger.merge("mask-add mask-subtract")).to eq("mask-subtract")
    expect(merger.merge(
        "mask-(--foo) mask-[foo] mask-none " \
        "mask-linear-1 mask-linear-2 " \
        "mask-linear-from-[position:test] mask-linear-from-3 " \
        "mask-linear-to-[position:test] mask-linear-to-3 " \
        "mask-linear-from-color-red mask-linear-from-color-3 " \
        "mask-linear-to-color-red mask-linear-to-color-3 " \
        "mask-t-from-[position:test] mask-t-from-3 " \
        "mask-t-to-[position:test] mask-t-to-3 " \
        "mask-t-from-color-red mask-t-from-color-3 " \
        "mask-radial-(--test) mask-radial-[test] " \
        "mask-radial-from-[position:test] mask-radial-from-3 " \
        "mask-radial-to-[position:test] mask-radial-to-3 " \
        "mask-radial-from-color-red mask-radial-from-color-3"
      )
          ).to eq("mask-none mask-linear-2 mask-linear-from-3 mask-linear-to-3 mask-linear-from-color-3 mask-linear-to-color-3 mask-t-from-3 mask-t-to-3 mask-t-from-color-3 mask-radial-[test] mask-radial-from-3 mask-radial-to-3 mask-radial-from-color-3")
    expect(merger.merge(
        "mask-(--something) mask-[something] " \
        "mask-top-left mask-center mask-(position:--var) mask-[position:1px_1px] mask-position-(--var) mask-position-[1px_1px]"
      )
          ).to eq("mask-[something] mask-position-[1px_1px]")
    expect(merger.merge(
        "mask-(--something) mask-[something] " \
        "mask-auto mask-[size:foo] mask-(size:--foo) mask-size-[foo] mask-size-(--foo) mask-cover mask-contain"
      )
          ).to eq("mask-[something] mask-contain")
    expect(merger.merge("mask-type-luminance mask-type-alpha")).to eq("mask-type-alpha")
    expect(merger.merge("shadow-md shadow-lg/25 text-shadow-md text-shadow-lg/25")).to eq("shadow-lg/25 text-shadow-lg/25")
    expect(merger.merge("drop-shadow-some-color drop-shadow-[#123456] drop-shadow-lg drop-shadow-[10px_0]")).to eq("drop-shadow-[#123456] drop-shadow-[10px_0]")
    expect(merger.merge("drop-shadow-[#123456] drop-shadow-some-color")).to eq("drop-shadow-some-color")
    expect(merger.merge("drop-shadow-2xl drop-shadow-[shadow:foo]")).to eq("drop-shadow-[shadow:foo]")
  end

  it "tailwind 4 2 features" do
    # Logical inset utilities
    expect(merger.merge("inset-s-1 inset-s-2")).to eq("inset-s-2")
    expect(merger.merge("inset-e-1 inset-e-2")).to eq("inset-e-2")
    expect(merger.merge("inset-bs-1 inset-bs-2")).to eq("inset-bs-2")
    expect(merger.merge("inset-be-1 inset-be-2")).to eq("inset-be-2")
    expect(merger.merge("inset-s-1 inset-bs-1")).to eq("inset-s-1 inset-bs-1")
    expect(merger.merge("inset-s-1 inset-e-1 inset-bs-1 inset-be-1 inset-0")).to eq("inset-0")

    # Logical spacing
    expect(merger.merge("pbs-1 pbs-2")).to eq("pbs-2")
    expect(merger.merge("pbe-1 pbe-2")).to eq("pbe-2")
    expect(merger.merge("mbs-1 mbs-2")).to eq("mbs-2")
    expect(merger.merge("mbe-1 mbe-2")).to eq("mbe-2")
    expect(merger.merge("pbs-1 pbe-1 p-0")).to eq("p-0")
    expect(merger.merge("mbs-1 mbe-1 m-0")).to eq("m-0")

    # Logical scroll spacing
    expect(merger.merge("scroll-pbs-1 scroll-pbs-2")).to eq("scroll-pbs-2")
    expect(merger.merge("scroll-pbe-1 scroll-pbe-2")).to eq("scroll-pbe-2")
    expect(merger.merge("scroll-mbs-1 scroll-mbs-2")).to eq("scroll-mbs-2")
    expect(merger.merge("scroll-mbe-1 scroll-mbe-2")).to eq("scroll-mbe-2")
    expect(merger.merge("scroll-pbs-1 scroll-pbe-1 scroll-p-0")).to eq("scroll-p-0")
    expect(merger.merge("scroll-mbs-1 scroll-mbe-1 scroll-m-0")).to eq("scroll-m-0")

    # Logical border block
    expect(merger.merge("border-bs border-bs-2")).to eq("border-bs-2")
    expect(merger.merge("border-be border-be-2")).to eq("border-be-2")
    expect(merger.merge("border-bs border-be border-2")).to eq("border-2")

    # Logical sizing
    expect(merger.merge("inline-full inline-auto")).to eq("inline-auto")
    expect(merger.merge("block-full block-auto")).to eq("block-auto")
    expect(merger.merge("min-inline-full min-inline-auto")).to eq("min-inline-auto")
    expect(merger.merge("max-inline-full max-inline-none")).to eq("max-inline-none")
    expect(merger.merge("min-block-full min-block-auto")).to eq("min-block-auto")
    expect(merger.merge("max-block-full max-block-none")).to eq("max-block-none")
    expect(merger.merge("inline-2xl inline-3xl")).to eq("inline-3xl")
    expect(merger.merge("min-inline-xs min-inline-1/2")).to eq("min-inline-1/2")
    expect(merger.merge("max-inline-svw max-inline-xl")).to eq("max-inline-xl")

    # Font feature settings
    expect(merger.merge("font-features-[\"smcp\"] font-features-[\"tnum\"]")).to eq("font-features-[\"tnum\"]")

    # Decimal fractions
    expect(merger.merge("aspect-4/3 aspect-8.5/11")).to eq("aspect-8.5/11")
    expect(merger.merge("w-1/2 w-8.5/11")).to eq("w-8.5/11")
  end

  it "tailwind 4 3 scrollbar features" do
    expect(merger.merge("scrollbar-auto scrollbar-thin scrollbar-none")).to eq("scrollbar-none")
    expect(merger.merge("scrollbar-gutter-auto scrollbar-gutter-stable scrollbar-gutter-both")).to eq("scrollbar-gutter-both")

    expect(merger.merge("scrollbar-thumb-red-500 scrollbar-thumb-blue-500")).to eq("scrollbar-thumb-blue-500")
    expect(merger.merge("scrollbar-thumb-red-500 scrollbar-thumb-red-500/50")).to eq("scrollbar-thumb-red-500/50")
    expect(merger.merge("scrollbar-thumb-[#0088cc] scrollbar-thumb-(--thumb-color)")).to eq("scrollbar-thumb-(--thumb-color)")

    expect(merger.merge("scrollbar-track-red-500 scrollbar-track-blue-500")).to eq("scrollbar-track-blue-500")
    expect(merger.merge("scrollbar-track-red-500 scrollbar-track-[color:var(--track-color)]")).to eq("scrollbar-track-[color:var(--track-color)]")

    expect(merger.merge("scrollbar-thin scrollbar-thumb-red-500 scrollbar-track-blue-500")).to eq("scrollbar-thin scrollbar-thumb-red-500 scrollbar-track-blue-500")
  end

  it "tailwind 4 3 container query container features" do
    expect(merger.merge("@container @container-normal @container-size")).to eq("@container-size")
    expect(merger.merge("@container-[inline-size] @container-(--container-type)")).to eq("@container-(--container-type)")

    expect(merger.merge("@container @container-size/sidebar")).to eq("@container-size/sidebar")
    expect(merger.merge("@container-normal @container-size/sidebar")).to eq("@container-size/sidebar")
    expect(merger.merge("@container-size/sidebar @container")).to eq("@container-size/sidebar @container")
    expect(merger.merge("@container/sidebar @container-normal")).to eq("@container/sidebar @container-normal")

    expect(merger.merge("@container/sidebar @container-normal/sidebar @container-size/content")).to eq("@container-size/content")
    expect(merger.merge("@container/sidebar @container-normal/content @container-size")).to eq("@container-normal/content @container-size")
    expect(merger.merge("@container-size @container/sidebar")).to eq("@container/sidebar")

    expect(merger.merge("@container-size/[sidebar] @container-normal/(--container-name)")).to eq("@container-normal/(--container-name)")
    expect(merger.merge("hover:@container hover:@container-size/sidebar")).to eq("hover:@container-size/sidebar")
    expect(merger.merge("hover:@container-size/sidebar hover:@container")).to eq("hover:@container-size/sidebar hover:@container")
    expect(merger.merge("@container! @container-size/sidebar!")).to eq("@container-size/sidebar!")
    expect(merger.merge("@container-size/sidebar! @container!")).to eq("@container-size/sidebar! @container!")

    expect(merger.merge("@container-foo/sidebar @container-size/sidebar")).to eq("@container-foo/sidebar @container-size/sidebar")
  end

  it "tailwind 4 3 zoom features" do
    expect(merger.merge("zoom-50 zoom-100")).to eq("zoom-100")
    expect(merger.merge("zoom-100 zoom-[var(--zoom)]")).to eq("zoom-[var(--zoom)]")
    expect(merger.merge("zoom-[1.5] zoom-(--zoom)")).to eq("zoom-(--zoom)")
    expect(merger.merge("zoom-50 scale-125")).to eq("zoom-50 scale-125")
  end

  it "tailwind 4 3 tab size features" do
    expect(merger.merge("tab-2 tab-8")).to eq("tab-8")
    expect(merger.merge("tab-8 tab-[12px]")).to eq("tab-[12px]")
    expect(merger.merge("tab-[3] tab-(--tab-size)")).to eq("tab-(--tab-size)")
    expect(merger.merge("tab-4 tabular-nums")).to eq("tab-4 tabular-nums")
  end

  it "tailwind 4 15 features" do
    expect(merger.merge("h-12 h-lh")).to eq("h-lh")
    expect(merger.merge("min-h-12 min-h-lh")).to eq("min-h-lh")
    expect(merger.merge("max-h-12 max-h-lh")).to eq("max-h-lh")
  end
end
