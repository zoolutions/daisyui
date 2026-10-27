# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Popover tooltip", type: :system do
  it "opens in the top layer and remains inside the viewport" do
    visit component_path("tooltip")

    trigger = find_button("Left edge")
    trigger.hover

    expect(page).to have_css("#left_edge_tooltip:popover-open", visible: true)
    expect(trigger["aria-describedby"]).to eq("left_edge_tooltip")

    bounds = page.evaluate_script(<<~JS)
      (() => {
        const rect = document.querySelector("#left_edge_tooltip").getBoundingClientRect()
        const style = getComputedStyle(document.querySelector("#left_edge_tooltip"))
        return {
          left: rect.left,
          right: rect.right,
          viewport: window.innerWidth,
          maxWidth: Number.parseFloat(style.maxWidth),
          visibility: style.visibility,
        }
      })()
    JS

    expect(bounds.fetch("left")).to be >= 8
    expect(bounds.fetch("right")).to be <= bounds.fetch("viewport") - 8
    expect(bounds.fetch("maxWidth")).to eq(256)
    expect(bounds.fetch("visibility")).to eq("visible")

    arrow = page.evaluate_script(<<~JS)
      (() => {
        const host = document.querySelector('[data-controller~="daisy-tooltip"]')
        const tooltip = document.querySelector("#left_edge_tooltip")
        const arrow = tooltip.querySelector('[data-daisy-tooltip-target~="arrow"]')
        const arrowStyle = getComputedStyle(arrow)
        const arrowBounds = arrow.getBoundingClientRect()
        const tooltipBounds = tooltip.getBoundingClientRect()

        return {
          stockArrowDisplay: getComputedStyle(host, "::after").display,
          tooltipOverflow: getComputedStyle(tooltip).overflow,
          width: arrowBounds.width,
          height: arrowBounds.height,
          arrowBottom: arrowBounds.bottom,
          tooltipBottom: tooltipBounds.bottom,
          background: arrowStyle.backgroundColor,
          tooltipBackground: getComputedStyle(tooltip).backgroundColor,
          borders: [
            arrowStyle.borderTopWidth,
            arrowStyle.borderRightWidth,
            arrowStyle.borderBottomWidth,
            arrowStyle.borderLeftWidth,
          ],
        }
      })()
    JS

    expect(arrow.fetch("stockArrowDisplay")).to eq("none")
    expect(arrow.fetch("tooltipOverflow")).to eq("visible")
    expect(arrow.fetch("width")).to be > 0
    expect(arrow.fetch("height")).to be > 0
    expect(arrow.fetch("arrowBottom")).to be > arrow.fetch("tooltipBottom")
    expect(arrow.fetch("background")).to eq(arrow.fetch("tooltipBackground"))
    expect(arrow.fetch("borders")).to all(eq("0px"))

    find("h1", text: "Tooltip").hover
    expect(page).to have_no_css("#left_edge_tooltip:popover-open")
  end

  # iOS Safari sends pointerenter → pointerdown → pointerup → pointerleave for
  # one tap and does not focus the tapped button, so nothing but the tap
  # lifecycle can keep the tooltip open.
  it "toggles on a touch tap and closes on a tap outside" do
    visit component_path("tooltip")
    find_button("Right edge")

    tap = <<~JS
      ((selector) => {
        const target = document.querySelector(selector)
        const init = { bubbles: true, cancelable: true, composed: true, pointerType: "touch", isPrimary: true }
        target.dispatchEvent(new PointerEvent("pointerenter", { ...init, bubbles: false }))
        target.dispatchEvent(new PointerEvent("pointerdown", init))
        target.dispatchEvent(new PointerEvent("pointerup", init))
        target.dispatchEvent(new PointerEvent("pointerleave", { ...init, bubbles: false }))
      })
    JS
    tap_on = ->(selector) { page.execute_script("#{tap}(arguments[0])", selector) }
    trigger = '[data-controller~="daisy-tooltip"]:has(#right_edge_tooltip)'

    tap_on.call(trigger)
    expect(page).to have_css("#right_edge_tooltip:popover-open", visible: true)
    expect(page.evaluate_script('getComputedStyle(document.querySelector("#right_edge_tooltip")).visibility'))
      .to eq("visible")

    tap_on.call("h1")
    expect(page).to have_no_css("#right_edge_tooltip:popover-open")

    tap_on.call(trigger)
    expect(page).to have_css("#right_edge_tooltip:popover-open", visible: true)
    tap_on.call(trigger)
    expect(page).to have_no_css("#right_edge_tooltip:popover-open")

    # Chromium focuses a tapped button; Tab must take the tooltip away with focus.
    right_edge = find_button("Right edge")
    page.execute_script("arguments[0].focus()", right_edge)
    tap_on.call(trigger)
    expect(page).to have_css("#right_edge_tooltip:popover-open", visible: true)
    right_edge.send_keys(:tab)
    expect(page).to have_no_css("#right_edge_tooltip:popover-open")
  end
end
