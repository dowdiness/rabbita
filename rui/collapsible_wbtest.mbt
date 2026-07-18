///|
test "collapsible hover uses the accent surface without changing accordion hover" {
  assert_true(
    UiInteractionCss.contains(
      "[data-slot=\"collapsible-trigger\"]:not([aria-disabled=\"true\"]):hover",
    ),
  )
  assert_true(
    UiInteractionCss.contains(
      "--rui-accordion-bg:var(--rui-accent,oklch(0.97 0 0))",
    ),
  )
  assert_true(
    UiInteractionCss.contains(
      "[data-slot=\"accordion-trigger\"]:not([aria-disabled=\"true\"]):hover",
    ),
  )
}
