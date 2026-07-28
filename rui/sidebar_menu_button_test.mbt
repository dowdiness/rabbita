///|
#cfg(target="js")
extern "js" fn install_sidebar_menu_button_test_window() =
  #| () => {
  #|   if (typeof globalThis.window === "undefined") {
  #|     globalThis.window = { requestAnimationFrame: () => 0 };
  #|   }
  #| }

///|
#warnings("-alert_unstable")
#cfg(target="js")
fn render_sidebar_menu_button_value(
  builder : () -> @rabbita.Val[@html.Html],
) -> String {
  install_sidebar_menu_button_test_window()
  ignore(@rabbita.new(builder))
  @rabbita.render_to_string(builder)
}

///|
#warnings("-alert_unstable")
#cfg(not(target="js"))
fn render_sidebar_menu_button_value(
  builder : () -> @rabbita.Val[@html.Html],
) -> String {
  @rabbita.render_to_string(builder)
}

///|
test "sidebar menu button variants preserve native button and anchor semantics" {
  let default_button = render(
    @rui.sidebar_menu_button(id="default-menu-button", "Overview"),
  )
  assert_contains(default_button, "<button")
  assert_contains(default_button, "type=\"button\"")
  assert_contains(default_button, "data-slot=\"sidebar-menu-button\"")
  assert_contains(default_button, "data-variant=\"default\"")
  assert_not_contains(
    default_button, "--rui-sidebar-item-base-shadow:0 0 0 1px",
  )

  let outline_anchor = render(
    @rui.sidebar_menu_button(
      href="/projects",
      is_active=true,
      variant=SidebarMenuButtonOutline,
      "Projects",
    ),
  )
  assert_contains(outline_anchor, "<a")
  assert_contains(outline_anchor, "href=\"/projects\"")
  assert_contains(outline_anchor, "aria-current=\"page\"")
  assert_contains(outline_anchor, "data-variant=\"outline\"")
  assert_contains(
    outline_anchor, "--rui-sidebar-item-base-bg:var(--rui-background,oklch(1 0 0))",
  )
  assert_contains(
    outline_anchor, "--rui-sidebar-item-base-shadow:0 0 0 1px var(--rui-sidebar-border",
  )
}

///|
test "sidebar tooltip reuses its anchor trigger without an interactive wrapper" {
  let html = render_sidebar_menu_button_value(() => {
    @rui.sidebar_menu_button_with_tooltip(
      id="projects-link",
      tooltip="Projects",
      href="/projects",
      variant=SidebarMenuButtonOutline,
      tooltip_side=Right,
      "Projects",
    )
  })
  assert_contains(html, "<a")
  assert_contains(html, "id=\"projects-link\"")
  assert_contains(html, "href=\"/projects\"")
  assert_contains(html, "data-slot=\"sidebar-menu-button\"")
  assert_contains(html, "data-tooltip-root=\"\"")
  assert_contains(html, "data-sidebar-collapsed-only=\"true\"")
  assert_contains(html, "id=\"projects-link-tooltip\"")
  assert_contains(html, "data-slot=\"tooltip-content\"")
  assert_contains(html, "data-tooltip-owner-id=\"projects-link\"")
  assert_contains(html, "data-state=\"closed\"")
  assert_not_contains(html, "<button")
  assert_not_contains(html, "aria-describedby=\"projects-link-tooltip\"")
  assert_not_contains(html, "projects-link-tooltip-root")
}

///|
test "sidebar tooltip reuses its button trigger without nesting buttons" {
  let html = render_sidebar_menu_button_value(() => {
    @rui.sidebar_menu_button_with_tooltip(
      id="settings-button",
      tooltip="Settings",
      "Settings",
    )
  })
  assert_eq(html.split("<button").count(), 2)
  assert_contains(html, "id=\"settings-button\"")
  assert_contains(html, "id=\"settings-button-tooltip\"")
}
