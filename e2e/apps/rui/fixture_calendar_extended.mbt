///|
fn fixture_range_text(value : @rui.DateRange) -> String {
  let start = value.start().to_iso_string()
  match value.end() {
    Some(end) => "\{start}..\{end.to_iso_string()}"
    None => "\{start}..pending"
  }
}

///|
fn calendar_range_fixture() -> Val[Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let (selection, set_selection) = @rabbita.create_variable(
    "2026-07-10..2026-07-17",
  )
  let calendar = @rui.calendar_range(
    id="fixture-calendar-range",
    default_month=@rui.calendar_date(year=2026, month=7, day=1),
    default_selected=@rui.date_range(
      start=@rui.calendar_date(year=2026, month=7, day=10),
      end=@rui.calendar_date(year=2026, month=7, day=17),
    ),
    today~,
    aria_label="Fixture release window",
    on_select=set_selection.map(value => _ => fixture_range_text(value)),
  )
  calendar.map2(selection, fn(calendar, selection) {
    fixture_section("fixture-section-calendar-range", "Calendar Range", [
      calendar,
      @html.output(id="fixture-calendar-range-output", selection),
    ])
  })
}

///|
fn calendar_multiple_fixture() -> Val[Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let (selection, set_selection) = @rabbita.create_variable(
    "2026-07-08,2026-07-16",
  )
  let calendar = @rui.calendar_multiple(
    id="fixture-calendar-multiple",
    default_month=@rui.calendar_date(year=2026, month=7, day=1),
    default_selected=[@rui.calendar_date(year=2026, month=7, day=8), today],
    today~,
    aria_label="Fixture available dates",
    on_select=set_selection.map(values => {
      _ => values.map(date => date.to_iso_string()).join(",")
    }),
  )
  calendar.map2(selection, fn(calendar, selection) {
    fixture_section("fixture-section-calendar-multiple", "Calendar Multiple", [
      calendar,
      @html.output(id="fixture-calendar-multiple-output", selection),
    ])
  })
}

///|
fn date_range_picker_fixture() -> Val[Html] {
  let today = @rui.calendar_date(year=2026, month=7, day=16)
  let (selection, set_selection) = @rabbita.create_variable(
    "2026-07-20..2026-07-24",
  )
  let (open_state, set_open_state) = @rabbita.create_variable("closed")
  let picker = @rui.date_range_picker(
    id="fixture-date-range-picker",
    default_value=@rui.date_range(
      start=@rui.calendar_date(year=2026, month=7, day=20),
      end=@rui.calendar_date(year=2026, month=7, day=24),
    ),
    today~,
    aria_label="Fixture deployment window",
    on_value_change=set_selection.map(value => _ => fixture_range_text(value)),
    on_open_change=set_open_state.map(open => {
      _ => if open { "open" } else { "closed" }
    }),
  )
  picker.map3(selection, open_state, fn(picker, selection, open_state) {
    fixture_section("fixture-section-date-range-picker", "Date Range Picker", [
      picker,
      @html.output(
        id="fixture-date-range-picker-output",
        "state:\{open_state}|value:\{selection}",
      ),
    ])
  })
}

///|
fn calendar_extended_fixture() -> Val[Html] {
  calendar_range_fixture().map3(
    calendar_multiple_fixture(),
    date_range_picker_fixture(),
    fn(range, multiple, picker) { fragment([range, multiple, picker]) },
  )
}
