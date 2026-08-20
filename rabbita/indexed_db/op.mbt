///|
using @cmd {type Cmd}

///|
using @debug {type Repr}

///|
#cfg(target="js")
extenum @cmd.Extension += {
  IndexedDBGet(Config, String, Bool, @cmd.Emit[ReadResult])
  IndexedDBPut(Config, String, String, @cmd.Emit[WriteResult])
}

///|
#cfg(target="js")
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(indexed_db_invoke)
  ..on_debug(extension => {
    match extension {
      IndexedDBGet(config, key, migrate_legacy, _) =>
        Repr::ctor("IndexedDBGet", [
          (None, Repr(config)),
          (None, Repr(key)),
          (None, Repr(migrate_legacy)),
        ])
      IndexedDBPut(config, key, value, _) =>
        Repr::ctor("IndexedDBPut", [
          (None, Repr(config)),
          (None, Repr(key)),
          (None, Repr(value)),
        ])
      _ => raise @cmd.Unhandled
    }
  })

///|
#cfg(target="js")
fn indexed_db_invoke(
  extension : @cmd.Extension,
  _context : &@cmd.Context,
) -> @cmd.OpCont[Cmd] raise @cmd.Unhandled {
  match extension {
    IndexedDBGet(config, key, migrate_legacy, reply) =>
      LegacyEffect(@cmd.immediately, scheduler => {
        enqueue_get(config, key, migrate_legacy, result => {
          scheduler.add(reply(result))
        })
      })
    IndexedDBPut(config, key, value, reply) =>
      LegacyEffect(@cmd.immediately, scheduler => {
        enqueue_put(config, key, value, result => scheduler.add(reply(result)))
      })
    _ => raise @cmd.Unhandled
  }
}

///|
/// Read one string record and return the result to the Rabbita update loop.
#cfg(target="js")
pub fn get(
  config : Config,
  key : String,
  migrate_legacy? : Bool = false,
  result~ : @cmd.Emit[ReadResult],
) -> @cmd.Cmd {
  op.request(IndexedDBGet(config, key, migrate_legacy, result))
}

///|
/// Replace one string record and acknowledge only after transaction commit.
#cfg(target="js")
pub fn put(
  config : Config,
  key : String,
  value : String,
  result~ : @cmd.Emit[WriteResult],
) -> @cmd.Cmd {
  op.request(IndexedDBPut(config, key, value, result))
}

///|
#cfg(not(target="js"))
#warnings("-unused_error_type")
fn unsupported_indexed_db() -> Unit {
  ()
}
