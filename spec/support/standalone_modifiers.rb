# frozen_string_literal: true

module ClassMergeCoverage
  # Registered daisyUI modifier tokens deliberately left out of every family.
  # They never conflict with anything and are always kept. The registry
  # coverage spec fails for a token that is neither in a family, a Tailwind
  # utility, nor listed here.
  STANDALONE_MODIFIERS = Set.new(
    [
      # Aura effects combine freely
      "aura-dual", "aura-glow", "aura-gold", "aura-holo", "aura-rainbow", "aura-silver",
      # Avatar presence and placeholder states
      "avatar-offline", "avatar-online", "avatar-placeholder",
      # Button shapes and states combine with sizes and colors
      "btn-active", "btn-block", "btn-circle", "btn-disabled", "btn-square", "btn-wide",
      # Card layout options
      "card-border", "card-side", "image-full",
      # Collapse icons and forced open/close states
      "collapse-arrow", "collapse-close", "collapse-open", "collapse-plus",
      # Open/hover/active/focus/disabled states
      "dock-active", "drawer-open", "dropdown-hover", "dropdown-open", "link-hover",
      "menu-active", "menu-disabled", "menu-focus", "modal-open", "swap-active",
      "tab-active", "tab-disabled", "tooltip-open",
      # FAB layout
      "fab-flower",
      # Label wrappers and table row hover emit another component's base class
      "floating-label", "hover", "input", "select", "swap", "toggle",
      # List column behaviour
      "list-col-grow", "list-col-wrap",
      # Loading animations (one per element, but no size/color semantics)
      "loading-ball", "loading-bars", "loading-dots", "loading-infinity", "loading-ring", "loading-spinner",
      # Mask shapes, including numbered variants the suffix rule cannot read
      "mask-circle", "mask-decagon", "mask-diamond", "mask-half-1", "mask-half-2", "mask-heart",
      "mask-hexagon", "mask-hexagon-2", "mask-pentagon", "mask-square", "mask-squircle", "mask-star",
      "mask-star-2", "mask-triangle", "mask-triangle-2", "mask-triangle-3", "mask-triangle-4",
      # Megamenu widths
      "megamenu-full", "megamenu-wide",
      # OTP layout
      "otp-joined",
      # Rating half stars and the hidden clear input
      "rating-half", "rating-hidden",
      # Skeleton text variant
      "skeleton-text",
      # Swap animations
      "swap-flip", "swap-rotate",
      # Table options combine freely
      "table-pin-cols", "table-pin-rows", "table-zebra",
      # Tab styles
      "tabs-border", "tabs-box", "tabs-lift",
      # Timeline layout options
      "timeline-box", "timeline-compact", "timeline-snap-icon"
    ]
  ).freeze
end
