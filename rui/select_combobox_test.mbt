///|
test "select owns incremental value and listbox state" {
  let options = [
    @rui.select_option(value="alpha", label="Alpha"),
    @rui.select_option(value="beta", label="Beta"),
    @rui.select_option(value="gamma", label="Gamma", disabled=true),
  ]
  let html = render_incremental(() => {
    @rui.select(
      id="project-select",
      options~,
      default_value="beta",
      default_open=true,
      name="project",
      style=["max-width:20rem"],
    )
  })
  assert_contains(html, "data-slot=\"select\"")
  assert_contains(html, "data-state=\"open\"")
  assert_contains(html, "data-value=\"beta\"")
  assert_contains(html, "data-slot=\"select-hidden-input\"")
  assert_contains(html, "name=\"project\"")
  assert_contains(html, "value=\"beta\"")
  assert_contains(html, "role=\"listbox\"")
  assert_contains(html, "role=\"combobox\"")
  assert_contains(
    html, "background:var(--rui-control-bg,var(--rui-control-base-bg,var(--rui-input-background,transparent)))",
  )
  assert_contains(
    html, "border-color:var(--rui-control-border,var(--rui-control-base-border,var(--rui-input,oklch(0.922 0 0))))",
  )
  assert_contains(
    html, "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 1px 2px rgb(0 0 0 / 0.05)))",
  )
  assert_contains(html, "aria-controls=\"project-select-content\"")
  assert_contains(html, "id=\"project-select-content\"")
  assert_contains(html, "role=\"option\"")
  assert_contains(html, "aria-selected=\"true\"")
  assert_contains(html, "aria-disabled=\"true\"")
  assert_contains(html, "data-slot=\"select-item-indicator\"")
  assert_contains(
    html, "background:var(--rui-menu-item-bg,var(--rui-menu-item-base-bg,transparent))",
  )
  assert_contains(html, "--rui-menu-item-base-bg:var(--rui-accent")
  assert_contains(html, "popover=\"auto\"")
  assert_contains(html, "anchor-name:--rui-anchor_")
  assert_contains(html, "position-anchor:--rui-anchor_")
  assert_contains(html, "position-area:bottom span-x-end")
  assert_not_contains(html, "-10000px")
  assert_contains(html, "max-width:20rem")
}

///|
test "select compound API shares the opaque internal scope" {
  let options = [
    @rui.select_option(value="one", label="One"),
    @rui.select_option(value="two", label="Two"),
  ]
  let html = render_incremental(() => {
    @rui.select(
      id="custom-select",
      options~,
      default_value="one",
      default_open=true,
      render=scope => {
        @html.div([
          @rui.select_trigger(scope~, style=["background:rebeccapurple"]),
          @rui.select_content(scope~, id="numbers-popup", [
            @rui.select_scroll_up_button(scope~),
            @rui.select_group([
              @rui.select_label("Numbers"),
              @rui.select_item(scope~, value="one", "One"),
              @rui.select_separator(),
              @rui.select_item(scope~, value="two", "Two"),
            ]),
            @rui.select_scroll_down_button(scope~),
          ]),
        ])
      },
    )
  })
  assert_contains(html, "data-slot=\"select-trigger\"")
  assert_contains(html, "data-slot=\"select-content\"")
  assert_contains(html, "aria-controls=\"numbers-popup\"")
  assert_contains(html, "id=\"numbers-popup\"")
  assert_contains(html, "data-slot=\"select-group\"")
  assert_contains(html, "data-slot=\"select-label\"")
  assert_contains(html, "data-slot=\"select-separator\"")
  assert_contains(html, "data-slot=\"select-scroll-up-button\"")
  assert_contains(html, "data-slot=\"select-scroll-down-button\"")
  assert_contains(html, "tabindex=\"-1\"")
  assert_contains(html, "cursor:default")
  assert_contains(html, "background:rebeccapurple")
  assert_contains(html, "position-anchor:--rui-anchor_")
}

///|
test "combobox renders filtered-selection primitives from internal state" {
  let options = [
    @rui.combobox_option(value="moonbit", label="MoonBit"),
    @rui.combobox_option(value="rabbita", label="Rabbita"),
    @rui.combobox_option(value="vega", label="Vega", disabled=true),
  ]
  let html = render_incremental(() => {
    @rui.combobox(
      id="framework-combobox",
      options~,
      default_value="rabbita",
      default_open=true,
      name="framework",
      invalid=true,
    )
  })
  assert_contains(html, "data-slot=\"combobox\"")
  assert_contains(html, "data-state=\"open\"")
  assert_contains(html, "data-invalid=\"\"")
  assert_contains(html, "data-slot=\"combobox-control\"")
  assert_contains(
    html, "background:var(--rui-control-bg,var(--rui-control-base-bg,var(--rui-input-background,transparent)))",
  )
  assert_contains(
    html, "border-color:var(--rui-control-border,var(--rui-control-base-border,var(--rui-input,oklch(0.922 0 0))))",
  )
  assert_contains(
    html, "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 1px 2px rgb(0 0 0 / 0.05)))",
  )
  assert_contains(html, "data-slot=\"combobox-input\"")
  assert_contains(html, "role=\"combobox\"")
  assert_contains(html, "aria-expanded=\"true\"")
  assert_contains(html, "aria-haspopup=\"listbox\"")
  assert_contains(html, "aria-controls=\"framework-combobox-content\"")
  assert_contains(html, "id=\"framework-combobox-input\"")
  assert_contains(html, "id=\"framework-combobox-content\"")
  assert_contains(html, "data-trigger-id=\"framework-combobox-control\"")
  assert_contains(html, "anchor-name:--rui-anchor_")
  assert_contains(html, "position-anchor:--rui-anchor_")
  assert_not_contains(html, "-10000px")
  assert_not_contains(html, "aria-activedescendant")
  assert_not_contains(html, "tabindex=\"0\"")
  assert_contains(html, "value=\"Rabbita\"")
  assert_contains(html, "data-slot=\"combobox-content\"")
  assert_contains(html, "role=\"listbox\"")
  assert_contains(html, "data-slot=\"combobox-item\"")
  assert_contains(
    html, "background:var(--rui-menu-item-bg,var(--rui-menu-item-base-bg,transparent))",
  )
  assert_contains(html, "aria-selected=\"true\"")
  assert_contains(html, "data-slot=\"combobox-item-indicator\"")
  assert_contains(html, "name=\"framework\"")
  assert_contains(html, "value=\"rabbita\"")
  assert_contains(html, "data-slot=\"combobox-clear\"")
  assert_not_contains(html, "data-slot=\"combobox-trigger\"")
  assert_contains(html, "data-size=\"icon-xs\"")
  assert_contains(html, "tabindex=\"-1\"")
}

///|
test "empty default combobox exposes one centered icon trigger" {
  let html = render_incremental(() => {
    @rui.combobox(id="empty-framework-combobox", options=[
      @rui.combobox_option(value="moonbit", label="MoonBit"),
      @rui.combobox_option(value="rabbita", label="Rabbita"),
    ])
  })
  assert_not_contains(html, "data-slot=\"combobox-clear\"")
  assert_contains(html, "data-slot=\"combobox-trigger\"")
  assert_contains(html, "data-variant=\"ghost\"")
  assert_contains(html, "data-size=\"icon-xs\"")
  assert_contains(html, "aria-label=\"Toggle options\"")
  assert_contains(html, "aria-haspopup=\"listbox\"")
  assert_contains(html, "aria-expanded=\"false\"")
  assert_contains(html, "tabindex=\"-1\"")
  assert_contains(html, "width:1.5rem;height:1.5rem")
  assert_contains(html, "data-slot=\"combobox-trigger-icon\"")
  assert_contains(html, "viewBox=\"0 0 24 24\"")
  assert_contains(html, "width=\"16\"")
  assert_contains(html, "height=\"16\"")
  assert_contains(html, "d=\"m6 9 6 6 6-6\"")
}

///|
test "combobox input and trigger keep unique ids and anchor to the input" {
  let options = [
    @rui.combobox_option(value="alpha", label="Alpha"),
    @rui.combobox_option(value="beta", label="Beta"),
  ]
  let html = render_incremental(() => {
    @rui.combobox(id="compound-combobox", options~, default_open=true, render=scope => {
      @html.fragment([
        @rui.combobox_input(scope~, id="actual-combobox-input"),
        @rui.combobox_trigger(
          scope~,
          id="actual-combobox-trigger",
          aria_label="Toggle options",
        ),
        @rui.combobox_clear(scope~, id="actual-combobox-clear", style=[
          "background:rebeccapurple",
        ]),
        @rui.combobox_content(
          scope~,
          id="actual-combobox-popup",
          @rui.combobox_item(scope~, value="alpha", "Alpha"),
        ),
      ])
    })
  })
  assert_contains(html, "id=\"actual-combobox-input\"")
  assert_contains(html, "id=\"actual-combobox-trigger\"")
  assert_contains(html, "id=\"actual-combobox-clear\"")
  assert_contains(html, "data-slot=\"combobox-clear\"")
  assert_contains(html, "data-variant=\"ghost\"")
  assert_contains(html, "data-size=\"icon-xs\"")
  assert_contains(
    html, "background:var(--rui-button-bg,var(--rui-button-base-bg,transparent))",
  )
  assert_contains(html, "background:rebeccapurple")
  assert_contains(html, "id=\"actual-combobox-popup\"")
  assert_contains(html, "aria-controls=\"actual-combobox-popup\"")
  assert_contains(html, "data-trigger-id=\"actual-combobox-input\"")
  assert_contains(html, "position-anchor:--rui-anchor_")
  assert_contains(html, "aria-label=\"Toggle options\"")
  assert_contains(html, "tabindex=\"-1\"")
  assert_contains(html, "data-slot=\"combobox-trigger-icon\"")
  assert_contains(html, "display:inline-flex;width:1rem;height:1rem")
  assert_contains(html, "line-height:0")
  assert_not_contains(html, "id=\"compound-combobox-trigger\"")
  assert_not_contains(html, "id=\"compound-combobox-input\"")
}

///|
test "multiple combobox exposes chips and collection composition" {
  let options = [
    @rui.combobox_option(value="a", label="Alpha"),
    @rui.combobox_option(value="b", label="Beta"),
  ]
  let html = render_incremental(() => {
    @rui.combobox(
      id="tags-combobox",
      options~,
      multiple=true,
      default_values=["a", "b"],
      render=scope => {
        @html.div([
          @rui.combobox_chips([
            @rui.combobox_chip(scope~, value="a", "Alpha"),
            @rui.combobox_chip(scope~, value="b", "Beta"),
            @rui.combobox_chips_input(scope~, aria_label="Filter tags"),
          ]),
          @rui.combobox_content(
            scope~,
            id="tags-popup",
            @rui.combobox_collection([
              @rui.combobox_label("Tags"),
              @rui.combobox_item(scope~, value="a", "Alpha"),
              @rui.combobox_separator(),
              @rui.combobox_item(scope~, value="b", "Beta"),
            ]),
          ),
        ])
      },
    )
  })
  assert_contains(html, "data-multiple=\"true\"")
  assert_contains(html, "aria-multiselectable=\"true\"")
  assert_contains(html, "data-slot=\"combobox-chips\"")
  assert_contains(html, "min-height:2.25rem")
  assert_contains(
    html, "border-color:var(--rui-control-border,var(--rui-control-base-border,var(--rui-input,oklch(0.922 0 0))))",
  )
  assert_contains(
    html, "background:var(--rui-control-bg,var(--rui-control-base-bg,var(--rui-input-background,transparent)))",
  )
  assert_contains(
    html, "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 1px 2px rgb(0 0 0 / 0.05)))",
  )
  assert_contains(html, "data-slot=\"combobox-chip\"")
  assert_contains(html, "data-slot=\"combobox-chip-remove\"")
  assert_contains(html, "data-variant=\"ghost\"")
  assert_contains(html, "data-size=\"icon-xs\"")
  assert_contains(
    html, "background:var(--rui-button-bg,var(--rui-button-base-bg,transparent))",
  )
  assert_contains(html, "opacity:var(--rui-chip-remove-opacity,0.5)")
  assert_contains(html, "data-slot=\"combobox-chip-input\"")
  assert_contains(html, "aria-label=\"Filter tags\"")
  assert_contains(html, "role=\"combobox\"")
  assert_contains(html, "aria-expanded=\"false\"")
  assert_not_contains(html, "aria-controls")
  assert_not_contains(html, "aria-activedescendant")
  assert_contains(html, "min-width:4rem")
  assert_contains(html, "data-slot=\"combobox-collection\"")
  assert_contains(html, "data-slot=\"combobox-label\"")
  assert_contains(html, "data-slot=\"combobox-separator\"")
  assert_contains(html, "id=\"tags-popup\"")
}

///|
test "default multiple combobox uses chips as its only control surface" {
  let html = render_incremental(() => {
    @rui.combobox(
      id="default-tags-combobox",
      options=[
        @rui.combobox_option(value="a", label="Alpha"),
        @rui.combobox_option(value="b", label="Beta"),
      ],
      multiple=true,
      default_values=["a"],
    )
  })
  assert_contains(html, "data-slot=\"combobox-control\"")
  assert_contains(
    html, "data-slot=\"combobox-control\" id=\"default-tags-combobox-control\" style=\"box-sizing:border-box;display:flex;width:100%;min-width:0;",
  )
  assert_contains(html, "data-slot=\"combobox-chips\"")
  assert_contains(html, "data-slot=\"combobox-clear\"")
  assert_contains(html, "data-slot=\"combobox-chip-input\"")
}

///|
test "closed select and disabled hidden controls stay out of focus and submission" {
  let select_options = [
    @rui.select_option(value="a", label="Alpha"),
    @rui.select_option(value="b", label="Beta"),
  ]
  let select_html = render_incremental(() => {
    @rui.select(
      id="closed-select",
      options=select_options,
      default_value="a",
      name="closed",
      disabled=true,
    )
  })
  assert_contains(select_html, "role=\"combobox\"")
  assert_contains(select_html, "aria-expanded=\"false\"")
  assert_not_contains(select_html, "aria-controls")
  assert_not_contains(select_html, "tabindex=\"0\"")
  assert_contains(select_html, "data-slot=\"select-hidden-input\"")
  assert_contains(select_html, " disabled")

  let combobox_options = [@rui.combobox_option(value="a", label="Alpha")]
  let combobox_html = render_incremental(() => {
    @rui.combobox(
      id="disabled-combobox",
      options=combobox_options,
      default_value="a",
      name="disabled-combobox",
      disabled=true,
    )
  })
  assert_contains(combobox_html, "value=\"Alpha\"")
  assert_not_contains(combobox_html, "aria-controls")
  assert_not_contains(combobox_html, "aria-activedescendant")
  assert_contains(combobox_html, " disabled")
}
