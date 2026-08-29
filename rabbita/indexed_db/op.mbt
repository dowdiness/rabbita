///|
using @cmd {type Cmd}

///|
using @debug {type Repr}

///|
#cfg(target="js")
extenum @cmd.Extension += {
  IndexedDBGet(Config, String, Bool, @cmd.Emit[ReadResult])
  IndexedDBPut(Config, String, String, @cmd.Emit[WriteResult])
  IndexedDBMutate(Config, Array[Mutation], @cmd.Emit[WriteResult])
  IndexedDBScan(Config, @cmd.Emit[ScanResult])
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
      IndexedDBMutate(config, mutations, _) =>
        Repr::ctor("IndexedDBMutate", [
          (None, Repr(config)),
          (None, Repr(mutations)),
        ])
      IndexedDBScan(config, _) =>
        Repr::ctor("IndexedDBScan", [(None, Repr(config))])
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
    IndexedDBMutate(config, mutations, reply) =>
      LegacyEffect(@cmd.immediately, scheduler => {
        enqueue_mutate(config, mutations, result => scheduler.add(reply(result)))
      })
    IndexedDBScan(config, reply) =>
      LegacyEffect(@cmd.immediately, scheduler => {
        enqueue_scan(config, result => scheduler.add(reply(result)))
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
/// Apply string puts and deletes atomically in one transaction.
#cfg(target="js")
pub fn mutate(
  config : Config,
  mutations : Array[Mutation],
  result~ : @cmd.Emit[WriteResult],
) -> @cmd.Cmd {
  op.request(IndexedDBMutate(config, mutations.copy(), result))
}

///|
/// Scan every record in one object store and return after transaction commit.
#cfg(target="js")
pub fn scan(config : Config, result~ : @cmd.Emit[ScanResult]) -> @cmd.Cmd {
  op.request(IndexedDBScan(config, result))
}

///|
#cfg(not(target="js"))
#warnings("-unused_error_type")
fn unsupported_indexed_db() -> Unit {
  ()
}
