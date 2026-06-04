using @rabbita { simple_cell, new }
using @html {div, h1, button}

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
    view=(emit, model) => div <| [
      h1("\{model}"),
      button(on_click=emit(Inc), "+"),
      button(on_click=emit(Dec), "-"),
    ],
  )
  new(app).mount("app")
}