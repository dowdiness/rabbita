///|
fn dialog_fixture() -> Val[Html] {
  let modal = @rui.dialog(id="fixture-dialog-modal", scope => {
    fragment([
      @rui.dialog_trigger(scope, variant=Outline, "Open modal dialog"),
      @rui.dialog_portal([
        @rui.dialog_content(scope, show_close=true, [
          @rui.dialog_header([
            @rui.dialog_title(scope, "Edit fixture profile"),
            @rui.dialog_description(
              scope, "Update the profile and save the dialog.",
            ),
          ]),
          div(style=["display:grid;gap:0.5rem"], [
            @rui.label(for_="fixture-dialog-name", "Display name"),
            @rui.input(id="fixture-dialog-name", value="Rabbita team"),
          ]),
          @rui.dialog_footer(@rui.dialog_close(scope, "Save dialog")),
        ]),
      ]),
    ])
  })
  let non_modal = @rui.dialog(id="fixture-dialog-non-modal", modal=false, scope => {
    fragment([
      @rui.dialog_trigger(scope, variant=Outline, "Open non-modal dialog"),
      @rui.dialog_portal([
        @rui.dialog_content(scope, show_close=true, [
          @rui.dialog_header([
            @rui.dialog_title(scope, "Non-modal fixture"),
            @rui.dialog_description(
              scope, "The surrounding page remains interactive.",
            ),
          ]),
          @rui.dialog_footer(@rui.dialog_close(scope, "Close non-modal")),
        ]),
      ]),
    ])
  })
  modal.map2(non_modal, fn(modal, non_modal) {
    fixture_section("fixture-section-dialog", "Dialog", [modal, non_modal])
  })
}

///|
fn alert_dialog_fixture() -> Val[Html] {
  @rui.alert_dialog(id="fixture-alert-dialog", scope => {
    fragment([
      @rui.alert_dialog_trigger(scope, variant=Destructive, "Delete fixture"),
      @rui.alert_dialog_portal([
        @rui.alert_dialog_content(scope, [
          @rui.alert_dialog_header([
            @rui.alert_dialog_title(scope, "Delete this fixture?"),
            @rui.alert_dialog_description(
              scope, "This action cannot be undone.",
            ),
          ]),
          @rui.alert_dialog_footer([
            @rui.alert_dialog_cancel(scope, "Cancel deletion"),
            @rui.alert_dialog_action(scope, "Confirm deletion"),
          ]),
        ]),
      ]),
    ])
  }).map(dialog => {
    fixture_section("fixture-section-alert-dialog", "Alert dialog", [dialog])
  })
}

///|
fn sheet_fixture() -> Val[Html] {
  let right = @rui.sheet(id="fixture-sheet-right", scope => {
    fragment([
      @rui.sheet_trigger(scope, variant=Outline, "Open settings sheet"),
      @rui.sheet_content(scope, side=SheetRight, [
        @rui.sheet_header([
          @rui.sheet_title(scope, "Fixture settings"),
          @rui.sheet_description(scope, "Edit settings in a side sheet."),
        ]),
        div(style=["display:grid;gap:0.5rem"], [
          @rui.label(for_="fixture-sheet-email", "Notification email"),
          @rui.input(id="fixture-sheet-email", value="team@example.com"),
        ]),
        @rui.sheet_footer(@rui.sheet_close(scope, "Save sheet")),
      ]),
    ])
  })
  let bottom = @rui.sheet(id="fixture-sheet-bottom", scope => {
    fragment([
      @rui.sheet_trigger(scope, variant=Outline, "Open bottom sheet"),
      @rui.sheet_content(scope, side=SheetBottom, [
        @rui.sheet_header([
          @rui.sheet_title(scope, "Bottom fixture sheet"),
          @rui.sheet_description(scope, "This sheet enters from below."),
        ]),
        @rui.sheet_footer(@rui.sheet_close(scope, "Close bottom sheet")),
      ]),
    ])
  })
  right.map2(bottom, fn(right, bottom) {
    fixture_section("fixture-section-sheet", "Sheet", [right, bottom])
  })
}

///|
fn context_menu_fixture() -> Val[Html] {
  let (action, set_action) = @rabbita.create_variable("none")
  let menu = @rui.context_menu(
    id="fixture-context-menu",
    default_checked_values=["grid"],
    default_radio_values=[("layout", "canvas")],
    scope => {
      fragment([
        @rui.context_menu_trigger(
          scope,
          tabindex=0,
          style=[
            "display:flex;width:18rem;height:8rem;align-items:center;justify-content:center;border:1px dashed var(--rui-border);border-radius:0.625rem",
          ],
          "Right-click fixture canvas",
        ),
        @rui.context_menu_portal([
          @rui.context_menu_content(scope, aria_label="Fixture canvas menu", [
            @rui.context_menu_group(aria_label="Actions", [
              @rui.context_menu_label("Actions"),
              @rui.context_menu_item(
                scope,
                on_select=set_action(_ => "duplicated"),
                "Duplicate fixture",
              ),
              @rui.context_menu_item(scope, disabled=true, "Unavailable action"),
              @rui.context_menu_checkbox_item(
                scope,
                value="grid",
                close_on_select=false,
                "Show grid",
              ),
            ]),
            @rui.context_menu_separator(),
            @rui.context_menu_radio_group(scope, value="layout", radio => {
              fragment([
                @rui.context_menu_radio_item(
                  radio,
                  value="canvas",
                  close_on_select=false,
                  "Canvas layout",
                ),
                @rui.context_menu_radio_item(
                  radio,
                  value="editor",
                  close_on_select=false,
                  "Editor layout",
                ),
              ])
            }),
            @rui.context_menu_sub(scope, value="move", sub => {
              fragment([
                @rui.context_menu_sub_trigger(sub, "Move fixture"),
                @rui.context_menu_sub_content(sub, [
                  @rui.context_menu_group(aria_label="Destination", [
                    @rui.context_menu_item(scope, "Design system"),
                    @rui.context_menu_item(scope, "Experiments"),
                  ]),
                ]),
              ])
            }),
          ]),
        ]),
      ])
    },
  )
  menu.map2(action, fn(menu, action) {
    fixture_section("fixture-section-context-menu", "Context menu", [
      menu,
      @html.output(id="fixture-context-menu-output", action),
    ])
  })
}
