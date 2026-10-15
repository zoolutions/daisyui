# frozen_string_literal: true

require "open3"
require "rbconfig"
require "stringio"

# Without Rails, DaisyUI.configure is the boot point: it publishes a finalized
# configuration, so a non-main Ractor can merge classes with no
# DaisyUI.finalize! call of the app's own.
RSpec.describe DaisyUI, ".configure", :finalizes do
  it_behaves_like "a boot-finalized configuration",
    readers: {
      "DaisyUI.configuration" => -> { described_class.configuration },
      "DaisyUI.configuration.class_merge" => -> { described_class.configuration.class_merge },
      "DaisyUI.configuration.modifiers" => -> { described_class.configuration.modifiers },
      "DaisyUI::Button.modifiers" => -> { DaisyUI::Button.modifiers },
      "DaisyUI::Button.modifier_groups" => -> { DaisyUI::Button.modifier_groups }
    },
    finalize: -> { described_class.configure { |config| config.prefix = "tw-" } }

  it "finalizes an app component loaded before it" do
    # Tokens of its own: the class outlives stub_const in DaisyUI::Base.subclasses.
    widget = Class.new(DaisyUI::Base) { register_modifiers(size: { sm: "configured-sm" }, round: "configured-round") }
    stub_const("ConfiguredWidget", widget)

    described_class.configure

    expect([widget.component_class, widget.modifiers, widget.modifier_groups, widget.flags])
      .to all(satisfy { |registry| Ractor.shareable?(registry) })
  end

  describe "then DaisyUI::ClassMerge.merge in a non-main Ractor" do
    before { described_class.configure { |config| config.class_merge.theme(spacing: %w[gutter]) } }

    # Capture-free: the kit runs it in Ractor.new.
    let(:subject_call) { ->(classes) { DaisyUI::ClassMerge.merge(classes) } }

    it_behaves_like "runs inside a non-main Ractor", inputs: ["p-2 p-gutter btn btn-sm btn-lg"]
  end

  describe "called again" do
    it "yields a writable copy and publishes it only once it is finalized" do
      described_class.configure { |config| config.prefix = "tw-" }
      published = described_class.configuration

      described_class.configure do |config|
        expect(config).not_to be(published)
        expect(config).not_to be_frozen
        expect(described_class.configuration).to be(published)
        config.unknown_modifiers = :ignore
      end

      expect(described_class.configuration).to have_attributes(prefix: "tw-", unknown_modifiers: :ignore)
      expect(published).to have_attributes(prefix: "tw-", unknown_modifiers: :raise)
      expect(Ractor.shareable?(described_class.configuration)).to be(true)
    end

    it "keeps the published configuration when the block raises" do
      described_class.configure { |config| config.prefix = "tw-" }
      published = described_class.configuration

      expect { described_class.configure { |config| config.unknown_modifiers = :explode } }.to raise_error(ArgumentError)
      expect(described_class.configuration).to be(published)
    end
  end

  # The second call blocks on configure's lock, so it starts from what the
  # first one published. Unguarded, it copies the same configuration and the
  # last one to publish drops the other's setting.
  it "serializes concurrent calls, so neither drops the other's settings" do
    copied = Queue.new
    second = nil
    # rubocop:disable-next ThreadSafety/NewThread -- two threads configure at once on purpose
    first = Thread.new do
      described_class.configure do |config|
        config.prefix = "tw-"
        second = Thread.new do
          described_class.configure do |other|
            other.unknown_modifiers = :ignore
            copied << :second
          end
        end
        Thread.pass until copied.size.positive? || second.status == "sleep"
      end
    end
    first.join
    second.join

    expect(described_class.configuration).to have_attributes(prefix: "tw-", unknown_modifiers: :ignore)
  end

  it "changes nothing when the block raises, the first time too" do
    current = described_class.configuration

    expect do
      described_class.configure do |config|
        config.prefix = "tw-"
        config.unknown_modifiers = :explode
      end
    end.to raise_error(ArgumentError)

    expect(described_class.configuration).to be(current)
    expect(current.prefix).to be_nil
  end

  describe "a merger built before it" do
    it "is rebuilt from the published configuration where reset! never ran, as in another Ractor" do
      stale = DaisyUI::ClassMerge.merger
      allow(DaisyUI::ClassMerge).to receive(:reset!)

      described_class.configure { |config| config.class_merge.theme(text: %w[display]) }

      expect(DaisyUI::ClassMerge.merger).not_to be(stale)
      expect(DaisyUI::ClassMerge.merge("text-display text-error")).to eq("text-display text-error")
    end

    it "is rebuilt in a non-main Ractor that already merged", :ractor do
      skip "needs Ruby 4.0+ (Ractor::Port, Ractor#value)" unless defined?(Ractor::Port) && Ractor.method_defined?(:value)

      described_class.configure
      merged = Ractor::Port.new
      ractor = Ractor.new(merged) do |port|
        before = DaisyUI::ClassMerge.merge("text-display text-error")
        port << :merged
        Ractor.receive
        [before, DaisyUI::ClassMerge.merge("text-display text-error")]
      end
      merged.receive # the Ractor has built its merger
      described_class.configure { |config| config.class_merge.theme(text: %w[display]) }
      ractor.send(:reconfigured)

      expect(ractor.value).to eq(["text-error", "text-display text-error"])
    end
  end

  describe "a component that loads after it" do
    # Tokens of its own: the class outlives stub_const in DaisyUI::Base.subclasses.
    before do
      described_class.configure
      stub_const("LateWidget", Class.new(DaisyUI::Base) { register_modifiers(size: { sm: "late-sm", lg: "late-lg" }) })
    end

    it "has shareable registries without another finalize" do
      expect([LateWidget.component_class, LateWidget.modifiers, LateWidget.modifier_groups, LateWidget.flags])
        .to all(satisfy { |registry| Ractor.shareable?(registry) })
    end

    describe "then DaisyUI::ClassMerge.merge in a non-main Ractor" do
      let(:subject_call) { ->(classes) { DaisyUI::ClassMerge.merge(classes) } }

      it_behaves_like "runs inside a non-main Ractor", inputs: ["late-sm late-lg btn-sm btn-lg"]
    end
  end

  # Finalizing never raises: what cannot be made shareable is kept as it is,
  # and the configuration holding it is then readable on the main Ractor only.
  describe "with a value that cannot be made shareable" do
    before { described_class.configuration.reset_reported_unknown_modifiers! }
    after { described_class.configuration.reset_reported_unknown_modifiers! }

    it "boots with an unknown_modifiers lambda that closes over app state" do
      reported = []

      expect { described_class.configure { |config| config.unknown_modifiers = ->(error) { reported << error } } }
        .not_to raise_error
      DaisyUI::Toggle.new(:primray).call

      expect(reported.map(&:modifier)).to eq([:primray])
      expect(described_class.configuration).to be_frozen
      expect(Ractor.shareable?(described_class.configuration)).to be(false)
    end

    it "boots with a callable that holds a logger, which keeps logging" do
      io = StringIO.new
      logger = Struct.new(:io, :lock) { def warn(message) = lock.synchronize { io.puts(message) } }.new(io, Mutex.new)
      reporter = Struct.new(:logger) { def call(error) = logger.warn(error.message) }.new(logger)

      expect { described_class.configure { |config| config.unknown_modifiers = reporter } }.not_to raise_error
      DaisyUI::Toggle.new(:primray).call

      expect(io.string).to include("DaisyUI::Toggle has no modifier :primray")
      expect([reporter, reporter.logger, io]).to all(satisfy { |object| !object.frozen? })
      expect(described_class.configuration).to be_frozen
    end

    it "boots with a class_merge validator that closes over app state" do
      brands = %w[ocean forest]

      expect do
        described_class.configure do |config|
          config.class_merge.class_groups("brand" => [{ "brand" => [->(value) { brands.include?(value) }] }])
        end
      end.not_to raise_error

      expect(DaisyUI::ClassMerge.merge("brand-ocean p-2 brand-forest")).to eq("p-2 brand-forest")
      expect(brands).not_to be_frozen
      expect(described_class.configuration).to be_frozen
    end
  end

  # A fresh process, the way a Rails-less app boots: require, then configure.
  it "finalizes a Rails-less app at boot, with an unshareable callable" do
    script = <<~RUBY
      require "daisyui"
      reported = []
      DaisyUI.configure { |config| config.unknown_modifiers = ->(error) { reported << error } }
      DaisyUI::Toggle.new(:primray).call
      print [DaisyUI.configuration.frozen?, Ractor.shareable?(DaisyUI::Button.modifiers), reported.size].inspect
    RUBY
    lib = File.expand_path("../../../lib", __dir__)

    output, status = Open3.capture2e(RbConfig.ruby, "-I", lib, "-e", script)

    expect(status).to be_success, output
    expect(output).to end_with("[true, true, 1]")
  end
end
