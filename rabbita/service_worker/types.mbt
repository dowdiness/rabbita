///|
using @debug {trait Debug, type Repr}

// ===========================================================================
// WorkerState — enum as state machine
// ===========================================================================

///|
/// The lifecycle state of a Service Worker, matching the `state` attribute of
/// the browser's `ServiceWorker` object.
///
/// The variants follow the spec transition graph:
///
/// ```text
/// Parsed → Installing → Installed → Activating → Activated
///              │              │           │            │
///              └──────────────┴───────────┴────────────┴──→ Redundant
/// ```
///
/// https://w3c.github.io/ServiceWorker/#dom-serviceworker-state
pub(all) enum WorkerState {
  Parsed
  Installing
  Installed
  Activating
  Activated
  Redundant
  Unknown(String)
} derive(Debug, Eq)

///|
pub impl Show for WorkerState with fn output(self, buf) {
  match self {
    Parsed => buf.write_string("parsed")
    Installing => buf.write_string("installing")
    Installed => buf.write_string("installed")
    Activating => buf.write_string("activating")
    Activated => buf.write_string("activated")
    Redundant => buf.write_string("redundant")
    Unknown(raw) => {
      buf.write_string("unknown(")
      buf.write_string(raw)
      buf.write_string(")")
    }
  }
}

///|
/// Parse a browser `ServiceWorker.state` string into a typed `WorkerState`.
/// Unknown values become `Unknown(raw)` rather than a silent `Redundant`.
fn WorkerState::WorkerState(s : String) -> WorkerState {
  match s {
    "parsed" => Parsed
    "installing" => Installing
    "installed" => Installed
    "activating" => Activating
    "activated" => Activated
    "redundant" => Redundant
    other => Unknown(other)
  }
}

///|
/// Whether this worker is in `activating` or `activated` state.
///
/// Used by `Registration::has_activation_started` for the `active` slot worker.
pub fn WorkerState::is_active(self : WorkerState) -> Bool {
  match self {
    Activating | Activated => true
    _ => false
  }
}

///|
/// Whether this worker has reached a true terminal state (`redundant`).
pub fn WorkerState::is_terminal(self : WorkerState) -> Bool {
  match self {
    Redundant => true
    _ => false
  }
}

///|
/// Whether this worker is in a stable, non-transitional state (`activated`).
pub fn WorkerState::is_stable(self : WorkerState) -> Bool {
  match self {
    Activated => true
    _ => false
  }
}

///|
/// Whether this worker is still in the process of installing or activating.
pub fn WorkerState::is_settling(self : WorkerState) -> Bool {
  match self {
    Parsed | Installing | Activating => true
    _ => false
  }
}

///|
/// Whether this state can legally transition to `next` per the spec graph.
pub fn WorkerState::can_transition_to(
  self : WorkerState,
  next : WorkerState,
) -> Bool {
  match (self, next) {
    (Parsed, Installing) => true
    (Installing, Installed | Redundant) => true
    (Installed, Activating | Redundant) => true
    (Activating, Activated | Redundant) => true
    (Activated, Redundant) => true
    _ => false
  }
}

///|
test "WorkerState custom constructor maps spec strings; unknown stays Unknown" {
  inspect(WorkerState("parsed"), content="parsed")
  inspect(WorkerState("installing"), content="installing")
  inspect(WorkerState("installed"), content="installed")
  inspect(WorkerState("activating"), content="activating")
  inspect(WorkerState("activated"), content="activated")
  inspect(WorkerState("redundant"), content="redundant")
  inspect(WorkerState("mystery"), content="unknown(mystery)")
}

///|
test "WorkerState allows Activated to Redundant and treats only Redundant as terminal" {
  inspect(Activated.can_transition_to(Redundant), content="true")
  inspect(Activated.is_terminal(), content="false")
  inspect(Redundant.is_terminal(), content="true")
  inspect(Activated.is_stable(), content="true")
  inspect(Activating.is_stable(), content="false")
}

// ===========================================================================
// RegistrationId
// ===========================================================================

///|
/// A stable identifier for a Service Worker registration.
///
/// `scope` is stored as an absolute URL (the value of
/// `ServiceWorkerRegistration.scope`). Construct via `RegistrationId(scope)`;
/// relative paths are resolved against the current page URL on the JS target.
pub struct RegistrationId {
  priv scope : String
} derive(Debug, Eq, Hash)

///|
pub fn RegistrationId::RegistrationId(scope : String) -> RegistrationId {
  { scope: canonicalize_scope(scope) }
}

///|
/// The absolute scope URL identifying this registration.
pub fn RegistrationId::scope(self : RegistrationId) -> String {
  self.scope
}

///|
pub impl Show for RegistrationId with fn output(self, buf) {
  Show::output(Debug::to_repr(self), buf)
}

///|
/// Resolve `scope` against the current document URL on JS; identity elsewhere.
#cfg(target="js")
fn canonicalize_scope(scope : String) -> String {
  ffi_canonicalize_scope(scope)
}

///|
#cfg(not(target="js"))
fn canonicalize_scope(scope : String) -> String {
  scope
}

///|
#cfg(target="js")
extern "js" fn ffi_canonicalize_scope(scope : String) -> String =
  #| (scope) => {
  #|   try {
  #|     if (typeof location !== "undefined" && location && location.href) {
  #|       return new URL(scope, location.href).href
  #|     }
  #|   } catch (_) {}
  #|   try {
  #|     return new URL(scope).href
  #|   } catch (_) {}
  #|   try {
  #|     return new URL(scope, "http://localhost/").href
  #|   } catch (_) {
  #|     return scope
  #|   }
  #| }

///|
/// Whether `reg_scope` (from `registration.scope`) is the same registration as
/// `expected` (a canonical absolute scope URL).
fn scopes_match(reg_scope : String, expected : String) -> Bool {
  reg_scope == expected
}

///|
test "scopes_match requires exact absolute scope equality" {
  inspect(
    scopes_match("https://example.com/", "https://example.com/app/"),
    content="false",
  )
  inspect(
    scopes_match("https://example.com/app/", "https://example.com/app/"),
    content="true",
  )
}

// ===========================================================================
// WorkerInfo — immutable snapshot of a single worker slot
// ===========================================================================

///|
#warnings("-struct_never_constructed")
pub struct WorkerInfo {
  script_url : String
  state : WorkerState
} derive(Debug, Eq)

///|
pub impl Show for WorkerInfo with fn output(self, buf) {
  Show::output(Debug::to_repr(self), buf)
}

// ===========================================================================
// Registration — immutable snapshot of a ServiceWorkerRegistration
// ===========================================================================

///|
/// Immutable snapshot of a `ServiceWorkerRegistration` at a point in time.
///
/// Because the browser's `ServiceWorkerRegistration` object is mutable (its
/// `installing`, `waiting`, and `active` slots change over time), this type
/// captures the relevant fields so it can be safely stored in a Rabbita
/// `Model`.
#warnings("-struct_never_constructed")
pub struct Registration {
  id : RegistrationId
  installing : WorkerInfo?
  waiting : WorkerInfo?
  active : WorkerInfo?
} derive(Debug, Eq)

///|
pub impl Show for Registration with fn output(self, buf) {
  Show::output(Debug::to_repr(self), buf)
}

///|
/// Whether activation has started for the worker in the `active` slot
/// (`activating` or `activated`).
///
/// This reflects the registration's `active` slot only. It does **not** mean
/// the worker is currently controlling the page; use
/// `ServiceWorkerContainer.controller` for that.
pub fn Registration::has_activation_started(self : Registration) -> Bool {
  match self.active {
    Some(w) => w.state.is_active()
    None => false
  }
}

///|
/// Whether a new version is waiting for activation.
pub fn Registration::has_waiting(self : Registration) -> Bool {
  self.waiting is Some(_)
}

///|
/// Whether a new version is currently installing.
pub fn Registration::has_installing(self : Registration) -> Bool {
  self.installing is Some(_)
}

///|
/// Whether an update is in progress (installing or waiting).
pub fn Registration::has_pending_update(self : Registration) -> Bool {
  self.has_installing() || self.has_waiting()
}

///|
test "Registration snapshots expose pending-update predicates" {
  let worker : WorkerInfo = { script_url: "/sw.js", state: Installed }
  let id = RegistrationId("/app/")

  let pending : Registration = {
    id,
    installing: Some(worker),
    waiting: None,
    active: None,
  }
  let waiting_only : Registration = {
    id,
    installing: None,
    waiting: Some(worker),
    active: None,
  }
  let active : Registration = {
    id,
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Activated }),
  }

  inspect(pending.has_installing(), content="true")
  inspect(pending.has_waiting(), content="false")
  inspect(pending.has_pending_update(), content="true")
  inspect(pending.has_activation_started(), content="false")

  inspect(waiting_only.has_waiting(), content="true")
  inspect(waiting_only.has_pending_update(), content="true")

  inspect(active.has_activation_started(), content="true")
  inspect(active.has_pending_update(), content="false")
}

///|
test "Registration::has_activation_started follows the active worker state" {
  let id = RegistrationId("/app/")
  let activating : Registration = {
    id,
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Activating }),
  }
  let activated : Registration = {
    id,
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Activated }),
  }
  let installed : Registration = {
    id,
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Installed }),
  }
  let no_controller : Registration = {
    id,
    installing: None,
    waiting: None,
    active: None,
  }

  inspect(activating.has_activation_started(), content="true")
  inspect(activated.has_activation_started(), content="true")
  inspect(installed.has_activation_started(), content="false")
  inspect(no_controller.has_activation_started(), content="false")
}

///|
test "redundant installing worker still counts as pending until slot is cleared" {
  let id = RegistrationId("/app/")
  let stale : Registration = {
    id,
    installing: Some({ script_url: "/sw.js", state: Redundant }),
    waiting: None,
    active: None,
  }
  let cleared : Registration = {
    id,
    installing: None,
    waiting: None,
    active: None,
  }
  inspect(stale.has_pending_update(), content="true")
  inspect(cleared.has_pending_update(), content="false")
}

// ===========================================================================
// Registration options
// ===========================================================================

///|
pub(all) enum WorkerType {
  Classic
  Module
} derive(Debug, Eq)

///|
pub impl Show for WorkerType with fn output(self, buf) {
  match self {
    Classic => buf.write_string("classic")
    Module => buf.write_string("module")
  }
}

///|
pub(all) enum UpdateViaCache {
  Imports
  All
  None_
} derive(Debug, Eq)

///|
pub impl Show for UpdateViaCache with fn output(self, buf) {
  match self {
    Imports => buf.write_string("imports")
    All => buf.write_string("all")
    None_ => buf.write_string("none")
  }
}

///|
/// Options for `register`. Omitting a field leaves the browser default.
#warnings("-struct_never_constructed")
pub struct RegistrationOptions {
  scope : String?
  worker_type : WorkerType?
  update_via_cache : UpdateViaCache?
} derive(Debug, Eq)

///|
pub fn RegistrationOptions::RegistrationOptions(
  scope? : String,
  worker_type? : WorkerType,
  update_via_cache? : UpdateViaCache,
) -> RegistrationOptions {
  { scope, worker_type, update_via_cache }
}

// ===========================================================================
// Errors
// ===========================================================================

///|
/// Failures surfaced by Service Worker commands and subscriptions.
pub(all) enum ServiceWorkerError {
  Unavailable
  RegistrationNotFound(RegistrationId)
  NoActiveWorker(RegistrationId)
  DomError(String)
  DecodeError(String)
} derive(Debug, Eq)

///|
pub impl Show for ServiceWorkerError with fn output(self, buf) {
  match self {
    Unavailable => buf.write_string("Unavailable")
    RegistrationNotFound(id) => {
      buf.write_string("RegistrationNotFound(")
      Show::output(id, buf)
      buf.write_string(")")
    }
    NoActiveWorker(id) => {
      buf.write_string("NoActiveWorker(")
      Show::output(id, buf)
      buf.write_string(")")
    }
    DomError(message) => {
      buf.write_string("DomError(")
      Show::output(message, buf)
      buf.write_string(")")
    }
    DecodeError(message) => {
      buf.write_string("DecodeError(")
      Show::output(message, buf)
      buf.write_string(")")
    }
  }
}

///|
/// Why an inbound worker message could not be decoded into `Message`.
pub(all) enum MessageDecodeError {
  UnsupportedPayload
  InvalidJson(String)
} derive(Debug, Eq)

///|
pub impl Show for MessageDecodeError with fn output(self, buf) {
  match self {
    UnsupportedPayload => buf.write_string("UnsupportedPayload")
    InvalidJson(message) => {
      buf.write_string("InvalidJson(")
      Show::output(message, buf)
      buf.write_string(")")
    }
  }
}

// ===========================================================================
// Message — unified typed message envelope
// ===========================================================================

///|
/// A typed message exchanged between a Rabbita application and a Service
/// Worker.
///
/// V1 supports text frames and JSON-object / JSON-array payloads only.
/// Other structured-clone values are reported as `MessageDecodeError`, not
/// silently stringified.
pub(all) enum Message {
  Text(String)
  Json(Json)
} derive(Debug)

///|
pub impl Show for Message with fn output(self, buf) {
  match self {
    Text(text) => {
      buf.write_string("Text(")
      Show::output(text, buf)
      buf.write_string(")")
    }
    Json(value) => {
      buf.write_string("Json(")
      buf.write_string(value.stringify())
      buf.write_string(")")
    }
  }
}
