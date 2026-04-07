///|
using @html {div, text}

///|
pub(all) enum Msg {
  Noop
}

///|
fn view(dispatch : @rabbita.Dispatch[Msg], _ : Unit) -> @rabbita.Html {
  ignore(dispatch)
  div([text("project3 sibling app-b")])
}

///|
fn main {
  let app = @rabbita.simple_cell(model=(), update=fn(_, _) { () }, view~)
  @rabbita.new(app).mount("app")
}
