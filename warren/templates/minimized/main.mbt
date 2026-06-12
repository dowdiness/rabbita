using @rabbita { new, simple_cell }
using @html { button, div, h1 }

enum Msg {
  Inc
  Dec
}

fn main {
  let app = simple_cell(
    model=0,
    update=(msg, model) => match msg {
      Inc => model + 1
      Dec => model - 1
    },
    view=(emit, model) => div(class="app") <| [
      h1("\{model}"),
      div(class="actions") <| [
        button(on_click=emit(Dec), "-"),
        button(on_click=emit(Inc), "+"),
      ],
    ],
  )
  new(app).mount("app")
}
