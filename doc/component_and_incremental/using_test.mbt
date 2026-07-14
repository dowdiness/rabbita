///|
using @rabbita {type Html, type Val, none}

///|
using @html {button, div, h1, h2, li, main_, nothing, p, section, span, ul}

///|
using @vector {type Vector}

///|
test {
  ignore(app)
  ignore(dashboard)
  ignore(stepped_counter)
  ignore(todo_list)
  ignore(cached_panel)
  ignore(disposable_panel)
  ignore(Dashboard::{ count: 0, status: "ready" })
  ignore(Todo::{ id: 1, title: "Read", details: "Read the chapter" })
  let panels = [Overview, Preferences]
  ignore(panels)
}
