///|
using @rabbita {type Dispatch, type Cmd, type Html, none, batch}

///|
using @html {div, h1, p, button}

///|
test {
  let render : (Dispatch[BatchMsg], Html) -> Html = (dispatch, child) => {
    div([
      h1("batch"),
      p("command"),
      button(on_click=dispatch(RunBatch), "run"),
      child,
    ])
  }
  ignore(render)

  let idle : Cmd = none
  let combined : Cmd = batch([idle])
  ignore(combined)

  ignore(RunBatch)
  ignore(Applied(0))
  let batch_tag = match RunBatch {
    RunBatch => 1
    Applied(_) => 2
  }
  ignore(batch_tag)

  ignore(batch_update)
}
