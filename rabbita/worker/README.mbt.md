# Dedicated module Workers

`worker` is a JS-only binding for browser module Workers. A subscription owns
one native Worker; a managed command represents one correlated request. It does
not provide persistence, retries, domain readiness, or exactly-once execution.

## Ownership

```moonbit nocheck
// In subscriptions(model, emit):
@worker.listen(
  "editor-engine",
  "/engine.js",
  generation=model.restart_generation,
  on_event=event => emit(WorkerEvent(event)),
)

// In update, after receiving Connected(connection):
@worker.request(
  connection,
  request_payload,
  reply=result => emit(RequestFinished(connection, domain_request_id, result)),
  timeout_ms=15000,
)
```

Store the opaque, immutable `Connection` in Model, not a native handle, callback
or Promise. `Connected` means the transport was constructed: module loading and
application restoration can still fail. Editing readiness belongs to the
application protocol.

The local subscription key, URL and explicit generation determine lifetime.
Changing only callbacks retains the Worker and rebinds its event callback.
Changing URL/generation, removing the subscription, or disposing its state
scope closes that incarnation. Separate state stores using the same key do not
share a Worker. A failed subscription does not restart on unrelated updates;
change generation or remove/re-add it to request a new connection.

Worker URLs are trusted application configuration, resolved by the browser
relative to the document. The binding creates `{type: "module"}` Workers with
the browser's default same-origin credentials. It does not discover, compile
or bundle Worker assets. Supply a separately deployed module URL and an
appropriate `worker-src` Content Security Policy. Browser construction errors,
including restrictive Trusted Types policies, are reported rather than bypassed.

## Requests and admission

`request` captures the connection and serializes its JSON payload when the Cmd
is constructed. It posts only when the runtime executes that Cmd. An old Cmd
never looks up a replacement by subscription key: a closed connection yields
`ConnectionClosed` before sending.

Each request has a private correlation ID. A result or failure settles its
waiter at most once; duplicate or late results for completed IDs are ignored.
Removal clears pending timers, detaches listeners, settles waiters and
terminates the native Worker. This cleanup is idempotent.

A closed connection is checked again before delivering a successful result.
A message already queued in Rabbita still needs **application admission**:
carry the captured connection and domain request ID in the message, and accept
it only if both match the current domain state. Do not derive the target from
whatever document/connection happens to be active when a callback runs.

Subscription removal can deliver cancellation to a surviving state owner. A
destroyed owner cannot receive messages: Rabbita frees its store before Sub
unload. Retain admitted edits and recovery data above a disposable editor view
before removing it.

## Wire protocol

Only JSON strings cross the thread boundary; compiler-generated MoonBit
objects are not a wire format. The application encodes/decodes its typed
requests and responses at this JSON seam.

Host request:

```json
{"rabbita_worker":1,"id":"1","kind":"request","payload":{"increment":3}}
```

Worker result (echo the request ID verbatim):

```json
{"rabbita_worker":1,"id":"1","kind":"result","payload":{"count":3}}
```

Optional progress:

```json
{"rabbita_worker":1,"id":"1","kind":"progress"}
```

Progress renews only that pending request's inactivity timer. It is not a
result, save receipt or unsolicited application event. Unknown/completed IDs
are ignored; malformed envelopes close the connection with `InvalidMessage`.
Domain errors are ordinary application-coded result payloads.

Messages are posted in command execution order. The binding does not serialize
an application's asynchronous Worker handlers: a domain requiring FIFO
execution must use its own single-consumer queue inside the Worker.

## Failure and timeouts

| Failure | Meaning |
| --- | --- |
| `Unavailable` | Not running in a browser window, or Worker support unavailable |
| `ConstructionFailed` | Native Worker construction threw |
| `ConnectionClosed` | Captured incarnation no longer exists |
| `PostFailed` | Native post/structured-clone operation threw |
| `WorkerFailed` | Native Worker error event |
| `MessageError` | Native message deserialization error event |
| `InvalidMessage` | Incoming data violated the transport envelope |
| `Timeout` | Request inactivity deadline expired |
| `InvalidTimeout` | Timeout was not a positive `Int` |

Errors are redacted categories, not payloads, URLs, stacks or native error text.
Fatal Worker/message/protocol errors close the connection and report
`Failed(Some(connection), failure)` as well as settling its pending requests.
Construction/unavailable failures have no connection. Unload sends no lifecycle
event to the owner being destroyed.

The default inactivity timeout is 15,000 ms. A timeout or post failure ends only
that request's waiter; other requests can remain pending. An invalid timeout
rejects before post. Timers are browser timers and can be throttled in background
tabs: this is not a hard real-time deadline.

A request can time out or its Worker can terminate **after performing an
effect**. Cancellation does not roll it back. Recovery, idempotency and durable
receipts remain application responsibilities; the binding never reconnects or
replays a request automatically.

This package is JS-only and cannot be imported into Rabbita's native/Wasm SSR
renderer. Its separate JS nonbrowser gate prevents construction and posting
even when a server provides a global Worker implementation. Hydration skip is
not the sole execution gate.

## Verification

The public-API browser fixture is [`e2e/apps/worker`](../../e2e/apps/worker), with
acceptance tests in [`worker.spec.ts`](../../e2e/tests/worker.spec.ts).
It uses real native Workers; the tests inject native boundary faults where a
deserialization/clone failure cannot naturally arise from valid JSON strings.

The Node regressions exercise the JS nonbrowser/polyfill gate, not native
`App::render`.
