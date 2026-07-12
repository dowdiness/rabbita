using @rabbita { new, create_pure_state }
using @html { button, div, h1 }

enum Msg {
  Inc
  Dec
}

fn main {
  fn app() {
    let (model, emit) = create_pure_state(
      0,
      update=(msg, model) =>
        match msg {
          Inc => model + 1
          Dec => model - 1
        },
    )
    model.map(model => div(class="app") <| [
      h1("\{model}"),
      div(class="actions") <| [
        button(on_click=emit(Dec), "-"),
        button(on_click=emit(Inc), "+"),
      ],
    ])
  }
  new(app).mount("app")
}
