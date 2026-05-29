///|
using @html {div, text}

///|
fn main {
  let app = @rabbita.simple_cell(
    model="moonModDir",
    update=fn(_ : Unit, model) { model },
    view=fn(_ : @rabbita.Emit[Unit], model) { div([text(model)]) },
  )
  @rabbita.new(app).mount("app")
}
