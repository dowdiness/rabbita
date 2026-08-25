///|
fn semantic_actions_fixture() -> Val[Html] {
  let (action, set_action) = @rabbita.create_variable("none")
  action.view(action => {
    fixture_section("fixture-section-semantic-actions", "Alerts and Actions", [
      @rui.alert(id="fixture-alert", [
        @rui.alert_title("Fixture deployment ready"),
        @rui.alert_description("All semantic checks completed."),
        @rui.alert_action(
          @rui.button(
            size=Sm,
            on_click=set_action(_ => "alert-acknowledged"),
            "Acknowledge fixture alert",
          ),
        ),
      ]),
      @rui.button_group(
        id="fixture-button-group",
        aria_label="Fixture edit actions",
        [
          @rui.button(
            variant=Outline,
            on_click=set_action(_ => "saved"),
            "Save fixture",
          ),
          @rui.button_group_separator(),
          @rui.button(
            variant=Outline,
            disabled=true,
            on_click=set_action(_ => "deleted"),
            "Delete fixture",
          ),
        ],
      ),
      @rui.attachment(id="fixture-attachment", state=AttachmentUploading, [
        @rui.attachment_media(@rui.spinner(label="Uploading fixture file")),
        @rui.attachment_content([
          @rui.attachment_title("fixture-report.pdf"),
          @rui.attachment_description("Uploading · 42%"),
        ]),
        @rui.attachment_actions(
          @rui.attachment_action(
            aria_label="Cancel fixture upload",
            on_click=set_action(_ => "upload-cancelled"),
            "×",
          ),
        ),
      ]),
      @html.output(id="fixture-semantic-actions-output", action),
    ])
  })
}

///|
fn semantic_avatar_fixture() -> Val[Html] {
  let loaded = @rui.avatar_with_fallback(
    id="fixture-avatar-loaded",
    src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==",
    alt="Loaded fixture avatar",
    "LA",
  )
  let failed = @rui.avatar_with_fallback(
    id="fixture-avatar-failed",
    src="data:image/png;base64,not-a-real-image",
    alt="Failed fixture avatar",
    "FA",
  )
  loaded.map2(failed, fn(loaded, failed) {
    fixture_section("fixture-section-semantic-media", "Media and Direction", [
      loaded,
      failed,
      @rui.aspect_ratio(
        ratio=2.0,
        id="fixture-aspect-ratio",
        style=["width:16rem;background:var(--rui-muted,oklch(0.97 0 0))"],
        span("2:1 fixture surface"),
      ),
      @rui.direction(
        direction=Rtl,
        id="fixture-direction-rtl",
        "واجهة الاختبار",
      ),
    ])
  })
}

///|
fn semantic_navigation_fixture() -> Html {
  fixture_section(
    "fixture-section-semantic-navigation",
    "Navigation Semantics",
    [
      @rui.breadcrumb(
        aria_label="Fixture breadcrumb",
        @rui.breadcrumb_list([
          @rui.breadcrumb_item(
            @rui.breadcrumb_link(href="#fixture-main", "Fixtures"),
          ),
          @rui.breadcrumb_separator(),
          @rui.breadcrumb_item(@rui.breadcrumb_page("Semantic components")),
        ]),
      ),
      @rui.pagination(
        aria_label="Fixture pagination",
        @rui.pagination_content([
          @rui.pagination_item(
            @rui.pagination_previous(href="#fixture-main", disabled=true),
          ),
          @rui.pagination_item(
            @rui.pagination_link(
              href="#fixture-main",
              is_active=true,
              aria_label="Fixture page 1",
              "1",
            ),
          ),
          @rui.pagination_item(@rui.pagination_ellipsis()),
          @rui.pagination_item(
            @rui.pagination_next(href="#fixture-section-semantic-data"),
          ),
        ]),
      ),
      @rui.badge(variant=Secondary, "Semantic badge"),
      @rui.badge_link(
        href="#fixture-main",
        disabled=true,
        aria_label="Unavailable fixture badge",
        "Unavailable",
      ),
      @rui.marker(variant=MarkerBorder, [
        @rui.marker_icon("●"),
        @rui.marker_content("Fixture milestone"),
      ]),
    ],
  )
}

///|
fn semantic_compositions_fixture() -> Html {
  fixture_section(
    "fixture-section-semantic-compositions",
    "Content Compositions",
    [
      @rui.card(id="fixture-card", style=["width:18rem"], [
        @rui.card_header([
          @rui.card_title("Fixture card"),
          @rui.card_description("A complete card composition."),
        ]),
        @rui.card_content("Stable component content"),
        @rui.card_footer(@rui.badge(variant=Outline, "Ready")),
      ]),
      @rui.empty(id="fixture-empty", style=["width:18rem"], [
        @rui.empty_header([
          @rui.empty_media(variant=EmptyMediaIcon, "∅"),
          @rui.empty_title("No fixture results"),
          @rui.empty_description("Try another semantic query."),
        ]),
        @rui.empty_content(
          @rui.button(variant=Outline, "Reset fixture filters"),
        ),
      ]),
      @rui.item_group(
        id="fixture-item-group",
        style=["width:18rem"],
        @rui.item([
          @rui.item_media(variant=ItemMediaIcon, "F"),
          @rui.item_content([
            @rui.item_title("Fixture item"),
            @rui.item_description("Item description"),
          ]),
        ]),
      ),
      @rui.message(id="fixture-message", align=AlignEnd, [
        @rui.message_avatar(@rui.avatar(@rui.avatar_fallback("RU"))),
        @rui.message_content([
          @rui.message_header("RUI fixture"),
          @rui.bubble_group(
            @rui.bubble(
              variant=BubbleSecondary,
              align=AlignEnd,
              @rui.bubble_content("Semantic message bubble"),
            ),
          ),
          @rui.message_footer("Delivered"),
        ]),
      ]),
    ],
  )
}

///|
fn semantic_data_fixture() -> Html {
  fixture_section("fixture-section-semantic-data", "Data Semantics", [
    @rui.table(id="fixture-table", [
      @rui.table_caption("Fixture build matrix"),
      @rui.table_header(
        @rui.table_row([
          @rui.table_head(scope=Col, "Target"),
          @rui.table_head(scope=Col, "Status"),
        ]),
      ),
      @rui.table_body(
        @rui.table_row([@rui.table_cell("Chromium"), @rui.table_cell("Passing")]),
      ),
    ]),
    @rui.chart_container(
      id="fixture-chart",
      aria_label="Fixture coverage chart",
      style=["width:16rem"],
      @rui.chart_style(
        variables=[("covered", "#2563eb")],
        div(
          id="fixture-chart-bar",
          style=["width:75%;height:2rem;background:var(--color-covered)"],
          "75%",
        ),
      ),
    ),
    @rui.progress(
      id="fixture-progress",
      value=140,
      min=0,
      max=100,
      aria_label="Fixture completion",
      children=[
        @rui.progress_label("Fixture completion"),
        @rui.progress_value(value=140, min=0, max=100),
      ],
    ),
    @rui.progress(
      id="fixture-progress-indeterminate",
      aria_label="Fixture pending work",
    ),
  ])
}

///|
fn semantic_status_fixture() -> Html {
  fixture_section("fixture-section-semantic-status", "Status and Typography", [
    @rui.typography_h2("Fixture typography"),
    @rui.typography_p([
      @rui.typography_lead("Readable component prose"),
      @rui.typography_inline_code("moon test"),
    ]),
    @rui.kbd_group([@rui.kbd("Ctrl"), span("+"), @rui.kbd("K")]),
    @rui.separator(id="fixture-semantic-separator", decorative=false),
    @rui.skeleton(id="fixture-skeleton", title="Loading fixture preview", style=[
      "width:8rem;height:1rem",
    ]),
    @rui.spinner(id="fixture-spinner", label="Loading fixture semantics"),
  ])
}

///|
fn semantic_components_fixture() -> Val[Html] {
  semantic_actions_fixture().map2(semantic_avatar_fixture(), fn(
    actions,
    media,
  ) {
    fragment([
      actions,
      media,
      semantic_navigation_fixture(),
      semantic_compositions_fixture(),
      semantic_data_fixture(),
      semantic_status_fixture(),
    ])
  })
}
