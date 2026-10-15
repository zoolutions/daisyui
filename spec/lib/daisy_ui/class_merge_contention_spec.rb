# frozen_string_literal: true

RSpec.describe DaisyUI::ClassMerge do
  describe ".merge" do
    before { described_class.reset! }

    let(:subject_call) { -> { described_class.merge("p-2 p-4 btn btn-sm btn-primary btn-lg", "hover:bg-base-200") } }

    it_behaves_like "thread-safe under contention", threads: 8, iterations: 50, consistent: :equal
    it_behaves_like "fiber-safe under an Async reactor", fibers: 8, iterations: 50, consistent: :equal
  end

  describe ".tailwind_utils" do
    # Every thread asks before the class groups exist; the Thread.pass inside
    # the build hands the GVL to the others, so an unguarded `||=` builds them
    # once per thread and the results are not identical.
    before do
      DaisyUI::Store.delete(:daisy_ui_tailwind_utils)
      allow(DaisyUI::ClassMerge::ClassGroupUtils).to receive(:new).and_wrap_original do |original, *args|
        Thread.pass
        original.call(*args)
      end
    end

    let(:subject_call) { -> { described_class.tailwind_utils } }

    it_behaves_like "thread-safe under contention", threads: 8, iterations: 5, consistent: :identical

    # Proves the setup above reaches the build, so the race is really run.
    it "builds the class groups exactly once across the threads" do
      # rubocop:disable-next ThreadSafety/NewThread -- starts threads on purpose, to contend on the build
      Array.new(8) { Thread.new { described_class.tailwind_utils } }.each(&:join)

      expect(DaisyUI::ClassMerge::ClassGroupUtils).to have_received(:new).once
    end
  end
end
