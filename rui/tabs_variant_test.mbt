///|
test "tabs entries render optional SVG icons through the black-box API" {
  let html = render_incremental(() => {
    @rui.tabs(default_value="preview", aria_label="View mode", items=[
      @rui.tab_entry(
        value="preview",
        label="Preview",
        icon=@svg.svg(width=24, height=24, view_box="0 0 24 24", [
          @svg.path(
            d="M4 4h16v16H4zM4 9h16M9 9v11",
            fill="none",
            stroke="currentColor",
            stroke_width=2,
          ),
        ]),
        content=@html.p("Preview content"),
      ),
    ])
  })
  assert_contains(html, "data-slot=\"tabs-trigger-icon\"")
  assert_contains(
    html, "display:inline-flex;width:1rem;height:1rem;flex:none;align-items:center;justify-content:center;pointer-events:none",
  )
  assert_contains(html, "<svg")
  assert_contains(html, "M4 4h16v16H4zM4 9h16M9 9v11")
  assert_element_tag_contains(
    html, "data-value=\"preview\" role=\"tab\"", "data-state=\"active\"",
  )
  assert_contains(html, "Preview")
}

///|
test "tabs expose the Vega line list variant through the black-box API" {
  let items = [
    @rui.tab_entry(
      value="preview",
      label="Preview",
      content=@html.p("Preview content"),
    ),
    @rui.tab_entry(value="code", label="Code", content=@html.p("Code content")),
  ]
  let html = render_incremental(() => {
    @rui.tabs(items~, default_value="preview", list_variant=TabsLine, list_style=[
      "gap:0.75rem",
    ])
  })
  assert_contains(
    html, "data-slot=\"tabs-list\" data-orientation=\"horizontal\" data-variant=\"line\"",
  )
  assert_contains(
    html, "gap:0.25rem;border-radius:0;background:transparent;overflow:visible;min-height:2.25rem;flex-direction:row;gap:0.75rem",
  )
  assert_element_tag_contains(
    html, "data-value=\"preview\" role=\"tab\"", "data-state=\"active\"",
  )
  assert_contains(
    html, "--rui-tabs-base-shadow:var(--rui-tabs-active-shadow,0 1px 2px rgb(0 0 0 / 0.05))",
  )
}

///|
test "tabs keep the default muted list variant for existing callers" {
  let html = render(
    @rui.tabs_list(@rui.tabs_trigger(value="one", selected=true, "One")),
  )
  assert_contains(html, "data-variant=\"default\"")
  assert_contains(
    html, "background:var(--rui-muted,oklch(0.97 0 0));overflow-x:auto",
  )
}

///|
test "theme supplies line tab indicators without consumer CSS" {
  let html = render(
    @rui.theme(
      @rui.tabs_list(
        variant=TabsLine,
        @rui.tabs_trigger(value="one", selected=true, "One"),
      ),
    ),
  )
  assert_contains(
    html, "[data-slot=\"tabs-list\"][data-variant=\"line\"] > [data-slot=\"tabs-trigger\"]::after",
  )
  assert_contains(html, "--rui-tabs-active-bg:transparent")
  assert_contains(html, "--rui-tabs-active-shadow:none")
  assert_contains(html, "bottom:-5px")
  assert_contains(html, "inset-inline-end:-0.25rem")
  assert_contains(
    html, "[data-slot=\"tabs-trigger\"][data-state=\"active\"]::after",
  )
  assert_not_contains(html, "&gt;")
}
