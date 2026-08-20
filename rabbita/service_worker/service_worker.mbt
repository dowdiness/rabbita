///|
using @cmd {type Cmd}

///|
/// Register a Service Worker script.
///
/// - `script_url`: URL of the Service Worker script (e.g. `"/sw.js"`)
/// - `options`: optional `scope`, `worker_type`, and `update_via_cache`
/// - `registered`: called with a `Registration` snapshot on success
/// - `failed`: called with a typed `ServiceWorkerError` on failure
pub fn register(
  script_url : String,
  options? : RegistrationOptions,
  registered? : @cmd.Emit[Registration],
  failed? : @cmd.Emit[ServiceWorkerError],
) -> Cmd {
  op.request(ServiceWorkerRegister(script_url, options, registered, failed))
}

///|
/// Query the registration matching `client_url` using the browser's
/// longest-prefix `getRegistration` rules.
///
/// `reply` receives `Some(Registration)` if a registration matches the client
/// URL, or `None` if none is found. This is **not** exact scope identity; use
/// a `RegistrationId` from a prior snapshot for update/unregister/post_message.
pub fn get_registration(
  client_url : String,
  reply? : @cmd.Emit[Registration?],
  failed? : @cmd.Emit[ServiceWorkerError],
) -> Cmd {
  op.request(ServiceWorkerGetRegistration(client_url, reply, failed))
}

///|
/// Query all registrations for this origin.
pub fn get_registrations(
  reply? : @cmd.Emit[Array[Registration]],
  failed? : @cmd.Emit[ServiceWorkerError],
) -> Cmd {
  op.request(ServiceWorkerGetRegistrations(reply, failed))
}

///|
/// Check the service worker script for an update for the registration
/// identified by `id` (exact absolute scope match).
///
/// HTTP cache behavior follows the registration's `updateViaCache` policy and
/// the browser's update algorithm.
pub fn update(
  id : RegistrationId,
  done? : @cmd.Emit[Unit],
  failed? : @cmd.Emit[ServiceWorkerError],
) -> Cmd {
  op.request(ServiceWorkerUpdate(id, done, failed))
}

///|
/// Unregister the Service Worker registration identified by `id`.
///
/// Resolution uses exact scope identity so a stale child id cannot unregister
/// a parent registration. `reply` receives `true` if unregistration succeeded,
/// `false` if the registration was not found.
pub fn unregister(
  id : RegistrationId,
  reply? : @cmd.Emit[Bool],
  failed? : @cmd.Emit[ServiceWorkerError],
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
  failed? : @cmd.Emit[ServiceWorkerError],
) -> Cmd {
  op.request(ServiceWorkerPostMessage(id, payload, failed))
}
