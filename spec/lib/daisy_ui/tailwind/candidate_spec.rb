# frozen_string_literal: true

RSpec.describe DaisyUI::Tailwind::Candidate do
  describe ".valid?" do
    %w[
      btn btn-primary sm:btn-lg @sm:btn-lg xl:@md:card-side after:hidden
      -mt-2 w-1/2 bg-base-100/50 has-[:checked]:badge-primary
      w-[calc(100%-1rem)] [&>li]:p-2 btn! skeleton bg-red-500/[.5]
      group/item peer/field group-hover/item:underline group-has-[[data-state=error]]/item:block
      group-[.is-open]/item:flex peer-checked/field:block md:group-hover/item:underline
      motion-ease-in-out/opacity motion-duration-[9s]/opacity hover:motion-ease-in-out/scale
      motion-ease-in-out/opacity!
    ].each do |token|
      it "accepts #{token.inspect}" do
        expect(described_class.valid?(token)).to be(true)
      end
    end

    # A hyphenated head before one `/<name>` reads as a utility's modifier, so
    # a hyphenated gem's require path passes too: harmless noise in
    # @source inline, the price of accepting plugin modifiers (#71).
    it "accepts a hyphenated require path, which has a modifier's shape" do
      expect(described_class.valid?("phlex-rails/version")).to be(true)
    end

    # Each of these is a real string from a component's Ruby. One unbalanced
    # bracket in `@source inline("…")` makes Tailwind drop every class after
    # it, so none may reach the manifest.
    [
      "", "-", "_", "--size:", "anchor-name:--", "clip-path:polygon(0", "w-[1",
      "dropdown_", "phlex/version", "Email", "0,100%", "[0-9]{", "}",
      ".showModal()", "position:fixed;inset:auto", 'a"b', "a'b", "a\\b", "a`b",
      # A `/` before a letter is a path unless it names a group, a peer or a
      # plugin utility's modifier.
      "app/components", "vendor/foo", "group/item/extra", "lib/daisy_ui/base.rb",
      "hover/item:underline", "foo/bar/baz", "-/x", "--/x",
      # Named containers share an npm scope's shape, so both stay out.
      "@container/main", "@sm/main:flex", "@hotwired/stimulus",
      # A known limitation, not a rule: a path inside an arbitrary value is
      # still read as a path, although Tailwind would compile it.
      "bg-[url(/images/x.png)]"
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
