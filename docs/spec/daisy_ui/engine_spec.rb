# frozen_string_literal: true

require "rails_helper"

# The daisyui engine finalizes DaisyUI in after_initialize, with no app code:
# once this app has booted, a non-main Ractor can merge classes.
RSpec.describe DaisyUI::Engine do
  it "finalizes DaisyUI once the app has booted" do
    expect(Ractor.shareable?(DaisyUI.configuration)).to be(true)
    expect(Ractor.shareable?(DaisyUI::Button.modifiers)).to be(true)
  end

  it "lets a non-main Ractor merge classes" do
    skip "needs Ruby 4.0+ (Ractor#value)" unless Ractor.method_defined?(:value)

    merged = Ractor.new { DaisyUI::ClassMerge.merge("btn btn-sm btn-lg p-2 p-4") }.value

    expect(merged).to eq("btn btn-lg p-4")
  end
end
