# Components and the Incremental Graph

A Rabbita component is an ordinary MoonBit function that builds part of the
incremental graph and returns a `Val[Html]`. It may create local state, derive
values, and call other components.

There is no separate `Component` type. A component function does not correspond
one-to-one with an `Html` value and an ordinary function call does not create a
lifecycle boundary by itself. The useful distinction is between building the
graph and evaluating it:

- The root body runs at mount, and fixed child bodies run as their parent builds
- Selector-created components run when their dynamic branch is created
- `map`, `view`, and `view2` through `view9` callbacks run when needed
- State updates reevaluate affected callbacks instead of rebuilding the app

## Build and compose components

This component owns a counter state machine. `create_pure_state` returns the
state as `count : Val[Int]` and an emitter for `CounterMsg` commands.

```moonbit check
///|
enum CounterMsg {
  Increment
  Decrement
}

///|
fn counter(title : String) -> Val[Html] {
  let (count, emit) = @rabbita.create_pure_state(0, update=fn(msg, count) {
    match msg {
      Increment => count + 1
      Decrement => count - 1
    }
  })
  count.view(count => {
    section([
      h2(title),
      button(on_click=emit(Decrement), "-"),
      span(count.to_string()),
      button(on_click=emit(Increment), "+"),
    ])
  })
}
```

A parent component can build two independent counters and combine their
incremental `Html` values:

```moonbit check
///|
fn app() -> Val[Html] {
  let left = counter("Left")
  let right = counter("Right")
  left.view2(right, (left, right) => main_([left, right]))
}
```

When `app` is mounted, its body calls `counter` twice and constructs this graph:

```text
left count  -> left view  --+
                            +-> app view2 -> root Html
right count -> right view --+
```

Clicking the left counter changes the left state. The left `view` callback and
the final `view2` callback reevaluate, while the right `view` callback does not.
The bodies of `app` and `counter` do not run again for that update.

```moonbit nocheck
///|
fn main {
  @rabbita.new(app).mount("main")
}
```

## Understand `Val` and `Eq`

A `Val[T]` represents a `T` in the incremental graph. It is not a snapshot of
the current `T`. Component code connects `Val` values, while callbacks passed
to `map` and `view` receive the evaluated values.

`Val::constant(value)` creates a `Val` whose value never changes. Use it when a
component returns fixed `Html` or when a fixed value must be passed to an API
that expects a `Val`.

Rabbita evaluates changes on demand. A state update marks dependent nodes as
dirty, then the root `Val[Html]` is read on the rendering frame. When a node is
recomputed, its new result is compared with its previous result using `Eq`. An
equal result does not propagate farther through the graph.

This has two important consequences:

- If an update returns a model equal to the old model, dependent callbacks do
  not run
- A `map` callback must run before Rabbita can compare its new result, but an
  equal result prevents callbacks farther downstream from running

Deriving smaller values lets equality stop work closer to the changed field:

```moonbit check
///|
struct Dashboard {
  count : Int
  status : String
} derive(Eq)

///|
fn dashboard(model : Val[Dashboard]) -> Val[Html] {
  let count = model
    .map(model => model.count)
    .view(count => p("Count: \{count}"))

  let status = model
    .map(model => model.status)
    .view(status => p("Status: \{status}"))

  count.view2(status, (count, status) => div([count, status]))
}
```

If only `status` changes, the `count` projection is checked and still produces
the same `Int`. Its `count.view(...)` callback is therefore skipped. A single
large `model.view(...)` would instead rebuild all of the dashboard `Html` for
every model change.

Use `map` to derive ordinary values and `view` to derive `Html`. The `map2`
through `map9` and `view2` through `view9` methods create one derived node with
several direct inputs. They avoid intermediate tuple nodes. When a render unit
needs more than nine independent inputs, it is usually clearer to split it into
smaller components or intermediate derived values.

`Eq` must describe every change that downstream code can observe. Prefer
immutable state and create a new value for each update. In particular, prefer
an immutable `Vector` for ordered collections. Mutating the same `Array` or
`Map` instance in place can leave no reliable old value for equality to
compare.

## Parent and child communication

Shared state belongs in the closest common parent, while state used by only one
child can stay local to that child. A parent passes fixed configuration as plain
values, changing data as `Val[T]`, and an `Emit[Msg]` when child events should
be handled by the parent's state machine. `Emit::map` can adapt a parent emitter
to a child-specific message type. The child returns `Val[Html]`, which the
parent combines with other child results.

A plain argument is fixed when that component branch is built. For example,
`counter(title : String)` treats its title as configuration, while
`dashboard(model : Val[Dashboard])` observes later model changes.

If a child owns local state but its update or subscriptions need the latest
input from its parent, use `create_state_with_input`. It passes the current input
to its initializer, update, and subscriptions callbacks. Changing that input
alone does not send a message, run the update callback, or refresh
subscriptions.

```moonbit check
///|
enum SteppedCounterMsg {
  Inc
  Dec
}

///|
fn stepped_counter(step : Val[Int]) -> Val[Html] {
  let (count, emit) = @rabbita.create_state_with_input(
    input=step,
    init=fn(_, _) { (0, none) },
    update=fn(_, step, msg, count) {
      match msg {
        Inc => (count + step, none)
        Dec => (count - step, none)
      }
    },
  )
  count.view2(step, (count, step) => {
    section([
      h2("Stepped counter"),
      p("Step: \{step}"),
      button(on_click=emit(Dec), "-"),
      span(count.to_string()),
      button(on_click=emit(Inc), "+"),
    ])
  })
}
```

The rendered `Html` depends directly on `step` through `view2`, so it updates
when `step` changes. That change still does not call the state update. The next
`Inc` or `Dec` message uses the latest step value.

Create state and child components while building a component or a dynamic
branch. Do not call `create_state`, `create_pure_state`, or another component
from inside a `map` or `view` callback, including `view2` through `view9`.
Those callbacks may run many times and would create new state machines on every
evaluation.

## Keyed components with `assoc`

Use `assoc` or `assoc_by` when an ordered collection contains stateful child
components. Always pass a named component function. Each stable key owns one
branch, while the supplied `Val` carries later value changes into that branch.
The item's boolean expansion state is a simple local variable, so it uses
`create_variable`.

```moonbit check
///|
struct Todo {
  id : Int
  title : String
  details : String
} derive(Eq)

///|
fn todo_item(id : Int, todo : Val[Todo]) -> Val[Html] {
  let (expanded, set_expanded) = @rabbita.create_variable(false)
  todo.view2(expanded, (todo, expanded) => {
    li([
      span("\{id}: \{todo.title}"),
      button(on_click=set_expanded(value => !value), "details"),
      if expanded {
        p(todo.details)
      } else {
        nothing
      },
    ])
  })
}

///|
fn todo_list(todos : Val[Vector[Todo]]) -> Val[Html] {
  let rows = todos.assoc_by(todo_item, by=todo => todo.id)
  rows.view(rows => ul(rows))
}
```

Keys must be unique and stable. The result follows the source `Vector` order.
Updating a value with the same key updates the `Val[Todo]` without rebuilding
its component, so `expanded` is preserved. Reordering also preserves the
branch. Removing a key disposes its state and subscriptions. Adding that key
again creates a fresh branch.

These keys identify incremental branches only. They are not attached to the
resulting `Html` values.

## Branch lifetime

`enumerate` and `switch` select a component branch from a stable tag. Implement
`Enumerate` when an enum naturally defines those tags:

```moonbit check
///|
enum Panel {
  Overview
  Preferences
} derive(Eq)

///|
impl @rabbita.Enumerate for Panel with fn tag(self) {
  match self {
    Overview => "overview"
    Preferences => "preferences"
  }
}

///|
fn overview_panel() -> Val[Html] {
  Val::constant(h1("Overview"))
}

///|
fn preferences_panel() -> Val[Html] {
  Val::constant(h1("Preferences"))
}

///|
fn cached_panel(panel : Val[Panel]) -> Val[Html] {
  panel.enumerate(panel => {
    match panel {
      Overview => overview_panel()
      Preferences => preferences_panel()
    }
  })
}

///|
fn disposable_panel(panel : Val[Panel]) -> Val[Html] {
  panel.switch(panel => {
    match panel {
      Overview => overview_panel()
      Preferences => preferences_panel()
    }
  })
}
```

| API | Branch identity | Lifecycle |
| --- | --- | --- |
| `assoc` / `assoc_by` | A unique key | Removing the key disposes it |
| `enumerate` / `enumerate_by` | Every observed tag | It stays cached and is reused |
| `switch` / `switch_by` | The active tag | It is disposed and later rebuilt |

Use `enumerate` for a small, bounded set of tabs whose local state and
subscriptions should survive while inactive. Avoid it for an unbounded set of
tags. Use `switch` for pages or dialogs whose inactive state should be released.

The selector callback runs only when its branch is created. A later value with
the same tag does not call it again, so that callback argument is not a live
component input. If a tagged value contains changing data, derive a separate
`Val` for that data and pass it to the named component.

The callback should immediately match the tag and dispatch each case to a named
component, as above. Do not put the rendering or state logic directly inside
the `enumerate` or `switch` callback. A normal `if` or `match` inside `view`
only chooses `Html`. It does not create or dispose component branches.

## Compared with fine-grained reactivity and implicit tracking

Rabbita combines an explicit incremental graph with virtual DOM rendering.
Dependencies are declared at `map` and `view` call sites instead of inferred
from reads during rendering. Because a `Val` cannot be read as an ordinary
value, this rules out the implicit-tracking bug where a reactive read happens
outside a tracking context and the UI silently stops updating. This adds some
plumbing, but keeps graph edges and branch lifetimes visible.

Virtual DOM diffing is not usually the dominant factor in application
performance. Network requests, payloads, caching, and backend work often matter
more. If profiling identifies rendering as significant, split large views into
smaller components or use `@html.lazy(hash, render)`. The hash must cover every
input that affects the rendered `Html`.
