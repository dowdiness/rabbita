///|
using @rabbita {type Html, type Val}

///|
using @html {
  div,
  fragment,
  h1,
  h2,
  label,
  main_,
  nothing,
  p,
  section,
  span,
  strong,
}

///|
let fixture_section_border = "1px solid var(--rui-border,oklch(0.922 0 0))"

///|
let fixture_slide_style : String = "display:flex;align-items:center;justify-content:center;height:8rem;background:var(--rui-muted,oklch(0.97 0 0));border-radius:0.5rem"

///|
let fixture_resizable_panel_style : String = "display:flex;align-items:center;justify-content:center;background:var(--rui-muted,oklch(0.97 0 0));border-radius:0.5rem"

///|
fn fixture_section(id : String, title : String, body : Array[Html]) -> Html {
  section(
    id~,
    style=[
      "display:flex;flex-direction:column;gap:0.75rem;padding:1.5rem;border-bottom:\{fixture_section_border}",
    ],
    [
      h2(style=["margin:0;font-size:1.125rem;font-weight:600"], title),
      div(
        style=[
          "display:flex;flex-wrap:wrap;gap:1rem;align-items:center;padding-top:0.25rem",
        ],
        body,
      ),
    ],
  )
}

///|
fn fixture_intro() -> Html {
  section(style=["padding:1.5rem;border-bottom:\{fixture_section_border}"], [
    h1(style=["margin:0;font-size:1.5rem"], "RUI component fixture"),
    p(
      style=["margin:0.25rem 0 0"],
      "Stable public behavior exercised by the Playwright suite.",
    ),
  ])
}

///|
fn sidebar_fixture() -> Val[Html] {
  let overview_button = @rui.sidebar_menu_button_with_tooltip(
    id="fixture-sidebar-overview",
    tooltip="Overview",
    href="#fixture-section-sidebar",
    is_active=true,
    size=SidebarMenuDefault,
    [@html.span("Overview")],
  )
  let settings_button = @rui.sidebar_menu_button_with_tooltip(
    id="fixture-sidebar-settings",
    tooltip="Settings",
    href="#fixture-section-sidebar",
    size=SidebarMenuDefault,
    [@html.span("Settings")],
  )
  let menu = overview_button.map2(settings_button, fn(overview, settings) {
    @rui.sidebar_menu([
      @rui.sidebar_menu_item([overview]),
      @rui.sidebar_menu_item([settings]),
    ])
  })
  let provider = @rui.sidebar_provider_with_input(
    input=menu,
    default_collapsed=false,
    style=[
      "--rui-sidebar-width:20rem;height:17rem;min-height:17rem;overflow:hidden;display:flex;border:1px solid \{fixture_section_border};border-radius:0.625rem",
    ],
    (scope, menu_html) => {
      fragment([
        @rui.sidebar(
          scope,
          id="fixture-sidebar-root",
          collapsible=SidebarIcon,
          mobile=false,
          [
            @rui.sidebar_header(
              @rui.sidebar_input(
                aria_label="Filter fixture navigation",
                placeholder="Filter…",
              ),
            ),
            @rui.sidebar_content(
              @rui.sidebar_group([
                @rui.sidebar_group_label(scope~, "Workspace"),
                @rui.sidebar_group_action(
                  aria_label="Collapse sidebar",
                  on_click=@rui.sidebar_collapse(scope),
                  @html.span("«"),
                ),
                @rui.sidebar_group_content(menu_html),
              ]),
            ),
            @rui.sidebar_rail(
              scope,
              min_width=192,
              max_width=352,
              aria_label="Resize sidebar",
            ),
          ],
        ),
        div(
          style=[
            "display:flex;flex:1;flex-direction:column;gap:0.5rem;padding:0.75rem",
          ],
          [
            div(style=["display:flex;align-items:center;gap:0.5rem"], [
              @rui.sidebar_trigger(
                scope,
                mobile=false,
                controls="fixture-sidebar-root",
                aria_label="Toggle sidebar",
                @html.span("☰"),
              ),
              strong("Workspace overview"),
            ]),
            p(style=["margin:0"], "Use the trigger to collapse the sidebar."),
          ],
        ),
      ])
    },
  )
  provider.map(provider_html => {
    fixture_section("fixture-section-sidebar", "Sidebar", [provider_html])
  })
}

///|
fn radio_group_fixture() -> Val[Html] {
  let group = @rui.radio_group(
    default_value="monthly",
    name="fixture-billing",
    orientation=RadioHorizontal,
    aria_label="Billing cycle",
    scope => {
      div(style=["display:flex;flex-wrap:wrap;align-items:center;gap:1rem"], [
        div(style=["display:flex;align-items:center;gap:0.5rem"], [
          @rui.radio_group_item(
            scope~,
            value="monthly",
            id="fixture-billing-monthly",
            aria_label="Monthly",
          ),
          label(for_="fixture-billing-monthly", "Monthly"),
        ]),
        div(style=["display:flex;align-items:center;gap:0.5rem"], [
          @rui.radio_group_item(
            scope~,
            value="annual",
            id="fixture-billing-annual",
            aria_label="Annual",
          ),
          label(for_="fixture-billing-annual", "Annual"),
        ]),
        div(style=["display:flex;align-items:center;gap:0.5rem"], [
          @rui.radio_group_item(
            scope~,
            value="weekly",
            id="fixture-billing-weekly",
            aria_label="Weekly",
          ),
          label(for_="fixture-billing-weekly", "Weekly"),
        ]),
      ])
    },
  )
  group.map(group_html => {
    fixture_section("fixture-section-radio", "Radio group", [group_html])
  })
}

///|
fn slider_fixture() -> Val[Html] {
  let slider = @rui.slider(
    id="fixture-slider",
    default_value=30,
    min=0,
    max=100,
    step=10,
    aria_label="Fixture slider",
    style=["width:min(100%,20rem)"],
  )
  slider.map(slider_html => {
    fixture_section("fixture-section-slider", "Slider", [slider_html])
  })
}

///|
fn tooltip_fixture() -> Val[Html] {
  let tip = @rui.tooltip(
    id="fixture-tooltip",
    delay=80,
    close_delay=0,
    show_arrow=true,
    trigger_variant=Outline,
    "Hover for tooltip",
    "Tooltip body content",
  )
  tip.map(tip_html => {
    fixture_section("fixture-section-tooltip", "Tooltip", [tip_html])
  })
}

///|
fn carousel_fixture() -> Val[Html] {
  let carousel = @rui.carousel(
    id="fixture-carousel",
    count=3,
    loop_=true,
    orientation=CarouselHorizontal,
    aria_label="Fixture carousel",
    style=["width:24rem"],
    scope => {
      fragment([
        @rui.carousel_items(scope~, items=[
          div(style=[fixture_slide_style], "First slide"),
          div(style=[fixture_slide_style], "Second slide"),
          div(style=[fixture_slide_style], "Third slide"),
        ]),
        @rui.carousel_previous(scope~),
        @rui.carousel_next(scope~),
      ])
    },
  )
  carousel.map(carousel_html => {
    fixture_section("fixture-section-carousel", "Carousel", [carousel_html])
  })
}

///|
fn select_fixture() -> Val[Html] {
  let select = @rui.select(
    id="fixture-select",
    options=[
      @rui.select_option(value="alpha", label="Alpha"),
      @rui.select_option(value="beta", label="Beta"),
      @rui.select_option(value="gamma", label="Gamma"),
    ],
    placeholder="Choose an option…",
  )
  select.map(select_html => {
    fixture_section("fixture-section-select", "Select", [select_html])
  })
}

///|
fn combobox_fixture() -> Val[Html] {
  let combobox = @rui.combobox(
    id="fixture-combobox",
    options=[
      @rui.combobox_option(value="moonbit", label="MoonBit"),
      @rui.combobox_option(value="rabbita", label="Rabbita"),
      @rui.combobox_option(value="typescript", label="TypeScript"),
      @rui.combobox_option(value="rust", label="Rust"),
    ],
    placeholder="Search runtimes…",
    empty_text="No matching runtimes.",
  )
  combobox.map(combobox_html => {
    fixture_section("fixture-section-combobox", "Combobox", [combobox_html])
  })
}

///|
fn drawer_fixture() -> Val[Html] {
  let drawer = @rui.drawer(id="fixture-drawer", scope => {
    fragment([
      @rui.drawer_trigger(scope, variant=Outline, "Open drawer"),
      @rui.drawer_portal([
        @rui.drawer_content(
          scope,
          direction=DrawerRight,
          show_handle=true,
          show_close=true,
          close_label="Close drawer",
          [
            @rui.drawer_header([
              @rui.drawer_title(scope, "Drawer title"),
              @rui.drawer_description(scope, "Drawer description."),
            ]),
            p(style=["margin:0"], "Drawer body"),
            @rui.drawer_footer(@rui.drawer_close(scope, "Close drawer")),
          ],
        ),
      ]),
    ])
  })
  drawer.map(drawer_html => {
    fixture_section("fixture-section-drawer", "Drawer", [drawer_html])
  })
}

///|
fn resizable_fixture() -> Val[Html] {
  let group = @rui.resizable_panel_group(
    id="fixture-resizable",
    default_size=50,
    min=25,
    max=75,
    orientation=Vertical,
    aria_label="Resize fixture panels",
    style=["height:12rem;width:min(100%,32rem)"],
    scope => {
      fragment([
        @rui.resizable_panel(
          scope~,
          side=FirstPanel,
          style=[fixture_resizable_panel_style],
          "First panel",
        ),
        @rui.resizable_handle(
          scope~,
          with_handle=true,
          aria_label="Resize fixture panels",
        ),
        @rui.resizable_panel(
          scope~,
          side=SecondPanel,
          style=[fixture_resizable_panel_style],
          "Second panel",
        ),
      ])
    },
  )
  group.map(group_html => {
    fixture_section("fixture-section-resizable", "Resizable", [group_html])
  })
}

///|
fn navigation_menu_fixture() -> Val[Html] {
  let nav = @rui.navigation_menu(
    id="fixture-navigation-menu",
    aria_label="Fixture navigation",
    scope => {
      div(style=["min-height:8rem"], [
        @rui.navigation_menu_list(scope, [
          @rui.navigation_menu_item(scope, value="platform", item => {
            fragment([
              @rui.navigation_menu_trigger(item, "Platform"),
              @rui.navigation_menu_indicator(item),
              @rui.navigation_menu_content(item, [
                @rui.navigation_menu_link(
                  href="#fixture-section-navigation-menu",
                  active=true,
                  [
                    strong("Components"),
                    span(style=["display:block"], "Black-box defaults"),
                  ],
                ),
                @rui.navigation_menu_link(
                  href="#fixture-section-navigation-menu",
                  [
                    strong("Patterns"),
                    span(style=["display:block"], "Compound composition"),
                  ],
                ),
              ]),
            ])
          }),
          @rui.navigation_menu_item(scope, value="resources", item => {
            fragment([
              @rui.navigation_menu_trigger(item, "Resources"),
              @rui.navigation_menu_indicator(item),
              @rui.navigation_menu_content(item, [
                @rui.navigation_menu_link(
                  href="#fixture-section-navigation-menu",
                  [
                    strong("API reference"),
                    span(style=["display:block"], "Typed MoonBit surface"),
                  ],
                ),
                @rui.navigation_menu_link(
                  href="#fixture-section-navigation-menu",
                  [
                    strong("Examples"),
                    span(style=["display:block"], "Working interactions"),
                  ],
                ),
              ]),
            ])
          }),
        ]),
        @rui.navigation_menu_viewport(scope, nothing),
      ])
    },
  )
  nav.map(nav_html => {
    fixture_section("fixture-section-navigation-menu", "Navigation menu", [
      nav_html,
    ])
  })
}

///|
fn date_picker_fixture() -> Val[Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let picker = @rui.date_picker(
    id="fixture-date-picker",
    default_value=today,
    today~,
    placeholder="Pick a date…",
    aria_label="Fixture date picker",
  )
  picker.map(picker_html => {
    fixture_section("fixture-section-date-picker", "Date picker", [picker_html])
  })
}

///|
fn toast_fixture() -> Val[Html] {
  let toaster = @rui.sonner(max_toasts=3, position="bottom-right", scope => {
    div(style=["display:flex;flex-wrap:wrap;gap:0.5rem"], [
      @rui.button(
        size=Sm,
        on_click=scope.show(
          title="Saved",
          description="The draft is kept.",
          variant=ToastDefault,
        ),
        "Show toast",
      ),
      @rui.button(
        size=Sm,
        variant=Secondary,
        on_click=scope.show(
          title="Published",
          description="The preview is live.",
          variant=ToastSuccess,
        ),
        "Show success toast",
      ),
    ])
  })
  toaster.map(toaster_html => {
    fixture_section("fixture-section-toast", "Toast", [toaster_html])
  })
}

///|
fn popover_fixture() -> Val[Html] {
  let popover = @rui.popover(
    id="fixture-popover",
    title_id="fixture-popover-title",
    description_id="fixture-popover-desc",
    trigger_variant=Outline,
    "Open popover",
    div(style=["display:flex;flex-direction:column;gap:0.5rem"], [
      @rui.popover_header([
        @rui.popover_title(id="fixture-popover-title", "Popover title"),
        @rui.popover_description(
          id="fixture-popover-desc",
          "Popover description.",
        ),
      ]),
      @rui.popover_close_button(target_id="fixture-popover", size=Sm, "Apply"),
    ]),
  )
  popover.map(popover_html => {
    fixture_section("fixture-section-popover", "Popover", [popover_html])
  })
}

///|
fn hover_card_fixture() -> Val[Html] {
  let card = @rui.hover_card(
    id="fixture-hover-card",
    href="#fixture-section-hover-card",
    open_delay=80,
    close_delay=40,
    trigger_variant=Outline,
    "Hover profile",
    div(style=["display:flex;flex-direction:column;gap:0.5rem"], [
      strong("Rabbita UI"),
      p(style=["margin:0"], "Native MoonBit components with incremental state."),
    ]),
  )
  card.map(card_html => {
    fixture_section("fixture-section-hover-card", "Hover card", [card_html])
  })
}

///|
fn calendar_fixture() -> Val[Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let calendar = @rui.calendar(
    default_selected=today,
    today~,
    aria_label="Fixture calendar",
  )
  calendar.map(calendar_html => {
    fixture_section("fixture-section-calendar", "Calendar", [calendar_html])
  })
}

///|
fn dropdown_menu_fixture() -> Val[Html] {
  let menu = @rui.dropdown_menu(id="fixture-dropdown-menu", scope => {
    fragment([
      @rui.dropdown_menu_trigger(scope, variant=Outline, "Workspace menu"),
      @rui.dropdown_menu_portal([
        @rui.dropdown_menu_content(scope, side=Bottom, align=Start, [
          @rui.dropdown_menu_group(aria_label="Workspace", [
            @rui.dropdown_menu_label("Workspace"),
            @rui.dropdown_menu_item(scope, "New tab"),
            @rui.dropdown_menu_item(scope, "Invite member"),
            @rui.dropdown_menu_item(scope, disabled=true, "Duplicate workspace"),
          ]),
        ]),
      ]),
    ])
  })
  menu.map(menu_html => {
    fixture_section("fixture-section-dropdown-menu", "Dropdown menu", [
      menu_html,
    ])
  })
}

///|
fn menubar_fixture() -> Val[Html] {
  let bar = @rui.menubar(
    id="fixture-menubar",
    aria_label="Fixture application menu",
    scope => {
      fragment([
        @rui.menubar_menu(scope, value="file", menu => {
          fragment([
            @rui.menubar_trigger(menu, "File"),
            @rui.menubar_portal([
              @rui.menubar_content(menu, [
                @rui.menubar_group(aria_label="Project commands", [
                  @rui.menubar_label("Project"),
                  @rui.menubar_item(menu, "New project"),
                  @rui.menubar_item(menu, "Open…"),
                  @rui.menubar_item(menu, disabled=true, "Import"),
                ]),
              ]),
            ]),
          ])
        }),
        @rui.menubar_menu(scope, value="help", menu => {
          fragment([
            @rui.menubar_trigger(menu, "Help"),
            @rui.menubar_portal([
              @rui.menubar_content(menu, [
                @rui.menubar_group(aria_label="Help", [
                  @rui.menubar_label("Help"),
                  @rui.menubar_item(menu, "Keyboard shortcuts"),
                ]),
              ]),
            ]),
          ])
        }),
      ])
    },
  )
  bar.map(bar_html => {
    fixture_section("fixture-section-menubar", "Menubar", [bar_html])
  })
}

///|
fn app() -> Val[Html] {
  let a1 = sidebar_fixture()
  let a2 = radio_group_fixture()
  let a3 = slider_fixture()
  let a4 = tooltip_fixture()
  let a5 = carousel_fixture()
  let a6 = select_fixture()
  let a7 = combobox_fixture()
  let a8 = drawer_fixture()
  let a9 = resizable_fixture()
  let a10 = navigation_menu_fixture()
  let a11 = date_picker_fixture()
  let a12 = toast_fixture()
  let a13 = popover_fixture()
  let a14 = hover_card_fixture()
  let a15 = calendar_fixture()
  let a16 = dropdown_menu_fixture()
  let a17 = menubar_fixture()
  let first = a1.map9(a2, a3, a4, a5, a6, a7, a8, a9, fn(
    s1,
    s2,
    s3,
    s4,
    s5,
    s6,
    s7,
    s8,
    s9,
  ) {
    [s1, s2, s3, s4, s5, s6, s7, s8, s9]
  })
  let second = a10.map8(a11, a12, a13, a14, a15, a16, a17, fn(
    s10,
    s11,
    s12,
    s13,
    s14,
    s15,
    s16,
    s17,
  ) {
    [s10, s11, s12, s13, s14, s15, s16, s17]
  })
  first.map2(second, fn(first, second) {
    let sections : Array[Html] = [fixture_intro()]
    sections.append(first)
    sections.append(second)
    main_(id="fixture-main", style=["max-width:64rem;margin:0 auto"], sections)
  })
}

///|
fn main {
  @rabbita.new(app).mount("app")
}
