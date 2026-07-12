///|
using @html {div, text}

///|
fn main {
  let app = @rabbita.new(() => {
    let (model, emit) = @rabbita.create_pure_state(
      "moonModDir",
      update=fn(_ : Unit, model) { model },
    )
    model.map(model => {
      ignore(emit)
      div([text(model)])
    })
  })
  app.mount("app")
}
