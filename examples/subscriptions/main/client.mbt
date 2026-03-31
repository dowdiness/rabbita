///|
using @html {button, code, div, h1, p, text}

///|
using @rabbita {type Cmd, type Dispatch, type Html}

///|
enum Msg {
  Tick
  ToggleTicker
  Resized
}

///|
struct Model {
  seconds : Int
  resize_count : Int
  ticking : Bool
}

///|
fn update(_ : Dispatch[Msg], msg : Msg, model : Model) -> (Cmd, Model) {
  match msg {
    Tick => (@rabbita.none, { ..model, seconds: model.seconds + 1 })
    ToggleTicker => (@rabbita.none, { ..model, ticking: !model.ticking })
    Resized =>
      (@rabbita.none, { ..model, resize_count: model.resize_count + 1 })
  }
}

///|
fn subscriptions(dispatch : Dispatch[Msg], model : Model) -> @sub.Sub {
  println("sub")
  @sub.batch([
    @sub.on_resize(dispatch(Resized)),
    if model.ticking {
      @sub.every(1000, dispatch(Tick))
    } else {
      @sub.none
    },
  ])
}

///|
fn toggle_label(ticking : Bool) -> String {
  if ticking {
    "Pause ticker"
  } else {
    "Resume ticker"
  }
}

///|
fn view(dispatch : Dispatch[Msg], model : Model) -> Html {
  let ticker_status = if model.ticking { "Active" } else { "Paused" }
  div(class="page") <| [
    div(class="panel") <| [
      p(class="eyebrow", "Rabbita example"),
      h1(class="title", "Subscriptions"),
      p(
        class="lead",
        "This example wires a timer and a resize listener through the ",
      ),
      p(class="lead") <| [
        code(class="inline-code", "subscriptions="),
        text(" hook on a cell."),
      ],
      div(class="stats") <| [
        div(class="stat") <| [
          p(class="label", "Ticker status"),
          p(class="value", ticker_status),
        ],
        div(class="stat") <| [
          p(class="label", "Seconds from @sub.every"),
          p(class="value", "\{model.seconds}"),
        ],
        div(class="stat") <| [
          p(class="label", "Resize events from @sub.on_resize"),
          p(class="value", "\{model.resize_count}"),
        ],
      ],
      div(class="actions") <| [
        button(
          class="toggle",
          on_click=dispatch(ToggleTicker),
          toggle_label(model.ticking),
        ),
      ],
      p(
        class="note",
        "Try resizing the window. Pause the ticker to see only the resize subscription stay active.",
      ),
    ],
  ]
}

///|
#cfg(target="js")
fn main {
  let app = @rabbita.cell(
    model={ seconds: 0, resize_count: 0, ticking: true },
    update~,
    view~,
    subscriptions~,
  )
  @rabbita.new(app).mount("app")
}
