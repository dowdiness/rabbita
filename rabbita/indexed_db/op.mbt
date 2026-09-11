///|
using @cmd {type Cmd}

///|
using @debug {type Repr}

///|
#cfg(target="js")
extenum @cmd.Extension += {
  IndexedDBGet(Store, String, @cmd.Emit[Result[Lookup, ReadError]])
  IndexedDBContains(Store, String, @cmd.Emit[Result[Bool, ReadError]])
  IndexedDBEntries(Store, @cmd.Emit[Result[Array[Entry], ReadError]])
  IndexedDBApply(Store, Array[Mutation], @cmd.Emit[WriteError?])
}

///|
#cfg(target="js")
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(indexed_db_invoke)
  ..on_debug(extension => {
    match extension {
      IndexedDBGet(_, _, _) => Repr::ctor("IndexedDBGet", [])
      IndexedDBContains(_, _, _) => Repr::ctor("IndexedDBContains", [])
      IndexedDBEntries(_, _) => Repr::ctor("IndexedDBEntries", [])
      IndexedDBApply(_, mutations, _) =>
        Repr::ctor("IndexedDBApply", [(None, Repr(mutations.length()))])
      _ => raise @cmd.Unhandled
    }
  })

///|
#cfg(target="js")
fn indexed_db_invoke(
  extension : @cmd.Extension,
  _ : &@cmd.Context,
) -> @cmd.OpCont[Cmd] raise @cmd.Unhandled {
  match extension {
    IndexedDBGet(store, key, msg) =>
      Async(async fn() {
        @js.suspend(fn(resolve, _) {
          enqueue_get(store, key, result => resolve(msg(result)))
        })
      })
    IndexedDBContains(store, key, msg) =>
      Async(async fn() {
        @js.suspend(fn(resolve, _) {
          enqueue_contains(store, key, result => resolve(msg(result)))
        })
      })
    IndexedDBEntries(store, msg) =>
      Async(async fn() {
        @js.suspend(fn(resolve, _) {
          enqueue_entries(store, result => resolve(msg(result)))
        })
      })
    IndexedDBApply(store, mutations, msg) =>
      Async(async fn() {
        @js.suspend(fn(resolve, _) {
          enqueue_apply(store, mutations, result => resolve(msg(result)))
        })
      })
    _ => raise @cmd.Unhandled
  }
}

///|
#cfg(target="js")
pub fn Store::get(
  self : Store,
  key : String,
  msg : @cmd.Emit[Result[Lookup, ReadError]],
) -> Cmd {
  op.request(IndexedDBGet(self, key, msg))
}

///|
#cfg(target="js")
pub fn Store::contains(
  self : Store,
  key : String,
  msg : @cmd.Emit[Result[Bool, ReadError]],
) -> Cmd {
  op.request(IndexedDBContains(self, key, msg))
}

///|
#cfg(target="js")
pub fn Store::entries(
  self : Store,
  msg : @cmd.Emit[Result[Array[Entry], ReadError]],
) -> Cmd {
  op.request(IndexedDBEntries(self, msg))
}

///|
#cfg(target="js")
pub fn Store::set(
  self : Store,
  key : String,
  value : String,
  msg : @cmd.Emit[WriteError?],
) -> Cmd {
  self.apply([Mutation::Set(key, value)], msg)
}

///|
#cfg(target="js")
pub fn Store::delete(
  self : Store,
  key : String,
  msg : @cmd.Emit[WriteError?],
) -> Cmd {
  self.apply([Mutation::Delete(key)], msg)
}

///|
#cfg(target="js")
pub fn Store::apply(
  self : Store,
  mutations : Array[Mutation],
  msg : @cmd.Emit[WriteError?],
) -> Cmd {
  op.request(IndexedDBApply(self, mutations.copy(), msg))
}

///|
#cfg(not(target="js"))
fn unsupported_indexed_db() -> Unit {
  ()
}
