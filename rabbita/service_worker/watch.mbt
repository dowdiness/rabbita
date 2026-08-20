// ===========================================================================
// SlotStateChangeBinding — statechange on one registration worker slot
// ===========================================================================

///|
/// Binds a `statechange` listener to one worker slot that may be replaced
/// over time (e.g. `registration.installing` after `updatefound`).
#cfg(target="js")
priv enum SlotStateChangeBinding {
  Unbound
  Bound(@dom.ServiceWorker, @dom.Listener)
}

///|
#cfg(target="js")
fn SlotStateChangeBinding::unbind(
  self : SlotStateChangeBinding,
) -> SlotStateChangeBinding {
  match self {
    Unbound => Unbound
    Bound(worker, listener) => {
      worker.remove_event_listener("statechange", listener)
      Unbound
    }
  }
}

///|
/// Re-bind `statechange` on `worker`, unbinding any previous binding first.
#cfg(target="js")
fn SlotStateChangeBinding::rebind(
  self : SlotStateChangeBinding,
  worker : @dom.ServiceWorker?,
  listener : @dom.Listener,
) -> SlotStateChangeBinding {
  let self = self.unbind()
  match worker {
    None => self
    Some(worker) => {
      worker.add_event_listener("statechange", listener)
      Bound(worker, listener)
    }
  }
}

// ===========================================================================
// RegistrationWatch — updatefound + worker slot statechange
// ===========================================================================

///|
/// Watches a live `ServiceWorkerRegistration` and emits immutable snapshots
/// whenever its worker slots change.
#cfg(target="js")
priv struct RegistrationWatch {
  mut generation : Int
  mut changed : @cmd.Emit[Registration]?
  mut failed : @cmd.Emit[ServiceWorkerError]?
  mut id : RegistrationId?
  mut reg : @dom.ServiceWorkerRegistration?
  mut updatefound_listener : @dom.Listener?
  mut installing : SlotStateChangeBinding
  mut waiting : SlotStateChangeBinding
  mut active : SlotStateChangeBinding
}

///|
#cfg(target="js")
fn RegistrationWatch::RegistrationWatch(
  changed : @cmd.Emit[Registration]?,
  failed : @cmd.Emit[ServiceWorkerError]?,
) -> RegistrationWatch {
  {
    generation: 0,
    changed,
    failed,
    id: None,
    reg: None,
    updatefound_listener: None,
    installing: Unbound,
    waiting: Unbound,
    active: Unbound,
  }
}

///|
#cfg(target="js")
fn RegistrationWatch::is_current(
  self : RegistrationWatch,
  generation : Int,
) -> Bool {
  self.generation == generation
}

///|
#cfg(target="js")
fn RegistrationWatch::set_callbacks(
  self : RegistrationWatch,
  changed : @cmd.Emit[Registration]?,
  failed : @cmd.Emit[ServiceWorkerError]?,
) -> Unit {
  self.changed = changed
  self.failed = failed
}

///|
#cfg(target="js")
fn RegistrationWatch::emit_failure(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
  err : ServiceWorkerError,
) -> Unit {
  guard self.is_current(generation) else { return }
  guard self.failed is Some(f) else { return }
  scheduler.add(f(err))
}

///|
#cfg(target="js")
fn RegistrationWatch::emit(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
  reg : @dom.ServiceWorkerRegistration,
) -> Unit {
  guard self.is_current(generation) else { return }
  guard self.changed is Some(f) else { return }
  scheduler.add(f(snapshot_registration(reg)))
}

///|
#cfg(target="js")
fn RegistrationWatch::unbind_all(self : RegistrationWatch) -> Unit {
  self.installing = self.installing.unbind()
  self.waiting = self.waiting.unbind()
  self.active = self.active.unbind()
  match (self.reg, self.updatefound_listener) {
    (Some(reg), Some(listener)) =>
      reg.remove_event_listener("updatefound", listener)
    _ => ()
  }
  self.reg = None
  self.updatefound_listener = None
}

///|
#cfg(target="js")
fn RegistrationWatch::dispose(self : RegistrationWatch) -> Unit {
  self.generation += 1
  self.unbind_all()
}

///|
/// After `statechange`, wait for a macrotask so registration slot clears that
/// the browser queues after worker-state updates are visible before snapshotting.
#cfg(target="js")
fn RegistrationWatch::schedule_reconcile(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
) -> Unit {
  ignore(
    @dom.window().set_timeout(() => self.reconcile(scheduler, generation), 0),
  )
}

///|
#cfg(target="js")
fn RegistrationWatch::reconcile(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
) -> Unit {
  guard self.is_current(generation) else { return }
  guard self.id is Some(id) else { return }
  @js.spawn_detach(async fn() {
    try {
      match resolve_registration_id(id) {
        None => ()
        Some(reg) => {
          guard self.is_current(generation) else { return }
          self.reg = Some(reg)
          self.emit(scheduler, generation, reg)
          self.rebind_worker_slots(scheduler, generation, reg)
        }
      }
    } catch {
      _ => ()
    }
  })
}

///|
#cfg(target="js")
fn RegistrationWatch::rebind_worker_slots(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
  reg : @dom.ServiceWorkerRegistration,
) -> Unit {
  guard self.is_current(generation) else { return }
  let on_state_change = _ => {
    guard self.is_current(generation) else { return }
    self.schedule_reconcile(scheduler, generation)
  }
  self.installing = self.installing.rebind(
    reg.installing().to_option(),
    on_state_change,
  )
  self.waiting = self.waiting.rebind(reg.waiting().to_option(), on_state_change)
  self.active = self.active.rebind(reg.active().to_option(), on_state_change)
}

///|
#cfg(target="js")
fn RegistrationWatch::on_updatefound(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
) -> Unit {
  guard self.is_current(generation) else { return }
  self.schedule_reconcile(scheduler, generation)
}

///|
#cfg(target="js")
fn RegistrationWatch::attach(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  generation : Int,
  reg : @dom.ServiceWorkerRegistration,
) -> Unit {
  guard self.is_current(generation) else { return }
  self.unbind_all()
  let on_updatefound = _ => self.on_updatefound(scheduler, generation)
  reg.add_event_listener("updatefound", on_updatefound)
  self.reg = Some(reg)
  self.updatefound_listener = Some(on_updatefound)
  self.emit(scheduler, generation, reg)
  self.rebind_worker_slots(scheduler, generation, reg)
}

///|
#cfg(target="js")
fn RegistrationWatch::start(
  self : RegistrationWatch,
  scheduler : &@cmd.Scheduler,
  id : RegistrationId,
) -> Unit {
  let generation = self.generation
  self.id = Some(id)
  @js.spawn_detach(async fn() {
    try {
      guard container() is Some(_) else {
        self.emit_failure(scheduler, generation, Unavailable)
        return
      }
      match resolve_registration_id(id) {
        None =>
          self.emit_failure(scheduler, generation, RegistrationNotFound(id))
        Some(reg) => self.attach(scheduler, generation, reg)
      }
    } catch {
      err => self.emit_failure(scheduler, generation, DomError(err.to_string()))
    }
  })
}
