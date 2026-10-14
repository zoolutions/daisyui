# frozen_string_literal: true

require "spec_helper"

describe DaisyUI::Dropdown do
  subject(:output) { render described_class.new }

  describe "responsiveness" do
    %i[sm md lg xl @sm @md @lg @xl].each do |viewport|
      context "when given an :#{viewport} responsive option as a single argument" do
        subject(:output) do
          render described_class.new(:top, responsive: { viewport => :hover })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="dropdown dropdown-top #{viewport}:dropdown-hover"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end

      context "when given multiple responsive options as an array" do
        subject(:output) do
          render described_class.new(:top, responsive: { viewport => %i[hover open] })
        end

        it "renders it separately with a responsive prefix" do
          expected_html = html <<~HTML
            <div class="dropdown dropdown-top #{viewport}:dropdown-hover #{viewport}:dropdown-open"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "modifiers" do
    {
      # Placement
      start: "dropdown-start",
      center: "dropdown-center",
      end: "dropdown-end",
      top: "dropdown-top",
      bottom: "dropdown-bottom",
      left: "dropdown-left",
      right: "dropdown-right",
      # Behavior
      hover: "dropdown-hover",
      open: "dropdown-open"
    }.each do |condition, css|
      context "when given :#{condition} condition" do
        subject(:output) { render described_class.new(condition) }

        it "renders it apart from the main class" do
          expected_html = html <<~HTML
            <div class="dropdown #{css}"></div>
          HTML

          expect(output).to eq(expected_html)
        end
      end
    end
  end

  describe "passing :as option" do
    subject(:output) { render described_class.new(as: :div) }

    it "renders the dropdown as the given tag" do
      expected_html = html <<~HTML
        <div class="dropdown"></div>
      HTML

      expect(output).to eq(expected_html)
    end

    context "when using details as the :as option" do
      subject(:output) do
        render described_class.new(:tap_to_close) do |dropdown|
          dropdown.button(:active, class: "my-button", data: { my: "buttons" }) do
            "Click"
          end
        end
      end

      it "renders the dropdown content as a summary tag" do
        expected_html = html <<~HTML
          <details class="dropdown">
            <summary class="btn btn-active my-button" data-my="buttons">Click</summary>
          </details>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe "passing modifiers to the menu" do
    subject(:output) { render component.new }

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Dropdown.new do |dropdown|
            dropdown.menu(:vertical, :xs) do |menu|
              menu.item do
                a do
                  "Item 1"
                end
              end
            end
          end
        end
      end
    end

    it "renders the menu with the given modifiers" do
      expected_html = html <<~HTML
        <div class="dropdown">
          <ul class="menu menu-vertical menu-xs dropdown-content" tabindex="0">
            <li>
              <a>Item 1</a>
            </li>
          </ul>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering a full dropdown that closes when tapping outside" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Dropdown.new(:top) do |dropdown|
            dropdown.button(:active, class: "my-button", data: { my: "buttons" }) do
              "Click"
            end

            dropdown.menu do |menu|
              menu.item do
                a do
                  "Item 1"
                end
              end
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <div class="dropdown dropdown-top">
          <div class="btn btn-active my-button"#{' '}
               role="button"#{' '}
               tabindex="0"#{' '}
               data-my="buttons">Click</div>
          <ul class="menu dropdown-content" tabindex="0">
            <li>
              <a>Item 1</a>
            </li>
          </ul>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering a full dropdown that closes when tapping the button" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Dropdown.new(:tap_to_close, :top) do |dropdown|
            dropdown.button(:active, class: "my-button", data: { my: "buttons" }) do
              "Click"
            end

            dropdown.menu do |menu|
              menu.item do
                a do
                  "Item 1"
                end
              end
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <details class="dropdown dropdown-top">
          <summary#{' '}
            class="btn btn-active my-button"#{' '}
            data-my="buttons">Click</summary>
          <ul class="menu dropdown-content">
            <li>
              <a>Item 1</a>
            </li>
          </ul>
        </details>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering a full dropdown with card content that closes when tapping outside" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Dropdown.new(:top) do |dropdown|
            dropdown.button(:active, class: "my-button", data: { my: "buttons" }) do
              "Click"
            end

            dropdown.content as: DaisyUI::Card do |card|
              card.body do
                card.title do
                  "Title"
                end

                p do
                  "Body"
                end
              end
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <div class="dropdown dropdown-top">
          <div class="btn btn-active my-button"#{' '}
               role="button"#{' '}
               tabindex="0"#{' '}
               data-my="buttons">Click</div>
          <section class="card dropdown-content" tabindex="0">
            <div class="card-body">
              <header class="card-title">Title</header>
              <p>Body</p>
            </div>
          </section>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "rendering a full dropdown with card content that closes when tapping the button" do
    subject(:output) do
      render component.new
    end

    let(:component) do
      Class.new(Phlex::HTML) do
        def view_template(&)
          render DaisyUI::Dropdown.new(:tap_to_close, :top) do |dropdown|
            dropdown.button(:active, class: "my-button", data: { my: "buttons" }) do
              "Click"
            end

            dropdown.content as: DaisyUI::Card, class: "bg-base-100" do |card|
              card.body do
                card.title do
                  "Title"
                end

                p do
                  "Body"
                end
              end
            end
          end
        end
      end
    end

    it "is expected to match the formatted HTML" do
      expected_html = html <<~HTML
        <details class="dropdown dropdown-top">
          <summary
            class="btn btn-active my-button"
            data-my="buttons">Click</summary>
          <section class="card dropdown-content bg-base-100">
            <div class="card-body">
              <header class="card-title">Title</header>
              <p>Body</p>
            </div>
          </section>
        </details>
      HTML

      expect(output).to eq(expected_html)
    end
  end

  describe "passing HTML attributes" do
    context "when passing id and data attributes to the dropdown" do
      subject(:output) do
        render described_class.new(:top, id: "my-dropdown", data: { controller: "dropdown", action: "click" })
      end

      it "renders with the specified attributes" do
        expected_html = html <<~HTML
          <div class="dropdown dropdown-top" data-controller="dropdown" data-action="click" id="my-dropdown"></div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when using tap_to_close with id and aria attributes" do
      subject(:output) do
        render described_class.new(:tap_to_close, id: "my-details", aria: { label: "Menu" })
      end

      it "renders details element with the specified attributes" do
        expected_html = html <<~HTML
          <details class="dropdown" aria-label="Menu" id="my-details"></details>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when passing attributes to sub-components" do
      subject(:output) { render component.new }

      let(:component) do
        Class.new(Phlex::HTML) do
          def view_template(&)
            render DaisyUI::Dropdown.new(:top, id: "dropdown-1", data: { test: "main" }) do |dropdown|
              dropdown.button(:primary, id: "btn-1", aria: { label: "Open menu" }) do
                "Menu"
              end

              dropdown.menu(id: "menu-1", data: { items: "3" }) do |menu|
                menu.item do
                  a do
                    "Item 1"
                  end
                end
              end
            end
          end
        end
      end

      it "passes attributes to all components correctly" do
        expected_html = html <<~HTML
          <div class="dropdown dropdown-top" data-test="main" id="dropdown-1">
            <div class="btn btn-primary"
                 role="button"
                 tabindex="0"
                 aria-label="Open menu"
                 id="btn-1">Menu</div>
            <ul class="menu dropdown-content"
                tabindex="0"
                data-items="3"
                id="menu-1">
              <li>
                <a>Item 1</a>
              </li>
            </ul>
          </div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when passing attributes to content sub-component" do
      subject(:output) { render component.new }

      let(:component) do
        Class.new(Phlex::HTML) do
          def view_template(&)
            render DaisyUI::Dropdown.new(:top) do |dropdown|
              dropdown.button(:ghost) do
                "Click"
              end

              dropdown.content(id: "content-1", data: { status: "active" }, aria: { live: "polite" }) do
                div do
                  "Dropdown content"
                end
              end
            end
          end
        end
      end

      it "passes attributes to the content element" do
        expected_html = html <<~HTML
          <div class="dropdown dropdown-top">
            <div class="btn btn-ghost" role="button" tabindex="0">Click</div>
            <div tabindex="0"
                 class="dropdown-content"
                 id="content-1"
                 data-status="active"
                 aria-live="polite">
              <div>Dropdown content</div>
            </div>
          </div>
        HTML

        expect(output).to eq(expected_html)
      end
    end

    context "when using tap_to_close with attributes on sub-components" do
      subject(:output) { render component.new }

      let(:component) do
        Class.new(Phlex::HTML) do
          def view_template(&)
            render DaisyUI::Dropdown.new(:tap_to_close, id: "details-dropdown") do |dropdown|
              dropdown.button(:warning, id: "summary-btn", data: { analytics: "click" }) do
                "Toggle"
              end

              dropdown.content(id: "details-content", class: "w-52") do
                p do
                  "Content here"
                end
              end
            end
          end
        end
      end

      it "passes attributes correctly in tap_to_close mode" do
        expected_html = html <<~HTML
          <details class="dropdown" id="details-dropdown">
            <summary class="btn btn-warning"
                     data-analytics="click"
                     id="summary-btn">Toggle</summary>
            <div class="dropdown-content w-52" id="details-content">
              <p>Content here</p>
            </div>
          </details>
        HTML

        expect(output).to eq(expected_html)
      end
    end
  end

  describe ":popover modifier" do
    subject(:output) do
      render described_class.new(:popover, :end, popover_id: "actions_menu") do |dropdown|
        dropdown.button(:ghost, :sm) { "Trigger" }
        dropdown.menu(:sm, class: "w-56") do |menu|
          menu.item { "Edit" }
        end
      end
    end

    it "renders DaisyUI's flat popover structure (button + menu as siblings)" do
      expected_html = html <<~HTML
        <div>
          <button class="btn btn-ghost btn-sm"
                  popovertarget="actions_menu"
                  style="anchor-name:--actions_menu_anchor"
                  aria-haspopup="menu"
                  aria-controls="actions_menu"
                  aria-expanded="false">Trigger</button>
          <ul class="menu menu-sm dropdown dropdown-end w-56"
              role="menu"
              popover="auto"
              style="position-anchor:--actions_menu_anchor"
              id="actions_menu">
            <li>Edit</li>
          </ul>
        </div>
      HTML

      expect(output).to eq(expected_html)
    end

    it "puts dropdown + placement classes on the popover element, not the wrapper" do
      # The popover <ul> carries `dropdown dropdown-end` (so `position-area`
      # applies); the wrapper is a plain <div> with no positioning class.
      expect(output).to match(/<ul class="[^"]*\bdropdown dropdown-end\b[^"]*"[^>]*popover="auto"/)
      expect(output).to match(/\A<div><button/)
    end

    it "does not emit dropdown-content on the popover element" do
      expect(output).not_to include("dropdown-content")
    end

    it "emits no stray dropdown-popover class for the unregistered modifier" do
      expect(output).not_to include("dropdown-popover")
    end

    it "renders the trigger as a real <button> (required by the Popover API)" do
      expect(output).to match(/<button[^>]*popovertarget="actions_menu"/)
    end

    it "wires aria-controls and aria-expanded on the trigger" do
      expect(output).to match(/<button[^>]*aria-controls="actions_menu"/)
      expect(output).to match(/<button[^>]*aria-expanded="false"/)
    end

    it "marks the menu popover with role=\"menu\" for assistive tech" do
      expect(output).to match(/<ul[^>]*role="menu"[^>]*popover="auto"/)
    end

    it "does not mark a non-menu content panel with role=\"menu\"" do
      panel = render described_class.new(:popover, popover_id: "panel") do |dropdown|
        dropdown.button { "Trigger" }
        dropdown.content { "Card body" }
      end

      expect(panel).not_to match(/<div[^>]*class="dropdown"[^>]*role="menu"/)
    end

    it "lets a caller override the menu role" do
      custom = render described_class.new(:popover, popover_id: "m") do |dropdown|
        dropdown.button { "Trigger" }
        dropdown.menu(role: "listbox") { |menu| menu.item { "Edit" } }
      end

      expect(custom).to match(/<ul[^>]*role="listbox"/)
      expect(custom).not_to include('role="menu"')
    end

    it "auto-generates a popover id when none is supplied" do
      generated = render described_class.new(:popover) do |dropdown|
        dropdown.button { "Trigger" }
        dropdown.menu { |menu| menu.item { "Edit" } }
      end

      expect(generated).to match(/popovertarget="dropdown_[0-9a-f]{16}"/)
      expect(generated).to match(/id="dropdown_[0-9a-f]{16}"/)
      expect(generated).to include('popover="auto"')
    end

    it "supports content (non-menu panel) with the same wiring" do
      panel = render described_class.new(:popover, popover_id: "panel") do |dropdown|
        dropdown.button { "Trigger" }
        dropdown.content { "Card body" }
      end

      expected_html = html <<~HTML
        <div>
          <button class="btn" popovertarget="panel"
                  style="anchor-name:--panel_anchor" aria-haspopup="menu"
                  aria-controls="panel" aria-expanded="false">Trigger</button>
          <div class="dropdown" id="panel" popover="auto"
               style="position-anchor:--panel_anchor">Card body</div>
        </div>
      HTML

      expect(panel).to eq(expected_html)
    end

    describe "stimulus: opt-in" do
      it "emits NO stimulus attributes by default (zero-JS)" do
        expect(output).not_to include("data-controller")
        expect(output).not_to include("daisy-dropdown")
      end

      it "wires the daisy-dropdown controller + trigger/menu targets when stimulus: true" do
        enhanced = render described_class.new(:popover, :end, popover_id: "m", stimulus: true) do |dropdown|
          dropdown.button(:ghost, :sm) { "Trigger" }
          dropdown.menu(:sm) { |menu| menu.item { "Edit" } }
        end

        expect(enhanced).to include('data-controller="daisy-dropdown"')
        expect(enhanced).to match(/<button[^>]*data-daisy-dropdown-target="trigger"/)
        expect(enhanced).to match(/<ul[^>]*data-daisy-dropdown-target="menu"/)
      end

      it "overrides the identifier when stimulus: is a String" do
        enhanced = render described_class.new(:popover, popover_id: "m", stimulus: "vendor-dropdown") do |dropdown|
          dropdown.button { "Trigger" }
          dropdown.menu { |menu| menu.item { "Edit" } }
        end

        expect(enhanced).to include('data-controller="vendor-dropdown"')
        expect(enhanced).to include('data-vendor-dropdown-target="trigger"')
        expect(enhanced).not_to include("daisy-dropdown")
      end

      it "space-joins a caller-supplied controller instead of clobbering it" do
        enhanced = render described_class.new(
          :popover, popover_id: "m", stimulus: true, data: { controller: "analytics" }
        ) do |dropdown|
          dropdown.button { "Trigger" }
          dropdown.menu { |menu| menu.item { "Edit" } }
        end

        expect(enhanced).to include('data-controller="analytics daisy-dropdown"')
      end
    end
  end
end
