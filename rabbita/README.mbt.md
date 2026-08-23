# Rabbita

A declarative, functional web UI framework inspired by Elm and Bonsai.

This project was previously named `Rabbit-TEA` and is now renamed to `rabbita` .

## Features

* Predictable flow

  Each component handles state changes through typed messages. Commands keep
  side effects explicit.

* Strict Types

  Rigorous types. No `Any` sprawl. No stringly-typed APIs.

* Balanced bundle size

  ~15 KB min+gzip, includes streaming VDOM diff and the MoonBit standard library (DCE via moonc).

* Modular & Incremental

  Organize reusable UI as ordinary functions that compose state, derived
  values, and child components. Updates reevaluate dependent callbacks, while
  equal results stop propagating.

## Quick Start

You can try it in the [playground](https://moonbit-community.github.io/rabbita/playground/) or set up a project in the terminal.

Make sure you have installed [`moon`](https://www.moonbitlang.com/download/) first:

```
moon install moonbit-community/warren
warren new my-project
cd my-project
warren dev --browser-entry main
```

See [Warren](./warren/README.md) for more information.

## Example

```mbt nocheck
using @rabbita {type Html, type Val}
using @html {button, div, h1}

///|
enum Msg {
  Inc
  Dec
}

///|
fn counter() -> Val[Html] {
  let (count, emit) = @rabbita.create_pure_state(0, update=fn(count, msg) {
    match msg {
      Inc => count + 1
      Dec => count - 1
    }
  })
  count.view(count => {
    div([
      h1(count.to_string()),
      button(on_click=emit(Inc), "+"),
      button(on_click=emit(Dec), "-"),
    ])
  })
}

///|
fn main {
  ignore(@rabbita.new(counter).mount("app"))
}
```

`mount` returns a `MountedApp`. Keep it if the app may be removed before the
page closes. Call `unmount` to remove the app:

```moonbit nocheck
let mounted = @rabbita.new(counter).mount("app")
// Later, when the host no longer owns this application:
mounted.unmount()
```

`unmount` is safe to call more than once. It stops the app's subscriptions and
queued renders, then removes its DOM. Work that already started may finish, but
Rabbita ignores any commands it returns. If another app has replaced the DOM,
the old handle leaves the new DOM unchanged.

## Used By

- [mooncakes.io](https://mooncakes.io)
- [moonbitlang.com](https://moonbitlang.com)
- [moonbit-community.github.io/rabbita](https://moonbit-community.github.io/rabbita)
- [bingque](https://www.bingque.com)
- [caimeo.space](http://caimeox.github.io/symweb)
