///|
fn form_fixture() -> Val[Html] {
  let (state, set_state) = @rabbita.create_variable(
    ("Ada Lovelace", "analytical-engine", "Initial launch note", false),
  )
  state.view(state => {
    let (name, website, note, submitted) = state
    fixture_section(
      "fixture-section-form",
      "Form, Field, Input, Input Group, and Textarea",
      [
        @rui.form(
          id="fixture-profile-form",
          name="fixture-profile",
          on_submit=set_state(current => (current.0, current.1, current.2, true)),
          @rui.field_set([
            @rui.field_legend("Fixture profile"),
            @rui.field_group([
              @rui.form_field(
                name="display-name",
                required=true,
                describedby="fixture-name-description",
                [
                  @rui.form_label(for_="fixture-form-name", "Display name"),
                  @rui.form_control(
                    @rui.input(
                      id="fixture-form-name",
                      name="display-name",
                      value=name,
                      required=true,
                      attrs=@html.Attrs::build().aria_describedby(
                        "fixture-name-description",
                      ),
                      placeholder="Ada Lovelace",
                      on_input=set_state.map(value => {
                        current => (value, current.1, current.2, false)
                      }),
                    ),
                  ),
                  @rui.form_description(
                    id="fixture-name-description",
                    "Shown to fixture collaborators.",
                  ),
                ],
              ),
              @rui.field([
                @rui.field_label(for_="fixture-form-site", "Workspace URL"),
                @rui.input_group([
                  @rui.input_group_addon(
                    for_="fixture-form-site",
                    @rui.input_group_text("https://"),
                  ),
                  @rui.input_group_input(
                    id="fixture-form-site",
                    name="workspace-url",
                    value=website,
                    on_input=set_state.map(value => {
                      current => (current.0, value, current.2, false)
                    }),
                  ),
                  @rui.input_group_addon(
                    align=InputInlineEnd,
                    @rui.input_group_text(".moonbit.app"),
                  ),
                ]),
              ]),
              @rui.field([
                @rui.field_label(for_="fixture-form-note", "Launch note"),
                @rui.textarea(
                  id="fixture-form-note",
                  name="launch-note",
                  value=note,
                  rows=3,
                  on_input=set_state.map(value => {
                    current => (current.0, current.1, value, false)
                  }),
                ),
              ]),
            ]),
            @html.output(
              id="fixture-form-output",
              if submitted {
                "submitted:\{name}|\{website}|\{note}"
              } else {
                "editing:\{name}|\{website}|\{note}"
              },
            ),
            @rui.button(type_="submit", "Save fixture profile"),
          ]),
        ),
      ],
    )
  })
}

///|
fn native_select_fixture() -> Val[Html] {
  let (value, set_value) = @rabbita.create_variable("team")
  value.view(value => {
    fixture_section("fixture-section-native-select", "Native Select", [
      div(style=["display:grid;gap:0.5rem"], [
        @rui.label(for_="fixture-native-select", "Access scope"),
        @rui.native_select(
          id="fixture-native-select",
          name="access-scope",
          value~,
          on_change=set_value.map(value => _ => value),
          [
            @rui.native_select_optgroup(label="Workspace", [
              @rui.native_select_option(value="personal", "Personal"),
              @rui.native_select_option(value="team", "Team"),
            ]),
            @rui.native_select_optgroup(label="Advanced", [
              @rui.native_select_option(value="organization", "Organization"),
            ]),
          ],
        ),
        @html.output(id="fixture-native-select-output", "selected:\{value}"),
      ]),
      div(style=["display:grid;gap:0.5rem"], [
        @rui.label(for_="fixture-native-select-disabled", "Environment"),
        @rui.native_select(
          id="fixture-native-select-disabled",
          disabled=true,
          value="production",
          [
            @rui.native_select_option(value="production", "Production"),
            @rui.native_select_option(value="preview", "Preview"),
          ],
        ),
      ]),
    ])
  })
}

///|
fn input_otp_fixture() -> Val[Html] {
  let (value, set_value) = @rabbita.create_variable("")
  let (completed, set_completed) = @rabbita.create_variable("")
  let otp = @rui.input_otp(
    id="fixture-input-otp",
    max_length=6,
    separator_after=3,
    pattern="[0-9]*",
    aria_label="Fixture verification code",
    on_value_change=set_value.map(value => _ => value),
    on_complete=set_completed.map(value => _ => value),
  )
  let disabled = @rui.input_otp(
    id="fixture-input-otp-disabled",
    max_length=6,
    default_value="482931",
    disabled=true,
    aria_label="Previously verified fixture code",
  )
  otp.map4(value, completed, disabled, fn(otp, value, completed, disabled) {
    fixture_section("fixture-section-input-otp", "Input OTP", [
      div(style=["display:grid;gap:0.5rem"], [
        otp,
        @html.output(id="fixture-otp-value", "value:\{value}"),
        @html.output(id="fixture-otp-complete", "complete:\{completed}"),
      ]),
      disabled,
    ])
  })
}

///|
fn forms_extended_fixture() -> Val[Html] {
  form_fixture().map3(native_select_fixture(), input_otp_fixture(), fn(
    form,
    native_select,
    otp,
  ) {
    fragment([form, native_select, otp])
  })
}
