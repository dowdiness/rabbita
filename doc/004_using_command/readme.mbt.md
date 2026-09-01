# Using Command

`Cmd` is Rabbita's **managed effect** value: it describes side-effect work for
the runtime, but does not execute by itself.  
If you only `ignore(cmd)`, nothing runs.

A command executes only after it is handed to the runtime, for example:

- returned from `update`
- attached to an event handler in `view`
- passed into app APIs like `with_init`


## State without commands vs state with commands

In earlier tours we used `@rabbita.create_pure_state`:

```text
update : (Model, Msg) -> Model
```

When you need follow-up effects, use `@rabbita.create_state`:

```text
update : (Model, Msg, Emit[Msg]) -> (Model, Cmd)
```

This update shape lets you return an extra `Cmd`.
`Emit[Msg]` turns messages into command values (for example, `emit(Inc)`),
so `update` can coordinate side effects while `view` stays declarative.

## A minimal command-powered app

To keep continuity with previous tours, we still use a counter example.
This version introduces one command message, `IncLater`, to show how
`emit` and `delay` cooperate: `emit(Inc)` turns a message into a `Cmd`,
and `delay(cmd, ms)` tells runtime to execute that command later.

```moonbit nocheck
///|
enum Msg {
  Inc
  IncLater
  Reset
}

///|
type Model = Int

///|
fn update(count : Model, msg : Msg, emit : Emit[Msg]) -> (Model, Cmd) {
  match msg {
    Inc => (count + 1, none)
    IncLater => (count, delay(emit(Inc), 300))
    Reset => (0, none)
  }
}

///|
fn view(emit : Emit[Msg], count : Model) -> Html {
  div([
    h1("count = \{count}"),
    p("`IncLater` is implemented by `delay(emit(Inc), 300)`."),
    button(on_click=emit(Inc), "+1"),
    button(on_click=emit(IncLater), "+1 after 300ms"),
    button(on_click=emit(Reset), "reset"),
  ])
}
```

In this update function, `none` means "no extra managed effect".
So `Inc` and `Reset` both return `none` because they only change state
immediately. `IncLater` is different: it returns a real command
(`delay(emit(Inc), 300)`) and keeps state unchanged for now.

`Inc` and `Reset` are immediate state transitions, while `IncLater` returns
`(count, delay(emit(Inc), 300))` and leaves `count` unchanged for now.
If you click `+1 after 300ms`, the sequence is:

1. `view` emits `IncLater`.
2. `update` returns `(count, delay(emit(Inc), 300))`, so state stays unchanged.
3. After 300ms, runtime executes the delayed command and emits `Inc`.
4. `update` handles `Inc` and increments `count`.

The key mental model is that `update` can return both a new state and a managed
effect that may emit future messages.


## Common command helpers

After `emit + delay`, the most common helpers are `batch`, `perform`, and
`attempt`. Use them based on whether you need to combine commands, run async
work that should succeed, or handle async failure explicitly.

### `batch`

Use `batch` when one branch should trigger multiple commands together.

```moonbit check
///|
enum BatchMsg {
  RunBatch
  Applied(Int)
}

///|
fn batch_update(
  model : Int,
  msg : BatchMsg,
  emit : Emit[BatchMsg],
) -> (Int, Cmd) {
  match msg {
    RunBatch => (model, batch([emit(Applied(1)), emit(Applied(2))]))
    Applied(value) => (model + value, none)
  }
}
```

### `perform`

Use `perform` when async work is expected to succeed and you want to map the
result back into a normal message.

```moonbit nocheck
///|
enum PerformMsg {
  StartLoad
  Loaded(Int)
}

///|
fn perform_update(
  model : Int,
  msg : PerformMsg,
  emit : Emit[PerformMsg],
) -> (Int, Cmd) {
  match msg {
    StartLoad =>
      (model, @rabbita.perform(value => emit(Loaded(value)), () => 42))
    Loaded(value) => (model + value, none)
  }
}
```

### `attempt`

Use `attempt` when async work may fail and you want success/failure handled in
the same `update` flow through `Result`.

```moonbit nocheck
///|
enum AttemptMsg {
  StartTry
  Tried(Result[Int, Error])
}

///|
fn attempt_update(
  model : Int,
  msg : AttemptMsg,
  emit : Emit[AttemptMsg],
) -> (Int, Cmd) {
  match msg {
    StartTry =>
      (
        model,
        @rabbita.attempt(result => emit(Tried(result)), () => {
          if model % 2 == 0 {
            10
          } else {
            fail("demo failure")
          }
        }),
      )
    Tried(result) =>
      match result {
        Ok(value) => (model + value, none)
        Err(_) => (model, none)
      }
  }
}
```

`effect` is also available for fire-and-forget side work.

## Key takeaways

- `Cmd` keeps side effects out of pure rendering logic.
- `view` stays the same shape: `(Emit[Msg], Model) -> Html`.
- `update` becomes command-aware and returns `(Model, Cmd)`.
- Use `none` when no side effect is needed, and use `batch` when multiple commands should run.

## What comes next

This chapter only covers the core command model and `@rabbita.create_state`.

In follow-up chapters, we can cover practical command packages separately:

- `@http` for requests
- `@clipboard` for copy/paste
- `@nav` for navigation
- `@dialog` for open/close dialog workflows
