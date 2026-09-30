# frozen_string_literal: true

# Ported from tailwind_merge 1.5.6 (https://github.com/gjtorikian/tailwind_merge)
# Copyright (c) 2022 Garen J. Torikian. MIT License, see LICENSE-tailwind_merge.txt.

RSpec.describe DaisyUI::ClassMerge::Merger, "config" do
  it "default config has correct types" do
    config = DaisyUI::ClassMerge::TailwindConfig::DEFAULTS

    expect(config[:cache_size]).to eq(500)
    expect(config[:ignore_empty_cache]).to be_truthy
    expect(config[:nonexistent]).to be_falsey
    expect(config[:class_groups]["display"].first).to eq("block")
    expect(config[:class_groups]["overflow"].first["overflow"].first).to eq("auto")
    expect(config[:class_groups]["overflow"].first[:nonexistent]).to be_falsey
  end

  it "defaults is deeply frozen" do
    unfrozen = []
    walk = lambda do |object, path|
      case object
      when Hash
        unfrozen << path unless object.frozen?
        object.each { |key, value| walk.call(value, "#{path}[#{key.inspect}]") }
      when Array
        unfrozen << path unless object.frozen?
        object.each_with_index { |value, index| walk.call(value, "#{path}[#{index}]") }
      end
    end
    walk.call(DaisyUI::ClassMerge::TailwindConfig::DEFAULTS, "DEFAULTS")

    expect(unfrozen).to be_empty
  end

  it "custom theme does not mutate default config" do
    default_spacing = DaisyUI::ClassMerge::TailwindConfig::DEFAULTS[:theme]["spacing"].dup

    3.times do |index|
      described_class.new(config: { theme: { "spacing" => ["custom-spacing-#{index}"] } })
    end

    expect(DaisyUI::ClassMerge::TailwindConfig::DEFAULTS[:theme]["spacing"]).to eq(default_spacing)
  end

  it "merge config does not mutate incoming config" do
    config = {
      cache_size: 10,
      theme: {
        "spacing" => ["custom-spacing"]
      }
    }
    original_config = config.dup
    original_config[:theme] = config[:theme].dup

    described_class.new(config:)

    expect(config).to eq(original_config)
  end
end
