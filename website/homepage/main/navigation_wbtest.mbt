///|
test "components route accepts component pages only" {
  assert_true(is_components_url("components"))
  assert_true(is_components_url("components/"))
  assert_true(is_components_url("components/button"))
  assert_true(is_components_url("components/button/"))
  assert_false(is_components_url("component"))
  assert_false(is_components_url("components-extra"))
  assert_false(is_components_url("components/button/example"))
}

///|
test "components route extracts a stable page slug" {
  assert_eq(component_slug_from_path("components"), "accordion")
  assert_eq(component_slug_from_path("components/"), "accordion")
  assert_eq(component_slug_from_path("components/button"), "button")
  assert_eq(component_slug_from_path("components/input-group/"), "input-group")
  assert_eq(component_slug_from_path("components/button/example"), "")
}

///|
test "components has its own page and navigation identity" {
  assert_eq(@rabbita.Enumerate::tag(Components("button")), "components:button")
  assert_true(
    @rabbita.Enumerate::tag(Components("button")) !=
    @rabbita.Enumerate::tag(Components("tabs")),
  )
  assert_true(NavComponents != NavHome)
  assert_true(NavComponents != NavTour)
}
