import { Controller } from "@hotwired/stimulus"

const VIEWPORT_PADDING = 8
const GAP = 8
const ARROW_WIDTH = 10
const ARROW_HEIGHT = 4
const FOCUSABLE_SELECTOR = 'button, a[href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
const OPPOSITE = { top: "bottom", bottom: "top", left: "right", right: "left" }
const TAP_POINTERS = ["touch", "pen"]

// daisy-tooltip — positions a :popover Tooltip in the browser top layer.
//
// The Popover API escapes clipping ancestors. This controller supplies the
// hover/focus lifecycle expected of a tooltip, then flips and shifts the real
// tooltip element only while it is open so it remains inside the visual
// viewport. No global listeners remain attached while the tooltip is closed.
//
// A touch or pen tap toggles the tooltip: it stays open after the finger lifts
// (pointerleave/focusout no longer close it) until a tap outside, a second tap
// on the trigger, or Escape. `toggle` is also a Stimulus action, for a host
// that wires `click->daisy-tooltip#toggle` on its own trigger.
export default class extends Controller {
  static targets = ["content", "arrow"]
  static values = { placement: { type: String, default: "top" } }

  connect() {
    if (!this.hasContentTarget) return

    this.originalMaxWidth = this.contentTarget.style.maxWidth
    this.onPointerEnter = (event) => this.#handlePointerEnter(event)
    this.onPointerLeave = () => this.#hideUnlessFocused()
    this.onPointerDown = () => {
      this.tapPending = false
    }
    this.onPointerUp = (event) => this.#handlePointerUp(event)
    this.onOutsidePointerDown = (event) => this.#handleOutsidePointerDown(event)
    this.onFocusIn = () => this.show()
    this.onFocusOut = (event) => this.#handleFocusOut(event)
    this.onKeydown = (event) => this.#handleKeydown(event)
    this.onGeometryChange = () => this.#schedulePosition()

    this.element.addEventListener("pointerenter", this.onPointerEnter)
    this.element.addEventListener("pointerleave", this.onPointerLeave)
    this.element.addEventListener("pointerdown", this.onPointerDown)
    this.element.addEventListener("pointerup", this.onPointerUp)
    this.element.addEventListener("focusin", this.onFocusIn)
    this.element.addEventListener("focusout", this.onFocusOut)
    this.#describeTrigger()

    if (this.element.classList.contains("tooltip-open")) this.show()
  }

  disconnect() {
    this.element.removeEventListener("pointerenter", this.onPointerEnter)
    this.element.removeEventListener("pointerleave", this.onPointerLeave)
    this.element.removeEventListener("pointerdown", this.onPointerDown)
    this.element.removeEventListener("pointerup", this.onPointerUp)
    this.element.removeEventListener("focusin", this.onFocusIn)
    this.element.removeEventListener("focusout", this.onFocusOut)
    this.#teardownOpen()
    this.#restoreDescription()
    if (this.hasContentTarget) this.contentTarget.style.maxWidth = this.originalMaxWidth
  }

  show() {
    if (!this.hasContentTarget || this.#isOpen()) return

    this.contentTarget.style.visibility = "hidden"
    this.contentTarget.showPopover()
    this.#setupOpen()
    this.#schedulePosition()
  }

  hide() {
    this.openedByTap = false
    if (this.#isOpen()) this.contentTarget.hidePopover()
    this.contentTarget.style.visibility = "hidden"
    this.#teardownOpen()
  }

  // Stimulus action. Closes a tooltip a tap opened; otherwise opens it (or
  // keeps a hover/focus-opened one open) until an outside tap or Escape.
  toggle(event) {
    if (event?.type === "click" && this.tapPending) {
      this.tapPending = false
      return
    }

    if (this.openedByTap && this.#isOpen()) {
      this.hide()
      return
    }

    this.show()
    this.openedByTap = this.#isOpen()
  }

  #setupOpen() {
    window.addEventListener("resize", this.onGeometryChange)
    window.addEventListener("scroll", this.onGeometryChange, true)
    window.addEventListener("keydown", this.onKeydown)
    document.addEventListener("pointerdown", this.onOutsidePointerDown, true)
    window.visualViewport?.addEventListener("resize", this.onGeometryChange)
    window.visualViewport?.addEventListener("scroll", this.onGeometryChange)
  }

  #teardownOpen() {
    cancelAnimationFrame(this.frame)
    window.removeEventListener("resize", this.onGeometryChange)
    window.removeEventListener("scroll", this.onGeometryChange, true)
    window.removeEventListener("keydown", this.onKeydown)
    document.removeEventListener("pointerdown", this.onOutsidePointerDown, true)
    window.visualViewport?.removeEventListener("resize", this.onGeometryChange)
    window.visualViewport?.removeEventListener("scroll", this.onGeometryChange)
  }

  #schedulePosition() {
    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(() => this.#position())
  }

  #position() {
    if (!this.#isOpen()) return

    const viewport = this.#viewport()
    const availableWidth = Math.max(0, viewport.width - VIEWPORT_PADDING * 2)
    this.contentTarget.style.maxWidth = this.originalMaxWidth
    const computedMaxWidth = Number.parseFloat(getComputedStyle(this.contentTarget).maxWidth)
    const maxWidth = Number.isFinite(computedMaxWidth) ? Math.min(computedMaxWidth, availableWidth) : availableWidth
    this.contentTarget.style.maxWidth = `${maxWidth}px`

    const trigger = this.element.getBoundingClientRect()
    const tooltip = this.contentTarget.getBoundingClientRect()
    const preferred = this.#coordinates(this.placementValue, trigger, tooltip)
    const oppositePlacement = OPPOSITE[this.placementValue] || "bottom"
    const opposite = this.#coordinates(oppositePlacement, trigger, tooltip)
    const useOpposite = this.#overflow(opposite, tooltip, viewport) < this.#overflow(preferred, tooltip, viewport)
    const placement = useOpposite ? oppositePlacement : this.placementValue
    const coordinates = useOpposite ? opposite : preferred
    const { x, y } = this.#shift(coordinates, tooltip, viewport)

    Object.assign(this.contentTarget.style, { left: `${x}px`, top: `${y}px`, visibility: "visible" })
    this.#positionArrow(placement, trigger, tooltip, x, y)
  }

  #coordinates(placement, trigger, tooltip) {
    const centerX = trigger.left + trigger.width / 2
    const centerY = trigger.top + trigger.height / 2

    switch (placement) {
      case "bottom":
        return { x: centerX - tooltip.width / 2, y: trigger.bottom + GAP }
      case "left":
        return { x: trigger.left - tooltip.width - GAP, y: centerY - tooltip.height / 2 }
      case "right":
        return { x: trigger.right + GAP, y: centerY - tooltip.height / 2 }
      default:
        return { x: centerX - tooltip.width / 2, y: trigger.top - tooltip.height - GAP }
    }
  }

  #overflow({ x, y }, tooltip, viewport) {
    const left = viewport.left + VIEWPORT_PADDING
    const right = viewport.left + viewport.width - VIEWPORT_PADDING
    const top = viewport.top + VIEWPORT_PADDING
    const bottom = viewport.top + viewport.height - VIEWPORT_PADDING

    return (
      Math.max(0, left - x) +
      Math.max(0, x + tooltip.width - right) +
      Math.max(0, top - y) +
      Math.max(0, y + tooltip.height - bottom)
    )
  }

  #shift({ x, y }, tooltip, viewport) {
    const left = viewport.left + VIEWPORT_PADDING
    const right = viewport.left + viewport.width - VIEWPORT_PADDING
    const top = viewport.top + VIEWPORT_PADDING
    const bottom = viewport.top + viewport.height - VIEWPORT_PADDING

    return {
      x: tooltip.width > right - left ? left : Math.min(Math.max(x, left), right - tooltip.width),
      y: tooltip.height > bottom - top ? top : Math.min(Math.max(y, top), bottom - tooltip.height),
    }
  }

  #positionArrow(placement, trigger, tooltip, x, y) {
    if (!this.hasArrowTarget) return

    const centerX = trigger.left + trigger.width / 2 - x
    const centerY = trigger.top + trigger.height / 2 - y
    const arrow = this.arrowTarget.style
    Object.assign(arrow, { inset: "auto", transform: "none" })

    if (placement === "top" || placement === "bottom") {
      arrow.left = `${this.#clamp(centerX - ARROW_WIDTH / 2, 4, tooltip.width - ARROW_WIDTH - 4)}px`
      if (placement === "top") arrow.bottom = `${-ARROW_HEIGHT}px`
      else {
        arrow.top = `${-ARROW_HEIGHT}px`
        arrow.transform = "rotate(180deg)"
      }
      return
    }

    arrow.top = `${this.#clamp(centerY - ARROW_HEIGHT / 2, 4, tooltip.height - ARROW_HEIGHT - 4)}px`
    if (placement === "left") {
      arrow.right = "-7px"
      arrow.transform = "rotate(-90deg)"
    } else {
      arrow.left = "-7px"
      arrow.transform = "rotate(90deg)"
    }
  }

  #viewport() {
    const visualViewport = window.visualViewport
    return {
      left: visualViewport?.offsetLeft ?? 0,
      top: visualViewport?.offsetTop ?? 0,
      width: visualViewport?.width ?? window.innerWidth,
      height: visualViewport?.height ?? window.innerHeight,
    }
  }

  #handlePointerEnter(event) {
    // A finger's pointerenter is the start of the tap that pointerup handles.
    if (event.pointerType === "touch") return

    this.show()
  }

  #handlePointerUp(event) {
    if (!TAP_POINTERS.includes(event.pointerType)) return

    this.toggle()
    this.tapPending = true
  }

  #handleOutsidePointerDown(event) {
    if (!this.openedByTap) return
    if (this.element.contains(event.target) || this.contentTarget.contains(event.target)) return

    this.hide()
  }

  #handleFocusOut(event) {
    if (this.openedByTap) return
    if (!this.element.contains(event.relatedTarget)) this.hide()
  }

  #hideUnlessFocused() {
    if (this.openedByTap) return
    if (!this.element.matches(":focus-within")) this.hide()
  }

  #handleKeydown(event) {
    if (event.key !== "Escape") return

    this.hide()
  }

  #describeTrigger() {
    const trigger = this.element.matches(FOCUSABLE_SELECTOR)
      ? this.element
      : this.element.querySelector(FOCUSABLE_SELECTOR)
    if (!trigger || !this.contentTarget.id) return

    this.describedTrigger = trigger
    this.previousDescription = trigger.getAttribute("aria-describedby")
    const descriptions = this.previousDescription?.split(/\s+/).filter(Boolean) || []
    trigger.setAttribute("aria-describedby", [...new Set([...descriptions, this.contentTarget.id])].join(" "))
  }

  #restoreDescription() {
    if (!this.describedTrigger) return

    if (this.previousDescription === null) this.describedTrigger.removeAttribute("aria-describedby")
    else this.describedTrigger.setAttribute("aria-describedby", this.previousDescription)
  }

  #isOpen() {
    return this.hasContentTarget && this.contentTarget.matches(":popover-open")
  }

  #clamp(value, minimum, maximum) {
    return Math.min(Math.max(value, minimum), Math.max(minimum, maximum))
  }
}
