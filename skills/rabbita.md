# Rabbita skill

# Basic requirement

- prefer to use API provided by this library than writing JS FFI manually. Avoid
using escape hatch like `@cmd.custom_cmd`, `@cmd.custom_sub`, `@cmd.effect`, `@cmd.attempt`,
`@html.Attrs`, `@dom`, `trait Scheduler`


- eliminate unnecessary state management and message sending.
  - If need router, mapping url to model using `@html.a`, `@sub.on_url_changed`,
    and `@sub.on_url_request`, rather than encoding state machine in update function.

- prefer immutable data structure over mutable `Map`, `Array`, `Set` (except
using array literal syntax in view)
- do not store callback, message, Cmd in model
- make message sending lambda short and clean: e.g, `x => send(UserMsg1(x))` and `send(UserMsg2)`


# HTTP

## Anti-pattern

- use mutable state in model and change the state inplace

- embedding logic in the message sending callback
    ```mbt nocheck
    @http.delete("api/user/1").expect_empty(result => {
      let status = result.is_none()
      send(UserDeletedStatus(status))
    })
    ```

    ```mbt nocheck
    div([ input(on_change=fn(s){ send(Msg(s.has_prefix("xxx"))) }) ])
    ```

- ignoring the returned `Request`, `RequestWithBody`, or `Cmd`
    ```mbt nocheck
    @http.get("api/user") |> ignore
    @http.post("api/user") |> ignore
    @http.post("api/user").expect_empty(x => send(Msg(x))) |> ignore
    ```
- storing the `Request` or `Cmd` in a global, Model, or something else data structures
    ```mbt nocheck
    let user_api_request = @http.get("api/user")
    let user_api_cmd = @http.get("api/user").expect_json(x => send(Msg(x)))
    let table = {
      "request1": @http.get("api/user"),
      "request2": send(Msg(x)),
    }
    ```
- wrapping the http request construction in a helper function
    ```mbt nocheck
    fn fetch_user(send : Emit[Msg]) -> Cmd {
      @http.get("api/user").expect_json(x => send(UserLoaded(x)))
    }
    ```



