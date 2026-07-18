///|
const DatePickerShowcaseGroupStyle : String = "display:flex;min-width:0;flex-direction:column;gap:0.625rem"

///|
const DatePickerShowcaseSingleCode : String =
  #|fn single_date_picker_demo() -> @rabbita.Val[@html.Html] {
  #|  let today = @rui.calendar_date(year=2026, month=7, day=16)
  #|  let picker = @rui.date_picker(
  #|    id="forms-gallery-date-picker-single",
  #|    default_value=today,
  #|    today~,
  #|    presets=[
  #|      @rui.date_picker_preset(label="Today", value=today),
  #|      @rui.date_picker_preset(
  #|        label="Tomorrow",
  #|        value=@rui.calendar_date(year=2026, month=7, day=17),
  #|      ),
  #|      @rui.date_picker_preset(
  #|        label="Next week",
  #|        value=@rui.calendar_date(year=2026, month=7, day=23),
  #|      ),
  #|      @rui.date_picker_preset(
  #|        label="Release",
  #|        value=@rui.calendar_date(year=2026, month=8, day=4),
  #|      ),
  #|    ],
  #|    trigger_style=["width:100%"],
  #|  )
  #|  picker.view(picker => {
  #|    @html.div(style=["width:min(100%,22rem);margin-inline:auto"], [
  #|      @html.div(
  #|        style=["display:flex;min-width:0;flex-direction:column;gap:0.625rem"],
  #|        [
  #|          @rui.label(
  #|            for_="forms-gallery-date-picker-single-trigger",
  #|            "Release date",
  #|          ),
  #|          picker,
  #|        ],
  #|      ),
  #|    ])
  #|  })
  #|}
  #|

///|
const DatePickerShowcaseRangeCode : String =
  #|fn date_range_picker_demo() -> @rabbita.Val[@html.Html] {
  #|  let picker = @rui.date_range_picker(
  #|    id="forms-gallery-date-picker-range",
  #|    default_value=@rui.date_range(
  #|      start=@rui.calendar_date(year=2026, month=7, day=20),
  #|      end=@rui.calendar_date(year=2026, month=8, day=9),
  #|    ),
  #|    today=@rui.calendar_date(year=2026, month=7, day=16),
  #|    trigger_style=["width:100%"],
  #|  )
  #|  picker.view(picker => {
  #|    @html.div(style=["width:min(100%,22rem);margin-inline:auto"], [
  #|      @html.div(
  #|        style=["display:flex;min-width:0;flex-direction:column;gap:0.625rem"],
  #|        [
  #|          @rui.label(
  #|            for_="forms-gallery-date-picker-range-trigger",
  #|            "Release window",
  #|          ),
  #|          picker,
  #|        ],
  #|      ),
  #|    ])
  #|  })
  #|}
  #|

///|
const DatePickerShowcaseDisabledCode : String =
  #|fn disabled_date_picker_demo() -> @rabbita.Val[@html.Html] {
  #|  let disabled = @rui.date_picker(
  #|    id="forms-gallery-date-picker-disabled",
  #|    disabled=true,
  #|    placeholder="No dates available",
  #|    trigger_style=["width:100%"],
  #|  )
  #|  disabled.view(disabled => {
  #|    @html.div(
  #|      style=["width:min(100%,22rem);margin-inline:auto"],
  #|      @html.div(
  #|        style=["display:flex;min-width:0;flex-direction:column;gap:0.625rem"],
  #|        [
  #|          @rui.label(
  #|            for_="forms-gallery-date-picker-disabled-trigger",
  #|            "Disabled",
  #|          ),
  #|          disabled,
  #|        ],
  #|      ),
  #|    )
  #|  })
  #|}
  #|

///|
const DatePickerShowcaseInvalidCode : String =
  #|fn invalid_date_picker_demo() -> @rabbita.Val[@html.Html] {
  #|  let invalid = @rui.date_picker(
  #|    id="forms-gallery-date-picker-invalid",
  #|    invalid=true,
  #|    placeholder="Required date",
  #|    trigger_style=["width:100%"],
  #|  )
  #|  invalid.view(invalid => {
  #|    @html.div(
  #|      style=["width:min(100%,22rem);margin-inline:auto"],
  #|      @html.div(
  #|        style=["display:flex;min-width:0;flex-direction:column;gap:0.625rem"],
  #|        [
  #|          @rui.label(
  #|            for_="forms-gallery-date-picker-invalid-trigger",
  #|            "Invalid",
  #|          ),
  #|          invalid,
  #|        ],
  #|      ),
  #|    )
  #|  })
  #|}
  #|

///|
fn date_picker_showcase_group(
  label : String,
  trigger_id : String,
  picker : @html.Html,
) -> @html.Html {
  @html.div(style=[DatePickerShowcaseGroupStyle], [
    @rui.label(for_=trigger_id, label),
    picker,
  ])
}

///|
fn date_picker_showcase() -> @rabbita.Val[@html.Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let single = @rui.date_picker(
    id="forms-gallery-date-picker-single",
    default_value=today,
    today~,
    presets=[
      @rui.date_picker_preset(label="Today", value=today),
      @rui.date_picker_preset(
        label="Tomorrow",
        value=@rui.calendar_date(year=2026, month=7, day=17),
      ),
      @rui.date_picker_preset(
        label="Next week",
        value=@rui.calendar_date(year=2026, month=7, day=23),
      ),
      @rui.date_picker_preset(
        label="Release",
        value=@rui.calendar_date(year=2026, month=8, day=4),
      ),
    ],
    trigger_style=["width:100%"],
  )
  let range = @rui.date_range_picker(
    id="forms-gallery-date-picker-range",
    default_value=@rui.date_range(
      start=@rui.calendar_date(year=2026, month=7, day=20),
      end=@rui.calendar_date(year=2026, month=8, day=9),
    ),
    today~,
    trigger_style=["width:100%"],
  )
  let disabled = @rui.date_picker(
    id="forms-gallery-date-picker-disabled",
    disabled=true,
    placeholder="No dates available",
    trigger_style=["width:100%"],
  )
  let invalid = @rui.date_picker(
    id="forms-gallery-date-picker-invalid",
    invalid=true,
    placeholder="Required date",
    trigger_style=["width:100%"],
  )
  single.view4(range, disabled, invalid, (single, range, disabled, invalid) => {
    showcase_component_demos(
      "Date Picker",
      "Single dates, presets, and ranges own their popup and calendar state. Disabled and invalid variants keep the same public API.",
      [
        showcase_demo_section(
          "Single date with presets",
          "Preset actions and the calendar share one component-owned value and popup.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,22rem);margin-inline:auto"],
              date_picker_showcase_group(
                "Release date", "forms-gallery-date-picker-single-trigger", single,
              ),
            ),
            DatePickerShowcaseSingleCode,
            tall=true,
          ),
        ),
        showcase_demo_section(
          "Date range",
          "Two activations produce a normalized start and end while the trigger remains black-box.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,22rem);margin-inline:auto"],
              date_picker_showcase_group(
                "Release window", "forms-gallery-date-picker-range-trigger", range,
              ),
            ),
            DatePickerShowcaseRangeCode,
            tall=true,
          ),
        ),
        showcase_demo_section(
          "Disabled",
          "The unavailable picker keeps the same trigger geometry while leaving the tab order.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,22rem);margin-inline:auto"],
              date_picker_showcase_group(
                "Disabled", "forms-gallery-date-picker-disabled-trigger", disabled,
              ),
            ),
            DatePickerShowcaseDisabledCode,
            variant=ShowcaseStagePlain,
          ),
        ),
        showcase_demo_section(
          "Invalid",
          "Validation treatment keeps the date picker interactive and its popup component-owned.",
          showcase_demo_stage(
            @html.div(
              style=["width:min(100%,22rem);margin-inline:auto"],
              date_picker_showcase_group(
                "Invalid", "forms-gallery-date-picker-invalid-trigger", invalid,
              ),
            ),
            DatePickerShowcaseInvalidCode,
            variant=ShowcaseStagePlain,
          ),
        ),
      ],
    )
  })
}
