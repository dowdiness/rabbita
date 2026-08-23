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

`mount` returns a `MountedApp` handle for applications whose lifetime is
shorter than the page. Retain the handle and call `unmount` when the host is
detached:

```moonbit nocheck
let mounted = @rabbita.new(counter).mount("app")
// Later, when the host no longer owns this application:
mounted.unmount()
```

`unmount` is idempotent. It stops Rabbita-managed subscriptions and queued
rendering before removing the mount's DOM. Effects already running outside
Rabbita may finish, but their returned commands are ignored. If another mount
has replaced the same container, unmounting the stale handle leaves the
replacement DOM unchanged.

## Used By

- [mooncakes.io](https://mooncakes.io)
- [moonbitlang.com](https://moonbitlang.com)
- [moonbit-community.github.io/rabbita](https://moonbit-community.github.io/rabbita)
- [bingque](https://www.bingque.com)
- [caimeo.space](http://caimeox.github.io/symweb)
