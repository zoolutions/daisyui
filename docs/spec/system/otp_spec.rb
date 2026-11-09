# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OTP input", type: :system do
  it "keeps each typed digit in its box although @tailwindcss/forms resets input font-size" do
    visit component_path("otp")

    fill_in "otp-code", with: "123456"

    metrics = page.evaluate_script(<<~JS)
      (() => {
        const input = document.querySelector("#otp-code")
        return {
          valid: input.matches(":valid"),
          inputFontSize: getComputedStyle(input).fontSize,
          otpFontSize: getComputedStyle(input.parentElement).fontSize,
        }
      })()
    JS

    expect(metrics.fetch("valid")).to be(true)
    expect(metrics.fetch("inputFontSize")).to eq(metrics.fetch("otpFontSize"))
  end

  it "styles the disabled example with daisyUI 5.7's disabled state" do
    visit component_path("otp")

    cursor = page.evaluate_script('getComputedStyle(document.querySelector("#disabled .otp")).cursor')

    expect(cursor).to eq("not-allowed")
  end
end
