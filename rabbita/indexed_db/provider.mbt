///|
type ReadOutcome = Result[Lookup, ReadError]

///|
type WriteOutcome = WriteError?

///|
type EntriesOutcome = Result[Array[Entry], ReadError]

///|
priv enum Pending {
  Get(String, (ReadOutcome) -> Unit)
  Contains(String, (Result[Bool, ReadError]) -> Unit)
  Apply(Array[Mutation], (WriteOutcome) -> Unit)
  Entries((EntriesOutcome) -> Unit)
}

///|
priv struct ProviderState {
  store : Store
  mut database : @dom.IDBDatabase?
  mut opening : @dom.IDBOpenDBRequest?
  mut opening_generation : Int
  mut next_generation : Int
  mut connection_generation : Int
  mut queue : Array[Pending]
  mut dispatching : Bool
}

///|
fn ProviderState::new(store : Store) -> ProviderState {
  {
    store,
    database: None,
    opening: None,
    opening_generation: 0,
    next_generation: 1,
    connection_generation: 0,
    queue: [],
    dispatching: false,
  }
}

///|
let provider_states : @ref.Ref[Map[Store, @ref.Ref[ProviderState]]] = {
  val: Map([]),
}

///|
fn state_for(store : Store) -> @ref.Ref[ProviderState] {
  match provider_states.val.get(store) {
    Some(state) => state
    None => {
      let state : @ref.Ref[ProviderState] = { val: ProviderState::new(store) }
      provider_states.val[store] = state
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
fn read_failure(name : String, _code : Int) -> ReadOutcome {
  if is_unavailable_error(name) {
    Err(ReadError::Unavailable)
  } else {
    Err(ReadError::Failed(name, _code))
  }
}

///|
fn write_failure(name : String, code : Int) -> WriteOutcome {
  if is_unavailable_error(name) {
    Some(WriteError::Unavailable)
  } else if is_quota_error(name, code) {
    Some(WriteError::QuotaExceeded)
  } else {
    Some(WriteError::Failed(name, code))
  }
}

///|
fn scan_failure(name : String, code : Int) -> EntriesOutcome {
  if is_unavailable_error(name) {
    Err(ReadError::Unavailable)
  } else {
    Err(ReadError::Failed(name, code))
  }
}

///|
fn finish_get(operation : Pending, result : ReadOutcome) -> Unit {
  match operation {
    Pending::Get(_, reply) => reply(result)
    Pending::Contains(_, _) | Pending::Apply(_, _) | Pending::Entries(_) => ()
  }
}

///|
fn finish_contains(
  operation : Pending,
  result : Result[Bool, ReadError],
) -> Unit {
  match operation {
    Pending::Contains(_, reply) => reply(result)
    Pending::Get(_, _) | Pending::Apply(_, _) | Pending::Entries(_) => ()
  }
}

///|
fn finish_apply(operation : Pending, result : WriteOutcome) -> Unit {
  match operation {
    Pending::Apply(_, reply) => reply(result)
    Pending::Get(_, _) | Pending::Contains(_, _) | Pending::Entries(_) => ()
  }
}

///|
fn finish_entries(operation : Pending, result : EntriesOutcome) -> Unit {
  match operation {
    Pending::Entries(reply) => reply(result)
    Pending::Get(_, _) | Pending::Contains(_, _) | Pending::Apply(_, _) => ()
  }
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
      Pending::Get(_, reply) => reply(read_failure(name, code))
      Pending::Contains(_, reply) =>
        reply(Err(read_failure(name, code).unwrap_err()))
      Pending::Apply(_, reply) => reply(write_failure(name, code))
      Pending::Entries(reply) => reply(scan_failure(name, code))
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
  if !state.val.dispatching && !state.val.queue.is_empty() {
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
      let store = state.val.store
      match factory.open_safe(store.name, store.version) {
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
                match database.has_object_store_safe(store.store_name) {
                  Err(error) => {
                    abnormal.val = true
                    fail_open(state, generation, error.name(), error.code())
                  }
                  Ok(true) => ()
                  Ok(false) =>
                    match database.create_object_store_safe(store.store_name) {
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
  let key = match operation {
    Pending::Get(key, _) => key
    Pending::Contains(_, _) | Pending::Apply(_, _) | Pending::Entries(_) => ""
  }
  let store = state.val.store
  let completed : @ref.Ref[Bool] = { val: false }
  let outcome : @ref.Ref[ReadOutcome?] = { val: None }
  let failure : @ref.Ref[ReadOutcome?] = { val: None }
  let complete = result => {
    guard !completed.val else { return }
    completed.val = true
    finish_get(operation, result)
  }
  let record_failure = (name : String, code : Int) => {
    if failure.val is None {
      failure.val = Some(read_failure(name, code))
    }
  }
  let fail = (name : String, code : Int) => {
    guard !completed.val else { return }
    record_failure(name, code)
    match transaction.abort_safe() {
      Ok(_) => ()
      Err(error) => {
        record_failure(error.name(), error.code())
        complete(failure.val.unwrap_or(Err(ReadError::Failed("", 0))))
      }
    }
  }
  transaction.set_on_error(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_abort(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
    complete(failure.val.unwrap_or(Err(ReadError::Failed("", 0))))
  })
  transaction.set_on_complete(() => {
    guard !completed.val else { return }
    match failure.val {
      Some(failure) => {
        complete(failure)
        return
      }
      None => ()
    }
    match outcome.val {
      None => complete(Err(ReadError::Failed("", 0)))
      Some(result) => complete(result)
    }
  })
  match transaction.object_store_safe(store.store_name) {
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
            match request.cursor_safe() {
              Err(error) => fail(error.name(), error.code())
              Ok(Some(cursor)) =>
                match cursor.string_value_safe() {
                  Err(error) => fail(error.name(), error.code())
                  Ok(Some(value)) =>
                    outcome.val = Some(Ok(Lookup::Found(value)))
                  Ok(None) => outcome.val = Some(Ok(Lookup::Unsupported))
                }
              Ok(None) => outcome.val = Some(Ok(Lookup::Missing))
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
    Pending::Get(_, _) | Pending::Contains(_, _) | Pending::Entries(_) =>
      "readonly"
    Pending::Apply(_, _) => "readwrite"
  }
  match database {
    None => ensure_open(state)
    Some(database) =>
      match database.transaction_safe(state.val.store.store_name, mode) {
        Err(error) =>
          finish_get(operation, read_failure(error.name(), error.code()))
        Ok(transaction) => start_get_transaction(state, operation, transaction)
      }
  }
}

///|
fn start_apply_transaction(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  transaction : @dom.IDBTransaction,
) -> Unit {
  let mutations = match operation {
    Pending::Apply(mutations, _) => mutations
    Pending::Get(_, _) | Pending::Contains(_, _) | Pending::Entries(_) => []
  }
  let store = state.val.store
  let completed : @ref.Ref[Bool] = { val: false }
  let failure : @ref.Ref[WriteOutcome?] = { val: None }
  let complete = result => {
    guard !completed.val else { return }
    completed.val = true
    finish_apply(operation, result)
  }
  let record_failure = (name : String, code : Int) => {
    if failure.val is None {
      failure.val = Some(write_failure(name, code))
    }
  }
  let fail = (name : String, code : Int) => {
    guard !completed.val else { return }
    record_failure(name, code)
    match transaction.abort_safe() {
      Ok(_) => ()
      Err(error) => {
        record_failure(error.name(), error.code())
        complete(failure.val.unwrap_or(Some(WriteError::Failed("", 0))))
      }
    }
  }
  transaction.set_on_error(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_abort(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
    complete(failure.val.unwrap_or(Some(WriteError::Failed("", 0))))
  })
  transaction.set_on_complete(() => complete(failure.val.unwrap_or(None)))
  match transaction.object_store_safe(store.store_name) {
    Err(error) => fail(error.name(), error.code())
    Ok(store) => {
      let requests : Array[@dom.IDBRequest] = []
      for mutation in mutations {
        if !completed.val {
          let request = match mutation {
            Mutation::Set(key, value) => store.put_string_safe(value, key)
            Mutation::Delete(key) => store.delete_safe(key)
          }
          match request {
            Ok(request) => requests.push(request)
            Err(error) => fail(error.name(), error.code())
          }
        }
      }
      guard !completed.val else { return }
      requests.each(request => {
        request.set_on_error(() => {
          fail(request.get_error_name(), request.get_error_code())
        })
        request.set_on_success(() => ())
      })
    }
  }
}

///|
fn start_contains(state : @ref.Ref[ProviderState], operation : Pending) -> Unit {
  let key = match operation {
    Pending::Contains(key, _) => key
    _ => ""
  }
  match state.val.database {
    None => ensure_open(state)
    Some(database) =>
      match database.transaction_safe(state.val.store.store_name, "readonly") {
        Err(error) =>
          finish_contains(
            operation,
            Err(read_failure(error.name(), error.code()).unwrap_err()),
          )
        Ok(transaction) => {
          let done : @ref.Ref[Bool] = { val: false }
          let failure : @ref.Ref[ReadError?] = { val: None }
          let value : @ref.Ref[Bool?] = { val: None }
          let complete = result => {
            guard !done.val else { return }
            done.val = true
            finish_contains(operation, result)
          }
          let record_failure = (name : String, code : Int) => {
            if failure.val is None {
              failure.val = Some(read_failure(name, code).unwrap_err())
            }
          }
          let fail = (name : String, code : Int) => {
            guard !done.val else { return }
            record_failure(name, code)
            match transaction.abort_safe() {
              Ok(_) => ()
              Err(error) => {
                record_failure(error.name(), error.code())
                complete(Err(failure.val.unwrap_or(ReadError::Failed("", 0))))
              }
            }
          }
          transaction.set_on_error(() => {
            record_failure(
              transaction.get_error_name(),
              transaction.get_error_code(),
            )
          })
          transaction.set_on_abort(() => {
            record_failure(
              transaction.get_error_name(),
              transaction.get_error_code(),
            )
            complete(Err(failure.val.unwrap_or(ReadError::Failed("", 0))))
          })
          transaction.set_on_complete(() => {
            complete(
              match failure.val {
                Some(error) => Err(error)
                None => Ok(value.val.unwrap_or(false))
              },
            )
          })
          match transaction.object_store_safe(state.val.store.store_name) {
            Err(error) => fail(error.name(), error.code())
            Ok(store) =>
              match store.get_key_safe(key) {
                Err(error) => fail(error.name(), error.code())
                Ok(request) => {
                  request.set_on_error(() => {
                    fail(request.get_error_name(), request.get_error_code())
                  })
                  request.set_on_success(() => {
                    match request.has_key_safe() {
                      Ok(found) => value.val = Some(found)
                      Err(error) => fail(error.name(), error.code())
                    }
                  })
                }
              }
          }
        }
      }
  }
}

///|
fn start_apply(state : @ref.Ref[ProviderState], operation : Pending) -> Unit {
  match state.val.database {
    None => ensure_open(state)
    Some(database) =>
      match database.transaction_safe(state.val.store.store_name, "readwrite") {
        Err(error) =>
          finish_apply(operation, write_failure(error.name(), error.code()))
        Ok(transaction) =>
          start_apply_transaction(state, operation, transaction)
      }
  }
}

///|
fn start_entries_transaction(
  state : @ref.Ref[ProviderState],
  operation : Pending,
  transaction : @dom.IDBTransaction,
) -> Unit {
  let store = state.val.store
  let completed : @ref.Ref[Bool] = { val: false }
  let outcome : @ref.Ref[EntriesOutcome?] = { val: None }
  let failure : @ref.Ref[EntriesOutcome?] = { val: None }
  let entries : Array[Entry] = []
  let complete = result => {
    guard !completed.val else { return }
    completed.val = true
    finish_entries(operation, result)
  }
  let record_failure = (name : String, code : Int) => {
    if failure.val is None {
      failure.val = Some(scan_failure(name, code))
    }
  }
  let fail = (name : String, code : Int) => {
    guard !completed.val else { return }
    record_failure(name, code)
    match transaction.abort_safe() {
      Ok(_) => ()
      Err(error) => {
        record_failure(error.name(), error.code())
        complete(failure.val.unwrap_or(Err(ReadError::Failed("", 0))))
      }
    }
  }
  transaction.set_on_error(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
  })
  transaction.set_on_abort(() => {
    record_failure(transaction.get_error_name(), transaction.get_error_code())
    complete(failure.val.unwrap_or(Err(ReadError::Failed("", 0))))
  })
  transaction.set_on_complete(() => {
    complete(
      failure.val.unwrap_or(
        outcome.val.unwrap_or(Err(ReadError::Failed("", 0))),
      ),
    )
  })
  match transaction.object_store_safe(store.store_name) {
    Err(error) => fail(error.name(), error.code())
    Ok(store) =>
      match store.open_cursor_all_safe() {
        Err(error) => fail(error.name(), error.code())
        Ok(request) => {
          request.set_on_error(() => {
            fail(request.get_error_name(), request.get_error_code())
          })
          request.set_on_success(() => {
            guard !completed.val else { return }
            match request.cursor_safe() {
              Err(error) => fail(error.name(), error.code())
              Ok(None) => outcome.val = Some(Ok(entries.copy()))
              Ok(Some(cursor)) => {
                match cursor.string_key_safe() {
                  Err(error) => fail(error.name(), error.code())
                  Ok(None) =>
                    entries.push(Entry::UnsupportedKey(entries.length()))
                  Ok(Some(key)) =>
                    match cursor.string_value_safe() {
                      Err(error) => fail(error.name(), error.code())
                      Ok(Some(value)) =>
                        entries.push(Entry::StringRecord(key, value))
                      Ok(None) => entries.push(Entry::UnsupportedValue(key))
                    }
                }
                guard !completed.val else { return }
                match cursor.continue_safe() {
                  Ok(_) => ()
                  Err(error) => fail(error.name(), error.code())
                }
              }
            }
          })
        }
      }
  }
}

///|
fn start_entries(state : @ref.Ref[ProviderState], operation : Pending) -> Unit {
  match state.val.database {
    None => ensure_open(state)
    Some(database) =>
      match database.transaction_safe(state.val.store.store_name, "readonly") {
        Err(error) =>
          finish_entries(operation, scan_failure(error.name(), error.code()))
        Ok(transaction) =>
          start_entries_transaction(state, operation, transaction)
      }
  }
}

///|
/// Admit the queued batch in invocation order without waiting for transaction
/// completion. IndexedDB owns scheduling for overlapping scopes; each started
/// operation retains its own completion callback.
fn drain(state : @ref.Ref[ProviderState]) -> Unit {
  guard !state.val.dispatching else { return }
  guard !state.val.queue.is_empty() else { return }
  match state.val.database {
    None => ensure_open(state)
    Some(_) => {
      state.val.dispatching = true
      let operations = state.val.queue.drain(0, state.val.queue.length())
      operations.each(operation => {
        match operation {
          Pending::Get(_, _) => start_get(state, operation)
          Pending::Contains(_, _) => start_contains(state, operation)
          Pending::Apply(_, _) => start_apply(state, operation)
          Pending::Entries(_) => start_entries(state, operation)
        }
      })
      state.val.dispatching = false
      if !state.val.queue.is_empty() {
        ensure_open(state)
      }
    }
  }
}

///|
fn enqueue_get(
  store : Store,
  key : String,
  callback : (ReadOutcome) -> Unit,
) -> Unit {
  let state = state_for(store)
  state.val.queue.push(Pending::Get(key, callback))
  ensure_open(state)
}

///|
fn enqueue_apply(
  store : Store,
  mutations : Array[Mutation],
  callback : (WriteOutcome) -> Unit,
) -> Unit {
  if mutations.is_empty() {
    callback(None)
    return
  }
  let state = state_for(store)
  state.val.queue.push(Pending::Apply(mutations.copy(), callback))
  ensure_open(state)
}

///|
fn enqueue_contains(
  store : Store,
  key : String,
  callback : (Result[Bool, ReadError]) -> Unit,
) -> Unit {
  let state = state_for(store)
  state.val.queue.push(Pending::Contains(key, callback))
  ensure_open(state)
}

///|
fn enqueue_entries(store : Store, callback : (EntriesOutcome) -> Unit) -> Unit {
  let state = state_for(store)
  state.val.queue.push(Pending::Entries(callback))
  ensure_open(state)
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
