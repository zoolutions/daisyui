# frozen_string_literal: true

RSpec.describe DaisyUI::Store do
  after { described_class.delete(:daisy_ui_store_spec) }

  describe ".fetch" do
    it "builds the value once and returns the same object afterwards" do
      first = described_class.fetch(:daisy_ui_store_spec) { +"built" }

      expect(described_class.fetch(:daisy_ui_store_spec) { +"rebuilt" }).to be(first)
    end

    it "caches nil and false instead of rebuilding them" do
      builds = 0
      2.times do
        described_class.fetch(:daisy_ui_store_spec) do
          builds += 1
          nil
        end
      end

      expect(builds).to eq(1)
    end

    it "needs an initializer block" do
      expect { described_class.fetch(:daisy_ui_store_spec) }.to raise_error(ArgumentError, /needs an initializer block/)
    end

    it "lets the initializer delete another key without deadlocking" do
      described_class.fetch(:daisy_ui_store_spec_other) { +"old" }

      value = described_class.fetch(:daisy_ui_store_spec) do
        described_class.delete(:daisy_ui_store_spec_other)
        +"built"
      end

      expect(value).to eq("built")
      expect(described_class.fetch(:daisy_ui_store_spec_other) { +"new" }).to eq("new")
    ensure
      described_class.delete(:daisy_ui_store_spec_other)
    end
  end

  describe ".fetch under contention" do
    # Thread.pass hands the GVL over mid-build, so an unguarded fetch builds a
    # distinct object per thread.
    let(:subject_call) do
      lambda do
        described_class.fetch(:daisy_ui_store_spec) do
          Thread.pass
          Object.new
        end
      end
    end

    it_behaves_like "thread-safe under contention", threads: 8, iterations: 20, consistent: :identical
  end

  describe ".delete" do
    it "drops the value so the next fetch builds it again" do
      first = described_class.fetch(:daisy_ui_store_spec) { Object.new }
      described_class.delete(:daisy_ui_store_spec)

      expect(described_class.fetch(:daisy_ui_store_spec) { Object.new }).not_to be(first)
    end

    it "ignores a key that was never stored" do
      expect(described_class.delete(:daisy_ui_store_spec)).to be_nil
    end
  end

  describe "per-Ractor values" do
    # Capture-free, so it names the constant rather than described_class.
    # rubocop:disable-next RSpec/DescribedClass
    let(:subject_call) do
      lambda do
        DaisyUI::Store.fetch(:daisy_ui_store_spec_ractor) { Ractor.current.object_id }
        DaisyUI::Store.fetch(:daisy_ui_store_spec_ractor) { Object.new } == Ractor.current.object_id
      end
    end

    after { described_class.delete(:daisy_ui_store_spec_ractor) }

    # A non-main Ractor builds its own value: it never sees the main Ractor's.
    it_behaves_like "runs inside a non-main Ractor"
  end

  describe ".main_ractor?" do
    it "is true on the main Ractor" do
      expect(described_class.main_ractor?).to be(true)
    end
  end
end
