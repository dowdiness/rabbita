///|
#warnings("-alert_unstable")
fn render_overlay_value(builder : () -> @rabbita.Val[@html.Html]) -> String {
  @rabbita.render_to_string(builder)
}

///|
fn overlay_assert_contains(actual : String, expected : String) -> Unit raise {
  if !actual.contains(expected) {
    fail(
      "expected overlay/layout HTML to contain `\{expected}`; got `\{actual}`",
    )
  }
}

///|
fn overlay_assert_not_contains(
  actual : String,
  unexpected : String,
) -> Unit raise {
  if actual.contains(unexpected) {
    fail(
      "expected overlay/layout HTML not to contain `\{unexpected}`; got `\{actual}`",
    )
  }
}

///|
#cfg(target="js")
test "sheet drawer and sidebar static parts render on JS" {
  let html = render_overlay_value(() => {
    @rabbita.Val::constant(
      @html.div([
        @rui.sheet_header("Sheet header"),
        @rui.sheet_footer("Sheet footer"),
        @rui.drawer_portal([
          @rui.drawer_handle(direction=DrawerLeft),
          @rui.drawer_header("Drawer header"),
        ]),
        @rui.sidebar_menu([
          @rui.sidebar_menu_item(
            @rui.sidebar_menu_button(href="/projects", "Projects"),
          ),
        ]),
      ]),
    )
  })
  overlay_assert_contains(html, "data-slot=\"sheet-header\"")
  overlay_assert_contains(html, "data-slot=\"sheet-footer\"")
  overlay_assert_contains(html, "data-slot=\"drawer-handle\"")
  overlay_assert_contains(html, "data-direction=\"left\"")
  overlay_assert_contains(html, "data-slot=\"drawer-header\"")
  overlay_assert_not_contains(html, "data-slot=\"drawer-portal\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-menu\"")
  overlay_assert_contains(html, "href=\"/projects\"")
}

///|
#cfg(target="native")
test "sheet composes a left native-dialog surface" {
  let html = render_overlay_value(() => {
    @rui.sheet(id="settings-sheet", default_open=true, scope => {
      @html.div([
        @rui.sheet_trigger(scope, "Open settings"),
        @rui.sheet_content(
          scope,
          side=@rui.SheetLeft,
          style=["width:28rem"],
          overlay_attrs=@html.Attrs::build().data_set("owner", "overlay"),
          [
            @rui.sheet_header([
              @rui.sheet_title(scope, "Settings"),
              @rui.sheet_description(scope, "Edit workspace settings."),
            ]),
            @rui.sheet_footer(@rui.sheet_close(scope, "Done")),
          ],
        ),
      ])
    })
  })
  overlay_assert_contains(html, "<dialog")
  overlay_assert_contains(html, "id=\"settings-sheet\"")
  overlay_assert_contains(html, "open")
  overlay_assert_contains(html, "closedby=\"any\"")
  overlay_assert_contains(html, "aria-modal=\"true\"")
  overlay_assert_contains(html, "aria-labelledby=\"settings-sheet-title\"")
  overlay_assert_contains(
    html, "aria-describedby=\"settings-sheet-description\"",
  )
  overlay_assert_contains(html, "data-slot=\"sheet-trigger\"")
  overlay_assert_contains(html, "data-slot=\"sheet-overlay\"")
  overlay_assert_contains(html, "data-owner=\"overlay\"")
  overlay_assert_contains(html, "data-slot=\"sheet-positioner\"")
  overlay_assert_contains(html, "data-slot=\"sheet-content\"")
  overlay_assert_contains(html, "data-side=\"left\"")
  overlay_assert_contains(html, "data-slot=\"sheet-title\"")
  overlay_assert_contains(html, "id=\"settings-sheet-title\"")
  overlay_assert_contains(html, "data-slot=\"sheet-description\"")
  overlay_assert_contains(html, "data-slot=\"sheet-close\"")
  overlay_assert_contains(html, "data-rui-close-icon=\"\"")
  overlay_assert_contains(html, "data-state=\"open\"")
  overlay_assert_contains(html, "<svg")
  overlay_assert_not_contains(html, ">×<")
  overlay_assert_contains(html, "animation:rui-sheet-enter 200ms ease-in-out")
  overlay_assert_contains(html, "will-change:opacity,transform")
  overlay_assert_contains(html, "--rui-dialog-overlay-opacity:1")
  overlay_assert_contains(html, "--rui-sheet-opacity:1")
  overlay_assert_contains(html, "--rui-sheet-transform:translate3d(0,0,0)")
  overlay_assert_contains(
    html, "opacity:var(--rui-close-opacity,var(--rui-close-base-opacity,0.7))",
  )
  overlay_assert_contains(
    html, "background:var(--rui-close-bg,var(--rui-button-bg,var(--rui-button-base-bg,transparent)))",
  )
  overlay_assert_contains(
    html, "box-shadow:var(--rui-close-shadow,var(--rui-button-shadow,var(--rui-button-base-shadow,none)))",
  )
  overlay_assert_contains(html, "pointer-events:auto")
  overlay_assert_contains(html, "width:min(85vw,24rem);height:100%")
  overlay_assert_contains(html, "width:28rem")
}

///|
#cfg(target="native")
test "drawer exposes bottom handle and deliberate close control" {
  let html = render_overlay_value(() => {
    @rui.drawer(id="details-drawer", default_open=true, scope => {
      @html.div([
        @rui.drawer_trigger(scope, "Open details"),
        @rui.drawer_portal([
          @rui.drawer_content(
            scope,
            show_close=true,
            close_on_overlay=false,
            overlay_attrs=@html.Attrs::build().data_set("owner", "overlay"),
            [
              @rui.drawer_header([
                @rui.drawer_title(scope, "Details"),
                @rui.drawer_description(scope, "Review this record."),
              ]),
              @rui.drawer_footer(@rui.drawer_close(scope, "Close details")),
            ],
          ),
        ]),
      ])
    })
  })
  overlay_assert_contains(html, "id=\"details-drawer\"")
  overlay_assert_contains(html, "closedby=\"closerequest\"")
  overlay_assert_contains(html, "data-slot=\"drawer-overlay\"")
  overlay_assert_contains(html, "data-owner=\"overlay\"")
  overlay_assert_contains(html, "data-slot=\"drawer-positioner\"")
  overlay_assert_contains(html, "data-slot=\"drawer-content\"")
  overlay_assert_contains(html, "data-direction=\"bottom\"")
  overlay_assert_contains(html, "data-slot=\"drawer-handle\"")
  overlay_assert_contains(html, "aria-hidden=\"true\"")
  overlay_assert_contains(html, "cursor:grab;touch-action:none")
  overlay_assert_contains(html, "data-slot=\"drawer-header\"")
  overlay_assert_contains(html, "data-slot=\"drawer-title\"")
  overlay_assert_contains(html, "data-slot=\"drawer-description\"")
  overlay_assert_contains(html, "data-slot=\"drawer-footer\"")
  overlay_assert_contains(html, "data-slot=\"drawer-close\"")
  overlay_assert_contains(html, "data-rui-close-icon=\"\"")
  overlay_assert_contains(html, "<svg")
  overlay_assert_not_contains(html, ">×<")
  overlay_assert_contains(
    html, "animation:rui-drawer-enter 200ms cubic-bezier(0.22,1,0.36,1)",
  )
  overlay_assert_contains(html, "will-change:opacity,transform")
  overlay_assert_contains(html, "--rui-dialog-overlay-opacity:1")
  overlay_assert_contains(html, "--rui-drawer-opacity:1")
  overlay_assert_contains(html, "--rui-drawer-transform:translate3d(0,0,0)")
  overlay_assert_contains(
    html, "opacity:var(--rui-close-opacity,var(--rui-close-base-opacity,0.7))",
  )
  overlay_assert_not_contains(html, "data-slot=\"drawer-portal\"")
}

///|
#cfg(target="native")
test "sheet and drawer forward non-modal dialog behavior" {
  let sheet_html = render_overlay_value(() => {
    @rui.sheet(id="nonmodal-sheet", default_open=true, modal=false, scope => {
      @rui.sheet_content(scope, "Inspector")
    })
  })
  overlay_assert_contains(sheet_html, "closedby=\"none\"")
  overlay_assert_contains(sheet_html, "data-modal=\"false\"")
  overlay_assert_not_contains(sheet_html, "aria-modal")
  overlay_assert_not_contains(sheet_html, "data-slot=\"sheet-overlay\"")
  let drawer_html = render_overlay_value(() => {
    @rui.drawer(id="nonmodal-drawer", default_open=true, modal=false, scope => {
      @rui.drawer_content(scope, "Inspector")
    })
  })
  overlay_assert_contains(drawer_html, "closedby=\"none\"")
  overlay_assert_contains(drawer_html, "data-modal=\"false\"")
  overlay_assert_not_contains(drawer_html, "aria-modal")
  overlay_assert_not_contains(drawer_html, "data-slot=\"drawer-overlay\"")
}

///|
#cfg(target="native")
test "closed sheet and drawer expose edge-specific exit transforms" {
  let sheet_html = render_overlay_value(() => {
    @rui.sheet(id="closed-right-sheet", scope => {
      @rui.sheet_content(scope, side=@rui.SheetRight, "Settings")
    })
  })
  overlay_assert_contains(sheet_html, "data-state=\"closed\"")
  overlay_assert_contains(sheet_html, "--rui-dialog-overlay-opacity:0")
  overlay_assert_contains(sheet_html, "--rui-sheet-opacity:0")
  overlay_assert_contains(
    sheet_html, "--rui-sheet-transform:translate3d(2.5rem,0,0)",
  )
  overlay_assert_contains(
    sheet_html, "animation:rui-sheet-exit 200ms ease-in-out",
  )
  let drawer_html = render_overlay_value(() => {
    @rui.drawer(id="closed-left-drawer", scope => {
      @rui.drawer_content(scope, direction=@rui.DrawerLeft, "Navigation")
    })
  })
  overlay_assert_contains(drawer_html, "data-state=\"closed\"")
  overlay_assert_contains(drawer_html, "--rui-dialog-overlay-opacity:0")
  overlay_assert_contains(drawer_html, "--rui-drawer-opacity:0")
  overlay_assert_contains(
    drawer_html, "--rui-drawer-transform:translate3d(calc(-100% - 2px),0,0)",
  )
  overlay_assert_contains(
    drawer_html, "animation:rui-drawer-exit 200ms cubic-bezier(0.22,1,0.36,1)",
  )
  let bottom_drawer_html = render_overlay_value(() => {
    @rui.drawer(id="closed-bottom-drawer", scope => {
      @rui.drawer_content(scope, direction=@rui.DrawerBottom, "Details")
    })
  })
  overlay_assert_contains(
    bottom_drawer_html, "--rui-drawer-transform:translate3d(0,calc(100% + 2px),0)",
  )
}

///|
#cfg(target="native")
test "drawer portal is transparent and overlay is independently composable" {
  let html = render_overlay_value(() => {
    @rui.drawer(id="standalone-drawer-parts", default_open=true, scope => {
      @rui.drawer_portal([
        @rui.drawer_overlay(
          scope,
          close_on_overlay=false,
          id="standalone-drawer-overlay",
          attrs=@html.Attrs::build().data_set("owner", "drawer-overlay"),
          style=["opacity:0.6"],
        ),
        @html.span(attrs=@html.Attrs::build().data_set("portal-child", ""), "D"),
      ])
    })
  })
  overlay_assert_contains(html, "id=\"standalone-drawer-overlay\"")
  overlay_assert_contains(html, "data-slot=\"drawer-overlay\"")
  overlay_assert_contains(html, "data-state=\"open\"")
  overlay_assert_contains(html, "data-owner=\"drawer-overlay\"")
  overlay_assert_contains(html, "opacity:0.6")
  overlay_assert_contains(html, "data-portal-child=\"\"")
  overlay_assert_not_contains(html, "data-slot=\"drawer-portal\"")
  overlay_assert_not_contains(html, "<dialog")
}

///|
#cfg(target="native")
test "sidebar provider renders icon-collapse compound API" {
  let html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, scope => {
      @html.fragment([
        @rui.sidebar(
          scope,
          id="workspace-sidebar",
          collapsible=@rui.SidebarIcon,
          variant=@rui.SidebarFloating,
          [
            @rui.sidebar_header(
              @rui.sidebar_input(
                aria_label="Search navigation",
                placeholder="Search",
              ),
            ),
            @rui.sidebar_content(
              @rui.sidebar_group([
                @rui.sidebar_group_label(scope~, "Workspace"),
                @rui.sidebar_group_action(
                  aria_label="Workspace actions",
                  @html.nothing,
                ),
                @rui.sidebar_group_content(
                  @rui.sidebar_menu([
                    @rui.sidebar_menu_item([
                      @rui.sidebar_menu_button(
                        href="/overview",
                        is_active=true,
                        "Overview",
                      ),
                      @rui.sidebar_menu_badge("3"),
                      @rui.sidebar_menu_action(
                        show_on_hover=true,
                        aria_label="Overview actions",
                        @html.nothing,
                      ),
                    ]),
                    @rui.sidebar_menu_item(
                      @rui.sidebar_menu_sub(
                        @rui.sidebar_menu_sub_item(
                          @rui.sidebar_menu_sub_button(
                            href="/reports",
                            "Reports",
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            @rui.sidebar_separator(),
            @rui.sidebar_footer("Account"),
            @rui.sidebar_rail(scope),
          ],
        ),
        @rui.sidebar_inset(
          @rui.sidebar_trigger(scope, controls="workspace-sidebar", "Toggle"),
        ),
      ])
    })
  })
  overlay_assert_contains(html, "data-slot=\"sidebar-wrapper\"")
  overlay_assert_contains(html, "data-state=\"collapsed\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-shell\"")
  overlay_assert_contains(
    html, "width:calc(var(--rui-sidebar-width-icon,3rem) + 1rem)",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar\"")
  overlay_assert_contains(html, "data-collapsible=\"icon\"")
  overlay_assert_contains(html, "data-variant=\"floating\"")
  overlay_assert_contains(html, "width:var(--rui-sidebar-width-icon,3rem)")
  overlay_assert_contains(html, "--rui-sidebar-group-label-margin:-2rem")
  overlay_assert_contains(html, "--rui-sidebar-group-label-opacity:0")
  overlay_assert_contains(html, "--rui-sidebar-group-label-pointer-events:none")
  overlay_assert_contains(html, "--rui-sidebar-group-action-display:none")
  overlay_assert_contains(html, "--rui-sidebar-menu-action-display:none")
  overlay_assert_contains(html, "--rui-sidebar-menu-badge-display:none")
  overlay_assert_contains(html, "--rui-sidebar-menu-sub-display:none")
  overlay_assert_contains(html, "--rui-sidebar-input-display:none")
  overlay_assert_contains(html, "--rui-sidebar-content-overflow-y:hidden")
  overlay_assert_contains(html, "--rui-sidebar-item-collapse-gap:0")
  overlay_assert_contains(html, "--rui-sidebar-item-collapse-font-size:0")
  overlay_assert_contains(html, "--rui-sidebar-item-collapse-width:2rem")
  overlay_assert_contains(html, "--rui-sidebar-item-collapse-height:2rem")
  overlay_assert_contains(html, "--rui-sidebar-item-justify-content:center")
  overlay_assert_contains(html, "data-slot=\"sidebar-header\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-input\"")
  overlay_assert_contains(
    html, "--rui-control-base-shadow:0 0 #0000;background:var(--rui-background,oklch(1 0 0));font-size:0.875rem",
  )
  overlay_assert_contains(
    html, "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 1px 2px rgb(0 0 0 / 0.05)))",
  )
  overlay_assert_not_contains(
    html, "box-shadow:0 1px 2px rgb(0 0 0 / 0.05);height:2rem",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-content\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-group\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-group-label\"")
  overlay_assert_contains(
    html, "color:var(--rui-sidebar-label-fg,var(--rui-sidebar-label-base-fg,color-mix(in oklab,var(--rui-sidebar-foreground",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-group-action\"")
  overlay_assert_contains(
    html, "position:absolute;top:0.875rem;inset-inline-end:0.75rem",
  )
  overlay_assert_contains(
    html, "background:var(--rui-sidebar-action-bg,var(--rui-button-bg,var(--rui-button-base-bg,transparent)))",
  )
  overlay_assert_contains(html, "data-state=\"auto\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-menu-button\"")
  overlay_assert_contains(html, "aria-current=\"page\"")
  overlay_assert_contains(
    html, "background:var(--rui-sidebar-item-bg,var(--rui-sidebar-item-base-bg,transparent))",
  )
  overlay_assert_contains(
    html, "--rui-sidebar-item-base-bg:var(--rui-sidebar-accent,var(--rui-accent,oklch(0.97 0 0)))",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-menu-badge\"")
  overlay_assert_contains(
    html, "color:var(--rui-sidebar-badge-fg,var(--rui-sidebar-badge-base-fg,inherit))",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-menu-action\"")
  overlay_assert_contains(html, "data-show-on-hover=\"true\"")
  overlay_assert_contains(
    html, "opacity:var(--rui-sidebar-action-opacity,var(--rui-sidebar-action-base-opacity,1))",
  )
  overlay_assert_contains(html, "--rui-sidebar-action-base-opacity:0")
  overlay_assert_contains(html, "data-slot=\"sidebar-menu-sub\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-menu-sub-button\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-separator\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-footer\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-rail\"")
  overlay_assert_contains(html, "tabindex=\"-1\"")
  overlay_assert_contains(html, "data-min-width=\"160\"")
  overlay_assert_contains(html, "data-max-width=\"512\"")
  overlay_assert_contains(html, "touch-action:none;user-select:none")
  overlay_assert_contains(
    html, "left:var(--rui-sidebar-rail-left,auto);right:var(--rui-sidebar-rail-right,-0.5rem)",
  )
  overlay_assert_contains(
    html, "--rui-sidebar-rail-left:auto;--rui-sidebar-rail-right:-0.5rem",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-rail-line\"")
  overlay_assert_contains(
    html, "background:var(--rui-sidebar-rail-line-bg,transparent)",
  )
  overlay_assert_contains(
    html, "pointer-events:none;transform:translateX(-50%)",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-trigger\"")
  overlay_assert_contains(html, "aria-controls=\"workspace-sidebar\"")
  overlay_assert_contains(html, "width:1.75rem;height:1.75rem")
  overlay_assert_contains(
    html, "width:1.25rem;height:1.25rem;--rui-button-icon-size:1rem",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-inset\"")
  overlay_assert_contains(html, "role=\"main\"")
}

///|
#cfg(target="native")
test "fixed sidebar keeps group labels visible when provider is collapsed" {
  let html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, scope => {
      @rui.sidebar(
        scope,
        collapsible=@rui.SidebarFixed,
        @rui.sidebar_group_label(scope~, "Always visible"),
      )
    })
  })
  overlay_assert_contains(html, "data-collapsible=\"none\"")
  overlay_assert_contains(html, "data-state=\"expanded\"")
  overlay_assert_contains(html, "data-slot=\"sidebar-shell\"")
  overlay_assert_contains(
    html, "width:var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  overlay_assert_contains(html, "data-slot=\"sidebar-group-label\"")
  overlay_assert_not_contains(html, "--rui-sidebar-group-label-margin:-2rem")
  overlay_assert_not_contains(html, "--rui-sidebar-group-label-opacity:0")
}

///|
#cfg(target="native")
test "mobile sidebar transitions a dismissible backdrop and inert surface" {
  let open_html = render_overlay_value(() => {
    @rui.sidebar_provider(default_mobile_open=true, scope => {
      @rui.sidebar(scope, mobile=true, "Mobile navigation")
    })
  })
  overlay_assert_contains(open_html, "data-slot=\"sidebar-overlay\"")
  overlay_assert_contains(open_html, "data-slot=\"sidebar-mobile-layer\"")
  overlay_assert_contains(open_html, "popover=\"manual\"")
  overlay_assert_contains(open_html, "transition:display 200ms,overlay 200ms")
  overlay_assert_contains(open_html, "data-mobile=\"true\"")
  overlay_assert_contains(open_html, "role=\"dialog\"")
  overlay_assert_contains(open_html, "aria-modal=\"true\"")
  overlay_assert_contains(open_html, "autofocus")
  overlay_assert_contains(open_html, "tabindex=\"-1\"")
  overlay_assert_contains(open_html, "data-mobile-state=\"open\"")
  overlay_assert_contains(open_html, "transform:translateX(0)")
  overlay_assert_contains(
    open_html, "pointer-events:auto;outline:none;box-shadow",
  )
  overlay_assert_contains(open_html, "--rui-sidebar-overlay-opacity:1")
  let closed_html = render_overlay_value(() => {
    @rui.sidebar_provider(scope => {
      @rui.sidebar(scope, mobile=true, "Mobile navigation")
    })
  })
  overlay_assert_contains(closed_html, "data-state=\"closed\"")
  overlay_assert_contains(closed_html, "data-mobile-state=\"closed\"")
  overlay_assert_contains(closed_html, "aria-hidden=\"true\"")
  overlay_assert_contains(closed_html, "inert")
  overlay_assert_contains(closed_html, "transform:translateX(-100%)")
  overlay_assert_contains(closed_html, "--rui-sidebar-overlay-opacity:0")
  overlay_assert_not_contains(closed_html, "display:none")
}

///|
#cfg(target="native")
test "sidebar resets desktop collapse on mobile and mirrors right inset spacing" {
  let mobile_html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, default_mobile_open=true, scope => {
      @rui.sidebar(
        scope,
        mobile=true,
        @rui.sidebar_group_label(scope~, "Workspace"),
      )
    })
  })
  overlay_assert_contains(mobile_html, "data-mobile=\"true\"")
  overlay_assert_contains(mobile_html, "data-state=\"expanded\"")
  overlay_assert_contains(
    mobile_html, "width:min(var(--rui-sidebar-width-mobile,18rem),calc(100vw - 2rem))",
  )
  overlay_assert_contains(mobile_html, "--rui-sidebar-group-label-margin:0")
  overlay_assert_contains(mobile_html, "--rui-sidebar-group-label-opacity:1")
  overlay_assert_contains(
    mobile_html, "--rui-sidebar-group-label-pointer-events:auto",
  )
  overlay_assert_contains(mobile_html, "--rui-sidebar-item-collapse-gap:0.5rem")
  overlay_assert_contains(
    mobile_html, "--rui-sidebar-item-collapse-font-size:var(--rui-sidebar-item-base-font-size,0.875rem)",
  )

  let right_html = render_overlay_value(() => {
    @rui.sidebar_provider(scope => {
      @rui.sidebar(
        scope,
        side=@rui.SidebarRight,
        variant=@rui.SidebarInset,
        "Right navigation",
      )
    })
  })
  overlay_assert_contains(right_html, "data-slot=\"sidebar-shell\"")
  overlay_assert_contains(right_html, "data-side=\"right\"")
  overlay_assert_contains(right_html, "data-variant=\"inset\"")
  overlay_assert_contains(right_html, "order:1")
  overlay_assert_contains(
    right_html, "width:var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  overlay_assert_contains(
    right_html, "width:calc(var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem)) - 1rem)",
  )
  overlay_assert_contains(right_html, "top:0.5rem;bottom:0.5rem;right:0.5rem")
  overlay_assert_contains(
    right_html, "border:0;border-radius:0;box-shadow:none",
  )
}

///|
#cfg(target="native")
test "offcanvas collapse slides the surface while its shell releases layout width" {
  let collapsed_html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, scope => {
      @rui.sidebar(
        scope,
        collapsible=@rui.SidebarOffcanvas,
        variant=@rui.SidebarFloating,
        "Navigation",
      )
    })
  })
  overlay_assert_contains(collapsed_html, "data-slot=\"sidebar-shell\"")
  overlay_assert_contains(collapsed_html, "data-state=\"collapsed\"")
  overlay_assert_contains(collapsed_html, "width:0px")
  overlay_assert_contains(
    collapsed_html, "width:calc(var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem)) - 1rem)",
  )
  overlay_assert_contains(
    collapsed_html, "transform:translateX(calc(-100% - 0.5rem))",
  )
  overlay_assert_contains(
    collapsed_html, "--rui-sidebar-rail-left:auto;--rui-sidebar-rail-right:-1rem;--rui-sidebar-rail-line-left:0%",
  )
  overlay_assert_contains(
    collapsed_html, "border-radius:var(--rui-radius,0.625rem);box-shadow:0 1px 3px rgb(0 0 0 / 0.08)",
  )
  overlay_assert_not_contains(
    collapsed_html, "width:0;min-width:0;margin:0;border:0;padding:0;box-shadow:none;overflow:hidden",
  )

  let right_html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, scope => {
      @rui.sidebar(
        scope,
        side=@rui.SidebarRight,
        collapsible=@rui.SidebarOffcanvas,
        [@html.span("Right navigation"), @rui.sidebar_rail(scope)],
      )
    })
  })
  overlay_assert_contains(right_html, "data-side=\"right\"")
  overlay_assert_contains(right_html, "order:1")
  overlay_assert_contains(right_html, "width:0px")
  overlay_assert_contains(right_html, "transform:translateX(100%)")
  overlay_assert_contains(
    right_html, "--rui-sidebar-rail-left:-0.5rem;--rui-sidebar-rail-right:auto",
  )
  overlay_assert_contains(
    right_html, "--rui-sidebar-rail-left:-1rem;--rui-sidebar-rail-right:auto;--rui-sidebar-rail-line-left:100%",
  )
  overlay_assert_contains(
    right_html, "pointer-events:none;transform:translateX(-50%)",
  )

  let hidden_mobile_html = render_overlay_value(() => {
    @rui.sidebar_provider(default_mobile_open=true, scope => {
      @rui.sidebar(scope, mobile=true, hidden=true, "Navigation")
    })
  })
  overlay_assert_contains(hidden_mobile_html, "data-mobile-state=\"closed\"")
  overlay_assert_contains(hidden_mobile_html, "aria-hidden=\"true\"")
  overlay_assert_contains(hidden_mobile_html, "--rui-sidebar-overlay-opacity:0")
  overlay_assert_contains(hidden_mobile_html, " hidden>")
}

///|
#cfg(target="native")
test "sidebar black-box defaults render desktop and mobile state" {
  let html = render_overlay_value(() => {
    @rui.sidebar_provider(default_collapsed=true, default_mobile_open=false, scope => {
      @html.fragment([
        @rui.sidebar(
          scope,
          id="default-sidebar",
          collapsible=@rui.SidebarIcon,
          "Navigation",
        ),
        @rui.sidebar_trigger(
          scope,
          controls="default-sidebar",
          "Toggle navigation",
        ),
      ])
    })
  })
  overlay_assert_contains(html, "data-slot=\"sidebar-wrapper\"")
  overlay_assert_contains(html, "data-state=\"collapsed\"")
  overlay_assert_contains(html, "data-mobile=\"closed\"")
  overlay_assert_contains(html, "aria-expanded=\"false\"")
  overlay_assert_contains(html, "aria-controls=\"default-sidebar\"")
}
