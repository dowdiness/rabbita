///|
test "floating surfaces retain native top-layer entry and exit transitions" {
  let common = "display 100ms allow-discrete,overlay 100ms allow-discrete;transition-behavior:allow-discrete"
  let primitives = render(
    @html.div([
      @rui.popover_content(
        id="animation-popover",
        trigger_id="animation-popover-trigger",
        open=true,
        "Popover",
      ),
      @rui.tooltip_content(
        id="animation-tooltip",
        trigger_id="animation-tooltip-trigger",
        open=true,
        "Tooltip",
      ),
      @rui.hover_card_content(
        id="animation-hover-card",
        trigger_id="animation-hover-card-trigger",
        open=true,
        "Hover card",
      ),
    ]),
  )
  assert_contains(primitives, "data-slot=\"popover-content\"")
  assert_contains(primitives, "data-slot=\"tooltip-content\"")
  assert_contains(primitives, "data-slot=\"hover-card-content\"")
  assert_contains(primitives, common)
  assert_contains(
    primitives, "visibility:visible;opacity:1;pointer-events:auto;transform:scale(1)",
  )

  let select_html = render_incremental(() => {
    @rui.select(
      id="animation-select",
      options=[@rui.select_option(value="one", label="One")],
      default_open=true,
    )
  })
  assert_contains(select_html, "data-slot=\"select-content\"")
  assert_contains(select_html, common)

  let combobox_html = render_incremental(() => {
    @rui.combobox(
      id="animation-combobox",
      options=[@rui.combobox_option(value="one", label="One")],
      default_open=true,
    )
  })
  assert_contains(combobox_html, "data-slot=\"combobox-content\"")
  assert_contains(combobox_html, common)
}

///|
test "menu and navigation popup families share the discrete transition recipe" {
  let common = "display 100ms allow-discrete,overlay 100ms allow-discrete;transition-behavior:allow-discrete"
  let menu_html = render_incremental(() => {
    @rui.dropdown_menu(id="animation-menu", default_open=true, scope => {
      @html.div([
        @rui.dropdown_menu_trigger(scope, "Menu"),
        @rui.dropdown_menu_content(scope, [
          @rui.dropdown_menu_item(scope, "Item"),
          @rui.dropdown_menu_sub(scope, value="more", sub => {
            @html.div([
              @rui.dropdown_menu_sub_trigger(sub, "More"),
              @rui.dropdown_menu_sub_content(
                sub,
                @rui.dropdown_menu_item(scope, "Nested"),
              ),
            ])
          }),
        ]),
      ])
    })
  })
  assert_contains(menu_html, "data-slot=\"dropdown-menu-content\"")
  assert_contains(menu_html, "data-slot=\"dropdown-menu-sub-content\"")
  assert_contains(menu_html, common)

  let navigation_html = render_incremental(() => {
    @rui.navigation_menu(
      id="animation-navigation",
      default_value="docs",
      viewport=false,
      scope => {
        @rui.navigation_menu_list(
          scope,
          @rui.navigation_menu_item(scope, value="docs", item => {
            @html.fragment([
              @rui.navigation_menu_trigger(item, "Docs"),
              @rui.navigation_menu_content(item, "Navigation content"),
            ])
          }),
        )
      },
    )
  })
  assert_contains(navigation_html, "data-slot=\"navigation-menu-content\"")
  assert_contains(
    navigation_html, "display 150ms allow-discrete,overlay 150ms allow-discrete;transition-behavior:allow-discrete",
  )
}

///|
test "theme provides closed first frames and reduced-motion fallback" {
  let html = render(@rui.theme(@html.nothing))
  assert_contains(html, "@starting-style")
  assert_contains(
    html, "[data-slot=\"sidebar-mobile-layer\"]:popover-open [data-slot=\"sidebar-overlay\"][data-state=\"open\"]",
  )
  assert_contains(
    html, "[data-slot=\"sidebar-mobile-layer\"]:popover-open [data-slot=\"sidebar\"][data-mobile=\"true\"][data-state=\"expanded\"][data-side=\"left\"]",
  )
  assert_contains(
    html, "[data-slot=\"sidebar-mobile-layer\"]:popover-open [data-slot=\"sidebar\"][data-mobile=\"true\"][data-state=\"expanded\"][data-side=\"right\"]",
  )
  assert_contains(html, "transform:translateX(-100%) !important")
  assert_contains(html, "transform:translateX(100%) !important")
  assert_contains(
    html, "[data-slot=\"popover-content\"],[data-slot=\"tooltip-content\"],[data-slot=\"hover-card-content\"]",
  )
  assert_contains(
    html, "[data-submenu-owner])[data-state=\"open\"]:popover-open",
  )
  assert_contains(
    html, "[data-submenu-owner][data-state=\"open\"]:not(:popover-open)",
  )
  assert_contains(html, "pointer-events:none !important")
  assert_contains(
    html, "dialog[data-slot=\"popover-content\"][data-state=\"open\"][open]",
  )
  assert_contains(html, "transform:scale(0.95) !important")
  assert_contains(html, "@keyframes rui-sheet-enter")
  assert_contains(
    html, "from { opacity:0;transform:var(--rui-sheet-closed-transform); }",
  )
  assert_contains(html, "@keyframes rui-sheet-exit")
  assert_contains(html, "@keyframes rui-drawer-enter")
  assert_contains(
    html, "to { opacity:0;transform:var(--rui-drawer-closed-transform); }",
  )
  assert_contains(html, "@keyframes rui-drawer-exit")
  assert_contains(
    html, ":where([data-slot=\"sheet-overlay\"],[data-slot=\"drawer-overlay\"])[data-state=\"open\"]",
  )
  assert_contains(html, "animation:rui-edge-overlay-enter 200ms ease-out")
  assert_not_contains(html, "animation-fill-mode:forwards")
  assert_not_contains(
    html, "dialog[data-slot=\"sheet-native\"][open] [data-slot=\"sheet-content\"]",
  )
  assert_not_contains(
    html, "dialog[data-slot=\"drawer-native\"][open] [data-slot=\"drawer-content\"]",
  )
  assert_contains(html, "@media (prefers-reduced-motion:reduce)")
  assert_contains(
    html, "[data-slot=\"command-dialog-content\"],[data-slot=\"sidebar-mobile-layer\"],[data-slot=\"sidebar-shell\"]",
  )
  assert_contains(html, "transition-duration:0s !important")
  assert_contains(html, "transition-delay:0s !important")
  assert_contains(
    html, "[data-slot=\"sidebar\"][data-collapsible=\"offcanvas\"][data-state=\"collapsed\"] > :not([data-slot=\"sidebar-rail\"])",
  )
  assert_contains(
    html, "[data-slot=\"sidebar-menu-item\"]:hover > [data-slot=\"sidebar-menu-action\"] {\n      --rui-sidebar-action-fg:",
  )
  assert_not_contains(
    html, "[data-slot=\"sidebar-menu-item\"]:hover > [data-slot=\"sidebar-menu-action\"] {\n      --rui-button-fg:",
  )
  assert_contains(
    html, "[data-slot=\"sidebar-menu-button\"][data-active=\"true\"] ~ [data-slot=\"sidebar-menu-action\"] {\n    --rui-sidebar-action-fg:",
  )
  assert_not_contains(
    html, "[data-slot=\"sidebar-menu-button\"][data-active=\"true\"] ~ [data-slot=\"sidebar-menu-action\"] {\n    --rui-button-fg:",
  )
}
