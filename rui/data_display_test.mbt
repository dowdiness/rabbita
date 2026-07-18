///|
test "avatar exposes Vega composition, sizing, and caller overrides" {
  let html = render(
    @rui.avatar_group([
      @rui.avatar(size=Lg, style=["width:3rem"], [
        @rui.avatar_fallback("YK"),
        @rui.avatar_image(src="/avatar.png", alt="Yorkin", loading="lazy"),
        @rui.avatar_badge(@html.nothing),
      ]),
      @rui.avatar_group_count(size=Lg, "+3"),
    ]),
  )
  assert_contains(html, "data-slot=\"avatar-group\"")
  assert_contains(html, "data-slot=\"avatar\"")
  assert_contains(html, "data-size=\"lg\"")
  assert_contains(html, "data-slot=\"avatar-image\"")
  assert_contains(html, "src=\"/avatar.png\"")
  assert_contains(html, "alt=\"Yorkin\"")
  assert_contains(html, "data-slot=\"avatar-fallback\"")
  assert_contains(html, "data-slot=\"avatar-badge\"")
  assert_contains(html, "data-slot=\"avatar-group-count\"")
  assert_contains(html, "--rui-avatar-size:2.5rem")
  assert_contains(html, "--rui-avatar-badge-size:0.75rem")
  assert_contains(html, "width:3rem")
}

///|
test "avatar black-box owns image loading and fallback state" {
  let html = render_incremental(() => {
    @rui.avatar_with_fallback(
      id="profile-avatar",
      src="/profile.png",
      alt="Profile",
      "PF",
    )
  })
  assert_contains(html, "data-slot=\"avatar\"")
  assert_contains(html, "data-image-state=\"loading\"")
  assert_contains(html, "data-slot=\"avatar-fallback\"")
  assert_contains(html, ">PF</span>")
  assert_contains(html, "id=\"profile-avatar-image\"")
  assert_contains(html, "src=\"/profile.png\"")
  assert_contains(html, "hidden")

  let missing = render_incremental(() => {
    @rui.avatar_with_fallback(id="missing-avatar", src="", "NA")
  })
  assert_contains(missing, "data-image-state=\"error\"")
}

///|
test "progress clamps determinate values and exposes native state" {
  let html = render(
    @rui.progress(
      value=125,
      min=0,
      max=100,
      labelledby="upload-label",
      style=["gap:1rem"],
      children=[
        @rui.progress_label(value=125, id="upload-label", "Upload"),
        @rui.progress_value(value=125),
      ],
    ),
  )
  assert_contains(html, "role=\"progressbar\"")
  assert_contains(html, "aria-labelledby=\"upload-label\"")
  assert_contains(html, "aria-valuemin=\"0\"")
  assert_contains(html, "aria-valuemax=\"100\"")
  assert_contains(html, "aria-valuenow=\"100\"")
  assert_contains(html, "aria-valuetext=\"100%\"")
  assert_contains(html, "data-state=\"complete\"")
  assert_contains(html, "data-complete=\"\"")
  assert_contains(html, "data-slot=\"progress-track\"")
  assert_contains(html, "data-slot=\"progress-indicator\"")
  assert_contains(html, "width:100%")
  assert_contains(html, "gap:1rem")
  assert_contains(html, ">100%</span>")
}

///|
test "progress indeterminate state omits aria-valuenow" {
  let html = render(@rui.progress(aria_label="Loading"))
  assert_contains(html, "data-state=\"indeterminate\"")
  assert_contains(html, "data-indeterminate=\"\"")
  assert_contains(html, "aria-valuetext=\"indeterminate progress\"")
  assert_contains(html, "inline-size:40%")
  assert_contains(html, "inset-inline-start:-40%")
  assert_contains(html, "@keyframes rui-progress-indeterminate")
  assert_contains(html, "@media (prefers-reduced-motion:reduce)")
  assert_not_contains(html, "aria-valuenow")
  let indicator_html = render(@rui.progress_indicator())
  assert_not_contains(indicator_html, "width:")
}

///|
test "progress normalizes a maximum below its minimum" {
  let html = render(@rui.progress(value=7, min=10, max=5))
  assert_contains(html, "aria-valuemin=\"10\"")
  assert_contains(html, "aria-valuemax=\"10\"")
  assert_contains(html, "aria-valuenow=\"10\"")
  assert_contains(html, "aria-valuetext=\"100%\"")
  assert_contains(html, "data-state=\"complete\"")
  assert_contains(html, "width:100%")
}

///|
test "table preserves native semantics and composable slots" {
  let html = render(
    @rui.table(style=["font-size:1rem"], container_style=["max-width:40rem"], [
      @rui.table_caption("Recent invoices"),
      @rui.table_header(
        @rui.table_row([@rui.table_head("Invoice"), @rui.table_head("Amount")]),
      ),
      @rui.table_body(
        @rui.table_row(selected=true, [
          @rui.table_cell("INV-001"),
          @rui.table_cell("$250.00"),
        ]),
      ),
      @rui.table_footer(
        @rui.table_row(@rui.table_cell(colspan=2, "Total $250.00")),
      ),
    ]),
  )
  assert_contains(html, "data-slot=\"table-container\"")
  assert_contains(html, "data-slot=\"table\"")
  assert_contains(html, "data-slot=\"table-header\"")
  assert_contains(html, "data-slot=\"table-body\"")
  assert_contains(html, "data-slot=\"table-footer\"")
  assert_contains(html, "data-slot=\"table-caption\"")
  assert_contains(html, "<th")
  assert_contains(html, "scope=\"col\"")
  assert_contains(html, "<td")
  assert_contains(html, "colspan=\"2\"")
  assert_contains(html, "data-state=\"selected\"")
  assert_contains(
    html, "background:var(--rui-table-row-bg,var(--rui-table-row-base-bg,transparent))",
  )
  assert_contains(
    html, "--rui-table-row-base-bg:var(--rui-muted,oklch(0.97 0 0))",
  )
  assert_contains(html, "font-size:1rem")
  assert_contains(html, "max-width:40rem")

  let expanded_html = render(
    @rui.table_row(expanded=true, @rui.table_cell("Details")),
  )
  assert_contains(expanded_html, "data-expanded=\"\"")
  assert_contains(
    expanded_html, "--rui-table-row-base-bg:color-mix(in oklab,var(--rui-muted,oklch(0.97 0 0)) 50%,transparent)",
  )
  assert_not_contains(expanded_html, "aria-expanded")
}

///|
test "data-display components clone caller attrs" {
  let attrs = @html.Attrs::build().aria_label("Shared")
  ignore(@rui.avatar(attrs~, "A"))
  ignore(@rui.progress(attrs~))
  ignore(@rui.table(attrs~, @rui.table_body(([] : Array[@html.Html]))))
  let original = render(@html.div(attrs~, @html.nothing))
  assert_contains(original, "aria-label=\"Shared\"")
  assert_not_contains(original, "data-slot")
  assert_not_contains(original, "role=\"progressbar\"")
}
