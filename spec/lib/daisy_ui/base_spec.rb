# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Base do
  describe "responsive base class with a symbol component_class and a prefix" do
    around do |example|
      original_prefix = DaisyUI.configuration.prefix

      DaisyUI.configure do |config|
        config.prefix = "foo-"
      end

      example.run

      DaisyUI.configure do |config|
        config.prefix = original_prefix
      end
    end

    it "coerces the symbol component_class before prefixing" do
      output = render DaisyUI::Link.new(responsive: { sm: true })

      expected_html = html <<~HTML
        <a class="sm:foo-link"></a>
      HTML

      expect(output).to eq(expected_html)
    end

    it "works for components whose component_class was always a symbol" do
      expect { render DaisyUI::Button.new(responsive: { sm: true }) }
        .not_to raise_error
    end
  end

  describe "modifiers inheritance" do
    let(:daisy_ui_class) do
      Class.new(DaisyUI::Base) do
        self.component_class = "base-component"

        def view_template(&)
          div(class: classes, **attributes, &)
        end

        register_modifiers(
          primary: "base-modifier-value"
        )
      end
    end

    let(:custom_component_class) do
      Class.new(daisy_ui_class) do
        register_modifiers(
          custom_modifier: "custom-modifier-value"
        )
      end
    end

    before do
      stub_const("CustomComponent", custom_component_class)
    end

    describe "rendering a custom component" do
      subject(:output) do
        render component.new
      end

      let(:component) do
        Class.new(Phlex::HTML) do
          def view_template(&)
            # Ensuring :primary does not override other components
            render DaisyUI::Button.new(:primary)
            render CustomComponent.new(
              :primary,
              :custom_modifier
            ) do
              "Custom"
            end
          end
        end
      end

      it "is expected to match the formatted HTML" do
        expected_html = html <<~HTML
          <button class="btn btn-primary"></button>
          <div class="base-component base-modifier-value custom-modifier-value">Custom</div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    describe "sibling classes don't interfere with each other" do
      let(:parent_class) do
        Class.new(DaisyUI::Base) do
          self.component_class = "parent-component"

          def view_template(&)
            div(class: classes, **attributes, &)
          end

          register_modifiers(
            inherited_modifier: "parent-modifier"
          )
        end
      end

      let(:sibling_a_class) do
        Class.new(parent_class) do
          self.component_class = "sibling-a"

          def view_template(&)
            div(class: classes, **attributes, &)
          end

          register_modifiers(
            primary: "sibling-a-primary",
            unique_a: "unique-to-a"
          )
        end
      end

      let(:sibling_b_class) do
        Class.new(parent_class) do
          self.component_class = "sibling-b"

          def view_template(&)
            div(class: classes, **attributes, &)
          end

          register_modifiers(
            primary: "sibling-b-primary",
            unique_b: "unique-to-b"
          )
        end
      end

      before do
        stub_const("SiblingA", sibling_a_class)
        stub_const("SiblingB", sibling_b_class)
      end

      it "each sibling maintains its own modifiers independently" do
        component = Class.new(Phlex::HTML) do
          def view_template
            render SiblingA.new(:inherited_modifier, :primary, :unique_a)
            render SiblingB.new(:inherited_modifier, :primary, :unique_b)
          end
        end

        output = render component.new

        expected_html = html <<~HTML
          <div class="sibling-a parent-modifier sibling-a-primary unique-to-a"></div>
          <div class="sibling-b parent-modifier sibling-b-primary unique-to-b"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "class merging" do
    let(:bare_component) { Class.new(DaisyUI::Base) { self.component_class = nil }.new }

    it "lets a caller class replace a modifier of the same family" do
      expect(render(DaisyUI::Button.new(:sm, class: "btn-lg"))).to eq(html(<<~HTML))
        <button class="btn btn-lg"></button>
      HTML
      expect(render(DaisyUI::Badge.new(:primary, class: "badge-error"))).to eq(html(<<~HTML))
        <span class="badge badge-error"></span>
      HTML
    end

    it "returns nil when there are no classes" do
      expect(bare_component.send(:merge_classes, nil, "")).to be_nil
    end

    context "when merging is disabled" do
      around do |example|
        DaisyUI.configure { |config| config.class_merge.enabled = false }
        example.run
      ensure
        DaisyUI.configure { |config| config.class_merge.enabled = true }
      end

      it "joins classes as given" do
        expect(render(DaisyUI::Button.new(:sm, class: "btn-lg"))).to eq(html(<<~HTML))
          <button class="btn btn-sm btn-lg"></button>
        HTML
        expect(render(DaisyUI::Badge.new(:primary, class: "badge-error"))).to eq(html(<<~HTML))
          <span class="badge badge-primary badge-error"></span>
        HTML
      end

      it "returns nil when there are no classes" do
        expect(bare_component.send(:merge_classes, nil)).to be_nil
      end
    end
  end
end
