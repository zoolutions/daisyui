# frozen_string_literal: true

# conformance-kit's audit.require: loads the gem and finalizes it the way the
# Rails engine does at boot. DaisyUI.finalize! eager-loads every constant
# under DaisyUI, so `conformance-audit --strict` sees them all. The one file
# left out is lib/daisy_ui/engine.rb: it subclasses Rails::Engine, and this
# bundle has no Rails (lib/daisy_ui.rb loads it only under Rails).
require_relative "../lib/daisyui"

DaisyUI.finalize!
