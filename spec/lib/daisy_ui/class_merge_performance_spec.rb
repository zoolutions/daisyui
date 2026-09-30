# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge, :perf do
  def measure
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
  end

  let(:inputs) do
    Array.new(50) { |i| "btn btn-sm px-#{i % 12} py-2 text-sm btn-lg px-4 hover:bg-base-200 item-#{i}" }
  end

  it "merges 10k strings on a warm cache in under 50ms" do
    inputs.each { |input| described_class.merge(input) }

    elapsed = measure do
      10_000.times { |i| described_class.merge(inputs[i % inputs.size]) }
    end

    expect(elapsed).to be < 0.05
  end

  it "reports cold merge timing" do
    merger = DaisyUI::ClassMerge::Merger.new(config: DaisyUI.configuration.class_merge.merger_config)

    elapsed = measure { inputs.each { |input| merger.merge(input) } }

    puts format("\n  cold: %<total>.2fms for %<count>d merges (%<each>.1fµs each)",
      total: elapsed * 1000, count: inputs.size, each: elapsed * 1_000_000 / inputs.size
    )
    expect(elapsed).to be_positive
  end
end
