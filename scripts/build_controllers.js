// Builds the minified Stimulus controllers the gem ships to importmap hosts.
//
//   bun run scripts/build_controllers.js      # or: bundle exec rake build:js
//
// The controller sources under app/javascript/daisy_ui/controllers are the
// documentation, so they stay comment-dense. Browsers load a minified twin of
// each instead (config/importmap.rb pins the .min.js), with a linked sourcemap
// that carries the source, so devtools still shows the readable file.
//
// Each controller is minified ON ITS OWN. What it imports stays EXTERNAL, as a
// bare specifier the host's import map resolves: @hotwired/stimulus (the host's
// Stimulus) and @floating-ui/dom (the dropdown's optional, host-pinned fallback).
//
// The output is DETERMINISTIC for the bun pinned in .bun-version, so the
// .min.js/.min.js.map are committed (hosts and releases need no bun) and CI
// gates on `rake build:js_check`. Build with that bun: 1.4.0 prepends a require
// shim to a module with a dynamic import(), which the dropdown controller has.

import { rm } from "node:fs/promises"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

const root = join(dirname(fileURLToPath(import.meta.url)), "..")
const srcDir = join(root, "app/javascript/daisy_ui/controllers")

// config/importmap.rb pins the same names.
const ENTRIES = ["daisy_dropdown_controller", "daisy_tooltip_controller"]
const EXTERNAL = ["@hotwired/stimulus", "@floating-ui/dom"]

for (const name of ENTRIES) {
  await rm(join(srcDir, `${name}.min.js`), { force: true })
  await rm(join(srcDir, `${name}.min.js.map`), { force: true })
}

const result = await Bun.build({
  entrypoints: ENTRIES.map((name) => join(srcDir, `${name}.js`)),
  outdir: srcDir,
  root: srcDir,
  target: "browser",
  format: "esm",
  minify: true,
  sourcemap: "linked",
  naming: "[dir]/[name].min.[ext]",
  external: EXTERNAL,
})

if (!result.success) {
  for (const log of result.logs) console.error(log)
  process.exit(1)
}

for (const output of result.outputs) {
  console.log(`  ${output.path.replace(`${root}/`, "")}  ${output.size} bytes`)
}
