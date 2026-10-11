# frozen_string_literal: true

# Auto-pins the gem's bundled Stimulus controllers for importmap-rails consumers.
# Exposes the bundled `daisy-dropdown` and `daisy-tooltip` controllers. Register
# them in the host app (lazily recommended):
#
#   // app/javascript/controllers/index.js
#   import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
#   lazyLoadControllersFrom("daisy_ui/controllers", application)
#
# Each pin resolves to the minified build (`rake build:js`), whose linked
# sourcemap shows the readable source in devtools. Pinned one by one, not with
# pin_all_from: the directory also holds the .min.js twins, which would become
# pins of their own. Not preloaded: a lazily registered controller is fetched
# the first time its data-controller appears, so a page without one skips it.
pin "daisy_ui/controllers/daisy_dropdown_controller",
  to: "daisy_ui/controllers/daisy_dropdown_controller.min.js",
  preload: false
pin "daisy_ui/controllers/daisy_tooltip_controller",
  to: "daisy_ui/controllers/daisy_tooltip_controller.min.js",
  preload: false
