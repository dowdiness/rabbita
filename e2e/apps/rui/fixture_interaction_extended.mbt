///|
fn combobox_multiple_fixture() -> Val[Html] {
  let options = [
    @rui.combobox_option(value="moonbit", label="MoonBit"),
    @rui.combobox_option(value="rabbita", label="Rabbita"),
    @rui.combobox_option(value="typescript", label="TypeScript"),
    @rui.combobox_option(value="legacy", label="Legacy runtime", disabled=true),
  ]
  let (values, set_values) = @rabbita.create_variable("moonbit,rabbita")
  let combobox = @rui.combobox(
    id="fixture-combobox-multiple",
    options~,
    multiple=true,
    default_values=["moonbit", "rabbita"],
    placeholder="Add a fixture runtime…",
    empty_text="No additional runtimes.",
    name="fixture-runtimes",
    on_values_change=set_values.map(values => _ => values.join(",")),
  )
  combobox.map2(values, fn(combobox, values) {
    fixture_section("fixture-section-combobox-multiple", "Combobox Multiple", [
      div(style=["width:min(100%,24rem)"], combobox),
      @html.output(id="fixture-combobox-multiple-output", values),
    ])
  })
}

///|
fn slider_values_fixture() -> Val[Html] {
  let (changed, set_changed) = @rabbita.create_variable("20,80")
  let (committed, set_committed) = @rabbita.create_variable("none")
  let slider = @rui.slider_values(
    id="fixture-slider-values",
    default_values=[20, 80],
    min=0,
    max=100,
    step=10,
    large_step=30,
    min_steps_between_values=2,
    aria_label="Fixture budget",
    on_value_change=set_changed.map(values => {
      _ => values.map(value => value.to_string()).join(",")
    }),
    on_value_commit=set_committed.map(values => {
      _ => values.map(value => value.to_string()).join(",")
    }),
    style=["width:min(100%,24rem)"],
  )
  slider.map3(changed, committed, fn(slider, changed, committed) {
    fixture_section("fixture-section-slider-values", "Slider Values", [
      slider,
      @html.output(
        id="fixture-slider-values-output",
        "change:\{changed}|commit:\{committed}",
      ),
    ])
  })
}

///|
fn resizable_group_fixture() -> Val[Html] {
  let (sizes, set_sizes) = @rabbita.create_variable("26,44,30")
  let group = @rui.resizable_group(
    id="fixture-resizable-group",
    default_sizes=[26, 44, 30],
    min_sizes=[16, 24, 18],
    max_sizes=[52, 68, 54],
    on_resize=set_sizes.map(values => {
      _ => values.map(value => value.to_string()).join(",")
    }),
    style=[
      "width:min(100%,42rem);height:10rem;border:1px solid \{fixture_section_border}",
    ],
    scope => {
      fragment([
        @rui.resizable_group_panel(
          scope~,
          index=0,
          id="fixture-resizable-files",
          style=[fixture_resizable_panel_style],
          "Files",
        ),
        @rui.resizable_group_handle(
          scope~,
          between=0,
          with_handle=true,
          aria_label="Resize files and editor",
        ),
        @rui.resizable_group_panel(
          scope~,
          index=1,
          id="fixture-resizable-editor",
          style=[fixture_resizable_panel_style],
          "Editor",
        ),
        @rui.resizable_group_handle(
          scope~,
          between=1,
          with_handle=true,
          aria_label="Resize editor and preview",
        ),
        @rui.resizable_group_panel(
          scope~,
          index=2,
          id="fixture-resizable-preview",
          style=[fixture_resizable_panel_style],
          "Preview",
        ),
      ])
    },
  )
  group.map2(sizes, fn(group, sizes) {
    fixture_section("fixture-section-resizable-group", "Resizable Group", [
      group,
      @html.output(id="fixture-resizable-group-output", sizes),
    ])
  })
}

///|
fn fixture_scroll_items(prefix : String) -> Array[Html] {
  let items : Array[Html] = []
  for index in 1..<=18 {
    items.push(
      div(
        id="\{prefix}-\{index}",
        style=["height:2rem;flex:none;padding:0.25rem"],
        "Fixture item \{index}",
      ),
    )
  }
  items
}

///|
fn scroll_area_fixture() -> Val[Html] {
  let vertical = @rui.scroll_area_with_scrollbar(
    id="fixture-scroll-area",
    orientation=Vertical,
    style=["width:18rem;height:8rem;border:1px solid \{fixture_section_border}"],
    div(
      style=["display:flex;flex-direction:column"],
      fixture_scroll_items("scroll-item"),
    ),
  )
  let horizontal = @rui.scroll_area_with_scrollbar(
    id="fixture-scroll-area-horizontal",
    orientation=Horizontal,
    style=["width:18rem;height:4rem;border:1px solid \{fixture_section_border}"],
    div(
      style=["display:flex;width:56rem;height:100%;align-items:center;gap:1rem"],
      fixture_scroll_items("horizontal-scroll-item"),
    ),
  )
  vertical.map2(horizontal, fn(vertical, horizontal) {
    fixture_section("fixture-section-scroll-area", "Scroll Area", [
      vertical, horizontal,
    ])
  })
}

///|
fn message_scroller_fixture() -> Val[Html] {
  let scroller = @rui.message_scroller(
    id="fixture-message-scroller",
    default_at_end=false,
    style=[
      "width:20rem;height:10rem;border:1px solid \{fixture_section_border}",
    ],
    scope => {
      fragment([
        @rui.message_scroller_viewport(
          scope~,
          @rui.message_scroller_content(
            fixture_scroll_items("message-scroller-item").map(item => {
              @rui.message_scroller_item(style=["min-height:3rem"], item)
            }),
          ),
        ),
        @rui.message_scroller_button(
          scope~,
          direction=ScrollStart,
          label="Jump to first fixture message",
          "↑",
        ),
        @rui.message_scroller_button(
          scope~,
          direction=ScrollEnd,
          label="Jump to latest fixture message",
          "↓",
        ),
      ])
    },
  )
  scroller.map(scroller => {
    fixture_section("fixture-section-message-scroller", "Message Scroller", [
      scroller,
    ])
  })
}

///|
fn sidebar_mobile_fixture() -> Val[Html] {
  let (state, set_state) = @rabbita.create_variable("closed")
  let provider = @rui.sidebar_provider(
    default_mobile_open=false,
    on_mobile_open_change=set_state.map(open => {
      _ => if open { "open" } else { "closed" }
    }),
    style=["height:8rem;min-height:8rem"],
    scope => {
      fragment([
        @rui.sidebar(
          scope,
          id="fixture-sidebar-mobile",
          collapsible=SidebarOffcanvas,
          mobile=true,
          aria_label="Fixture mobile navigation",
          [
            @rui.sidebar_header([
              strong("Mobile workspace"),
              @rui.button(
                on_click=@rui.sidebar_close_mobile(scope),
                "Close mobile navigation",
              ),
            ]),
            @rui.sidebar_content(
              @rui.sidebar_group(
                @rui.sidebar_group_content(
                  @rui.sidebar_menu([
                    @rui.sidebar_menu_item(
                      @rui.sidebar_menu_button(
                        href="#fixture-section-sidebar-mobile",
                        "Mobile overview",
                      ),
                    ),
                    @rui.sidebar_menu_item(
                      @rui.sidebar_menu_button(
                        href="#fixture-section-sidebar-mobile",
                        "Mobile settings",
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
        @rui.sidebar_trigger(
          scope,
          mobile=true,
          controls="fixture-sidebar-mobile",
          aria_label="Open mobile sidebar",
          "☰",
        ),
      ])
    },
  )
  provider.map2(state, fn(provider, state) {
    fixture_section("fixture-section-sidebar-mobile", "Sidebar Mobile", [
      provider,
      @html.output(id="fixture-sidebar-mobile-output", state),
    ])
  })
}

///|
fn carousel_non_loop_fixture() -> Val[Html] {
  let (index, set_index) = @rabbita.create_variable(0)
  let carousel = @rui.carousel(
    id="fixture-carousel-non-loop",
    count=3,
    loop_=false,
    aria_label="Fixture bounded carousel",
    on_index_change=set_index.map(value => _ => value),
    style=["width:24rem"],
    scope => {
      fragment([
        @rui.carousel_items(scope~, items=[
          div(style=[fixture_slide_style], "Bounded first slide"),
          div(style=[fixture_slide_style], "Bounded second slide"),
          div(style=[fixture_slide_style], "Bounded third slide"),
        ]),
        @rui.carousel_previous(scope~),
        @rui.carousel_next(scope~),
      ])
    },
  )
  carousel.map2(index, fn(carousel, index) {
    fixture_section("fixture-section-carousel-non-loop", "Carousel Bounded", [
      carousel,
      @html.output(id="fixture-carousel-non-loop-output", "index:\{index}"),
    ])
  })
}
