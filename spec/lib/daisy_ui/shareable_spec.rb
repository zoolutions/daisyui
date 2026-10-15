# frozen_string_literal: true

RSpec.describe DaisyUI::Shareable do
  describe ".make" do
    it "deep-freezes the value and returns it" do
      value = { list: [+"a", { nested: +"b" }] }

      expect(described_class.make(value)).to be(value)
      expect([value, value[:list], value[:list][0], value[:list][1][:nested]]).to all(be_frozen)
      expect(Ractor.shareable?(value)).to be(true)
    end

    it "makes a capture-free lambda shareable" do
      validator = DaisyUI.instance_exec { ->(token) { token.start_with?("btn") } }

      expect(Ractor.shareable?(described_class.make(validator))).to be(true)
    end

    context "without Ractor (JRuby, TruffleRuby)" do
      before { allow(described_class).to receive(:ractor?).and_return(false) }

      it "still deep-freezes Hashes, Arrays and Strings" do
        value = { list: [+"a", { nested: +"b" }] }
        described_class.make(value)

        expect([value, value[:list], value[:list][0], value[:list][1][:nested]]).to all(be_frozen)
      end
    end
  end
end
