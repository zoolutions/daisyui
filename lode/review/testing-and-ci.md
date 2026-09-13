# Review rules: the two suites

Accepted findings about `spec/` and `docs/spec/`. See
[`../testing-and-ci/summary.md`](../testing-and-ci/summary.md) for how they are
wired.

## A browser spec waits for the positioned frame before reading geometry

`daisy_tooltip_controller.js` opens the popover and then positions it inside a
`requestAnimationFrame` (`#schedulePosition`, line 82), setting `left`, `top` and
`visibility: "visible"` together at the end of `#position()`. `:popover-open`
matches the moment `showPopover()` returns — one frame too early — so any
`getBoundingClientRect()` read at that point can see the unpositioned,
`visibility: hidden` element and the bounds assertion is racy.

`docs/spec/system/tooltip_popover_spec.rb` therefore waits on
`have_css("#…:popover-open", visible: true)` and asserts the computed
`visibility == "visible"` before trusting any coordinate.

- **Safe direction**: the assertion that the work finished is the thing to wait
  on — `visibility`, not "the element exists". A retry loop around a coordinate
  hides the race instead of proving it is gone.
- **Test**: the spec is itself the test.
- Origin: PR 37 thread on `docs/spec/system/tooltip_popover_spec.rb:29`
  (`04e60e8`).

## Not a bug: `around` hooks restore after a bare `example.run`, not in `ensure`

Reviewers repeatedly proposed wrapping the restore in `begin … ensure … end` in
the three spec files a PR happened to touch. Rejected, three times, with the same
reason: the pattern is suite-wide, not local. 13 of the 71 spec files set
`DaisyUI.configuration.prefix` in an `around` hook and every one of them restores
after a bare `example.run`; a `grep` for `ensure` in `spec/` returns nothing.

The hazard is real and documented — an example that *raises* (rather than failing
an expectation) skips the restore and leaks a prefix into every later example —
but converting three of thirteen files creates two conventions where there was
one. Adopting `ensure` is a single suite-wide refactor with its own PR, not a
drive-by in a feature branch.

- **Safe direction**: when adding a spec that mutates global configuration, copy
  the neighbouring file's `around` shape. Do not introduce `ensure` alone.
- Origin: PR 17 threads on `spec/lib/daisy_ui/aura_spec.rb:96`,
  `spec/lib/daisy_ui/megamenu_spec.rb:92` and `spec/lib/daisy_ui/otp_spec.rb:127`
  — three findings, one rule.
