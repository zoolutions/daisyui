# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge::Cache do
  subject(:cache) { described_class.new(2) }

  describe "#getset" do
    it "computes and stores a missing value" do
      expect(cache.getset("a") { "A" }).to eq("A")
      expect(cache.getset("a") { "other" }).to eq("A")
    end

    it "evicts the least recently used entry at capacity" do
      cache.getset("a") { "A" }
      cache.getset("b") { "B" }
      cache.getset("a") { "unused" } # touch a, so b is now the oldest
      cache.getset("c") { "C" }

      expect(cache.getset("b") { "recomputed" }).to eq("recomputed")
      expect(cache.getset("c") { "unused" }).to eq("C")
    end

    it "never holds more than its capacity" do
      10.times { |i| cache.getset(i) { i } }

      expect(cache.size).to eq(2)
    end

    it "does not store nil results" do
      cache.getset("a") { nil }

      expect(cache.getset("a") { "A" }).to eq("A")
    end

    it "stays consistent when shared across threads" do
      cache = described_class.new(50)
      threads = Array.new(8) do |t|
        Thread.new do
          1_000.times { |i| cache.getset("#{t}-#{i % 100}") { "#{t}-#{i % 100}" } }
        end
      end
      threads.each(&:join)

      expect(cache.size).to eq(50)
      expect(cache.getset("7-99") { "missing" }).to eq("7-99")
    end
  end
end
