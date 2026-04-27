///|
using @html {div, text}

///|
pub(all) enum Msg {
  Noop
}

///|
fn view(emit : @rabbita.Emit[Msg], _ : Unit) -> @rabbita.Html {
  ignore(emit)
  div([text("project3 sibling app-b")])
}

///|
fn main {
  let app = @rabbita.simple_cell(model=(), update=fn(_, _) { () }, view~)
  @rabbita.new(app).mount("app")
}
