# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "arbitrary values" do
  let(:merger) { described_class.new }

  it "handles simple conflicts with arbitrary values correctly" do
    expect(merger.merge("m-[2px] m-[10px]")).to eq("m-[10px]")
    expect(merger.merge("z-20 z-[99]")).to eq("z-[99]")
    expect(merger.merge("m-[2px] m-[11svmin] m-[12in] m-[13lvi] m-[14vb] m-[15vmax] m-[16mm] m-[17%] m-[18em] m-[19px] m-[10dvh]")).to eq("m-[10dvh]")
    expect(merger.merge("h-[10px] h-[11cqw] h-[12cqh] h-[13cqi] h-[14cqb] h-[15cqmin] h-[16cqmax]")).to eq("h-[16cqmax]")
    expect(merger.merge("my-[2px] m-[10rem]")).to eq("m-[10rem]")
    expect(merger.merge("cursor-pointer cursor-[grab]")).to eq("cursor-[grab]")
    expect(merger.merge("m-[2px] m-[calc(100%-var(--arbitrary))]")).to eq("m-[calc(100%-var(--arbitrary))]")
    expect(merger.merge("m-[2px] m-[length:var(--mystery-var)]")).to eq("m-[length:var(--mystery-var)]")
    expect(merger.merge("opacity-10 opacity-[0.025]")).to eq("opacity-[0.025]")
    expect(merger.merge("scale-75 scale-[1.7]")).to eq("scale-[1.7]")
    expect(merger.merge("brightness-90 brightness-[1.75]")).to eq("brightness-[1.75]")

    # Handling of value `0`
    expect(merger.merge("min-h-[0.5px] min-h-[0]")).to eq("min-h-[0]")
    expect(merger.merge("text-[0.5px] text-[color:0]")).to eq("text-[0.5px] text-[color:0]")
    expect(merger.merge("text-[0.5px] text-(--my-0)")).to eq("text-[0.5px] text-(--my-0)")
  end

  it "handles arbitrary length conflicts with labels and modifiers correctly" do
    expect(merger.merge("hover:m-[2px] hover:m-[length:var(--c)]")).to eq("hover:m-[length:var(--c)]")
    expect(merger.merge("hover:focus:m-[2px] focus:hover:m-[length:var(--c)]")).to eq("focus:hover:m-[length:var(--c)]")
    expect(merger.merge("border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))]")).to eq("border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))]")
    expect(merger.merge("border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-b")).to eq("border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-b")
    expect(merger.merge("border-b border-[color:rgb(var(--color-gray-500-rgb)/50%))] border-some-coloooor")).to eq("border-b border-some-coloooor")
  end

  it "handles complex arbitrary value conflicts correctly" do
    expect(merger.merge("grid-rows-[1fr,auto] grid-rows-2")).to eq("grid-rows-2")
    expect(merger.merge("grid-rows-[repeat(20,minmax(0,1fr))] grid-rows-3")).to eq("grid-rows-3")
  end

  it "handles ambiguous arbitrary values correctly" do
    expect(merger.merge("mt-2 mt-[calc(theme(fontSize.4xl)/1.125)]")).to eq("mt-[calc(theme(fontSize.4xl)/1.125)]")
    expect(merger.merge("p-2 p-[calc(theme(fontSize.4xl)/1.125)_10px]")).to eq("p-[calc(theme(fontSize.4xl)/1.125)_10px]")
    expect(merger.merge("mt-2 mt-[length:theme(someScale.someValue)]")).to eq("mt-[length:theme(someScale.someValue)]")

    expect(merger.merge("mt-2 mt-[theme(someScale.someValue)]")).to eq("mt-[theme(someScale.someValue)]")

    expect(merger.merge("text-2xl text-[length:theme(someScale.someValue)]")).to eq("text-[length:theme(someScale.someValue)]")
    expect(merger.merge("text-2xl text-[calc(theme(fontSize.4xl)/1.125)]")).to eq("text-[calc(theme(fontSize.4xl)/1.125)]")

    expect(merger.merge("bg-cover bg-[percentage:30%] bg-[size:200px_100px] bg-[length:200px_100px]")).to eq("bg-[percentage:30%] bg-[length:200px_100px]")
    expect(merger.merge("bg-none bg-[url(.)] bg-[image:.] bg-[url:.] bg-[linear-gradient(.)] bg-linear-to-r")).to eq("bg-linear-to-r")
    expect(merger.merge("border-[color-mix(in_oklab,var(--background),var(--calendar-color)_30%)] border")).to eq("border-[color-mix(in_oklab,var(--background),var(--calendar-color)_30%)] border")

    expect(merger.merge("font-[400] font-[600]")).to eq("font-[600]")
    expect(merger.merge("font-[var(--a)] font-[var(--b)]")).to eq("font-[var(--b)]")
    expect(merger.merge("font-[weight:var(--a)] font-[var(--b)]")).to eq("font-[var(--b)]")
    expect(merger.merge("font-[400] font-[weight:var(--b)]")).to eq("font-[weight:var(--b)]")
    expect(merger.merge("font-[weight:var(--a)] font-[weight:var(--b)]")).to eq("font-[weight:var(--b)]")
    expect(merger.merge("font-[family-name:var(--a)] font-[var(--b)]")).to eq("font-[family-name:var(--a)] font-[var(--b)]")
  end

  it "handles arbitrary custom properties correctly" do
    expect(merger.merge("bg-red bg-(--other-red) bg-bottom bg-(position:-my-pos)")).to eq("bg-(--other-red) bg-(position:-my-pos)")
    expect(merger.merge("shadow-xs shadow-(shadow:--something) shadow-red shadow-(--some-other-shadow) shadow-(color:--some-color)")).to eq("shadow-(--some-other-shadow) shadow-(color:--some-color)")

    expect(merger.merge("font-(--a) font-(--b)")).to eq("font-(--b)")
    expect(merger.merge("font-(weight:--a) font-(--b)")).to eq("font-(--b)")
    expect(merger.merge("font-(family-name:--a) font-(--b)")).to eq("font-(family-name:--a) font-(--b)")
  end
end
