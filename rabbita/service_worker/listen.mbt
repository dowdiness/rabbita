///|
#cfg(target="js")
using @cmd {type Emit, trait Scheduler}

///|
#cfg(target="js")
priv suberror ServiceWorkerSubscription {
  ContainerEvents(
    controller_changed~ : Cmd?,
    message~ : Emit[Message]?,
    message_error~ : Cmd?,
    decode_error~ : Emit[MessageDecodeError]?
  )
  RegistrationEvents(
    RegistrationId,
    changed~ : Emit[Registration]?,
    failed~ : Emit[ServiceWorkerError]?
  )
}

// ===========================================================================
// Message parsing
// ===========================================================================

///|
/// Parse a raw `@js.Value` from a `MessageEvent.data` into a typed `Message`.
///
/// Only strings and JSON-encodable objects/arrays are accepted. Other
/// structured-clone values become `MessageDecodeError` instead of a silent
/// `Text("[object …]")` conversion.
#cfg(target="js")
fn parse_worker_message(raw : @js.Value) -> Result[Message, MessageDecodeError] {
  if raw.is_string() {
    Ok(Text(raw.cast()))
  } else if raw.is_object() && !raw.is_null() {
    Ok(Json(raw.to_json())) catch {
      err => Err(InvalidJson(err.to_string()))
    }
  } else {
    Err(UnsupportedPayload)
  }
}

// ===========================================================================
// Sub loaders
// ===========================================================================

///|
#cfg(target="js")
fn sw_container_sub_loader(
  payload : Error,
  scheduler : &Scheduler,
) -> @sub.RunningSub? {
  match payload {
    ContainerEvents(
      controller_changed~,
      message~,
      message_error~,
      decode_error~
    ) => {
      guard @dom.window().navigator().service_worker().to_option()
        is Some(container) else {
        return None
      }
      let mut controller_tagger = controller_changed
      let mut message_tagger = message
      let mut message_error_tagger = message_error
      let mut decode_error_tagger = decode_error

      let on_controller_changed = _ => {
        guard controller_tagger is Some(msg) else { return }
        scheduler.add(msg)
      }

      let on_message = (event : @dom.Event) => {
        guard event.to_message_event() is Some(message_event) else { return }
        match parse_worker_message(message_event.get_data()) {
          Ok(payload) => {
            guard message_tagger is Some(f) else { return }
            scheduler.add(f(payload))
          }
          Err(err) => {
            guard decode_error_tagger is Some(f) else { return }
            scheduler.add(f(err))
          }
        }
      }

      let on_message_error = _ => {
        guard message_error_tagger is Some(msg) else { return }
        scheduler.add(msg)
      }

      container
      ..add_event_listener("controllerchange", on_controller_changed)
      ..add_event_listener("message", on_message)
      .add_event_listener("messageerror", on_message_error)

      Some({
        unload: _ => {
          container
          ..remove_event_listener("controllerchange", on_controller_changed)
          ..remove_event_listener("message", on_message)
          .remove_event_listener("messageerror", on_message_error)
        },
        update_tagger: new_payload => {
          guard new_payload
            is ContainerEvents(
              controller_changed~,
              message~,
              message_error~,
              decode_error~
            ) else {
            return
          }
          controller_tagger = controller_changed
          message_tagger = message
          message_error_tagger = message_error
          decode_error_tagger = decode_error
        },
      })
    }
    _ => None
  }
}

///|
#cfg(target="js")
fn registration_sub_loader(
  payload : Error,
  scheduler : &Scheduler,
) -> @sub.RunningSub? {
  match payload {
    RegistrationEvents(id, changed~, failed~) => {
      let watch = RegistrationWatch(changed, failed)
      watch.start(scheduler, id)
      Some({
        unload: _ => watch.dispose(),
        update_tagger: new_payload => {
          guard new_payload is RegistrationEvents(_, changed~, failed~) else {
            return
          }
          watch.set_callbacks(changed, failed)
        },
      })
    }
    _ => None
  }
}

// ===========================================================================
// Sub guard helpers
// ===========================================================================

///|
#cfg(target="js")
fn has_container_callbacks(
  controller_changed : Cmd?,
  message : @cmd.Emit[Message]?,
  message_error : Cmd?,
  decode_error : @cmd.Emit[MessageDecodeError]?,
) -> Bool {
  controller_changed is Some(_) ||
  message is Some(_) ||
  message_error is Some(_) ||
  decode_error is Some(_)
}

///|
#cfg(target="js")
fn has_registration_callbacks(
  changed : @cmd.Emit[Registration]?,
  failed : @cmd.Emit[ServiceWorkerError]?,
) -> Bool {
  changed is Some(_) || failed is Some(_)
}

// ===========================================================================
// Public API
// ===========================================================================

///|
/// Subscribe to `ServiceWorkerContainer` events:
/// - `controller_changed`: the active controller has changed
/// - `message`: a text or JSON message was received from a Service Worker
/// - `message_error`: the browser could not deserialise a message
/// - `decode_error`: the payload was structured-cloneable but not Text/JSON
///
/// At least one callback must be provided; otherwise `@sub.none` is returned.
/// Returns `@sub.none` when `navigator.serviceWorker` is unavailable.
#cfg(target="js")
pub fn listen(
  controller_changed? : Cmd,
  message? : @cmd.Emit[Message],
  message_error? : Cmd,
  decode_error? : @cmd.Emit[MessageDecodeError],
) -> @sub.Sub {
  guard has_container_callbacks(
    controller_changed, message, message_error, decode_error,
  ) else {
    @sub.none
  }

  let has_cc = controller_changed is Some(_)
  let has_msg = message is Some(_)
  let has_err = message_error is Some(_)
  let has_dec = decode_error is Some(_)

  let key = "service_worker.listen(cc=\{has_cc},msg=\{has_msg},err=\{has_err},dec=\{has_dec})"
  @sub.custom_sub(
    key,
    Local,
    ContainerEvents(
      controller_changed~,
      message~,
      message_error~,
      decode_error~,
    ),
    sw_container_sub_loader,
  )
}

///|
/// Subscribe to lifecycle events for a specific Service Worker registration
/// identified by `scope`.
///
/// `scope` is canonicalized to an absolute URL and resolved with **exact**
/// scope identity (not client-URL prefix matching).
///
/// The `changed` callback receives a fresh `Registration` snapshot after
/// `updatefound` / worker `statechange`, once registration slots have been
/// reconciled past the browser task that may clear redundant workers.
///
/// If the registration cannot be resolved when the subscription starts,
/// `failed` is invoked. Either `changed` or `failed` (or both) must be set.
#cfg(target="js")
pub fn watch_registration(
  scope : String,
  changed? : @cmd.Emit[Registration],
  failed? : @cmd.Emit[ServiceWorkerError],
) -> @sub.Sub {
  guard has_registration_callbacks(changed, failed) else { @sub.none }
  let id = RegistrationId(scope)
  let key = "service_worker.watch_registration(scope=\{id.scope()})"
  @sub.custom_sub(
    key,
    Local,
    RegistrationEvents(id, changed~, failed~),
    registration_sub_loader,
  )
}

// ===========================================================================
// Tests
// ===========================================================================

///|
#cfg(target="js")
test "has_container_callbacks requires at least one handler" {
  inspect(has_container_callbacks(None, None, None, None), content="false")
  inspect(
    has_container_callbacks(Some(@cmd.none), None, None, None),
    content="true",
  )
  inspect(
    has_container_callbacks(None, Some(_ => @cmd.none), None, None),
    content="true",
  )
  inspect(
    has_container_callbacks(None, None, Some(@cmd.none), None),
    content="true",
  )
  inspect(
    has_container_callbacks(None, None, None, Some(_ => @cmd.none)),
    content="true",
  )
}

///|
#cfg(target="js")
test "has_registration_callbacks accepts changed, failed, or both" {
  inspect(has_registration_callbacks(None, None), content="false")
  inspect(
    has_registration_callbacks(Some(_ => @cmd.none), None),
    content="true",
  )
  inspect(
    has_registration_callbacks(None, Some(_ => @cmd.none)),
    content="true",
  )
  inspect(
    has_registration_callbacks(Some(_ => @cmd.none), Some(_ => @cmd.none)),
    content="true",
  )
}

///|
#cfg(target="js")
test "parse_worker_message accepts text and json; rejects unsupported payloads" {
  match parse_worker_message(@js.Value::cast_from("ping")) {
    Ok(Text(text)) => inspect(text, content="ping")
    _ => fail("expected a text message")
  }
  match parse_worker_message(@js.Value::from_json({ "ok": true })) {
    Ok(Json(json)) => inspect(json.stringify(), content="{\"ok\":true}")
    _ => fail("expected a json message")
  }
  match parse_worker_message(@js.Value::cast_from(true)) {
    Err(UnsupportedPayload) => ()
    other =>
      fail(
        "boolean payload must be UnsupportedPayload, got \{Debug::to_repr(other)}",
      )
  }
  match parse_worker_message(@js.Value::cast_from(1)) {
    Err(UnsupportedPayload) => ()
    other =>
      fail(
        "number payload must be UnsupportedPayload, got \{Debug::to_repr(other)}",
      )
  }
}
