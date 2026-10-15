# frozen_string_literal: true

require "stringio"

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

    # Simulated on CRuby: this file itself needs Ractor.shareable?.
    context "without Ractor, as on JRuby and TruffleRuby (simulated)" do
      before { allow(described_class).to receive(:ractor?).and_return(false) }

      it "still deep-freezes Hashes, Arrays and Strings" do
        value = { list: [+"a", { nested: +"b" }] }
        described_class.make(value)

        expect([value, value[:list], value[:list][0], value[:list][1][:nested]]).to all(be_frozen)
      end
    end
  end

  # What an app configures: freeze what can be frozen, keep the rest as it is.
  describe ".share" do
    it "deep-freezes Hashes, Arrays and Strings and returns the value" do
      value = { [DaisyUI::Button, :huge] => [+"a", { nested: +"b" }] }

      expect(described_class.share(value)).to be(value)
      expect(Ractor.shareable?(value)).to be(true)
    end

    it "makes a capture-free lambda shareable" do
      validator = DaisyUI.instance_exec { ->(token) { token.start_with?("btn") } }

      expect(Ractor.shareable?(described_class.share(validator))).to be(true)
    end

    it "keeps a lambda that closes over app state as it is, without raising" do
      reported = []
      callable = ->(error) { reported << error }
      value = { list: [+"a"], callable: callable }

      expect { described_class.share(value) }.not_to raise_error
      expect([value, value[:list], value[:list][0]]).to all(be_frozen)
      expect([callable, reported]).to all(satisfy { |object| !object.frozen? })
      expect(Ractor.shareable?(value)).to be(false)
    end

    it "leaves any other object, such as a logger, untouched" do
      io = StringIO.new
      # An app's logger: an IO behind a Mutex (Ruby 4.0 has no default `logger`
      # gem). Ractor.make_shareable would freeze it, then fail on the Mutex.
      logger = Struct.new(:io, :lock) { def warn(message) = lock.synchronize { io.puts(message) } }.new(io, Mutex.new)
      value = { reporter: logger }

      expect { described_class.share(value) }.not_to raise_error
      expect([logger, io]).to all(satisfy { |object| !object.frozen? })
      logger.warn("still logging")
      expect(io.string).to include("still logging")
    end

    # Simulated on CRuby: this file itself needs Ractor.shareable?.
    context "without Ractor, as on JRuby and TruffleRuby (simulated)" do
      before { allow(described_class).to receive(:ractor?).and_return(false) }

      it "deep-freezes Hashes, Arrays and Strings and leaves a Proc alone" do
        callable = -> {}
        value = { list: [+"a", { nested: +"b" }], callable: callable }
        described_class.share(value)

        expect([value, value[:list], value[:list][0], value[:list][1][:nested]]).to all(be_frozen)
        expect(callable).not_to be_frozen
      end
    end
  end
end
