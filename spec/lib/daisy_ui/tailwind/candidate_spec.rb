# frozen_string_literal: true

RSpec.describe DaisyUI::Tailwind::Candidate do
  describe ".valid?" do
    %w[
      btn btn-primary sm:btn-lg @sm:btn-lg xl:@md:card-side after:hidden
      -mt-2 w-1/2 bg-base-100/50 has-[:checked]:badge-primary
      w-[calc(100%-1rem)] [&>li]:p-2 btn! skeleton
    ].each do |token|
      it "accepts #{token.inspect}" do
        expect(described_class.valid?(token)).to be(true)
      end
    end

    # Each of these is a real string from a component's Ruby. One unbalanced
    # bracket in `@source inline("…")` makes Tailwind drop every class after
    # it, so none may reach the manifest.
    [
      "", "-", "_", "--size:", "anchor-name:--", "clip-path:polygon(0", "w-[1",
      "dropdown_", "phlex/version", "Email", "0,100%", "[0-9]{", "}",
      ".showModal()", "position:fixed;inset:auto", 'a"b', "a'b", "a\\b", "a`b"
    ].each do |token|
      it "rejects #{token.inspect}" do
        expect(described_class.valid?(token)).to be(false)
      end
    end
  end

  describe ".tokens" do
    it "splits a class string and keeps only the candidates" do
      expect(described_class.tokens("btn  btn-primary --size: card-body")).to eq(%w[btn btn-primary card-body])
    end
  end
end
