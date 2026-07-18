///|
#warnings("-alert_unstable")
fn render_input_group_test(html : @html.Html) -> String {
  @rabbita.render_to_string(() => @rabbita.Val::constant(html))
}

///|
test "input group root owns one compact unshadowed control surface" {
  let html = render_input_group_test(
    @rui.input_group(id="workspace-group", @html.nothing),
  )
  assert_true(html.contains("data-slot=\"input-group\""))
  assert_true(html.contains("role=\"group\""))
  assert_true(html.contains("height:2rem"))
  assert_true(html.contains("min-height:2rem"))
  assert_true(html.contains("border-radius:var(--rui-radius,0.625rem)"))
  assert_true(html.contains("--rui-control-base-shadow:0 0 #0000"))
  assert_true(
    html.contains(
      "box-shadow:var(--rui-control-shadow,var(--rui-control-base-shadow,0 0 #0000))",
    ),
  )
  assert_true(!html.contains("0 1px 2px rgb(0 0 0 / 0.05)"))
}

///|
test "input group addon is a label only when it targets a control" {
  let label_html = render_input_group_test(
    @rui.input_group_addon(for_="workspace", "https://"),
  )
  assert_true(label_html.contains("<label"))
  assert_true(label_html.contains("for=\"workspace\""))
  assert_true(label_html.contains("data-slot=\"input-group-addon\""))

  let action_html = render_input_group_test(
    @rui.input_group_addon(
      align=@rui.InputInlineEnd,
      @rui.input_group_button("Copy"),
    ),
  )
  assert_true(action_html.contains("<div"))
  assert_true(action_html.contains("data-slot=\"input-group-addon\""))
  assert_true(action_html.contains("<button"))
  assert_true(!action_html.contains("<label"))
}

///|
test "input group addons expose all four alignment contracts" {
  let html = render_input_group_test(
    @html.div([
      @rui.input_group_addon(align=@rui.InputInlineStart, "Inline start"),
      @rui.input_group_addon(align=@rui.InputInlineEnd, "Inline end"),
      @rui.input_group_addon(align=@rui.InputBlockStart, "Block start"),
      @rui.input_group_addon(align=@rui.InputBlockEnd, "Block end"),
    ]),
  )
  assert_true(html.contains("data-align=\"inline-start\""))
  assert_true(html.contains("data-align=\"inline-end\""))
  assert_true(html.contains("data-align=\"block-start\""))
  assert_true(html.contains("data-align=\"block-end\""))
  assert_true(html.contains("order:-1;padding-inline-start:0.5rem"))
  assert_true(html.contains("order:1;padding-inline-end:0.5rem"))
  assert_true(
    html.contains(
      "order:-1;width:100%;justify-content:flex-start;padding:0.5rem 0.625rem 0",
    ),
  )
  assert_true(
    html.contains(
      "order:1;width:100%;justify-content:flex-start;padding:0 0.625rem 0.5rem",
    ),
  )
}

///|
test "input group buttons map every public size to the compact button recipe" {
  let xs = render_input_group_test(
    @rui.input_group_button(size=@rui.InputButtonXs, "Extra small"),
  )
  let sm = render_input_group_test(
    @rui.input_group_button(size=@rui.InputButtonSm, "Small"),
  )
  let icon_xs = render_input_group_test(
    @rui.input_group_button(size=@rui.InputButtonIconXs, "X"),
  )
  let icon_sm = render_input_group_test(
    @rui.input_group_button(size=@rui.InputButtonIconSm, "X"),
  )
  assert_true(xs.contains("data-slot=\"input-group-button\""))
  assert_true(xs.contains("data-size=\"xs\""))
  assert_true(sm.contains("data-size=\"sm\""))
  assert_true(icon_xs.contains("data-size=\"icon-xs\""))
  assert_true(icon_sm.contains("data-size=\"icon-sm\""))
  assert_true(xs.contains("--rui-button-base-shadow:none"))
  assert_true(
    xs.contains(
      "--rui-control-radius:calc(var(--rui-radius,0.625rem) - 0.1875rem)",
    ),
  )
  assert_true(
    icon_xs.contains(
      "--rui-control-radius:calc(var(--rui-radius,0.625rem) - 0.1875rem)",
    ),
  )
  assert_true(
    !sm.contains(
      "--rui-control-radius:calc(var(--rui-radius,0.625rem) - 0.1875rem)",
    ),
  )
  assert_true(
    !icon_sm.contains(
      "--rui-control-radius:calc(var(--rui-radius,0.625rem) - 0.1875rem)",
    ),
  )
}

///|
test "input group input clears nested chrome and fills the root height" {
  let html = render_input_group_test(
    @rui.input_group(@rui.input_group_input(id="workspace", value="rabbit-tea")),
  )
  assert_true(html.contains("data-slot=\"input-group-control\""))
  assert_true(html.contains("data-input-group-control=\"\""))
  assert_true(
    html.contains(
      "height:100%;min-height:0;flex:1;border:0;border-radius:0;background:transparent;box-shadow:none;outline:none",
    ),
  )
  assert_true(!html.contains("border-radius:inherit"))
}

///|
test "input group textarea uses the shared control slot and grows the surface" {
  let html = render_input_group_test(
    @rui.input_group(@rui.input_group_textarea(value="Notes", rows=4)),
  )
  assert_true(html.contains("data-slot=\"input-group-control\""))
  assert_true(html.contains("data-input-group-control=\"\""))
  assert_true(
    html.contains(
      "min-height:5rem;flex:1;resize:none;border:0;border-radius:0;background:transparent;padding-block:0.5rem;box-shadow:none;outline:none",
    ),
  )
  assert_true(!html.contains("border-radius:inherit"))
}

///|
test "input group custom control adapter owns its public slot and base chrome" {
  let html = render_input_group_test(
    @rui.input_group(
      @rui.input_group_control(
        style=["field-sizing:content;min-height:4rem;resize:none"],
        (attrs, style) => {
          @html.textarea(
            id="custom-control",
            rows=1,
            attrs~,
            style~,
            ([] : Array[@html.Html]),
          )
        },
      ),
    ),
  )
  assert_true(html.contains("data-slot=\"input-group-control\""))
  assert_true(html.contains("data-input-group-control=\"\""))
  assert_true(
    html.contains(
      "display:flex;width:100%;min-width:0;min-height:2rem;flex:1;border:0;border-radius:0;background:transparent;padding:0.625rem;color:inherit;font:inherit;box-shadow:none;outline:none;field-sizing:content;min-height:4rem;resize:none",
    ),
  )
}

///|
test "theme supplies input group layout focus invalid and nested-action rules" {
  let html = render_input_group_test(@rui.theme(@html.nothing))
  assert_true(
    html.contains(
      "[data-slot=\"input-group\"]:has(> [data-slot=\"input-group-control\"]:is(textarea))",
    ),
  )
  assert_true(
    html.contains(
      "[data-slot=\"input-group\"]:has(> [data-slot=\"input-group-addon\"][data-align=\"block-start\"])",
    ),
  )
  assert_true(html.contains("height:auto;\n    flex-direction:column"))
  assert_true(
    html.contains(
      "[data-slot=\"input-group\"]:has([data-slot][aria-invalid=\"true\"])",
    ),
  )
  assert_true(
    html.contains(
      "[data-slot=\"input-group\"]:has([data-slot=\"input-group-control\"]:focus-visible)",
    ),
  )
  assert_true(
    html.contains(
      "[data-slot=\"input-group-addon\"][data-align=\"inline-start\"]:has(> button)",
    ),
  )
  assert_true(
    html.contains(
      "[data-slot=\"input-group-addon\"] > button:is([data-size=\"xs\"],[data-size=\"icon-xs\"])",
    ),
  )
  assert_true(
    html.contains(
      ":where([data-slot=\"input-group-addon\"],[data-slot=\"input-group-text\"]) :where(svg,[aria-hidden=\"true\"])",
    ),
  )
}
