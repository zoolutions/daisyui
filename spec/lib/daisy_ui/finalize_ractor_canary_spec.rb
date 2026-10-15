# frozen_string_literal: true

# conformance-kit's Tier 3 canary: after DaisyUI.finalize! (what the Rails
# engine runs at boot), a non-main Ractor merges classes with a merger of its
# own. Ruby 4.0+ (Ractor#value); below that the kit skips with the reason.
RSpec.describe DaisyUI, ".finalize!", :finalizes, :ractor do
  before { described_class.finalize! }

  describe "then DaisyUI::ClassMerge.merge in a non-main Ractor" do
    # Capture-free: the kit runs it in Ractor.new.
    let(:subject_call) { ->(classes) { DaisyUI::ClassMerge.merge(classes) } }

    it_behaves_like "runs inside a non-main Ractor", inputs: ["p-2 p-4 btn btn-primary"]
    it_behaves_like "runs inside a non-main Ractor", inputs: ["btn btn-sm btn-lg text-sm text-error hover:bg-base-200"]
  end

  it "renders a component inside a non-main Ractor" do
    skip "needs Ruby 4.0+ (Ractor#value)" unless Ractor.method_defined?(:value)
    pending "Phlex cannot render in a non-main Ractor yet (Phlex::ATTRIBUTE_CACHE): " \
            "https://github.com/yippee-fun/phlex/pull/1055"

    html = Ractor.new do
      Thread.current.report_on_exception = false # the pending failure is expected, not news
      DaisyUI::Button.new(:primary).call
    end.value

    expect(html).to eq('<button class="btn btn-primary"></button>')
  end
end
