///|
#cfg(target="js")
using @cmd {type Emit, trait Scheduler}

///|
#cfg(target="js")
priv suberror ServiceWorkerSubscription {
  ContainerEvents(
    controller_changed~ : Cmd?,
    message~ : Emit[Message]?,
    message_error~ : Cmd?
  )
  RegistrationEvents(
    RegistrationId,
    changed~ : Emit[Registration]?,
    failed~ : Emit[String]?
  )
}

// ===========================================================================
// Message parsing
// ===========================================================================

///|
/// Parse a raw `@js.Value` from a `MessageEvent.data` into a typed `Message`.
#cfg(target="js")
fn parse_worker_message(raw : @js.Value) -> Message {
  if raw.is_string() {
    Text(raw.cast())
  } else {
    Json(raw.to_json()) catch {
      _ => Text(raw.to_string())
    }
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
    ContainerEvents(controller_changed~, message~, message_error~) => {
      let container = @dom.window().navigator().service_worker()
      let mut controller_tagger = controller_changed
      let mut message_tagger = message
      let mut message_error_tagger = message_error

      let on_controller_changed = _ => {
        guard controller_tagger is Some(msg) else { return }
        scheduler.add(msg)
      }

      let on_message = (event : @dom.Event) => {
        guard message_tagger is Some(f) else { return }
        guard event.to_message_event() is Some(message_event) else { return }
        scheduler.add(f(parse_worker_message(message_event.get_data())))
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
            is ContainerEvents(controller_changed~, message~, message_error~) else {
            return
          }
          controller_tagger = controller_changed
          message_tagger = message
          message_error_tagger = message_error
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
      watch.start(scheduler, id.scope)
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
) -> Bool {
  controller_changed is Some(_) ||
  message is Some(_) ||
  message_error is Some(_)
}

///|
#cfg(target="js")
fn has_registration_callback(changed : @cmd.Emit[Registration]?) -> Bool {
  changed is Some(_)
}

// ===========================================================================
// Public API
// ===========================================================================

///|
/// Subscribe to `ServiceWorkerContainer` events:
/// - `controller_changed`: the active controller has changed
/// - `message`: a message was received from a Service Worker
/// - `message_error`: a message could not be deserialised
///
/// At least one callback must be provided; otherwise `@sub.none` is returned.
#cfg(target="js")
pub fn listen(
  controller_changed? : Cmd,
  message? : @cmd.Emit[Message],
  message_error? : Cmd,
) -> @sub.Sub {
  guard has_container_callbacks(controller_changed, message, message_error) else {
    @sub.none
  }

  let has_cc = controller_changed is Some(_)
  let has_msg = message is Some(_)
  let has_err = message_error is Some(_)

  let key = "service_worker.listen(cc=\{has_cc},msg=\{has_msg},err=\{has_err})"
  @sub.custom_sub(
    key,
    Local,
    ContainerEvents(controller_changed~, message~, message_error~),
    sw_container_sub_loader,
  )
}

///|
/// Subscribe to lifecycle events for a specific Service Worker registration
/// identified by `scope`.
///
/// The `changed` callback is called with a fresh `Registration` snapshot
/// whenever `updatefound` fires or an `installing`, `waiting`, or `active`
/// worker `statechange` event fires.
///
/// If the scope cannot be resolved when the subscription starts, or resolution
/// fails, `failed` is invoked with an error message string.
#cfg(target="js")
pub fn watch_registration(
  scope : String,
  changed? : @cmd.Emit[Registration],
  failed? : @cmd.Emit[String],
) -> @sub.Sub {
  guard has_registration_callback(changed) else { @sub.none }
  let id : RegistrationId = { scope, }
  let key = "service_worker.watch_registration(scope=\{scope})"
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
  inspect(has_container_callbacks(None, None, None), content="false")
  inspect(has_container_callbacks(Some(@cmd.none), None, None), content="true")
  inspect(
    has_container_callbacks(None, Some(_ => @cmd.none), None),
    content="true",
  )
  inspect(has_container_callbacks(None, None, Some(@cmd.none)), content="true")
}

///|
#cfg(target="js")
test "has_registration_callback requires changed handler" {
  inspect(has_registration_callback(None), content="false")
  inspect(has_registration_callback(Some(_ => @cmd.none)), content="true")
}

///|
#cfg(target="js")
test "parse_worker_message decodes string and json payloads" {
  match parse_worker_message(@js.Value::cast_from("ping")) {
    Text(text) => inspect(text, content="ping")
    _ => fail("expected a text message")
  }
  match parse_worker_message(@js.Value::from_json({ "ok": true })) {
    Json(json) => inspect(json.stringify(), content="{\"ok\":true}")
    _ => fail("expected a json message")
  }
}
