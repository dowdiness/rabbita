///|
using @rabbita {type Cmd, type Emit, type Html, type Val}

///|
using @indexed_db {
  type Entry,
  type Lookup,
  type Mutation,
  type ReadError,
  type Store,
  type WriteError,
}

///|
using @html {button, div, h1, p}

///|
extern "js" fn resolved(value : String) -> @js.Promise = "(value) => Promise.resolve(value)"

///|
extern "js" fn rejected() -> @js.Promise = "() => Promise.reject(new Error('expected failure'))"

///|
let indexed_db_store : Store = Store::Store(
  "commands-and-async-indexed-db-e2e-20260911", 1, "records",
)

///|
priv struct Model {
  initialized : String
  delayed : String
  performed : String
  attempted : String
  batch_a : Bool
  batch_b : Bool
  indexed_db_status : String
} derive(Eq)

///|
priv enum Msg {
  Initialized(String)
  StartDelay
  DelayFinished
  StartPerform
  PerformFinished(String)
  StartAttempt
  AttemptFinished(Result[String, Error])
  StartBatch
  BatchA
  BatchB
  StartIndexedDb
  IndexedDbApplied(WriteError?)
  IndexedDbEntries(Result[Array[Entry], ReadError])
  IndexedDbContains(Result[Bool, ReadError])
  IndexedDbDeleted(WriteError?)
  IndexedDbGot(Result[Lookup, ReadError])
}

///|
fn update(model : Model, message : Msg, emit : Emit[Msg]) -> (Model, Cmd) {
  match message {
    Initialized(value) => ({ ..model, initialized: value }, @rabbita.none)
    StartDelay =>
      (
        { ..model, delayed: "waiting" },
        @rabbita.delay(emit(DelayFinished), 1000),
      )
    DelayFinished => ({ ..model, delayed: "finished" }, @rabbita.none)
    StartPerform =>
      (
        { ..model, performed: "running" },
        @rabbita.perform(value => emit(PerformFinished(value)), async fn() noraise {
          resolved("performed").wait().cast() catch {
            _ => "unexpected failure"
          }
        }),
      )
    PerformFinished(value) => ({ ..model, performed: value }, @rabbita.none)
    StartAttempt =>
      (
        { ..model, attempted: "running" },
        @rabbita.attempt(result => emit(AttemptFinished(result)), async fn() {
          rejected().wait().cast()
        }),
      )
    AttemptFinished(result) =>
      (
        {
          ..model,
          attempted: match result {
            Ok(value) => value
            Err(_) => "failed"
          },
        },
        @rabbita.none,
      )
    StartBatch =>
      (
        { ..model, batch_a: false, batch_b: false },
        @rabbita.batch([emit(BatchA), emit(BatchB)]),
      )
    BatchA => ({ ..model, batch_a: true }, @rabbita.none)
    BatchB => ({ ..model, batch_b: true }, @rabbita.none)
    StartIndexedDb =>
      (
        { ..model, indexed_db_status: "indexeddb: running" },
        indexed_db_store.apply(
          [Mutation::Set("alpha", "one"), Mutation::Set("beta", "two")],
          result => emit(IndexedDbApplied(result)),
        ),
      )
    IndexedDbApplied(result) =>
      match result {
        Some(_) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
        None =>
          (
            model,
            indexed_db_store.entries(result => emit(IndexedDbEntries(result))),
          )
      }
    IndexedDbEntries(result) =>
      match result {
        Err(_) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
        Ok(entries) =>
          if entries
            is [
              Entry::StringRecord("alpha", "one"),
              Entry::StringRecord("beta", "two"),
            ] {
            (
              model,
              indexed_db_store.contains("alpha", result => {
                emit(IndexedDbContains(result))
              }),
            )
          } else {
            ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
          }
      }
    IndexedDbContains(result) =>
      match result {
        Err(_) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
        Ok(true) =>
          (
            model,
            indexed_db_store.delete("alpha", result => {
              emit(IndexedDbDeleted(result))
            }),
          )
        Ok(false) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
      }
    IndexedDbDeleted(result) =>
      match result {
        Some(_) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
        None =>
          (
            model,
            indexed_db_store.get("alpha", result => emit(IndexedDbGot(result))),
          )
      }
    IndexedDbGot(result) =>
      match result {
        Ok(Lookup::Missing) =>
          ({ ..model, indexed_db_status: "indexeddb: complete" }, @rabbita.none)
        Ok(Lookup::Found(_)) | Ok(Lookup::Unsupported) | Err(_) =>
          ({ ..model, indexed_db_status: "indexeddb: failed" }, @rabbita.none)
      }
  }
}

///|
fn app() -> Val[Html] {
  let (model, emit) = @rabbita.create_state_with_init(
    init=fn(emit) {
      (
        {
          initialized: "starting",
          delayed: "idle",
          performed: "idle",
          attempted: "idle",
          batch_a: false,
          batch_b: false,
          indexed_db_status: "indexeddb: idle",
        },
        @rabbita.perform(value => emit(Initialized(value)), async fn() noraise {
          resolved("ready").wait().cast() catch {
            _ => "unexpected failure"
          }
        }),
      )
    },
    update~,
  )
  model.view(model => {
    div <| [
      h1("Commands and async"),
      p(id="init-command", "init: \{model.initialized}"),
      button(on_click=emit(StartDelay), "Run delayed command"),
      p(id="delay-status", "delay: \{model.delayed}"),
      button(on_click=emit(StartPerform), "Run perform"),
      p(id="perform-status", "perform: \{model.performed}"),
      button(on_click=emit(StartAttempt), "Run failing attempt"),
      p(id="attempt-status", "attempt: \{model.attempted}"),
      button(on_click=emit(StartBatch), "Run batch"),
      p(
        id="batch-status",
        if model.batch_a && model.batch_b {
          "batch: complete"
        } else {
          "batch: incomplete"
        },
      ),
      button(on_click=emit(StartIndexedDb), "Run IndexedDB store flow"),
      p(id="indexeddb-status", model.indexed_db_status),
    ]
  })
}
