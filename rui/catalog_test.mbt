///|
fn catalog_test_icon(path : String) -> @html.Html {
  @html.span(
    attrs=@html.Attrs::build().aria_hidden("true"),
    @svg.svg(width=16, height=16, view_box="0 0 24 24", [
      @svg.path(
        d=path,
        fill="none",
        stroke="currentColor",
        stroke_width=2,
        attrs=@svg.Attrs::build()
          .stroke_linecap("round")
          .stroke_linejoin("round"),
      ),
    ]),
  )
}

///|
test "Vega catalog content primitives expose stable slots" {
  let html = render(
    @html.div([
      @rui.aspect_ratio(ratio=1.5, "Preview"),
      @rui.direction(direction=@rui.Rtl, "RTL"),
      @rui.spinner(label="Loading"),
      @rui.kbd_group([@rui.kbd("⌘"), @rui.kbd("K")]),
      @rui.empty([
        @rui.empty_header([
          @rui.empty_media(
            variant=@rui.EmptyMediaIcon,
            catalog_test_icon("M12 5v14M5 12h14"),
          ),
          @rui.empty_title("No results"),
          @rui.empty_description("Try another query."),
        ]),
        @rui.empty_content(@rui.button("Create")),
      ]),
      @rui.item_group(
        @rui.item(variant=@rui.ItemOutline, [
          @rui.item_media(
            variant=@rui.ItemMediaIcon,
            catalog_test_icon("M4 4h16v16H4zM4 9h16"),
          ),
          @rui.item_content([
            @rui.item_title("Account"),
            @rui.item_description("Workspace owner"),
          ]),
          @rui.item_actions(@rui.button(size=@rui.Sm, "Open")),
        ]),
      ),
      @rui.marker(variant=@rui.MarkerSeparator, [
        @rui.marker_icon(catalog_test_icon("M12 12h.01")),
        @rui.marker_content("Today"),
      ]),
    ]),
  )
  assert_contains(html, "data-slot=\"aspect-ratio\"")
  assert_contains(html, "aspect-ratio:1.5")
  assert_contains(html, "data-slot=\"direction\"")
  assert_contains(html, "dir=\"rtl\"")
  assert_contains(html, "data-slot=\"spinner\"")
  assert_contains(html, "role=\"status\"")
  assert_contains(html, "data-slot=\"kbd-group\"")
  assert_contains(html, "data-slot=\"empty\"")
  assert_contains(html, "data-slot=\"empty-icon\"")
  assert_contains(html, "data-slot=\"item-group\"")
  assert_contains(html, "data-slot=\"item-actions\"")
  assert_contains(html, "data-slot=\"marker\"")
  assert_contains(html, "data-variant=\"separator\"")
}

///|
test "message attachment and bubble families compose without global CSS" {
  let html = render(
    @html.div([
      @rui.message_group(
        @rui.message(align=@rui.AlignEnd, [
          @rui.message_avatar("Y"),
          @rui.message_content([
            @rui.message_header("Yorkin"),
            @rui.bubble(variant=@rui.BubbleSecondary, [
              @rui.bubble_content("Ship it."),
              @rui.bubble_reactions([
                catalog_test_icon("M20 6 9 17l-5-5"),
                @html.span("2"),
              ]),
            ]),
            @rui.message_footer("Delivered"),
          ]),
        ]),
      ),
      @rui.attachment_group(
        @rui.attachment(
          state=@rui.AttachmentUploading,
          orientation=@rui.AttachmentHorizontal,
          [
            @rui.attachment_media("PDF"),
            @rui.attachment_content([
              @rui.attachment_title("spec.pdf"),
              @rui.attachment_description("42 KB"),
            ]),
            @rui.attachment_actions(
              @rui.attachment_action(
                aria_label="Remove",
                catalog_test_icon("M18 6 6 18M6 6l12 12"),
              ),
            ),
            @rui.attachment_trigger(aria_label="Open spec", "Open"),
          ],
        ),
      ),
    ]),
  )
  assert_contains(html, "data-slot=\"message-group\"")
  assert_contains(html, "data-align=\"end\"")
  assert_contains(html, "data-slot=\"bubble\"")
  assert_contains(html, "data-variant=\"secondary\"")
  assert_contains(html, "data-slot=\"bubble-reactions\"")
  assert_contains(html, "data-slot=\"attachment-group\"")
  assert_contains(html, "data-state=\"uploading\"")
  assert_contains(
    html, "background:var(--rui-attachment-bg,var(--rui-attachment-base-bg,var(--rui-card,var(--rui-background,white))))",
  )
  assert_contains(
    html, "box-shadow:var(--rui-attachment-shadow,var(--rui-attachment-base-shadow,none))",
  )
  assert_contains(html, "data-slot=\"attachment-media\"")
  assert_contains(html, "data-slot=\"attachment-action\"")
  assert_contains(html, "data-slot=\"attachment-trigger\"")

  let error_html = render(
    @rui.attachment(state=@rui.AttachmentError, @html.nothing),
  )
  assert_contains(
    error_html, "--rui-attachment-base-border:color-mix(in oklch,var(--rui-destructive,oklch(0.577 0.245 27.325)) 30%,transparent)",
  )
}

///|
test "field form input-group scroll-area and chart expose the official parts" {
  let html = render(
    @html.div([
      @rui.form(
        @rui.form_item(invalid=true, [
          @rui.form_label(for_="email", "Email"),
          @rui.form_control(
            @rui.input_group(invalid=true, [
              @rui.input_group_addon(for_="email", "@"),
              @rui.input_group_input(id="email", value="hello@example.com"),
              @rui.input_group_button("Copy"),
            ]),
          ),
          @rui.form_description("Used for notifications."),
          @rui.form_message("Already registered."),
        ]),
      ),
      @rui.field_set([
        @rui.field_legend("Profile"),
        @rui.field_group(
          @rui.field(orientation=@rui.FieldHorizontal, [
            @rui.field_label(for_="name", "Name"),
            @rui.field_content(@rui.input(id="name")),
          ]),
        ),
      ]),
      @rui.scroll_area(style=["height:8rem"], [
        @html.p("Scrollable"),
        @rui.scroll_bar(),
      ]),
      @rui.chart_container(aria_label="Revenue", [
        @rui.chart_style(
          variables=[("revenue", "rebeccapurple"), ("--color-cost", "tomato")],
          [
            @rui.chart_tooltip(
              @rui.chart_tooltip_content([
                @rui.chart_tooltip_label("Q2"),
                @rui.chart_tooltip_item(
                  label="Revenue",
                  value="$120k",
                  indicator=@rui.ChartLine,
                ),
              ]),
            ),
            @rui.chart_legend_content(
              @rui.chart_legend_item(color="rebeccapurple", "Revenue"),
            ),
          ],
        ),
      ]),
    ]),
  )
  assert_contains(html, "data-slot=\"form\"")
  assert_contains(html, "data-slot=\"form-item\"")
  assert_contains(html, "data-slot=\"form-label\"")
  assert_contains(html, "data-slot=\"form-description\"")
  assert_contains(html, "data-slot=\"form-message\"")
  assert_contains(html, "data-slot=\"input-group\"")
  assert_contains(html, "data-slot=\"input-group-addon\"")
  assert_contains(
    html, "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 1px 2px rgb(0 0 0 / 0.05)))",
  )
  assert_contains(html, "data-slot=\"field-set\"")
  assert_contains(html, "data-slot=\"field-legend\"")
  assert_contains(html, "data-orientation=\"horizontal\"")
  assert_contains(html, "data-slot=\"scroll-area\"")
  assert_contains(html, "data-slot=\"scroll-area-scrollbar\"")
  assert_contains(html, "data-slot=\"chart\"")
  assert_contains(html, "aria-label=\"Revenue\"")
  assert_contains(html, "data-slot=\"chart-style\"")
  assert_contains(html, "--color-revenue:rebeccapurple")
  assert_contains(html, "--color-cost:tomato")
  assert_contains(html, "data-slot=\"chart-tooltip\"")
  assert_contains(html, "data-slot=\"chart-tooltip-item\"")
  assert_contains(html, "data-indicator=\"line\"")
  assert_contains(html, "data-slot=\"chart-legend-content\"")
  assert_contains(html, "data-slot=\"chart-legend-item\"")
  assert_not_contains(html, "<style")
}

///|
test "stateful catalog components render their incremental initial model" {
  let html = render_incremental(() => {
    let toggle_view = @rui.toggle_group(
      default_values=["bold"],
      multiple=true,
      id="formatting",
      scope => {
        @html.div([
          @rui.toggle_group_item(scope~, value="bold", "B"),
          @rui.toggle_group_item(scope~, value="italic", "I"),
        ])
      },
    )
    let slider_view = @rui.slider(
      id="volume",
      default_value=35,
      aria_label="Volume",
    )
    let otp_view = @rui.input_otp(id="otp", default_value="123", max_length=6)
    let resizable_view = @rui.resizable_panel_group(
      id="split",
      default_size=40,
      scope => {
        @html.div([
          @rui.resizable_panel(scope~, side=@rui.FirstPanel, "A"),
          @rui.resizable_handle(scope~, with_handle=true),
          @rui.resizable_panel(scope~, side=@rui.SecondPanel, "B"),
        ])
      },
    )
    let scroller_view = @rui.message_scroller(id="thread", scope => {
      @html.div([
        @rui.message_scroller_viewport(
          scope~,
          @rui.message_scroller_content(
            @rui.message_scroller_item(scroll_anchor=true, "Latest"),
          ),
        ),
        @rui.message_scroller_button(
          scope~,
          label="Jump to latest message",
          catalog_test_icon("m6 9 6 6 6-6"),
        ),
      ])
    })
    let toaster_view = @rui.toaster(scope => {
      @html.button(
        type_="button",
        on_click=scope.show(title="Saved", description="Changes persisted"),
        "Notify",
      )
    })
    toggle_view.view6(
      slider_view,
      otp_view,
      resizable_view,
      scroller_view,
      toaster_view,
      (
        toggle_html,
        slider_html,
        otp_html,
        resizable_html,
        scroller_html,
        toaster_html,
      ) => {
        @html.div([
          toggle_html, slider_html, otp_html, resizable_html, scroller_html, toaster_html,
        ])
      },
    )
  })
  assert_contains(html, "data-slot=\"toggle-group\"")
  assert_contains(html, "data-state=\"on\"")
  assert_contains(html, "data-slot=\"slider\"")
  assert_contains(html, "data-value=\"35\"")
  assert_contains(html, "type=\"range\"")
  assert_contains(html, "data-slot=\"input-otp\"")
  assert_contains(html, "value=\"123\"")
  assert_contains(html, "data-slot=\"resizable-panel-group\"")
  assert_contains(html, "data-size=\"40\"")
  assert_contains(html, "data-slot=\"resizable-handle\"")
  assert_contains(html, "aria-orientation=\"horizontal\"")
  assert_contains(html, "data-slot=\"message-scroller\"")
  assert_contains(html, "data-slot=\"message-scroller-button\"")
  assert_contains(
    html, "--rui-message-scroller-shift:100%;--rui-message-scroller-scale:0.95",
  )
  assert_contains(
    html, "--rui-button-base-border:var(--rui-border,oklch(0.922 0 0))",
  )
  assert_contains(html, "--rui-button-base-bg:var(--rui-background,white)")
  assert_contains(
    html, "--rui-button-base-fg:var(--rui-foreground,oklch(0.145 0 0))",
  )
  assert_not_contains(
    html, "transform:translateX(-50%);border-color:var(--rui-border",
  )
  assert_contains(html, "data-slot=\"toaster\"")
}

///|
test "message scroller initial position matches its requested edge" {
  let html = render_incremental(() => {
    @rui.message_scroller(id="initial-thread", default_at_end=true, scope => {
      @html.div([
        @rui.message_scroller_viewport(scope~, "Messages"),
        @rui.message_scroller_button(
          scope~,
          direction=@rui.ScrollStart,
          label="Jump to first message",
          catalog_test_icon("m18 15-6-6-6 6"),
        ),
        @rui.message_scroller_button(
          scope~,
          direction=@rui.ScrollEnd,
          label="Jump to latest message",
          catalog_test_icon("m6 9 6 6 6-6"),
        ),
      ])
    })
  })
  assert_contains(html, "data-at-start=\"false\"")
  assert_contains(html, "data-at-end=\"true\"")
  assert_contains(html, "data-direction=\"start\"")
  assert_contains(html, "data-active=\"true\"")
  assert_contains(html, "data-direction=\"end\"")
}
