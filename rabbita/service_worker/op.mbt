///|
extenum @cmd.Extension += {
  ServiceWorkerRegister(
    String,
    RegistrationOptions?,
    @cmd.Emit[Registration]?,
    @cmd.Emit[ServiceWorkerError]?
  )
  ServiceWorkerGetRegistration(
    String,
    @cmd.Emit[Registration?]?,
    @cmd.Emit[ServiceWorkerError]?
  )
  ServiceWorkerGetRegistrations(
    @cmd.Emit[Array[Registration]]?,
    @cmd.Emit[ServiceWorkerError]?
  )
  ServiceWorkerUpdate(
    RegistrationId,
    @cmd.Emit[Unit]?,
    @cmd.Emit[ServiceWorkerError]?
  )
  ServiceWorkerUnregister(
    RegistrationId,
    @cmd.Emit[Bool]?,
    @cmd.Emit[ServiceWorkerError]?
  )
  ServiceWorkerPostMessage(
    RegistrationId,
    Message,
    @cmd.Emit[ServiceWorkerError]?
  )
}

///|
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(op_invoke)
  ..on_debug(extension => {
    match extension {
      ServiceWorkerRegister(url, options, _, _) =>
        Repr::ctor("ServiceWorkerRegister", [
          (None, Repr(url)),
          (None, Debug::to_repr(options)),
        ])
      ServiceWorkerGetRegistration(client_url, _, _) =>
        Repr::ctor("ServiceWorkerGetRegistration", [(None, Repr(client_url))])
      ServiceWorkerGetRegistrations(_, _) =>
        Repr::ctor("ServiceWorkerGetRegistrations", [])
      ServiceWorkerUpdate(id, _, _) =>
        Repr::ctor("ServiceWorkerUpdate", [(None, Repr(id.scope()))])
      ServiceWorkerUnregister(id, _, _) =>
        Repr::ctor("ServiceWorkerUnregister", [(None, Repr(id.scope()))])
      ServiceWorkerPostMessage(id, payload, _) =>
        Repr::ctor("ServiceWorkerPostMessage", [
          (None, Repr(id.scope())),
          (None, Debug::to_repr(payload)),
        ])
      _ => raise Unhandled
    }
  })

// ===========================================================================
// Shared helpers
// ===========================================================================

///|
#cfg(target="js")
fn[T] emit_or_none(callback : @cmd.Emit[T]?, value : T) -> Cmd {
  match callback {
    Some(f) => f(value)
    None => @cmd.none
  }
}

///|
#cfg(target="js")
fn fail_or_none(
  failed : @cmd.Emit[ServiceWorkerError]?,
  err : ServiceWorkerError,
) -> Cmd {
  match failed {
    Some(f) => f(err)
    None => @cmd.none
  }
}

///|
#cfg(target="js")
fn fail_dom_or_none(
  failed : @cmd.Emit[ServiceWorkerError]?,
  err : Error,
) -> Cmd {
  fail_or_none(failed, DomError(err.to_string()))
}

///|
#cfg(target="js")
fn worker_info(sw : @dom.ServiceWorker) -> WorkerInfo {
  { script_url: sw.script_url(), state: WorkerState(sw.state()) }
}

///|
#cfg(target="js")
fn snapshot_registration(reg : @dom.ServiceWorkerRegistration) -> Registration {
  {
    id: RegistrationId(reg.scope()),
    installing: reg.installing().to_option().map(worker_info),
    waiting: reg.waiting().to_option().map(worker_info),
    active: reg.active().to_option().map(worker_info),
  }
}

///|
/// Obtain the `ServiceWorkerContainer`, or `None` when the API is unavailable
/// (for example outside a secure context).
#cfg(target="js")
fn container() -> @dom.ServiceWorkerContainer? {
  @dom.window().navigator().service_worker().to_option()
}

///|
/// Client-URL lookup via `ServiceWorkerContainer.getRegistration`.
///
/// This follows the browser's longest-prefix matching rules and may return a
/// parent registration. Do **not** use this for destructive operations keyed
/// by `RegistrationId`.
#cfg(target="js")
async fn get_registration_for_client(
  client_url : String,
) -> @dom.ServiceWorkerRegistration? {
  guard container() is Some(c) else { return None }
  let raw = c
    .get_registration(client_url=@js.Optional::from_option(Some(client_url)))
    .wait()
  if (raw : @js.Value).is_undefined() {
    None
  } else {
    Some(raw.cast())
  }
}

///|
/// Resolve a live registration by exact absolute scope identity.
#cfg(target="js")
async fn resolve_registration_id(
  id : RegistrationId,
) -> @dom.ServiceWorkerRegistration? {
  let expected = id.scope()
  guard get_registration_for_client(expected) is Some(reg) else { return None }
  guard scopes_match(reg.scope(), expected) else { return None }
  Some(reg)
}

///|
#cfg(target="js")
fn registration_options_to_js(options : RegistrationOptions) -> @js.Value? {
  let has_any = options.scope is Some(_) ||
    options.worker_type is Some(_) ||
    options.update_via_cache is Some(_)
  guard has_any else { return None }
  let opts = @js.Object::new()
  if options.scope is Some(scope) {
    opts["scope"] = scope
  }
  if options.worker_type is Some(worker_type) {
    opts["type"] = Show::to_string(worker_type)
  }
  if options.update_via_cache is Some(policy) {
    opts["updateViaCache"] = Show::to_string(policy)
  }
  Some(opts.to_value())
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
    ServiceWorkerRegister(script_url, options, registered, failed) =>
      Async(() => {
        try {
          guard container() is Some(c) else {
            return fail_or_none(failed, Unavailable)
          }
          let promise = match options {
            None => c.register(script_url)
            Some(opts) =>
              match registration_options_to_js(opts) {
                None => c.register(script_url)
                Some(js_opts) =>
                  c.register(
                    script_url,
                    options=@js.Optional::from_option(Some(js_opts)),
                  )
              }
          }
          let reg : @dom.ServiceWorkerRegistration = promise.wait().cast()
          emit_or_none(registered, snapshot_registration(reg))
        } catch {
          err => fail_dom_or_none(failed, err)
        }
      })
    ServiceWorkerGetRegistration(client_url, reply, failed) =>
      Async(() => {
        try {
          guard container() is Some(_) else {
            return fail_or_none(failed, Unavailable)
          }
          let reg = get_registration_for_client(client_url).map(
            snapshot_registration,
          )
          emit_or_none(reply, reg)
        } catch {
          err => fail_dom_or_none(failed, err)
        }
      })
    ServiceWorkerGetRegistrations(reply, failed) =>
      Async(() => {
        try {
          guard container() is Some(c) else {
            return fail_or_none(failed, Unavailable)
          }
          let raw : Array[@js.Value] = c.get_registrations().wait().cast()
          let regs = raw.map(v => snapshot_registration(v.cast()))
          emit_or_none(reply, regs)
        } catch {
          err => fail_dom_or_none(failed, err)
        }
      })
    ServiceWorkerUpdate(id, done, failed) =>
      Async(() => {
        try {
          guard container() is Some(_) else {
            return fail_or_none(failed, Unavailable)
          }
          match resolve_registration_id(id) {
            None => fail_or_none(failed, RegistrationNotFound(id))
            Some(reg) => {
              reg.update().wait() |> ignore
              emit_or_none(done, ())
            }
          }
        } catch {
          err => fail_dom_or_none(failed, err)
        }
      })
    ServiceWorkerUnregister(id, reply, failed) =>
      Async(() => {
        try {
          guard container() is Some(_) else {
            return fail_or_none(failed, Unavailable)
          }
          match resolve_registration_id(id) {
            None => emit_or_none(reply, false)
            Some(reg) => {
              let ok : Bool = reg.unregister().wait().cast()
              emit_or_none(reply, ok)
            }
          }
        } catch {
          err => fail_dom_or_none(failed, err)
        }
      })
    ServiceWorkerPostMessage(id, payload, failed) =>
      Async(() => {
        try {
          guard container() is Some(_) else {
            return fail_or_none(failed, Unavailable)
          }
          match resolve_registration_id(id) {
            None => fail_or_none(failed, RegistrationNotFound(id))
            Some(reg) =>
              match reg.active().to_option() {
                None => fail_or_none(failed, NoActiveWorker(id))
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
          err => fail_dom_or_none(failed, err)
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
