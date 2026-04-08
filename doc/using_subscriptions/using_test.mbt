///|
using @rabbita {type Dispatch, type Cell, none}

///|
using @html {div, h1, p}

///|
test {
  let viewport_changed : (@common.Viewport) -> Msg = viewport => {
    ViewportChanged(viewport)
  }
  ignore(viewport_changed)

  ignore(subscriptions)
  ignore(app)

  let resized : (@common.Viewport) -> EventMsg = viewport => Resized(viewport)
  let hidden : (Bool) -> EventMsg = value => HiddenChanged(value)
  ignore(resized)
  ignore(hidden)
  ignore(event_subscriptions)
}

///|
test {
  let tag = match HiddenChanged(false) {
    Resized(viewport) => viewport.width
    HiddenChanged(hidden) => if hidden { 1 } else { 0 }
  }
  ignore(tag)
  ignore(event_subscriptions)
}
