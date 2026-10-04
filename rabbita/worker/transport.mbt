///|
priv struct Pending {
  complete : (Result[Json, Failure]) -> Unit
  timeout_ms : Int
  mut timer : Int
}

///|
priv struct Entry {
  connection : Connection
  native : NativeWorker
  notify : (Event) -> Unit
  pending : Map[String, Pending]
  mut live : Bool
  mut next_request : UInt64
}

///|
let next_connection : Ref[UInt64] = Ref(0)

///|
let entries : Map[Connection, Entry] = Map([])

///|
fn settle(entry : Entry, id : String, result : Result[Json, Failure]) -> Unit {
  guard entry.live && entry.pending.get(id) is Some(pending) else { return }
  entry.pending.remove(id)
  timer_clear(pending.timer)
  (pending.complete)(result)
}

///|
fn close_entry(entry : Entry, failure : Failure, notify~ : Bool) -> Unit {
  guard entry.live else { return }
  entry.live = false
  entries.remove(entry.connection)
  native_close(entry.native)
  // Complete only resolves a promise; no consumer code can run synchronously.
  // The removed registry entry and live=false fence all native callbacks.
  for _, pending in entry.pending {
    timer_clear(pending.timer)
    (pending.complete)(Err(failure))
  }
  entry.pending.clear()
  if notify {
    (entry.notify)(Failed(Some(entry.connection), failure))
  }
}

///|
fn refresh_timer(entry : Entry, id : String) -> Unit {
  guard entry.live && entry.pending.get(id) is Some(pending) else { return }
  timer_clear(pending.timer)
  pending.timer = timer_start(pending.timeout_ms, () => {
    settle(entry, id, Err(Timeout))
  })
}

///|
fn receive_message(entry : Entry, text : String) -> Unit {
  guard entry.live else { return }
  let message = @json.parse(text) catch {
    _ => {
      close_entry(entry, InvalidMessage, notify=true)
      return
    }
  }
  match message {
    {
      "rabbita_worker": Number(1.0, ..),
      "id": String(id),
      "kind": String(kind),
      ..
    } =>
      match kind {
        "progress" => refresh_timer(entry, id)
        "result" =>
          match message {
            { "payload": payload, .. } => settle(entry, id, Ok(payload))
            _ => close_entry(entry, InvalidMessage, notify=true)
          }
        _ => close_entry(entry, InvalidMessage, notify=true)
      }
    _ => close_entry(entry, InvalidMessage, notify=true)
  }
}

///|
fn install_worker(
  url : String,
  notify : (Event) -> Unit,
) -> Result[Entry, Failure] {
  guard browser_available() else { return Err(Unavailable) }
  // Never reuse a connection value, including on integer overflow.
  guard next_connection.val != 18446744073709551615 else {
    return Err(ConstructionFailed)
  }
  next_connection.val += 1
  let connection : Connection = { id: next_connection.val, }
  let mut entry : Entry? = None
  let native = native_create(
    url,
    text => if entry is Some(entry) { receive_message(entry, text) },
    () => {
      if entry is Some(entry) {
        close_entry(entry, WorkerFailed, notify=true)
      }
    },
    () => {
      if entry is Some(entry) {
        close_entry(entry, MessageError, notify=true)
      }
    },
  ).to_option()
  guard native is Some(native) else { return Err(ConstructionFailed) }
  let installed : Entry = {
    connection,
    native,
    notify,
    pending: {},
    live: true,
    next_request: 0,
  }
  entry = Some(installed)
  entries[connection] = installed
  Ok(installed)
}

///|
fn start_request(
  connection : Connection,
  payload : String,
  timeout_ms : Int,
  complete : (Result[Json, Failure]) -> Unit,
) -> Unit {
  guard browser_available() else { return complete(Err(Unavailable)) }
  guard timeout_ms > 0 else { return complete(Err(InvalidTimeout)) }
  guard entries.get(connection) is Some(entry) else {
    return complete(Err(ConnectionClosed))
  }
  guard entry.next_request != 18446744073709551615 else {
    return complete(Err(PostFailed))
  }
  entry.next_request += 1
  let id = entry.next_request.to_string()
  // id is generated decimal text, and payload was serialized at Cmd creation.
  // No parse/stringify round-trip or compiler-layout object crosses this seam.
  let text = "{\"rabbita_worker\":1,\"id\":\"\{id}\",\"kind\":\"request\",\"payload\":\{payload}}"
  entry.pending[id] = { complete, timeout_ms, timer: 0, }
  refresh_timer(entry, id)
  if !native_post(entry.native, text) {
    settle(entry, id, Err(PostFailed))
  }
}
