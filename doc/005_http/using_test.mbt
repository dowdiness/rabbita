///|
using @rabbita {type Emit, type Cmd, type Html, none}

///|
using @html {div, p, button}

///|
test {
  let model : Model = initial_model
  ignore(model)

  ignore(Load)
  ignore(Loaded(Ok("hello")))

  let save_model : SaveModel = save_initial_model
  ignore(save_model)

  ignore(SaveGreeting)
  ignore(GreetingSaved(None))

  ignore(update)
  ignore(view)
  ignore(save_update)
  ignore(save_view)
}
