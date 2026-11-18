# frozen_string_literal: true

require "spec_helper"

# modifier_map is built once per component class and published configuration,
# then shared by every instance (#80).
describe DaisyUI::Base, "#modifier_map" do
  let(:widget) do
    Class.new(described_class) do
      self.component_class = :widget

      register_modifiers(size: { sm: "widget-sm" }, wide: "widget-wide")

      def view_template(&) = div(class: classes, **attributes, &)
    end
  end

  def modifier_map_of(component) = component.send(:modifier_map)

  it "returns the same frozen Hash to every instance" do
    first = modifier_map_of(widget.new(:sm))

    expect(modifier_map_of(widget.new(:wide))).to be(first)
    expect(first).to be_frozen
    expect(first).to include(skeleton: "skeleton", sm: "widget-sm", wide: "widget-wide")
  end

  it "caches a Ractor-shareable value" do
    skip "needs Ractor.shareable?" unless defined?(Ractor) && Ractor.respond_to?(:shareable?)

    modifier_map_of(widget.new)
    cache = widget.instance_variable_get(:@modifier_map_cache)

    expect(cache).not_to be_nil
    expect(Ractor.shareable?(cache)).to be(true)
  end

  it "keeps a map per class" do
    other = Class.new(described_class) { register_modifiers(tall: "other-tall") }

    expect(modifier_map_of(widget.new)).not_to include(:tall)
    expect(modifier_map_of(other.new)).to include(tall: "other-tall")
  end

  it "sees a modifier registered after the map was cached" do
    modifier_map_of(widget.new)
    widget.register_modifiers(tall: "widget-tall")

    expect(render(widget.new(:tall))).to eq('<div class="widget widget-tall"></div>')
  end

  context "when a configuration is published after the map was cached" do
    after do
      DaisyUI.configure do |config|
        config.modifiers.remove(:huge, component: widget)
        config.modifiers.remove(:loud)
      end
    end

    it "sees its component and global modifiers" do
      modifier_map_of(widget.new)
      DaisyUI.configure do |config|
        config.modifiers.add(:huge, classes: "widget-xl", component: widget)
        config.modifiers.add(:loud, classes: "font-bold")
      end

      expect(render(widget.new(:huge, :loud))).to eq('<div class="widget widget-xl font-bold"></div>')
    end
  end

  it "sees a modifier configured for a DaisyUI ancestor, the closest class winning" do
    child = Class.new(widget)
    DaisyUI.configure do |config|
      config.modifiers.add(:huge, classes: "widget-xl", component: widget)
      config.modifiers.add(:loud, classes: "parent-loud", component: widget)
      config.modifiers.add(:loud, classes: "child-loud", component: child)
    end

    expect(modifier_map_of(child.new)).to include(huge: "widget-xl", loud: "child-loud")
  ensure
    DaisyUI.configure do |config|
      config.modifiers.remove(:huge, component: widget)
      config.modifiers.remove(:loud, component: widget)
      config.modifiers.remove(:loud, component: child)
    end
  end

  context "with a writable configuration", :finalizes do
    it "builds the map per call, so a change made in place shows up" do
      modifier_map_of(widget.new)
      DaisyUI.configuration.modifiers.add(:huge, classes: "widget-xl", component: widget)

      expect(render(widget.new(:huge))).to eq('<div class="widget widget-xl"></div>')
    end
  end

  # The pre-#80 body: a fresh map on every call.
  it "halves what a three-modifier button allocates" do
    legacy = Class.new(DaisyUI::Button) do
      private def modifier_map
        configured = self.class.ancestors.take_while { |klass| klass != DaisyUI::Base }.reverse.reduce({}) do |result, klass|
          result.merge(DaisyUI.configuration.modifiers.for(component: klass))
        end
        { skeleton: "skeleton", **(self.class.modifiers || {}), **configured, **DaisyUI.configuration.modifiers.for(component: nil) }
      end
    end
    cached = Class.new(DaisyUI::Button)

    expect(allocations { cached.new(:primary, :sm, :outline).call })
      .to be <= allocations { legacy.new(:primary, :sm, :outline).call } * 0.5
  end

  def allocations(times = 200, &block)
    3.times(&block)
    GC.disable
    before = GC.stat(:total_allocated_objects)
    times.times(&block)
    (GC.stat(:total_allocated_objects) - before) / times.to_f
  ensure
    GC.enable
  end

  describe "in a non-main Ractor", :finalizes, :ractor do
    # Capture-free: the kit runs it in Ractor.new.
    let(:subject_call) { ->(name) { DaisyUI.const_get(name).new(:primary, :sm).send(:modifier_map) } }

    before { DaisyUI.finalize! }

    context "when the main Ractor has not cached the map" do
      it_behaves_like "runs inside a non-main Ractor", inputs: ["Badge"]
    end

    context "when the main Ractor has cached the map" do
      before { DaisyUI::Button.new.send(:modifier_map) }

      it_behaves_like "runs inside a non-main Ractor", inputs: ["Button"]
    end
  end
end
