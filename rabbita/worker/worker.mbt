///|
/// Identity of one installed Worker, not a logical subscription name.
pub struct Connection {
  priv id : UInt64
} derive(Eq, Hash)

///|
pub impl Debug for Connection with fn to_repr(_) {
  @debug.Repr::ctor("Connection", [])
}

///|
pub extend Connection with Eq::{equal, not_equal}

///|
pub extend Connection with Hash::{hash, hash_combine}

///|
pub extend Connection with @debug.Debug::{to_repr}

///|
/// Redacted transport failures. None imply that remote effects were rolled back.
pub(all) enum Failure {
  Unavailable
  ConstructionFailed
  ConnectionClosed
  PostFailed
  WorkerFailed
  MessageError
  InvalidMessage
  Timeout
  InvalidTimeout
} derive(Eq, Debug)

///|
pub extend Failure with Eq::{equal, not_equal}

///|
pub extend Failure with @debug.Debug::{to_repr}

///|
pub(all) enum Event {
  Connected(Connection)
  Failed(Connection?, Failure)
} derive(Eq, Debug)

///|
pub extend Event with Eq::{equal, not_equal}

///|
pub extend Event with @debug.Debug::{to_repr}

///|
priv suberror WorkerSubscription {
  Listen(String, @cmd.Emit[Event])
}

///|
fn worker_sub_loader(
  payload : Error,
  scheduler : &@cmd.Scheduler,
) -> @sub.RunningSub? {
  guard payload is Listen(url, on_event) else { return None }
  let mut tagger = on_event
  let notify = event => scheduler.add(tagger(event))
  let connection = match install_worker(url, notify) {
    Ok(entry) => {
      notify(Connected(entry.connection))
      Some(entry)
    }
    Err(failure) => {
      notify(Failed(None, failure))
      None
    }
  }
  // Retain failed subscriptions too: ordinary model updates must not retry.
  Some({
    unload: _ => {
      if connection is Some(entry) {
        close_entry(entry, ConnectionClosed, notify=false)
      }
    },
    update_tagger: payload => if payload is Listen(_, next) { tagger = next },
  })
}

///|
/// Own a dedicated module Worker until this subscription is removed.
/// Callback changes retag; key, URL or generation changes replace the Worker.
pub fn listen(
  key : String,
  url : String,
  generation? : Int = 0,
  on_event~ : @cmd.Emit[Event],
) -> @sub.Sub {
  @sub.custom_sub(
    "worker:\{key.length()}:\{key}:\{url.length()}:\{url}:\{generation}",
    Local,
    Listen(url, on_event),
    worker_sub_loader,
  )
}

///|
extenum @cmd.Extension += {
  WorkerRequest(Connection, String, Int, @cmd.Emit[Result[Json, Failure]])
  WorkerDelivery(
    Connection,
    Result[Json, Failure],
    @cmd.Emit[Result[Json, Failure]]
  )
}

///|
fn worker_invoke(
  extension : @cmd.Extension,
  _ : &@cmd.Context,
) -> @cmd.OpCont[@cmd.Cmd] raise @cmd.Unhandled {
  match extension {
    WorkerRequest(connection, payload, timeout_ms, reply) =>
      Async(async fn() {
        callback_promise(resolve => {
          start_request(connection, payload, timeout_ms, result => {
            resolve(op.request(WorkerDelivery(connection, result, reply)))
          })
        }).wait()
      })
    WorkerDelivery(connection, result, reply) => {
      // The promise can settle before removal, then drain after replacement.
      let result = if result is Ok(_) && !entries.contains(connection) {
        Err(ConnectionClosed)
      } else {
        result
      }
      Ready(reply(result))
    }
    _ => raise @cmd.Unhandled
  }
}

///|
let op : @cmd.Op = @cmd.Op()

///|
fn init {
  op
  ..on_invoke(worker_invoke)
  ..on_settle((_, _) => Ready((Json::null(), @cmd.none)))
  ..on_resume((_, _, _) => raise @cmd.HydrateExn::Skip)
  .on_debug(extension => {
    match extension {
      WorkerRequest(_, _, _, _) => @debug.Repr::ctor("WorkerRequest", [])
      WorkerDelivery(_, _, _) => @debug.Repr::ctor("WorkerDelivery", [])
      _ => raise @cmd.Unhandled
    }
  })
}

///|
/// Capture this exact incarnation and payload for a one-shot request.
/// The reply's domain message must retain its connection and domain request ID
/// so update can reject a message queued before a later replacement.
pub fn request(
  connection : Connection,
  payload : Json,
  reply~ : @cmd.Emit[Result[Json, Failure]],
  timeout_ms? : Int = 15000,
) -> @cmd.Cmd {
  op.request(WorkerRequest(connection, payload.stringify(), timeout_ms, reply))
}
