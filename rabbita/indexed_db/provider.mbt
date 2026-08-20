///|
priv enum Pending {
  Get(String, Bool, (ReadResult) -> Unit)
  Put(String, String, (WriteResult) -> Unit)
}

///|
priv struct ProviderState {
  config : Config
  mut database : @dom.IDBDatabase?
  mut opening : @dom.IDBOpenDBRequest?
  mut opening_generation : Int
  mut next_generation : Int
  mut connection_generation : Int
  mut blocked : Bool
  mut queue : Array[Pending]
  mut draining : Bool
}

///|
fn ProviderState::new(config : Config) -> ProviderState {
  {
    config,
    database: None,
    opening: None,
    opening_generation: 0,
    next_generation: 1,
    connection_generation: 0,
    blocked: false,
    queue: [],
    draining: false,
  }
}

///|
let provider_states : @ref.Ref[Map[String, @ref.Ref[ProviderState]]] = {
  val: Map([]),
}

///|
fn config_key(config : Config) -> String {
  config.name() + "|" + config.version().to_string() + "|" + config.store_name()
}

///|
fn state_for(config : Config) -> @ref.Ref[ProviderState] {
  let key = config_key(config)
  match provider_states.val.get(key) {
    Some(state) => state
    None => {
      let state : @ref.Ref[ProviderState] = { val: ProviderState::new(config) }
      provider_states.val[key] = state
      state
    }
  }
}

///|
fn is_unavailable_error(name : String) -> Bool {
  name == "SecurityError" || name == "InvalidStateError"
}

///|
fn is_quota_error(name : String, code : Int) -> Bool {
  name == "QuotaExceededError" || code == 22 || code == 1014
}

///|
fn read_failure(name : String, _code : Int) -> ReadResult {
  if is_unavailable_error(name) {
    ReadResult::Unavailable
  } else {
    ReadResult::Failed
  }
}

///|
fn write_failure(name : String, code : Int) -> WriteResult {
  if is_unavailable_error(name) {
    WriteResult::Unavailable
  } else if is_quota_error(name, code) {
    WriteResult::QuotaExceeded
  } else {
    WriteResult::Failed
  }
}

///|
fn finish_get(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  result : ReadResult,
) -> Unit {
  match operation {
    Pending::Get(_, _, reply) => reply(result)
    Pending::Put(_, _, _) => ()
  }
  state.val.draining = false
  drain(state)
}

///|
fn finish_put(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  result : WriteResult,
) -> Unit {
  match operation {
    Pending::Put(_, _, reply) => reply(result)
    Pending::Get(_, _, _) => ()
  }
  state.val.draining = false
  drain(state)
}

///|
fn fail_queued(
  state : @ref.Ref[ProviderState],
  name : String,
  code : Int,
) -> Unit {
  let queued = state.val.queue
  state.val.queue = []
  for operation in queued {
    match operation {
      Pending::Get(_, _, reply) => reply(read_failure(name, code))
      Pending::Put(_, _, reply) => reply(write_failure(name, code))
    }
  }
}

///|
fn invalidate_database(
  state : @ref.Ref[ProviderState],
  generation : Int,
  database : @dom.IDBDatabase,
) -> Unit {
  guard state.val.connection_generation == generation else { return }
  state.val.database = None
  state.val.connection_generation = 0
  database.close()
  if !state.val.draining && !state.val.queue.is_empty() {
    ensure_open(state)
  }
}

///|
fn fail_open(
  state : @ref.Ref[ProviderState],
  generation : Int,
  name : String,
  code : Int,
) -> Unit {
  guard state.val.opening_generation == generation else { return }
  state.val.opening = None
  state.val.opening_generation = 0
  fail_queued(state, name, code)
}

///|
fn open_database(state : @ref.Ref[ProviderState]) -> Unit {
  guard state.val.opening is None else { return }
  match @dom.indexed_db_safe() {
    Err(error) => fail_queued(state, error.name(), error.code())
    Ok(None) => fail_queued(state, "SecurityError", 0)
    Ok(Some(factory)) => {
      let generation = state.val.next_generation
      state.val.next_generation += 1
      let config = state.val.config
      match factory.open_safe(config.name(), config.version()) {
        Err(error) => fail_queued(state, error.name(), error.code())
        Ok(request) => {
          state.val.opening = Some(request)
          state.val.opening_generation = generation
          let abnormal : @ref.Ref[Bool] = { val: false }

          request.set_on_upgrade_needed(() => {
            guard state.val.opening_generation == generation else { return }
            match request.get_result_safe() {
              Err(error) => {
                abnormal.val = true
                fail_open(state, generation, error.name(), error.code())
              }
              Ok(database) =>
                match database.has_object_store_safe(config.store_name()) {
                  Err(error) => {
                    abnormal.val = true
                    fail_open(state, generation, error.name(), error.code())
                  }
                  Ok(true) => ()
                  Ok(false) =>
                    match
                      database.create_object_store_safe(config.store_name()) {
                      Ok(_) => ()
                      Err(error) => {
                        abnormal.val = true
                        fail_open(state, generation, error.name(), error.code())
                      }
                    }
                }
            }
          })
          request.set_on_blocked(() => {
            abnormal.val = true
            state.val.blocked = true
            fail_open(state, generation, "InvalidStateError", 0)
          })
          request.set_on_error(() => {
            abnormal.val = true
            fail_open(
              state,
              generation,
              request.get_error_name(),
              request.get_error_code(),
            )
          })
          request.set_on_success(() => {
            match request.get_result_safe() {
              Err(error) => {
                abnormal.val = true
                fail_open(state, generation, error.name(), error.code())
              }
              Ok(database) => {
                if abnormal.val || state.val.opening_generation != generation {
                  database.close()
                  return
                }
                state.val.opening = None
                state.val.opening_generation = 0
                state.val.database = Some(database)
                state.val.connection_generation = generation
                database.set_on_version_change(() => {
                  invalidate_database(state, generation, database)
                })
                drain(state)
              }
            }
          })
        }
      }
    }
  }
}

///|
fn ensure_open(state : @ref.Ref[ProviderState]) -> Unit {
  guard !state.val.queue.is_empty() else { return }
  if state.val.blocked {
    fail_queued(state, "InvalidStateError", 0)
    return
  }
  match state.val.database {
    Some(_) => drain(state)
    None => open_database(state)
  }
}

///|
fn start_get_transaction(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  transaction : @dom.IDBTransaction,
) -> Unit {
  let (key, migrate_legacy) = match operation {
    Pending::Get(key, migrate_legacy, _) => (key, migrate_legacy)
    Pending::Put(_, _, _) => ("", false)
  }
  let config = state.val.config
  let completed : @ref.Ref[Bool] = { val: false }
  let outcome : @ref.Ref[ReadResult?] = { val: None }
  let legacy_storage : @ref.Ref[@dom.Storage?] = { val: None }
  let legacy_value : @ref.Ref[String?] = { val: None }
  let complete = result => {
    guard !completed.val else { return }
    completed.val = true
    finish_get(state, operation, result)
  }
  let fail = (name : String, code : Int) => {
    complete(read_failure(name, code))
    transaction.abort()
  }
  transaction.set_on_error(() => {
    fail(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_abort(() => {
    fail(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_complete(() => {
    guard !completed.val else { return }
    match outcome.val {
      None => complete(ReadResult::Failed)
      Some(result) => {
        match (legacy_storage.val, legacy_value.val) {
          (Some(storage), Some(captured)) =>
            match storage.read_item_safe(key) {
              Ok(Some(current)) if current == captured =>
                ignore(storage.remove_item_safe(key))
              _ => ()
            }
          _ => ()
        }
        complete(result)
      }
    }
  })
  match transaction.object_store_safe(config.store_name()) {
    Err(error) => fail(error.name(), error.code())
    Ok(store) =>
      match store.open_cursor_safe(key) {
        Err(error) => fail(error.name(), error.code())
        Ok(request) => {
          request.set_on_error(() => {
            fail(request.get_error_name(), request.get_error_code())
          })
          request.set_on_success(() => {
            guard !completed.val else { return }
            match request.cursor() {
              Some(cursor) =>
                match cursor.string_value() {
                  Some(value) => outcome.val = Some(ReadResult::Loaded(value))
                  None => outcome.val = Some(ReadResult::Failed)
                }
              None =>
                if !migrate_legacy {
                  outcome.val = Some(ReadResult::Missing)
                } else {
                  match @dom.local_storage_safe() {
                    Err(error) => fail(error.name(), error.code())
                    Ok(None) => outcome.val = Some(ReadResult::Missing)
                    Ok(Some(storage)) =>
                      match storage.read_item_safe(key) {
                        Err(error) => fail(error.name(), error.code())
                        Ok(None) => outcome.val = Some(ReadResult::Missing)
                        Ok(Some(value)) => {
                          legacy_storage.val = Some(storage)
                          legacy_value.val = Some(value)
                          outcome.val = Some(ReadResult::Loaded(value))
                          match store.put_string_safe(value, key) {
                            Err(error) => fail(error.name(), error.code())
                            Ok(migration) => {
                              migration.set_on_error(() => {
                                fail(
                                  migration.get_error_name(),
                                  migration.get_error_code(),
                                )
                              })
                              migration.set_on_success(() => ())
                            }
                          }
                        }
                      }
                  }
                }
            }
          })
        }
      }
  }
}

///|
fn start_get(state : @ref.Ref[ProviderState], operation : Pending) -> Unit {
  let database = state.val.database
  let mode = match operation {
    Pending::Get(_, migrate_legacy, _) =>
      if migrate_legacy {
        "readwrite"
      } else {
        "readonly"
      }
    Pending::Put(_, _, _) => "readonly"
  }
  match database {
    None => ensure_open(state)
    Some(database) =>
      match database.transaction_safe(state.val.config.store_name(), mode) {
        Err(error) =>
          finish_get(state, operation, read_failure(error.name(), error.code()))
        Ok(transaction) => start_get_transaction(state, operation, transaction)
      }
  }
}

///|
fn start_put_transaction(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  transaction : @dom.IDBTransaction,
) -> Unit {
  let (key, value) = match operation {
    Pending::Put(key, value, _) => (key, value)
    Pending::Get(_, _, _) => ("", "")
  }
  let config = state.val.config
  let completed : @ref.Ref[Bool] = { val: false }
  let complete = result => {
    guard !completed.val else { return }
    completed.val = true
    finish_put(state, operation, result)
  }
  let fail = (name : String, code : Int) => {
    complete(write_failure(name, code))
    transaction.abort()
  }
  transaction.set_on_error(() => {
    fail(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_abort(() => {
    fail(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_complete(() => complete(WriteResult::Stored))
  match transaction.object_store_safe(config.store_name()) {
    Err(error) => fail(error.name(), error.code())
    Ok(store) =>
      match store.put_string_safe(value, key) {
        Err(error) => fail(error.name(), error.code())
        Ok(request) => {
          request.set_on_error(() => {
            fail(request.get_error_name(), request.get_error_code())
          })
          request.set_on_success(() => ())
        }
      }
  }
}

///|
fn start_put(state : @ref.Ref[ProviderState], operation : Pending) -> Unit {
  let database = state.val.database
  match database {
    None => ensure_open(state)
    Some(database) =>
      match
        database.transaction_safe(state.val.config.store_name(), "readwrite") {
        Err(error) =>
          finish_put(
            state,
            operation,
            write_failure(error.name(), error.code()),
          )
        Ok(transaction) => start_put_transaction(state, operation, transaction)
      }
  }
}

///|
fn drain(state : @ref.Ref[ProviderState]) -> Unit {
  guard !state.val.draining else { return }
  guard !state.val.queue.is_empty() else { return }
  match state.val.database {
    None => ensure_open(state)
    Some(_) => {
      let operation = state.val.queue[0]
      ignore(state.val.queue.remove(0))
      state.val.draining = true
      match operation {
        Pending::Get(_, _, _) => start_get(state, operation)
        Pending::Put(_, _, _) => start_put(state, operation)
      }
    }
  }
}

///|
fn enqueue_get(
  config : Config,
  key : String,
  migrate_legacy : Bool,
  callback : (ReadResult) -> Unit,
) -> Unit {
  let state = state_for(config)
  state.val.queue.push(Pending::Get(key, migrate_legacy, callback))
  ensure_open(state)
}

///|
fn enqueue_put(
  config : Config,
  key : String,
  value : String,
  callback : (WriteResult) -> Unit,
) -> Unit {
  let state = state_for(config)
  state.val.queue.push(Pending::Put(key, value, callback))
  ensure_open(state)
}

///|
/// Callback-shaped seam retained only for focused provider whitebox tests.
#warnings("-unused_value")
fn get_item(key : String, callback : (Int, String) -> Unit) -> Unit {
  let config = Config::Config("loomark.local-repository", 1, "archives")
  enqueue_get(config, key, true, result => {
    match result {
      ReadResult::Missing => callback(0, "")
      ReadResult::Loaded(value) => callback(1, value)
      ReadResult::Unavailable => callback(2, "")
      ReadResult::Failed => callback(3, "")
    }
  })
}

///|
/// Callback-shaped seam retained only for focused provider whitebox tests.
#warnings("-unused_value")
fn set_item(key : String, value : String, callback : (Int) -> Unit) -> Unit {
  let config = Config::Config("loomark.local-repository", 1, "archives")
  enqueue_put(config, key, value, result => {
    match result {
      WriteResult::Stored => callback(0)
      WriteResult::Unavailable => callback(1)
      WriteResult::QuotaExceeded => callback(2)
      WriteResult::Failed => callback(3)
    }
  })
}

///|
/// Reset only the in-process provider state for whitebox tests.
#warnings("-unused_value")
fn reset_provider_state_for_test() -> Unit {
  for _, state in provider_states.val {
    match state.val.database {
      Some(database) => database.close()
      None => ()
    }
  }
  provider_states.val = Map([])
}
