///|
using @rabbita {type Html, type Val}

///|
using @html {button, div, h1}

///|
priv enum Msg {
  Toggle
}

///|
fn app() -> Val[Html] {
  let (enabled, emit) = @rabbita.create_pure_state(false, update=fn(
    enabled,
    _,
  ) {
    !enabled
  })
  enabled.view(enabled => {
    div(class="app") <| [
      h1(if enabled { "On" } else { "Off" }),
      button(on_click=emit(Toggle), "Toggle"),
    ]
  })
}

///|
fn main {
  @rabbita.new(app).mount("app")
}
