///|
#warnings("-alert_unstable")
fn render_showcase_stage(html : @html.Html) -> String {
  @rabbita.render_to_string(() => @rabbita.Val::constant(html))
}

///|
#cfg(target="js")
extern "js" fn install_showcase_incremental_test_window() =
  #| () => {
  #|   if (typeof globalThis.window === "undefined") {
  #|     globalThis.window = { requestAnimationFrame: () => 0 };
  #|   }
  #| }

///|
#cfg(target="js")
#warnings("-alert_unstable")
fn render_showcase_incremental(
  builder : () -> @rabbita.Val[@html.Html],
) -> String {
  install_showcase_incremental_test_window()
  ignore(@rabbita.new(builder))
  @rabbita.render_to_string(builder)
}

///|
#cfg(not(target="js"))
#warnings("-alert_unstable")
fn render_showcase_incremental(
  builder : () -> @rabbita.Val[@html.Html],
) -> String {
  @rabbita.render_to_string(builder)
}

///|
fn assert_showcase_stage_contains(
  actual : String,
  expected : String,
) -> Unit raise {
  if !actual.contains(expected) {
    fail("expected showcase stage HTML to contain `\{expected}`")
  }
}

///|
fn showcase_component_tail(
  html : String,
  component_id : String,
) -> String raise {
  let component_marker = "id=\"\{component_id}\""
  if html.split(component_marker).to_array() is [_, component_and_rest] {
    component_and_rest.to_owned()
  } else {
    fail("expected showcase HTML to contain component `\{component_id}`")
  }
}

///|
fn assert_showcase_component_stages(
  html : String,
  component_id : String,
  expected_stage_ids : Array[String],
) -> Unit raise {
  let expected_count = expected_stage_ids.length()
  assert_eq(
    html.split("class=\"rui-showcase-demo-section\"").count(),
    expected_count + 1,
  )
  assert_eq(
    html.split("class=\"rui-showcase-demo-stage\"").count(),
    expected_count + 1,
  )
  assert_eq(html.split("aria-label=\"Copy code\"").count(), expected_count + 1)
  assert_eq(
    html.split("class=\"rui-showcase-rail-link\"").count(),
    expected_count + 1,
  )
  assert_eq(html.split("id=\"\{component_id}--").count(), expected_count + 1)
  for stage_id in expected_stage_ids {
    assert_showcase_stage_contains(html, "id=\"\{component_id}--\{stage_id}\"")
    assert_showcase_stage_contains(html, "#\{component_id}--\{stage_id}")
  }
}

///|
fn assert_menu_showcase_component(
  html : String,
  component_id : String,
  expected_stage_ids : Array[String],
) -> Unit raise {
  assert_showcase_component_stages(html, component_id, expected_stage_ids)
  if html.contains("padding-inline-start:2rem") {
    fail("menu showcase `\{component_id}` must not render inset menu items")
  }
}

///|
test "short showcase code stays expanded and keeps its copy action" {
  let html = render_showcase_stage(
    showcase_stage(@html.span("Demo"), "@rui.button(\"Save\")\n"),
  )
  for
    expected in [
      "rui-showcase-demo-code--expanded", "rui-showcase-demo-code-panel", "rui-showcase-demo-code-scroll",
      "rui-showcase-demo-code-copy", "aria-label=\"Copy code\"", "title=\"Copy code\"",
      "type=\"button\"", "overflow-x:auto", "@rui.button",
    ] {
    assert_showcase_stage_contains(html, expected)
  }
  if html.contains("View Code") ||
    html.contains("rui-showcase-demo-code-summary") ||
    html.contains("Hide Code") ||
    html.contains("rui-showcase-demo-code-hide") ||
    html.contains("max-height:18rem") {
    fail(
      "short showcase code must remain fully visible without a disclosure control",
    )
  }
}

///|
test "five-line showcase code uses one-way reveal and copy action" {
  let html = render_showcase_stage(
    showcase_stage(@html.span("Demo"), "one\ntwo\nthree\nfour\nfive"),
  )
  for
    expected in [
      "rui-showcase-demo-code-summary", "View Code", "rui-showcase-demo-code-panel",
      "rui-showcase-demo-code-copy", "aria-label=\"Copy code\"",
    ] {
    assert_showcase_stage_contains(html, expected)
  }
  if html.contains("rui-showcase-demo-code--expanded") {
    fail("five-line showcase code must keep the disclosure")
  }
}

///|
test "catalog rail reserves a focus-ring gutter" {
  assert_showcase_stage_contains(CatalogRailStyle, "padding-block:0.25rem")
  assert_showcase_stage_contains(
    CatalogRailStyle,
    "padding-inline:0.25rem 1rem",
  )
  assert_showcase_stage_contains(
    CatalogRailLinkStyle,
    "padding:0.375rem 0.625rem",
  )
  assert_showcase_stage_contains(CatalogRailLinkStyle, "width:fit-content")
}

///|
test "sidebar variants render as independent full-stage examples" {
  let html = render_showcase_stage(
    ig_sidebar_component(
      @html.span("default-demo"),
      @html.span("fixed-demo"),
      @html.span("icon-demo"),
      @html.span("loading-demo"),
      @html.span("floating-demo"),
      @html.span("inset-demo"),
      @html.span("right-demo"),
      @html.span("resize-demo"),
      @html.span("mobile-demo"),
    ),
  )
  assert_showcase_component_stages(html, "component-Sidebar", [
    "Default", "Fixed", "Icon-collapse", "Loading", "Floating", "Inset", "Right-side",
    "Resize", "Mobile",
  ])
  for
    expected in [
      "default-demo", "fixed-demo", "icon-demo", "loading-demo", "floating-demo",
      "inset-demo", "right-demo", "resize-demo", "mobile-demo", "padding:0",
    ] {
    assert_showcase_stage_contains(html, expected)
  }
}

///|
test "sidebar stages render the intended public API compositions" {
  let html = render_showcase_incremental(() => ig_navigation_page("sidebar"))
  let sidebar_html = showcase_component_tail(html, "component-Sidebar")
  for
    expected in [
      "showcase-sidebar-default", "showcase-sidebar-fixed", "showcase-sidebar-icon",
      "showcase-sidebar-loading", "showcase-sidebar-floating", "showcase-sidebar-inset",
      "showcase-sidebar-right", "showcase-sidebar-resize", "showcase-sidebar-mobile",
      "M15 3v18", "min_width=192", "mobile=true", "SidebarMenuSm", "SidebarMenuLg",
      "data-slot=\"sidebar-group-action\"", "data-slot=\"sidebar-menu-skeleton\"",
    ] {
    assert_showcase_stage_contains(sidebar_html, expected)
  }
  assert_eq(sidebar_html.split("data-slot=\"sidebar-wrapper\"").count(), 10)
  assert_eq(sidebar_html.split("data-slot=\"sidebar-inset\"").count(), 2)
  assert_eq(sidebar_html.split("role=\"main\"").count(), 2)
}

///|
test "sidebar code belongs to one variant and only inset uses sidebar_inset" {
  let examples = [
    (IgSidebarDefaultCode, "showcase-sidebar-default"),
    (IgSidebarFixedCode, "showcase-sidebar-fixed"),
    (IgSidebarIconCode, "showcase-sidebar-icon"),
    (IgSidebarLoadingCode, "showcase-sidebar-loading"),
    (IgSidebarFloatingCode, "showcase-sidebar-floating"),
    (IgSidebarRightCode, "showcase-sidebar-right"),
    (IgSidebarResizeCode, "showcase-sidebar-resize"),
    (IgSidebarMobileCode, "showcase-sidebar-mobile"),
  ]
  for example in examples {
    let (code, id) = example
    assert_showcase_stage_contains(code, id)
    if code.contains("sidebar_inset") || code.contains("sidebar_variant(") {
      fail("non-inset sidebar code must contain only its rendered composition")
    }
  }
  assert_showcase_stage_contains(IgSidebarInsetCode, "showcase-sidebar-inset")
  assert_showcase_stage_contains(IgSidebarInsetCode, "@rui.sidebar_inset")
  assert_showcase_stage_contains(IgSidebarRightCode, "panel_right_icon()")
  assert_showcase_stage_contains(IgSidebarResizeCode, "min_width=192")
  assert_showcase_stage_contains(IgSidebarResizeCode, "max_width=352")
  assert_showcase_stage_contains(IgSidebarMobileCode, "mobile=true")
  assert_showcase_stage_contains(IgSidebarFixedCode, "SidebarFixed")
  assert_showcase_stage_contains(IgSidebarFixedCode, "SidebarMenuSm")
  assert_showcase_stage_contains(IgSidebarFloatingCode, "SidebarMenuLg")
  assert_showcase_stage_contains(
    IgSidebarSharedCode,
    "sidebar_menu_skeleton(show_icon=true)",
  )
  assert_showcase_stage_contains(
    IgSidebarLoadingCode,
    "sidebar_loading_navigation()",
  )
  if IgSidebarFixedCode.contains("sidebar_trigger") ||
    IgSidebarFixedCode.contains("sidebar_rail") {
    fail("fixed sidebar code must not advertise controls that cannot change it")
  }
  assert_showcase_stage_contains(IgSidebarSharedCode, "on_click=close_command")
  assert_showcase_stage_contains(
    IgSidebarSharedCode,
    "@rui.sidebar_menu_button(href=\"#projects\"",
  )
  assert_showcase_stage_contains(
    IgSidebarSharedCode,
    "Projects and longer workspace names",
  )
  assert_showcase_stage_contains(IgSidebarSharedCode, "@rui.sidebar_menu_sub")
  assert_eq(IgSidebarSharedCode.split("is_active=true").count(), 2)
  if IgSidebarVariantFrameStyle.contains("border:") ||
    IgSidebarVariantFrameStyle.contains("border-radius:") {
    fail(
      "sidebar provider must not draw a second frame inside the showcase stage",
    )
  }
}

///|
test "fixed sidebar specimen omits ineffective controls" {
  let html = render_showcase_incremental(() => {
    ig_sidebar_variant(
      "showcase-sidebar-fixed-test",
      SidebarLeft,
      SidebarDefault,
      SidebarFixed,
      false,
      SidebarMenuDefault,
      false,
      false,
      false,
    )
  })
  for slot in ["sidebar-trigger", "sidebar-rail", "sidebar-menu-action"] {
    if html.contains("data-slot=\"\{slot}\"") {
      fail(
        "fixed sidebar specimen must not render ineffective `\{slot}` controls",
      )
    }
  }
}

///|
test "pagination and carousel variants render as independent stages" {
  let pagination_html = render_showcase_incremental(() => {
    ig_navigation_page("pagination")
  })
  let carousel_html = render_showcase_incremental(() => {
    ig_navigation_page("carousel")
  })
  assert_showcase_component_stages(pagination_html, "component-Pagination", [
    "Default", "Compact",
  ])
  assert_showcase_component_stages(carousel_html, "component-Carousel", [
    "Horizontal", "Vertical",
  ])
  for
    entry in [
      (IgPaginationDefaultCode, "pagination_ellipsis"),
      (IgPaginationCompactCode, "size=@rui.Sm"),
      (IgCarouselHorizontalCode, "loop_=true"),
      (IgCarouselVerticalCode, "default_index=1"),
    ] {
    let (code, expected) = entry
    assert_showcase_stage_contains(code, expected)
    if code.contains("ig_specimen") {
      fail("split showcase code must contain only its rendered example")
    }
  }
}

///|
test "resizable variants render as independent stages" {
  let resizable_html = render_showcase_incremental(() => {
    ig_feedback_page("resizable")
  })
  assert_showcase_component_stages(resizable_html, "component-Resizable", [
    "Horizontal-multi-panel", "Vertical-two-panel",
  ])
  for
    entry in [
      (IgResizableHorizontalCode, "resizable_group_handle"),
      (IgResizableVerticalCode, "resizable_panel_group"),
    ] {
    let (code, expected) = entry
    assert_showcase_stage_contains(code, expected)
    if code.contains("ig_specimen") {
      fail("split resizable code must contain only its rendered example")
    }
  }
}

///|
test "scroll area variants render as independent stages" {
  let html = render_showcase_stage(
    ig_scroll_area_component(
      @html.span("vertical-scroll-demo"),
      @html.span("horizontal-scroll-demo"),
    ),
  )
  assert_showcase_component_stages(html, "component-Scroll-Area", [
    "Vertical", "Horizontal",
  ])
  for expected in ["vertical-scroll-demo", "horizontal-scroll-demo"] {
    assert_showcase_stage_contains(html, expected)
  }
  for
    entry in [
      (IgScrollAreaVerticalCode, "orientation=@rui.Vertical"),
      (IgScrollAreaHorizontalCode, "orientation=@rui.Horizontal"),
    ] {
    let (code, expected) = entry
    assert_showcase_stage_contains(code, expected)
    if code.contains("ig_specimen") {
      fail("split scroll area code must contain only its rendered example")
    }
  }
}

///|
test "slider variants render as independent stages" {
  let html = render_showcase_stage(
    forms_slider_component(
      @html.span("default-slider-demo"),
      @html.span("range-slider-demo"),
      @html.span("vertical-slider-demo"),
    ),
  )
  assert_showcase_component_stages(html, "component-Slider", [
    "Default", "Range", "Vertical",
  ])
  for
    expected in [
      "default-slider-demo", "range-slider-demo", "vertical-slider-demo",
    ] {
    assert_showcase_stage_contains(html, expected)
  }
  for
    entry in [
      (FormsSliderDefaultCode, "@rui.slider("),
      (FormsSliderRangeCode, "@rui.slider_values("),
      (FormsSliderVerticalCode, "orientation=@rui.Vertical"),
    ] {
    let (code, expected) = entry
    assert_showcase_stage_contains(code, expected)
    if code.contains("FormsGalleryFormGridStyle") || code.contains("view4") {
      fail("split slider code must contain only its rendered example")
    }
  }
}

///|
test "menu showcases render independent stages with matching code actions" {
  let context_menu_html = render_showcase_incremental(() => {
    ig_overlay_page("context-menu")
  })
  let dropdown_menu_html = render_showcase_incremental(() => {
    ig_overlay_page("dropdown-menu")
  })
  let menubar_html = render_showcase_incremental(() => {
    ig_overlay_page("menubar")
  })
  assert_menu_showcase_component(context_menu_html, "component-Context-Menu", [
    "Actions-shortcuts", "Submenu-destructive-action", "Checkbox-items", "Radio-group",
  ])
  assert_menu_showcase_component(
    dropdown_menu_html,
    "component-Dropdown-Menu",
    [
      "Basic-groups", "Leading-icons", "Checkbox-items", "Radio-group", "Submenu-placement",
      "Multi-level-submenu",
    ],
  )
  for
    marker in [
      "showcase-dropdown-menu-multilevel", "Move to", "Projects", "Project destination",
    ] {
    assert_showcase_stage_contains(dropdown_menu_html, marker)
  }
  assert_eq(
    IgDropdownMenuMultiLevelCode.split("@rui.dropdown_menu_sub(").count(),
    3,
  )
  for
    marker in [
      "showcase_folder_icon()", "showcase_folder_open_icon()", "showcase_layout_icon()",
      "showcase_activity_icon()",
    ] {
    assert_showcase_stage_contains(
      ig_menu_code(
        IgDropdownMenuMultiLevelIconsCode,
        IgDropdownMenuMultiLevelCode,
      ),
      marker,
    )
  }
  assert_menu_showcase_component(menubar_html, "component-Menubar", [
    "Application-commands", "Submenu-destructive-action", "Checkbox-items", "Radio-group",
  ])
}

///|
test "navigation variants expose one stage and copy action per example" {
  let breadcrumb_html = render_showcase_stage(ig_breadcrumb_demo())
  assert_showcase_component_stages(breadcrumb_html, "component-Breadcrumb", [
    "Default", "Condensed",
  ])
  let accordion_html = render_showcase_stage(
    ig_accordion_component(@html.span("single"), @html.span("multiple")),
  )
  assert_showcase_component_stages(accordion_html, "component-Accordion", [
    "Single", "Multiple",
  ])
  let tabs_html = render_showcase_stage(
    ig_tabs_component(
      @html.span("default"),
      @html.span("line"),
      @html.span("vertical"),
      @html.span("disabled"),
      @html.span("icons"),
    ),
  )
  assert_showcase_component_stages(tabs_html, "component-Tabs", [
    "Default", "Line", "Vertical", "Disabled", "Icons",
  ])
  let collapsible_html = render_showcase_stage(
    ig_collapsible_component(
      @html.span("order"),
      @html.span("basic"),
      @html.span("settings"),
      @html.span("file-tree"),
    ),
  )
  assert_showcase_component_stages(collapsible_html, "component-Collapsible", [
    "Order-details", "Basic", "Settings-panel", "File-tree",
  ])
  for
    code in [
      IgCollapsibleOrderCode,
      IgCollapsibleBasicCode,
      IgCollapsibleSettingsCode,
      IgCollapsibleFileTreeCode,
    ] {
    assert_false(code.contains("ig_collapsible"))
    assert_false(code.contains("IgCollapsible"))
    assert_false(code.contains("MutedStyle"))
  }
  assert_true(IgCollapsibleFileTreeCode.contains("@rabbita.create_variable"))
  assert_true(IgCollapsibleFileTreeCode.contains("components/ui"))
  assert_true(IgCollapsibleFileTreeCode.contains("@rui.tabs("))
  assert_true(IgCollapsibleFileTreeCode.contains("@rui.card("))
  assert_true(IgCollapsibleFileTreeCode.contains("label=\"Explorer\""))
  assert_true(IgCollapsibleFileTreeCode.contains("label=\"Outline\""))
  let navigation_menu_html = render_showcase_stage(
    ig_navigation_menu_component(@html.span("viewport"), @html.span("inline")),
  )
  assert_showcase_component_stages(
    navigation_menu_html,
    "component-Navigation-Menu",
    ["Viewport", "Inline"],
  )
}

///|
test "component page registry is stable and unique" {
  assert_eq(showcase_page_entries.length(), 64)
  assert_eq(showcase_page_entries[0].slug, "accordion")
  assert_eq(showcase_page_entries[63].slug, "typography")
  for index = 0; index < showcase_page_entries.length(); index = index + 1 {
    let entry = showcase_page_entries[index]
    assert_true(entry.slug != "")
    assert_true(entry.title != "")
    assert_eq(showcase_page_index_by_slug(entry.slug), index)
    assert_eq(showcase_page_index_by_title(entry.title), index)
    for other = index + 1
        other < showcase_page_entries.length()
        other = other + 1 {
      assert_true(entry.slug != showcase_page_entries[other].slug)
      assert_true(entry.title != showcase_page_entries[other].title)
    }
  }
}

///|
test "a selected interaction page renders only its component" {
  let html = render_showcase_incremental(() => ig_overlay_page("dropdown-menu"))
  assert_eq(html.split("class=\"rui-showcase-component\"").count(), 2)
  assert_true(html.contains("id=\"component-Dropdown-Menu\""))
  assert_false(html.contains("id=\"component-Context-Menu\""))
  assert_false(html.contains("id=\"component-Menubar\""))
  assert_showcase_component_stages(html, "component-Dropdown-Menu", [
    "Basic-groups", "Leading-icons", "Checkbox-items", "Radio-group", "Submenu-placement",
    "Multi-level-submenu",
  ])
}

///|
test "top and bottom component pagers share one neighbour mapping" {
  let button_html = render_showcase_stage(foundations_button_demo())
  assert_eq(button_html.split("aria-label=\"Component pages\"").count(), 3)
  assert_eq(button_html.split("aria-label=\"Previous: Bubble\"").count(), 3)
  assert_eq(button_html.split("aria-label=\"Next: Button Group\"").count(), 3)
  assert_eq(button_html.split("/components/bubble/").count(), 3)
  assert_eq(button_html.split("/components/button-group/").count(), 3)
  let first_html = render_showcase_incremental(() => {
    ig_navigation_page("accordion")
  })
  assert_eq(first_html.split("aria-label=\"Component pages\"").count(), 3)
  assert_eq(first_html.split("aria-label=\"Next: Alert\"").count(), 3)
  assert_false(first_html.contains("aria-label=\"Previous:"))
  let last_html = render_showcase_stage(fdv_typography_demo())
  assert_eq(last_html.split("aria-label=\"Component pages\"").count(), 3)
  assert_eq(last_html.split("aria-label=\"Previous: Tooltip\"").count(), 3)
  assert_false(last_html.contains("aria-label=\"Next:"))
}

///|
test "components page marks one catalogue link and mounts one component" {
  let html = render_showcase_incremental(() => {
    components_page(@rabbita.Val::constant(false), "button")
  })
  assert_eq(html.split("class=\"rui-showcase-component\"").count(), 2)
  assert_eq(html.split("aria-current=\"page\"").count(), 3)
  assert_true(html.contains("id=\"component-Button\""))
  assert_false(html.contains("id=\"component-Badge\""))
  assert_false(html.contains("id=\"component-Button-Group\""))
}

///|
test "file tree preserves nested folder state while a parent is closed" {
  let initial = ["components", "components/ui", "lib"]
  let parent_closed = ig_collapsible_next_open_paths(
    initial, "components", false,
  )
  assert_false(parent_closed.contains("components"))
  assert_true(parent_closed.contains("components/ui"))
  let parent_reopened = ig_collapsible_next_open_paths(
    parent_closed, "components", true,
  )
  assert_true(parent_reopened.contains("components"))
  assert_true(parent_reopened.contains("components/ui"))
  assert_eq(parent_reopened.filter(path => path == "components").length(), 1)

  let html = render_showcase_incremental(ig_collapsible_file_tree_view)
  assert_showcase_stage_contains(html, "data-path=\"components\"")
  assert_showcase_stage_contains(html, "data-path=\"components/ui\"")
  assert_showcase_stage_contains(html, "aria-label=\"File tree view\"")
  assert_showcase_stage_contains(html, ">Explorer</button>")
  assert_showcase_stage_contains(html, ">Outline</button>")
  assert_showcase_stage_contains(html, "data-slot=\"card\"")
  assert_showcase_stage_contains(
    html, "id=\"showcase-file-tree-components/ui-trigger\"",
  )
  assert_showcase_stage_contains(html, "aria-expanded=\"true\"")
  assert_showcase_stage_contains(html, "data-path=\"public\"")
  assert_showcase_stage_contains(html, "aria-expanded=\"false\"")
}

///|
test "overlay variants expose one stage and copy action per example" {
  let alert_dialog_html = render_showcase_stage(
    ig_alert_dialog_component(@html.span("default"), @html.span("destructive")),
  )
  assert_showcase_component_stages(
    alert_dialog_html,
    "component-Alert-Dialog",
    ["Default", "Destructive"],
  )
  let dialog_html = render_showcase_stage(
    ig_dialog_component(@html.span("modal"), @html.span("nonmodal")),
  )
  assert_showcase_component_stages(dialog_html, "component-Dialog", [
    "Modal", "Non-modal",
  ])
  let drawer_html = render_showcase_stage(
    ig_drawer_component(
      @html.span("top"),
      @html.span("right"),
      @html.span("bottom"),
      @html.span("left"),
    ),
  )
  assert_showcase_component_stages(drawer_html, "component-Drawer", [
    "Top", "Right", "Bottom", "Left",
  ])
  let command_html = render_showcase_stage(
    ig_command_component(@html.span("inline"), @html.span("dialog")),
  )
  assert_showcase_component_stages(command_html, "component-Command", [
    "Inline", "Dialog",
  ])
  let popover_html = render_showcase_stage(
    ig_popover_component(@html.span("bottom"), @html.span("right")),
  )
  assert_showcase_component_stages(popover_html, "component-Popover", [
    "Bottom-start", "Right-center",
  ])
  let hover_card_html = render_showcase_stage(
    ig_hover_card_component(@html.span("top"), @html.span("left")),
  )
  assert_showcase_component_stages(hover_card_html, "component-Hover-Card", [
    "Top-center", "Left-end",
  ])
  let tooltip_html = render_showcase_stage(
    ig_tooltip_component(
      @html.span("top"),
      @html.span("right"),
      @html.span("bottom"),
      @html.span("left"),
    ),
  )
  assert_showcase_component_stages(tooltip_html, "component-Tooltip", [
    "Top-start", "Right-center", "Bottom-end", "Left-center",
  ])
  let sheet_html = render_showcase_stage(
    ig_sheet_component(
      @html.span("top"),
      @html.span("right"),
      @html.span("bottom"),
      @html.span("left"),
    ),
  )
  assert_showcase_component_stages(sheet_html, "component-Sheet", [
    "Top", "Right", "Bottom", "Left",
  ])
}

///|
test "notification variants expose independent stages" {
  let sonner_html = render_showcase_stage(
    ig_sonner_component(
      @html.span("default"),
      @html.span("success"),
      @html.span("destructive"),
      @html.span("queue"),
    ),
  )
  assert_showcase_component_stages(sonner_html, "component-Sonner", [
    "Default", "Success", "Destructive", "Queue-dismissal",
  ])
  let toast_html = render_showcase_stage(ig_toast_component())
  assert_showcase_component_stages(toast_html, "component-Toast", [
    "Default", "Success", "Destructive",
  ])
}

///|
test "form controls expose one stage and copy action per variant" {
  let input_html = render_showcase_incremental(() => {
    showcase_forms_page("input")
  })
  assert_showcase_component_stages(input_html, "component-Input", [
    "Text", "Email", "Disabled",
  ])
  let textarea_html = render_showcase_incremental(() => {
    showcase_forms_page("textarea")
  })
  assert_showcase_component_stages(textarea_html, "component-Textarea", [
    "Default", "Invalid", "Disabled",
  ])
  let field_html = render_showcase_incremental(() => {
    showcase_forms_page("field")
  })
  assert_showcase_component_stages(field_html, "component-Field", [
    "Complete-form-composition", "Horizontal", "Responsive", "Fieldset-and-legend",
  ])
  let radio_html = render_showcase_incremental(() => {
    showcase_forms_page("radio-group")
  })
  assert_showcase_component_stages(radio_html, "component-Radio-Group", [
    "Horizontal", "Vertical",
  ])
  let date_picker_html = render_showcase_incremental(date_picker_showcase)
  assert_showcase_component_stages(date_picker_html, "component-Date-Picker", [
    "Single-date-with-presets", "Date-range", "Disabled", "Invalid",
  ])
}

///|
test "form variant pages keep every copied example independent" {
  let checkbox_html = render_showcase_incremental(() => {
    showcase_forms_page("checkbox")
  })
  assert_showcase_component_stages(checkbox_html, "component-Checkbox", [
    "Mixed", "Invalid", "Disabled",
  ])
  let switch_html = render_showcase_incremental(() => {
    showcase_forms_page("switch")
  })
  assert_showcase_component_stages(switch_html, "component-Switch", [
    "Default", "Small", "Invalid", "Disabled",
  ])
  let combobox_html = render_showcase_incremental(() => {
    showcase_forms_page("combobox")
  })
  assert_showcase_component_stages(combobox_html, "component-Combobox", [
    "Multiple", "Grouped", "Empty-result", "Invalid", "Disabled",
  ])
  let select_html = render_showcase_incremental(() => {
    showcase_forms_page("select")
  })
  assert_showcase_component_stages(select_html, "component-Select", [
    "Compound-collection", "Invalid", "Disabled",
  ])
  let input_group_html = render_showcase_incremental(() => {
    showcase_forms_page("input-group")
  })
  assert_showcase_component_stages(input_group_html, "component-Input-Group", [
    "Basic", "Inline-start", "Inline-end", "Block-start-input", "Block-start-textarea",
    "Block-end-input", "Block-end-textarea", "Icon-search", "Icon-email", "Icons-card-validation",
    "Icons-metadata", "Text-currency", "Text-URL", "Text-username-suffix", "Text-character-count",
    "Button-copy", "Buttons-connection-actions", "Button-search", "Keyboard-shortcut",
    "Dropdown-icon-trigger", "Dropdown-text-trigger", "Spinner-trailing", "Spinner-leading",
    "Spinner-status-text", "Spinner-dual-status", "Textarea-toolbar", "Custom-control",
  ])
  for
    marker in [
      "forms-variants-input-group-block-start-textarea", "forms-variants-input-group-icon-metadata",
      "forms-variants-input-group-secure", "forms-variants-input-group-query", "forms-variants-input-group-spinner-status",
      "forms-variants-input-group-custom",
    ] {
    assert_showcase_stage_contains(input_group_html, marker)
  }
  for
    recipe in [
      (
        FormsInputGroupBlockStartTextareaCode,
        "forms-variants-input-group-block-start-textarea",
      ),
      (
        FormsInputGroupIconMetadataCode,
        "forms-variants-input-group-icon-metadata",
      ),
      (
        FormsInputGroupConnectionButtonsCode,
        "forms-variants-input-group-secure",
      ),
      (FormsInputGroupDropdownQueryCode, "forms-variants-input-group-query"),
      (
        FormsInputGroupSpinnerStatusCode,
        "forms-variants-input-group-spinner-status",
      ),
      (FormsInputGroupCustomControlCode, "forms-variants-input-group-custom"),
    ] {
    let (code, marker) = recipe
    assert_showcase_stage_contains(code, marker)
  }
  assert_showcase_stage_contains(
    FormsInputGroupCustomControlCode,
    "@rui.input_group_control",
  )
  if FormsInputGroupCustomControlCode.contains("data_set(\"slot\"") {
    fail("custom Input Group recipe must use the public black-box adapter")
  }
  let native_select_html = render_showcase_incremental(() => {
    showcase_forms_page("native-select")
  })
  assert_showcase_component_stages(
    native_select_html,
    "component-Native-Select",
    ["Default-with-groups", "Small", "Invalid", "Disabled"],
  )
  let otp_html = render_showcase_incremental(() => {
    showcase_forms_page("input-otp")
  })
  assert_showcase_component_stages(otp_html, "component-Input-OTP", [
    "Default", "Pattern", "2-2-2-Separator", "3-3", "4-4", "Four-Digits", "Alphanumeric",
    "Invalid-and-editable", "Disabled", "Form",
  ])
  if FormsOtpContinuousCode.contains("separator_after") {
    fail("Default Input OTP recipe must not render a separator")
  }
  assert_eq(FormsOtpSeparatorCode.split("@rui.input_otp_separator").count(), 3)
  assert_showcase_stage_contains(FormsOtpAlphanumericCode, "inputmode=\"text\"")
  assert_showcase_stage_contains(FormsOtpFormCode, "@rui.card(")
}

///|
test "foundation variants expose one stage and copy action per example" {
  assert_showcase_component_stages(
    render_showcase_stage(foundations_button_demo()),
    "component-Button",
    [
      "Default", "Secondary", "Outline", "Ghost", "Destructive", "Link", "Large",
      "Default-size", "Small", "Extra-small", "Large-icon", "Default-icon", "Small-icon",
      "Extra-small-icon",
    ],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_badge_demo()),
    "component-Badge",
    ["Default", "Secondary", "Outline", "Destructive", "Ghost", "Link"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(
      foundations_toggle_demo(@html.span("outline"), @html.span("default")),
    ),
    "component-Toggle",
    ["Outline-large", "Default-small"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_label_demo()),
    "component-Label",
    ["Default", "Disabled"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_kbd_demo()),
    "component-Kbd",
    ["Key", "Shortcut"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_spinner_demo()),
    "component-Spinner",
    ["Inline", "In-a-button"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_skeleton_demo()),
    "component-Skeleton",
    ["Default", "Avatar", "Card", "Text", "Form", "Table"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_alert_demo()),
    "component-Alert",
    ["Default", "Destructive"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_message_demo()),
    "component-Message",
    ["Start-aligned", "End-aligned"],
  )
  assert_showcase_component_stages(
    render_showcase_stage(foundations_bubble_demo()),
    "component-Bubble",
    [
      "Default", "Secondary", "Muted", "Tinted", "Outline-link", "Ghost", "Destructive",
    ],
  )
}

///|
test "identity variant pages keep copied examples independent" {
  let avatar_html = render_showcase_incremental(() => {
    showcase_foundations_page("avatar")
  })
  assert_showcase_component_stages(avatar_html, "component-Avatar", [
    "Default", "Small", "Large", "Image-and-badge", "Group-and-count",
  ])
  let card_html = render_showcase_incremental(() => {
    showcase_foundations_page("card")
  })
  assert_showcase_component_stages(card_html, "component-Card", [
    "Default", "Small",
  ])
  let aspect_html = render_showcase_incremental(() => {
    showcase_foundations_page("aspect-ratio")
  })
  assert_showcase_component_stages(aspect_html, "component-Aspect-Ratio", [
    "Square-1-1", "Standard-4-3", "Widescreen-16-9",
  ])
  let separator_html = render_showcase_incremental(() => {
    showcase_foundations_page("separator")
  })
  assert_showcase_component_stages(separator_html, "component-Separator", [
    "Horizontal", "Vertical",
  ])
}

///|
test "data display variant pages keep copied examples independent" {
  let attachment_html = render_showcase_incremental(() => {
    showcase_foundations_page("attachment")
  })
  assert_showcase_component_stages(attachment_html, "component-Attachment", [
    "Image-attachment", "File-attachment", "Idle", "Uploading", "Processing", "Error",
    "Done", "Default-size", "Small", "Extra-small", "Group", "Full-card-trigger",
  ])
  assert_eq(
    attachment_html
    .split("class=\"rui-showcase-attachment-stage-content\"")
    .count(),
    13,
  )
  for
    expected in [
      "width:min(100%,24rem)", "align-items:center", "justify-content:center",
    ] {
    assert_showcase_stage_contains(attachment_html, expected)
  }
  assert_showcase_stage_contains(FdvAttachmentTriggerCode, "width:100%")
  assert_showcase_stage_contains(
    FdvAttachmentGroupCode,
    "Open briefing notes in group",
  )
  assert_showcase_stage_contains(
    FdvAttachmentGroupCode,
    "Open customers in group",
  )
  assert_showcase_stage_contains(
    FdvAttachmentGroupCode,
    "width:100%;max-width:24rem",
  )
  assert_showcase_stage_contains(FdvAttachmentImageCode, "@html.img")
  assert_showcase_stage_contains(FdvAttachmentImageCode, "alt=\"Workspace\"")
  assert_showcase_stage_contains(FdvAttachmentImageCode, "alt=\"Desk\"")
  assert_showcase_stage_contains(FdvAttachmentImageCode, "alt=\"Office\"")
  assert_false(FdvAttachmentImageCode.contains("linear-gradient"))
  assert_eq(attachment_html.split("<img").count(), 4)
  for
    expected in [
      "photo-1497366754035-f200968a6e72", "photo-1497215728101-856f4ea42174", "photo-1497366811353-6870744d04b2",
      "alt=\"Workspace\"", "alt=\"Desk\"", "alt=\"Office\"",
    ] {
    assert_showcase_stage_contains(attachment_html, expected)
  }
  assert_false(
    attachment_html.contains("linear-gradient(145deg,#d7dfeb,#8ba0b5)"),
  )
  assert_showcase_stage_contains(FdvAttachmentUploadingCode, "@rui.spinner")
  assert_showcase_stage_contains(FdvAttachmentUploadingCode, "Cancel upload")
  assert_false(FdvAttachmentProcessingCode.contains("@rui.spinner"))
  assert_showcase_stage_contains(FdvAttachmentProcessingCode, "M16 13H8")
  assert_showcase_stage_contains(
    FdvAttachmentProcessingCode,
    "Remove market-research.pdf",
  )
  assert_showcase_stage_contains(FdvAttachmentErrorCode, "Retry upload")
  let typography_html = render_showcase_incremental(() => {
    showcase_foundations_page("typography")
  })
  assert_showcase_component_stages(typography_html, "component-Typography", [
    "H1", "H2", "H3", "H4", "Paragraph", "Lead", "Large", "Small", "Muted", "Blockquote",
    "List", "Inline-code",
  ])
  let item_html = render_showcase_incremental(() => {
    showcase_foundations_page("item")
  })
  assert_showcase_component_stages(item_html, "component-Item", [
    "Default", "Outline-small", "Muted-image",
  ])
  let empty_html = render_showcase_incremental(() => {
    showcase_foundations_page("empty")
  })
  assert_showcase_component_stages(empty_html, "component-Empty", [
    "Default-media", "Icon-media",
  ])
  let marker_html = render_showcase_incremental(() => {
    showcase_foundations_page("marker")
  })
  assert_showcase_component_stages(marker_html, "component-Marker", [
    "Default", "Separator", "Border",
  ])
  let progress_html = render_showcase_incremental(() => {
    showcase_foundations_page("progress")
  })
  assert_showcase_component_stages(progress_html, "component-Progress", [
    "Indeterminate", "Determinate",
  ])
}
