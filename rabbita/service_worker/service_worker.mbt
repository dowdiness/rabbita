///|
using @cmd {type Cmd}

///|
/// Register a Service Worker script.
///
/// - `script_url`: URL of the Service Worker script (e.g. `"/sw.js"`)
/// - `scope`: optional scope path; defaults to the directory of `script_url`
/// - `registered`: called with a `Registration` snapshot on success
/// - `failed`: called with an error message string on failure
pub fn register(
  script_url : String,
  scope? : String,
  registered? : @cmd.Emit[Registration],
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerRegister(script_url, scope, registered, failed))
}

///|
/// Query the registration for a given `scope`.
///
/// `reply` receives `Some(Registration)` if a registration exists for the
/// scope, or `None` if none is found.
pub fn get_registration(
  scope : String,
  reply? : @cmd.Emit[Registration?],
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerGetRegistration(scope, reply, failed))
}

///|
/// Query all registrations for this origin.
pub fn get_registrations(
  reply? : @cmd.Emit[Array[Registration]],
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerGetRegistrations(reply, failed))
}

///|
/// Check the network for an updated Service Worker script for the registration
/// identified by `id`.
pub fn update(
  id : RegistrationId,
  done? : @cmd.Emit[Unit],
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerUpdate(id, done, failed))
}

///|
/// Unregister the Service Worker registration identified by `id`.
///
/// `reply` receives `true` if the unregistration succeeded, `false` if the
/// registration was not found.
pub fn unregister(
  id : RegistrationId,
  reply? : @cmd.Emit[Bool],
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerUnregister(id, reply, failed))
}

///|
/// Send a message to the active Service Worker for the registration identified
/// by `id`.
///
/// Only the `active` worker receives messages via `postMessage`; if there is
/// no active worker the `failed` callback is invoked.
pub fn post_message(
  id : RegistrationId,
  payload : Message,
  failed? : @cmd.Emit[String],
) -> Cmd {
  op.request(ServiceWorkerPostMessage(id, payload, failed))
}
