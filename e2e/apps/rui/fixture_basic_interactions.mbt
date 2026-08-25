///|
fn accordion_fixture() -> Val[Html] {
  let single = @rui.accordion(
    id="fixture-accordion-single",
    type_=Single,
    collapsible=true,
    default_value="keyboard",
    items=[
      @rui.accordion_entry(
        value="keyboard",
        label="Keyboard interaction",
        content=p(style=["margin:0"], "Enter and Space toggle this panel."),
      ),
      @rui.accordion_entry(
        value="state",
        label="Owned state",
        content=p(style=["margin:0"], "Only one panel stays open."),
      ),
      @rui.accordion_entry(
        value="disabled",
        label="Unavailable section",
        disabled=true,
        content=p(style=["margin:0"], "This content stays unavailable."),
      ),
    ],
  )
  let multiple = @rui.accordion(
    id="fixture-accordion-multiple",
    type_=Multiple,
    default_values=["first"],
    items=[
      @rui.accordion_entry(
        value="first",
        label="First independent panel",
        content=p(style=["margin:0"], "First panel content"),
      ),
      @rui.accordion_entry(
        value="second",
        label="Second independent panel",
        content=p(style=["margin:0"], "Second panel content"),
      ),
    ],
  )
  single.map2(multiple, fn(single, multiple) {
    fixture_section("fixture-section-accordion", "Accordion", [
      div(style=["width:min(100%,28rem)"], single),
      div(style=["width:min(100%,28rem)"], multiple),
    ])
  })
}

///|
fn collapsible_fixture() -> Val[Html] {
  let enabled = @rui.collapsible(
    id="fixture-collapsible",
    trigger="Advanced settings",
    content=p(style=["margin:0"], "Advanced settings content"),
  )
  let disabled = @rui.collapsible(
    id="fixture-collapsible-disabled",
    disabled=true,
    trigger="Unavailable settings",
    content=p(style=["margin:0"], "Unavailable content"),
  )
  enabled.map2(disabled, fn(enabled, disabled) {
    fixture_section("fixture-section-collapsible", "Collapsible", [
      div(style=["width:min(100%,24rem)"], enabled),
      div(style=["width:min(100%,24rem)"], disabled),
    ])
  })
}

///|
fn tabs_fixture() -> Val[Html] {
  let horizontal = @rui.tabs(
    id="fixture-tabs-horizontal",
    default_value="preview",
    orientation=TabsHorizontal,
    aria_label="Fixture workflow",
    items=[
      @rui.tab_entry(
        value="preview",
        label="Preview",
        content=div("Preview panel content"),
      ),
      @rui.tab_entry(
        value="source",
        label="Source",
        content=div("Source panel content"),
      ),
      @rui.tab_entry(
        value="disabled",
        label="Disabled",
        disabled=true,
        content=div("Disabled panel content"),
      ),
    ],
  )
  let vertical = @rui.tabs(
    id="fixture-tabs-vertical",
    default_value="general",
    orientation=TabsVertical,
    aria_label="Fixture settings",
    items=[
      @rui.tab_entry(
        value="general",
        label="General",
        content=div("General settings content"),
      ),
      @rui.tab_entry(
        value="members",
        label="Members",
        content=div("Member settings content"),
      ),
      @rui.tab_entry(
        value="billing",
        label="Billing",
        content=div("Billing settings content"),
      ),
    ],
  )
  horizontal.map2(vertical, fn(horizontal, vertical) {
    fixture_section("fixture-section-tabs", "Tabs", [
      div(style=["width:min(100%,28rem)"], horizontal),
      div(style=["width:min(100%,28rem)"], vertical),
    ])
  })
}

///|
fn checkbox_fixture() -> Val[Html] {
  let unchecked = @rui.checkbox(
    id="fixture-checkbox",
    aria_label="Accept fixture policy",
  )
  let mixed = @rui.checkbox(
    id="fixture-checkbox-mixed",
    default_indeterminate=true,
    aria_label="Select all fixture items",
  )
  let disabled = @rui.checkbox(
    id="fixture-checkbox-disabled",
    default_checked=true,
    disabled=true,
    aria_label="Managed fixture policy",
  )
  unchecked.map3(mixed, disabled, fn(unchecked, mixed, disabled) {
    fixture_section("fixture-section-checkbox", "Checkbox", [
      label(for_="fixture-checkbox", [unchecked, span("Accept policy")]),
      label(for_="fixture-checkbox-mixed", [mixed, span("Select all")]),
      label(for_="fixture-checkbox-disabled", [disabled, span("Managed policy")]),
    ])
  })
}

///|
fn switch_fixture() -> Val[Html] {
  let enabled = @rui.switch(
    id="fixture-switch",
    aria_label="Enable fixture previews",
  )
  let disabled = @rui.switch(
    id="fixture-switch-disabled",
    default_checked=true,
    disabled=true,
    aria_label="Managed fixture backups",
  )
  enabled.map2(disabled, fn(enabled, disabled) {
    fixture_section("fixture-section-switch", "Switch", [
      label(for_="fixture-switch", [enabled, span("Live previews")]),
      label(for_="fixture-switch-disabled", [disabled, span("Managed backups")]),
    ])
  })
}

///|
fn toggle_fixture() -> Val[Html] {
  let toggle = @rui.toggle(
    id="fixture-toggle",
    variant=Outline,
    aria_label="Pin fixture release",
    "Pin release",
  )
  let single_group = @rui.toggle_group(
    id="fixture-toggle-group-single",
    default_values=["grid"],
    aria_label="Fixture layout",
    scope => {
      fragment([
        @rui.toggle_group_item(scope~, value="list", "List"),
        @rui.toggle_group_item(scope~, value="grid", "Grid"),
        @rui.toggle_group_item(
          scope~,
          value="disabled",
          disabled=true,
          "Disabled",
        ),
      ])
    },
  )
  let multiple_group = @rui.toggle_group(
    id="fixture-toggle-group-multiple",
    default_values=["bold"],
    multiple=true,
    aria_label="Fixture formatting",
    scope => {
      fragment([
        @rui.toggle_group_item(scope~, value="bold", "Bold"),
        @rui.toggle_group_item(scope~, value="italic", "Italic"),
        @rui.toggle_group_item(scope~, value="underline", "Underline"),
      ])
    },
  )
  toggle.map3(single_group, multiple_group, fn(toggle, single, multiple) {
    fixture_section("fixture-section-toggle", "Toggle and toggle group", [
      toggle, single, multiple,
    ])
  })
}
