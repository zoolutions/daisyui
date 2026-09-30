# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "modifiers" do
  let(:merger) { described_class.new }

  it "conflicts across prefix modifiers" do
    expect(merger.merge("hover:block hover:inline")).to eq("hover:inline")
    expect(merger.merge("hover:block hover:focus:inline")).to eq("hover:block hover:focus:inline")
    expect(merger.merge("hover:block hover:focus:inline focus:hover:inline")).to eq("hover:block focus:hover:inline")
    expect(merger.merge("focus-within:inline focus-within:block")).to eq("focus-within:block")
  end

  it "conflicts across postfix modifiers" do
    expect(merger.merge("text-lg/7 text-lg/8")).to eq("text-lg/8")
    expect(merger.merge("text-lg/none leading-9")).to eq("text-lg/none leading-9")
    expect(merger.merge("leading-9 text-lg/none")).to eq("text-lg/none")
    expect(merger.merge("w-full w-1/2")).to eq("w-1/2")

    config = {
      cache_size: 10,
      theme: {},
      class_groups: {
        foo: ["foo-1/2", "foo-2/3"],
        bar: %w[bar-1 bar-2],
        baz: %w[baz-1 baz-2]
      },
      conflicting_class_groups: {},
      conflicting_class_group_modifiers: {
        baz: ["bar"]
      },
      order_sensitive_modifiers: []
    }
    custom_merger = described_class.new(config:)

    expect(custom_merger.merge("foo-1/2 foo-2/3")).to eq("foo-2/3")
    expect(custom_merger.merge("foo-1/2 foo-2/3")).to eq("foo-2/3")

    expect(custom_merger.merge("bar-1 bar-2")).to eq("bar-2")
    expect(custom_merger.merge("bar-1 baz-1")).to eq("bar-1 baz-1")
    expect(custom_merger.merge("bar-1/2 bar-2")).to eq("bar-2")
    expect(custom_merger.merge("bar-2 bar-1/2")).to eq("bar-1/2")
    expect(custom_merger.merge("bar-1 baz-1/2")).to eq("baz-1/2")
  end

  it "sorts modifiers correctly" do
    expect(merger.merge("c:d:e:block d:c:e:inline")).to eq("d:c:e:inline")
    expect(merger.merge("*:before:block *:before:inline")).to eq("*:before:inline")
    expect(merger.merge("*:before:block before:*:inline")).to eq("*:before:block before:*:inline")
    expect(merger.merge("x:y:*:z:block y:x:*:z:inline")).to eq("y:x:*:z:inline")
  end

  it "sorts modifiers correctly according to order sensitive modifiers" do
    config = {
      cache_size: 10,
      theme: {},
      class_groups: {
        foo: %w[foo-1 foo-2]
      },
      conflicting_class_groups: {},
      conflicting_class_group_modifiers: {},
      order_sensitive_modifiers: %w[a b]
    }

    custom_merger = described_class.new(config:)

    expect(custom_merger.merge("c:d:e:foo-1 d:c:e:foo-2")).to eq("d:c:e:foo-2")
    expect(custom_merger.merge("a:b:foo-1 a:b:foo-2")).to eq("a:b:foo-2")
    expect(custom_merger.merge("a:b:foo-1 b:a:foo-2")).to eq("a:b:foo-1 b:a:foo-2")
    expect(custom_merger.merge("x:y:a:z:foo-1 y:x:a:z:foo-2")).to eq("y:x:a:z:foo-2")
  end
end
