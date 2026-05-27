using @vector {type Vector}
using @rabbita {simple_cell, new, type Emit, type Html}
using @html {button, div, h1, input, li, span, ul, nothing, form}

///|
struct Todo {
  title : String
  done : Bool
} derive(Eq)

///|
struct Model {
  draft : String
  items : Vector[Todo]
}

///|
enum Msg {
  DraftChanged(String)
  Add
  Toggle(Todo)
  Delete(Todo)
}

///|
fn update(msg : Msg, model : Model) -> Model {
  let { draft, items } = model
  match msg {
    DraftChanged(draft) => { ..model, draft, }
    Add if draft == "" => model
    Add => { draft: "", items: items.push({ title: draft, done: false }) }
    Delete(todo) => { ..model, items: items.filter(x => x != todo) }
    Toggle(todo) =>
      {
        ..model,
        items: items.map(x => {
          guard x == todo else { return x }
          { ..x, done: !x.done }
        }),
      }
  }
}

///|
fn view(emit : Emit[Msg], model : Model) -> Html {
  let { draft, items } = model
  let total = items.length()
  let completed = items.filter(x => x.done).length()

  div(class="panel") <| [
    h1("Todos"),
    form(on_submit=emit(Add)) <| [
      input(
        value=draft,
        placeholder="What needs doing?",
        on_input=emit.map(s => DraftChanged(s)),
        nothing,
      ),
      input(input_type=Submit, "add"),
    ],
    ul() <| [
      for x in items => {
        li(class=if x.done { "done" } else { "" }) <| [
          input(
            input_type=Checkbox,
            checked=x.done,
            on_change=emit.map(_ => Toggle(x)),
            nothing,
          ),
          span(x.title),
          button(on_click=emit(Delete(x)), "delete"),
        ]
      }
    ],
    span(class="footer", "\{total - completed} active / \{completed} done"),
  ]
}

///|
fn main {
  let app = simple_cell(
    model={ draft: "", items: Vector::new() },
    update~,
    view~,
  )
  new(app).mount("app")
}
