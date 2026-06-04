using @sorted_map {type SortedMap}
using @rabbita {simple_cell, new, type Emit, type Html}
using @html {button, div, h1, input, li, span, ul, form}

///|
struct Todo {
  title : String
  done : Bool
} derive(Eq)

///|
struct Model {
  title : String
  items : SortedMap[Int, Todo]
  next : Int
}

///|
enum Msg {
  TitleChanged(String)
  Add
  Toggle(Int, Todo)
  Delete(Int)
}

///|
fn view(emit : Emit[Msg], model : Model) -> Html {
  let { title, items, .. } = model
  let total = items.length()
  let completed = items.filter((_, x) => x.done).length()

  div(class="panel") <| [
    h1("Todos"),
    form(on_submit=emit(Add)) <| [
      input(
        value=title,
        placeholder="What needs doing?",
        on_input=emit.map(s => TitleChanged(s)),
      ),
      input(input_type=Submit, value="add"),
    ],
    ul <| [
      for id, x in items => {
        li(class=if x.done { "done" } else { "" }) <| [
          input(
            input_type=Checkbox,
            checked=x.done,
            on_change=emit.map(_ => Toggle(id, x)),
          ),
          span(x.title),
          button(on_click=emit(Delete(id)), "delete"),
        ]
      }
    ],
    span(class="footer", "\{total - completed} active / \{completed} done"),
  ]
}

///|
fn update(msg : Msg, model : Model) -> Model {
  let { title, items, next } = model
  match msg {
    TitleChanged(title) => { ..model, title, }
    Add if title == "" => model
    Add =>
      {
        title: "",
        items: items.add(next, { title, done: false }),
        next: next + 1,
      }
    Delete(id) => { ..model, items: items.remove(id) }
    Toggle(id, todo) =>
      { ..model, items: items.add(id, { ..todo, done: !todo.done }) }
  }
}

///|
fn main {
  let app = simple_cell(
    model={ title: "", items: SortedMap::new(), next: 0 },
    update~,
    view~,
  )
  new(app).mount("app")
}
