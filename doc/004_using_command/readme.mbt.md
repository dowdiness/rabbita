# Using Command

`Cmd` is Rabbita's **managed effect** value: it describes side-effect work for
the runtime, but does not execute by itself.  
If you only `ignore(cmd)`, nothing runs.

A command executes only after it is handed to the runtime, for example:

- returned from `update`
- attached to an event handler in `view`
- passed into app APIs like `with_init`


## `simple_cell` vs `cell`

In earlier tours we used `@rabbita.simple_cell`:

```text
update : (Msg, Model) -> Model
```

When you need follow-up effects, use `@rabbita.cell`:

```text
update : (Dispatch[Msg], Msg, Model) -> (Cmd, Model)
```

This update shape lets you return an extra `Cmd`.
`Dispatch[Msg]` turns messages into command values (for example, `dispatch(Inc)`),
so `update` can coordinate side effects while `view` stays declarative.

## A minimal command-powered app

To keep continuity with previous tours, we still use a counter example.
This version introduces one command message, `IncLater`, to show how
`dispatch` and `delay` cooperate: `dispatch(Inc)` turns a message into a `Cmd`,
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
fn update(dispatch : Dispatch[Msg], msg : Msg, count : Model) -> (Cmd, Model) {
  match msg {
    Inc => (none, count + 1)
    IncLater => (delay(dispatch(Inc), 300), count)
    Reset => (none, 0)
  }
}

///|
fn view(dispatch : Dispatch[Msg], count : Model) -> Html {
  div([
    h1("count = \{count}"),
    p("`IncLater` is implemented by `delay(dispatch(Inc), 300)`."),
    button(on_click=dispatch(Inc), "+1"),
    button(on_click=dispatch(IncLater), "+1 after 300ms"),
    button(on_click=dispatch(Reset), "reset"),
  ])
}
```

In this update function, `none` means "no extra managed effect".
So `Inc` and `Reset` both return `none` because they only change state
immediately. `IncLater` is different: it returns a real command
(`delay(dispatch(Inc), 300)`) and keeps state unchanged for now.

`Inc` and `Reset` are immediate state transitions, while `IncLater` returns
`(delay(dispatch(Inc), 300), count)` and leaves `count` unchanged for now.
If you click `+1 after 300ms`, the sequence is:

1. `view` dispatches `IncLater`.
2. `update` returns `(delay(dispatch(Inc), 300), count)`, so state stays unchanged.
3. After 300ms, runtime executes the delayed command and dispatches `Inc`.
4. `update` handles `Inc` and increments `count`.

The key mental model is that `update` can return both a new state and a managed
effect that may emit future messages.


## Common command helpers

After `dispatch + delay`, the most common helpers are `batch`, `perform`, and
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
  dispatch : Dispatch[BatchMsg],
  msg : BatchMsg,
  model : Int,
) -> (Cmd, Int) {
  match msg {
    RunBatch => (batch([dispatch(Applied(1)), dispatch(Applied(2))]), model)
    Applied(value) => (none, model + value)
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
  dispatch : Dispatch[PerformMsg],
  msg : PerformMsg,
  model : Int,
) -> (Cmd, Int) {
  match msg {
    StartLoad =>
      (@rabbita.perform(value => dispatch(Loaded(value)), () => 42), model)
    Loaded(value) => (none, model + value)
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
  dispatch : Dispatch[AttemptMsg],
  msg : AttemptMsg,
  model : Int,
) -> (Cmd, Int) {
  match msg {
    StartTry =>
      (
        @rabbita.attempt(result => dispatch(Tried(result)), () => {
          if model % 2 == 0 {
            10
          } else {
            fail("demo failure")
          }
        }),
        model,
      )
    Tried(result) =>
      match result {
        Ok(value) => (none, model + value)
        Err(_) => (none, model)
      }
  }
}
```

`effect` is also available for fire-and-forget side work.

## Key takeaways

- `Cmd` keeps side effects out of pure rendering logic.
- `view` stays the same shape: `(Dispatch[Msg], Model) -> Html`.
- `update` becomes command-aware and returns `(Cmd, Model)`.
- Use `none` when no side effect is needed, and use `batch` when multiple commands should run.

## What comes next

This chapter only covers the core command model and `@rabbita.cell`.

In follow-up chapters, we can cover practical command packages separately:

- `@http` for requests
- `@clipboard` for copy/paste
- `@nav` for navigation
- `@dialog` for open/close dialog workflows
