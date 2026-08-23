///|
using @rabbita {type Html, type Val}

///|
using @html {button, div, h1, input, p}

///|
priv enum PureMsg {
  IncrementPure
}

///|
priv enum StatefulMsg {
  IncrementStateful
}

///|
priv enum InitMsg {
  InitReady
}

///|
priv enum InputMsg {
  AddCurrentStep
}

///|
priv enum LabelMsg {
  SetLabel(String)
}

///|
fn app() -> Val[Html] {
  let (pure_count, pure_emit) = @rabbita.create_pure_state(0, update=fn(
    count,
    _,
  ) {
    count + 1
  })
  let (stateful_count, stateful_emit) = @rabbita.create_state(0, update=fn(
    count,
    _,
    _,
  ) {
    (count + 1, @rabbita.none)
  })
  let (initialized, _) = @rabbita.create_state_with_init(
    init=fn(emit) { ("starting", emit(InitReady)) },
    update=fn(_, _, _) { ("ready", @rabbita.none) },
  )
  let (step, set_step) = @rabbita.create_variable(1)
  let (input_count, input_emit) = @rabbita.create_state_with_input(
    input=step,
    init=fn(_, _) { (0, @rabbita.none) },
    update=fn(count, current_step, _, _) {
      (count + current_step, @rabbita.none)
    },
  )
  let (label_value, label_emit) = @rabbita.create_pure_state("", update=fn(
    _,
    message,
  ) {
    match message {
      SetLabel(value) => value
    }
  })
  let input_label = label_emit.map(value => SetLabel(value))
  let doubled = pure_count.map(value => value * 2)
  let total = pure_count.map2(input_count, (left, right) => left + right)
  let summary = doubled.view2(total, (doubled, total) => {
    div(id="derived-values") <| [
      p(id="doubled", "doubled: \{doubled}"),
      p(id="total", "total: \{total}"),
    ]
  })
  let controls = pure_count.map6(
    stateful_count,
    initialized,
    step,
    input_count,
    label_value,
    (pure_count, stateful_count, initialized, step, input_count, label_value) => {
      div <| [
        h1("State and messages"),
        p(id="pure-count", "pure: \{pure_count}"),
        button(on_click=pure_emit(IncrementPure), "Increment pure"),
        p(id="stateful-count", "stateful: \{stateful_count}"),
        button(on_click=stateful_emit(IncrementStateful), "Increment stateful"),
        p(id="init-status", "init: \{initialized}"),
        p(id="step", "step: \{step}"),
        button(on_click=set_step(_ => 3), "Set step to 3"),
        p(id="input-count", "input count: \{input_count}"),
        button(on_click=input_emit(AddCurrentStep), "Add current step"),
        input(
          id="mapped-input",
          value=label_value,
          on_input=input_label,
          placeholder="Mapped input",
        ),
        p(id="mapped-value", "mapped: \{label_value}"),
      ]
    },
  )
  controls.map2(summary, (controls, summary) => div([controls, summary]))
}
