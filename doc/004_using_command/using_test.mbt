///|
using @rabbita {type Dispatch, type Cmd, type Html, none, batch}

///|
using @html {div, h1, p, button}

///|
test {
  ignore(RunBatch)
  let batch_tag = match RunBatch {
    RunBatch => 1
    Applied(_) => 2
  }
  ignore(batch_tag)

  ignore(batch_update)
}
