# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "arbitrary variants" do
  let(:merger) { described_class.new }

  it "basic arbitrary variants" do
    expect(merger.merge("[p]:underline [p]:line-through")).to eq("[p]:line-through")
    expect(merger.merge("[&>*]:underline [&>*]:line-through")).to eq("[&>*]:line-through")
    expect(merger.merge("[&>*]:underline [&>*]:line-through [&_div]:line-through")).to eq("[&>*]:line-through [&_div]:line-through")
    expect(merger.merge("supports-[display:grid]:flex supports-[display:grid]:grid")).to eq("supports-[display:grid]:grid")
  end

  it "arbitrary variants with modifiers" do
    expect(merger.merge("dark:lg:hover:[&>*]:underline dark:lg:hover:[&>*]:line-through")).to eq("dark:lg:hover:[&>*]:line-through")
    expect(merger.merge("dark:lg:hover:[&>*]:underline dark:hover:lg:[&>*]:line-through")).to eq("dark:hover:lg:[&>*]:line-through")
    # Whether a modifier is before or after arbitrary variant matters
    expect(merger.merge("hover:[&>*]:underline [&>*]:hover:line-through")).to eq("hover:[&>*]:underline [&>*]:hover:line-through")
    expect(merger.merge("hover:dark:[&>*]:underline dark:hover:[&>*]:underline dark:[&>*]:hover:line-through")).to eq("dark:hover:[&>*]:underline dark:[&>*]:hover:line-through")
  end

  it "arbitrary variants with complex syntax in them" do
    expect(merger.merge("[@media_screen{@media(hover:hover)}]:underline [@media_screen{@media(hover:hover)}]:line-through")).to eq("[@media_screen{@media(hover:hover)}]:line-through")
    expect(merger.merge("hover:[@media_screen{@media(hover:hover)}]:underline hover:[@media_screen{@media(hover:hover)}]:line-through")).to eq("hover:[@media_screen{@media(hover:hover)}]:line-through")
  end

  it "arbitrary variants with attribute selectors" do
    expect(merger.merge("[&[data-open]]:underline [&[data-open]]:line-through")).to eq("[&[data-open]]:line-through")
  end

  it "arbitrary variants with multiple attribute selectors" do
    expect(merger.merge("[&[data-foo][data-bar]:not([data-baz])]:underline [&[data-foo][data-bar]:not([data-baz])]:line-through")).to eq("[&[data-foo][data-bar]:not([data-baz])]:line-through")
  end

  it "multiple arbitrary variants" do
    expect(merger.merge("[&>*]:[&_div]:underline [&>*]:[&_div]:line-through")).to eq("[&>*]:[&_div]:line-through")
    expect(merger.merge("[&>*]:[&_div]:underline [&_div]:[&>*]:line-through")).to eq("[&>*]:[&_div]:underline [&_div]:[&>*]:line-through")
    expect(merger.merge("hover:dark:[&>*]:focus:disabled:[&_div]:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through")).to eq("dark:hover:[&>*]:disabled:focus:[&_div]:line-through")
    expect(merger.merge("hover:dark:[&>*]:focus:[&_div]:disabled:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through")).to eq("hover:dark:[&>*]:focus:[&_div]:disabled:underline dark:hover:[&>*]:disabled:focus:[&_div]:line-through")
  end

  it "arbitrary variants with arbitrary properties" do
    expect(merger.merge("[&>*]:[color:red] [&>*]:[color:blue]")).to eq("[&>*]:[color:blue]")
    expect(merger.merge("[&[data-foo][data-bar]:not([data-baz])]:nod:noa:[color:red] [&[data-foo][data-bar]:not([data-baz])]:noa:nod:[color:blue]")).to eq("[&[data-foo][data-bar]:not([data-baz])]:noa:nod:[color:blue]")
  end
end
