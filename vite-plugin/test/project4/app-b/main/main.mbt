///|
using @html {div, text}

///|
pub(all) enum Msg {
  Noop
}

///|
fn view(emit : @rabbita.Emit[Msg], _ : Unit) -> @rabbita.Html {
  ignore(emit)
  div([text("local project4 app-b")])
}

///|
fn main {
  let app = @rabbita.simple_cell(model=(), update=fn(_, _) { () }, view~)
  @rabbita.new(app).mount("app")
}
