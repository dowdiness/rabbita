///|
extenum @cmd.Extension += {
  ServiceWorkerRegister(
    String,
    String?,
    @cmd.Emit[Registration]?,
    @cmd.Emit[String]?
  )
  ServiceWorkerGetRegistration(
    String,
    @cmd.Emit[Registration?]?,
    @cmd.Emit[String]?
  )
  ServiceWorkerGetRegistrations(
    @cmd.Emit[Array[Registration]]?,
    @cmd.Emit[String]?
  )
  ServiceWorkerUpdate(RegistrationId, @cmd.Emit[Unit]?, @cmd.Emit[String]?)
  ServiceWorkerUnregister(RegistrationId, @cmd.Emit[Bool]?, @cmd.Emit[String]?)
  ServiceWorkerPostMessage(RegistrationId, Message, @cmd.Emit[String]?)
}

///|
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(op_invoke)
  ..on_debug(extension => {
    match extension {
      ServiceWorkerRegister(url, scope, _, _) =>
        Repr::ctor("ServiceWorkerRegister", [
          (None, Repr(url)),
          (None, Repr(scope)),
        ])
      ServiceWorkerGetRegistration(scope, _, _) =>
        Repr::ctor("ServiceWorkerGetRegistration", [(None, Repr(scope))])
      ServiceWorkerGetRegistrations(_, _) =>
        Repr::ctor("ServiceWorkerGetRegistrations", [])
      ServiceWorkerUpdate(id, _, _) =>
        Repr::ctor("ServiceWorkerUpdate", [(None, Repr(id.scope))])
      ServiceWorkerUnregister(id, _, _) =>
        Repr::ctor("ServiceWorkerUnregister", [(None, Repr(id.scope))])
      ServiceWorkerPostMessage(id, payload, _) =>
        Repr::ctor("ServiceWorkerPostMessage", [
          (None, Repr(id.scope)),
          (None, Debug::to_repr(payload)),
        ])
      _ => raise Unhandled
    }
  })

// ===========================================================================
// Shared helpers — eliminate repetition in op_invoke
// ===========================================================================

///|
/// Emit a value through an optional callback, or return `@cmd.none`.
#cfg(target="js")
fn[T] emit_or_none(callback : @cmd.Emit[T]?, value : T) -> Cmd {
  match callback {
    Some(f) => f(value)
    None => @cmd.none
  }
}

///|
/// Emit an error through an optional `failed` callback, or swallow it.
#cfg(target="js")
fn fail_or_none(failed : @cmd.Emit[String]?, err : Error) -> Cmd {
  match failed {
    Some(f) => f(err.to_string())
    None => @cmd.none
  }
}

///|
/// Emit a string error through an optional `failed` callback, or swallow it.
#cfg(target="js")
fn fail_str_or_none(failed : @cmd.Emit[String]?, message : String) -> Cmd {
  match failed {
    Some(f) => f(message)
    None => @cmd.none
  }
}

///|
/// Build a `ServiceWorker` snapshot from a live browser object.
#cfg(target="js")
fn worker_info(sw : @dom.ServiceWorker) -> WorkerInfo {
  { script_url: sw.script_url(), state: WorkerState(sw.state()) }
}

///|
/// Capture the current slots of a live `ServiceWorkerRegistration` into an
/// immutable `Registration` value safe for storage in a Rabbita `Model`.
#cfg(target="js")
fn snapshot_registration(reg : @dom.ServiceWorkerRegistration) -> Registration {
  {
    id: { scope: reg.scope() },
    installing: reg.installing().to_option().map(worker_info),
    waiting: reg.waiting().to_option().map(worker_info),
    active: reg.active().to_option().map(worker_info),
  }
}

///|
/// Obtain the `ServiceWorkerContainer` from the current window.
#cfg(target="js")
fn container() -> @dom.ServiceWorkerContainer {
  @dom.window().navigator().service_worker()
}

///|
/// Resolve a live `ServiceWorkerRegistration` by scope, returning `None` when
/// the scope has no registration.
#cfg(target="js")
async fn resolve_registration(
  scope : String,
) -> @dom.ServiceWorkerRegistration? {
  let raw = container()
    .get_registration(client_url=@js.Optional::from_option(Some(scope)))
    .wait()
  if (raw : @js.Value).is_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

// ===========================================================================
// op_invoke — JS target
// ===========================================================================

///|
#cfg(target="js")
fn op_invoke(
  extension : @cmd.Extension,
  _context : &@cmd.Context,
) -> @cmd.OpCont[Cmd] raise @cmd.Unhandled {
  match extension {
    ServiceWorkerRegister(script_url, scope, registered, failed) =>
      Async(() => {
        try {
          let promise = match scope {
            None => container().register(script_url)
            Some(s) => {
              let opts = @js.Object::new()
              opts["scope"] = s
              let options = @js.Optional::from_option(Some(opts.to_value()))
              container().register(script_url, options~)
            }
          }
          let reg : @dom.ServiceWorkerRegistration = promise.wait().cast()
          emit_or_none(registered, snapshot_registration(reg))
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    ServiceWorkerGetRegistration(scope, reply, failed) =>
      Async(() => {
        try {
          let reg = resolve_registration(scope).map(snapshot_registration)
          emit_or_none(reply, reg)
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    ServiceWorkerGetRegistrations(reply, failed) =>
      Async(() => {
        try {
          let raw : Array[@js.Value] = container()
            .get_registrations()
            .wait()
            .cast()
          let regs = raw.map(v => snapshot_registration(v.cast()))
          emit_or_none(reply, regs)
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    ServiceWorkerUpdate(id, done, failed) =>
      Async(() => {
        try {
          match resolve_registration(id.scope) {
            None =>
              fail_str_or_none(
                failed,
                "no registration found for scope: \{id.scope}",
              )
            Some(reg) => {
              reg.update().wait() |> ignore
              emit_or_none(done, ())
            }
          }
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    ServiceWorkerUnregister(id, reply, failed) =>
      Async(() => {
        try {
          match resolve_registration(id.scope) {
            None => emit_or_none(reply, false)
            Some(reg) => {
              let ok : Bool = reg.unregister().wait().cast()
              emit_or_none(reply, ok)
            }
          }
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    ServiceWorkerPostMessage(id, payload, failed) =>
      Async(() => {
        try {
          match resolve_registration(id.scope) {
            None =>
              fail_str_or_none(
                failed,
                "no registration found for scope: \{id.scope}",
              )
            Some(reg) =>
              match reg.active().to_option() {
                None =>
                  fail_str_or_none(
                    failed,
                    "no active service worker for scope: \{id.scope}",
                  )
                Some(sw) => {
                  match payload {
                    Text(text) => sw.post_message(@js.Value::cast_from(text))
                    Json(json) => sw.post_message(@js.Value::from_json(json))
                  }
                  @cmd.none
                }
              }
          }
        } catch {
          err => fail_or_none(failed, err)
        }
      })
    _ => raise Unhandled
  }
}

// ===========================================================================
// op_invoke — non-JS stub
// ===========================================================================

///|
#cfg(not(target="js"))
#warnings("-unused_error_type")
fn op_invoke(
  extension : @cmd.Extension,
  _context : &@cmd.Context,
) -> @cmd.OpCont[Cmd] raise @cmd.Unhandled {
  match extension {
    ServiceWorkerRegister(_, _, registered, failed) => {
      ignore(registered)
      ignore(failed)
      None
    }
    ServiceWorkerGetRegistration(_, reply, failed) => {
      ignore(reply)
      ignore(failed)
      None
    }
    ServiceWorkerGetRegistrations(reply, failed) => {
      ignore(reply)
      ignore(failed)
      None
    }
    ServiceWorkerUpdate(_, done, failed) => {
      ignore(done)
      ignore(failed)
      None
    }
    ServiceWorkerUnregister(_, reply, failed) => {
      ignore(reply)
      ignore(failed)
      None
    }
    ServiceWorkerPostMessage(_, payload, failed) => {
      ignore(payload)
      ignore(failed)
      None
    }
    _ => None
  }
}
