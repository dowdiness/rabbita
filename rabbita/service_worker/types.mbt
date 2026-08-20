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
///              │              │           │
///              └──────────────┴───────────┴──→ Redundant
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
} derive(Debug, Eq)

///|
pub impl Show for WorkerState with fn output(self, buf) {
  buf.write_string(self.id())
}

///|
/// The lowercase spec identifier for this state.
pub fn WorkerState::id(self : WorkerState) -> String {
  match self {
    Parsed => "parsed"
    Installing => "installing"
    Installed => "installed"
    Activating => "activating"
    Activated => "activated"
    Redundant => "redundant"
  }
}

///|
fn WorkerState::from_string(s : String) -> WorkerState {
  match s {
    "parsed" => Parsed
    "installing" => Installing
    "installed" => Installed
    "activating" => Activating
    "activated" => Activated
    _ => Redundant
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
/// Whether this worker has reached a terminal state.
pub fn WorkerState::is_terminal(self : WorkerState) -> Bool {
  match self {
    Activated | Redundant => true
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
    _ => false
  }
}

///|
test "WorkerState::from_string maps spec ids and unknown values to Redundant" {
  inspect(WorkerState::from_string("parsed").id(), content="parsed")
  inspect(WorkerState::from_string("installing").id(), content="installing")
  inspect(WorkerState::from_string("installed").id(), content="installed")
  inspect(WorkerState::from_string("activating").id(), content="activating")
  inspect(WorkerState::from_string("activated").id(), content="activated")
  inspect(WorkerState::from_string("redundant").id(), content="redundant")
  inspect(WorkerState::from_string("unknown").id(), content="redundant")
}

// ===========================================================================
// RegistrationId
// ===========================================================================

///|
/// A stable identifier for a Service Worker registration, derived from its
/// resolved scope URL.
pub(all) struct RegistrationId {
  scope : String
} derive(Debug, Eq, Hash)

///|
pub impl Show for RegistrationId with fn output(self, buf) {
  Show::output(Debug::to_repr(self), buf)
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

  let pending : Registration = {
    id: { scope: "/app/" },
    installing: Some(worker),
    waiting: None,
    active: None,
  }
  let waiting_only : Registration = {
    id: { scope: "/app/" },
    installing: None,
    waiting: Some(worker),
    active: None,
  }
  let active : Registration = {
    id: { scope: "/app/" },
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
  let activating : Registration = {
    id: { scope: "/app/" },
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Activating }),
  }
  let activated : Registration = {
    id: { scope: "/app/" },
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Activated }),
  }
  let installed : Registration = {
    id: { scope: "/app/" },
    installing: None,
    waiting: None,
    active: Some({ script_url: "/sw.js", state: Installed }),
  }
  let no_controller : Registration = {
    id: { scope: "/app/" },
    installing: None,
    waiting: None,
    active: None,
  }

  inspect(activating.has_activation_started(), content="true")
  inspect(activated.has_activation_started(), content="true")
  inspect(installed.has_activation_started(), content="false")
  inspect(no_controller.has_activation_started(), content="false")
}

// ===========================================================================
// Message — unified typed message envelope
// ===========================================================================

///|
/// A typed message exchanged between a Rabbita application and a Service
/// Worker.  Used for both inbound (`postMessage` from worker) and outbound
/// (`post_message` to worker) directions; the direction is determined by the
/// API that produces or consumes it.
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
