///|
extern "js" fn install_fake_indexed_db(
  mode : String,
  record_kind : String,
  record_value : String,
) -> Unit =
  #| (mode, record_kind, record_value) => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const archive_key = "loomark.active-document-archive";
  #|   const store_name = "archives";
  #|   const fake = {
  #|     mode,
  #|     schema: false,
  #|     records: new Map(),
  #|     legacy_value: null,
  #|     legacy_error: null,
  #|     legacy_remove_count: 0,
  #|     open_count: 0,
  #|     transaction_count: 0,
  #|     put_count: 0,
  #|     abort_count: 0,
  #|     get_key_count: 0,
  #|     keyed_cursor_count: 0,
  #|     value_read_count: 0,
  #|     closed_count: 0,
  #|     stale_thrown: false,
  #|     retained_request: null,
  #|     pending_opens: [],
  #|     pending_transactions: [],
  #|     pending_completions: [],
  #|     withheld_completion: false,
  #|     pending_aborts: [],
  #|     database: null,
  #|   };
  #|   const previous = globalThis[fake_key];
  #|   if (previous != null) globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.stale")] = previous;
  #|   globalThis[fake_key] = fake;
  #|   if (record_kind === "string") fake.records.set(archive_key, record_value);
  #|   else if (record_kind === "undefined") fake.records.set(archive_key, undefined);
  #|   else if (record_kind === "number") fake.records.set(archive_key, 42);
  #|
  #|   globalThis.localStorage = {
  #|     getItem(key) {
  #|       if (fake.legacy_error != null) throw { name: fake.legacy_error };
  #|       return key === archive_key ? fake.legacy_value : null;
  #|     },
  #|     setItem(key, value) {
  #|       if (key === archive_key) fake.legacy_value = String(value);
  #|     },
  #|     removeItem(key) {
  #|       if (key === archive_key) {
  #|         fake.legacy_remove_count += 1;
  #|         fake.legacy_value = null;
  #|       }
  #|     },
  #|   };
  #|
  #|   const make_request = (result, error) => {
  #|     const request = { result, error };
  #|     const define_handler = (property, slot, delivery, ready = () => true) => {
  #|       request[slot] = null;
  #|       Object.defineProperty(request, property, {
  #|         get() { return request[slot]; },
  #|         set(handler) {
  #|           request[slot] = handler;
  #|           if (handler && request[delivery] != null && ready()) request[delivery]();
  #|         },
  #|       });
  #|     };
  #|     define_handler("onsuccess", "_success", "_deliver_success");
  #|     define_handler("onerror", "_error", "_deliver_error", () => request.error != null);
  #|     define_handler("onupgradeneeded", "_upgrade", "_deliver_upgrade");
  #|     define_handler("onblocked", "_blocked", "_deliver_blocked");
  #|     request._deliver_error = () => request._error?.({ target: request });
  #|     return request;
  #|   };
  #|
  #|   const make_transaction = () => {
  #|     const transaction = {
  #|       error: null,
  #|       finished: false,
  #|       writes: [],
  #|       request_success_count: 0,
  #|       oncomplete: null,
  #|       onerror: null,
  #|       onabort: null,
  #|     };
  #|     const make_write_request = (write, request_error, abort_after_success) => {
  #|       const request = make_request(undefined, null);
  #|       transaction.writes.push(write);
  #|       request._deliver_success = () => {
  #|         if (request_error != null) {
  #|           request.error = request_error;
  #|           request._deliver_error();
  #|           return;
  #|         }
  #|         request._success?.({ target: request });
  #|         if (abort_after_success != null) {
  #|           transaction.abort(abort_after_success);
  #|           return;
  #|         }
  #|         transaction.request_success_count += 1;
  #|         if (transaction.request_success_count !== transaction.writes.length) return;
  #|         if (fake.mode === "request-success-only") {
  #|           fake.pending_transactions.push(transaction);
  #|         } else if (!transaction.finished) {
  #|           transaction.complete();
  #|         }
  #|       };
  #|       return request;
  #|     };
  #|     transaction.objectStore = name => {
  #|       if ((name !== store_name && name !== "archives|x") || !fake.schema) throw { name: "NotFoundError" };
  #|       return {
  #|         getKey(key) {
  #|           fake.get_key_count += 1;
  #|           const request = make_request(
  #|             fake.records.has(key) ? key : undefined,
  #|             null,
  #|           );
  #|           request._deliver_success = () => {
  #|             request._success?.({ target: request });
  #|             if (!transaction.finished) transaction.complete();
  #|           };
  #|           return request;
  #|         },
  #|         openCursor(key) {
  #|           if (arguments.length === 0) {
  #|             const entries = Array.from(fake.records.entries())
  #|               .sort(([left], [right]) => {
  #|                 if (typeof left === "number" && typeof right === "number") {
  #|                   return left - right;
  #|                 }
  #|                 if (typeof left === "number") return -1;
  #|                 if (typeof right === "number") return 1;
  #|                 return left < right ? -1 : left > right ? 1 : 0;
  #|               });
  #|             let index = 0;
  #|             const request = make_request(null, null);
  #|             if (fake.mode === "cursor-result-getter-failed") {
  #|               Object.defineProperty(request, "result", {
  #|                 get() { throw { name: "UnknownError" }; },
  #|                 set(value) { request._result = value; },
  #|               });
  #|             }
  #|             if (fake.mode === "cursor-error") {
  #|               request.error = { name: "UnknownError" };
  #|               return request;
  #|             }
  #|             const deliver = () => {
  #|               if (index >= entries.length) {
  #|                 request.result = null;
  #|                 request._success?.({ target: request });
  #|                 if (!transaction.finished && fake.mode === "request-success-only") {
  #|                   fake.pending_transactions.push(transaction);
  #|                 } else if (!transaction.finished) {
  #|                   transaction.complete();
  #|                 }
  #|                 return;
  #|               }
  #|               const [cursor_key, value] = entries[index];
  #|               const cursor = {
  #|                 key: cursor_key,
  #|                 continue() {
  #|                   if (fake.mode === "cursor-continue-failed") {
  #|                     throw { name: "UnknownError" };
  #|                   }
  #|                   index += 1;
  #|                   deliver();
  #|                 },
  #|               };
  #|               if (fake.mode === "cursor-value-getter-failed") {
  #|                 Object.defineProperty(cursor, "value", {
  #|                   get() { throw { name: "UnknownError" }; },
  #|                 });
  #|               } else {
  #|                 cursor.value = value;
  #|               }
  #|               request.result = cursor;
  #|               request._success?.({ target: request });
  #|             };
  #|             request._deliver_success = deliver;
  #|             return request;
  #|           }
  #|           fake.keyed_cursor_count += 1;
  #|           const exists = fake.records.has(key);
  #|           const cursor = exists ? { key } : null;
  #|           if (cursor != null) {
  #|             Object.defineProperty(cursor, "value", {
  #|               get() {
  #|                 fake.value_read_count += 1;
  #|                 return fake.records.get(key);
  #|               },
  #|             });
  #|           }
  #|           const request = make_request(cursor, null);
  #|           request._deliver_success = () => {
  #|             request._success?.({ target: request });
  #|             if (!transaction.finished && fake.mode !== "request-success-only") transaction.complete();
  #|           };
  #|           return request;
  #|         },
  #|         put(value, key) {
  #|           fake.put_count += 1;
  #|           const request_error = fake.mode === "quota"
  #|             ? { name: "QuotaExceededError", code: 22 }
  #|             : null;
  #|           const abort_error = fake.mode === "abort-after-put"
  #|             ? { name: "AbortError" }
  #|             : null;
  #|           return make_write_request({ kind: "put", key, value }, request_error, abort_error);
  #|         },
  #|         delete(key) {
  #|           const request_error = fake.mode === "delete-failed-delayed-abort"
  #|             ? { name: "UnknownError" }
  #|             : null;
  #|           return make_write_request({ kind: "delete", key }, request_error, null);
  #|         },
  #|       };
  #|     };
  #|     transaction.complete = () => {
  #|       if (transaction.finished) return;
  #|       transaction.finished = true;
  #|       for (const write of transaction.writes) {
  #|         if (write.kind === "put") fake.records.set(write.key, write.value);
  #|         else fake.records.delete(write.key);
  #|       }
  #|       if (fake.mode === "commit-withheld" && !fake.withheld_completion) {
  #|         fake.withheld_completion = true;
  #|         fake.pending_completions.push(transaction);
  #|       } else {
  #|         transaction.oncomplete?.({ target: transaction });
  #|       }
  #|     };
  #|     transaction.abort = error => {
  #|       if (transaction.finished) return;
  #|       fake.abort_count += 1;
  #|       transaction.finished = true;
  #|       transaction.error = error ?? { name: "AbortError" };
  #|       if (fake.mode === "delete-failed-delayed-abort") {
  #|         fake.pending_aborts.push(transaction);
  #|         return;
  #|       }
  #|       transaction.onerror?.({ target: transaction });
  #|       transaction.onabort?.({ target: transaction });
  #|       if (fake.mode === "abort-after-put") transaction.oncomplete?.({ target: transaction });
  #|     };
  #|     return transaction;
  #|   };
  #|
  #|   const make_database = () => {
  #|     const database = {
  #|       closed: false,
  #|       onversionchange: null,
  #|       objectStoreNames: {
  #|         contains(name) { return fake.schema && (name === store_name || name === "archives|x"); },
  #|       },
  #|       createObjectStore(name) {
  #|         if (name !== store_name && name !== "archives|x") throw { name: "InvalidStateError" };
  #|         fake.schema = true;
  #|         return {};
  #|       },
  #|       transaction(name, _mode) {
  #|         fake.transaction_count += 1;
  #|         if (fake.mode === "stale-transaction-once" && !fake.stale_thrown) {
  #|           fake.stale_thrown = true;
  #|           throw { name: "InvalidStateError" };
  #|         }
  #|         if (database.closed) throw { name: "InvalidStateError" };
  #|         return make_transaction();
  #|       },
  #|       close() {
  #|         if (!database.closed) fake.closed_count += 1;
  #|         database.closed = true;
  #|       },
  #|     };
  #|     fake.database = database;
  #|     return database;
  #|   };
  #|
  #|   globalThis.indexedDB = {
  #|     open(name, version) {
  #|       if (name !== "loomark.local-repository" || version !== 1) {
  #|         throw { name: "UnknownError" };
  #|       }
  #|       fake.open_count += 1;
  #|       if (fake.mode === "throw-security") throw { name: "SecurityError" };
  #|       if (fake.mode === "throw-failed") throw { name: "UnknownError" };
  #|       const open_error = fake.mode === "open-error-security"
  #|         ? { name: "SecurityError" }
  #|         : fake.mode === "open-error-failed" || fake.mode === "delayed-open-error"
  #|           ? { name: "UnknownError" }
  #|           : null;
  #|       const request = make_request(null, open_error);
  #|       if (fake.mode === "delayed-open-error") request._deliver_error = null;
  #|       const database = make_database();
  #|       request.result = database;
  #|       const entry = { request, database };
  #|       if (fake.mode === "delayed-open" || fake.mode === "delayed-open-error") {
  #|         fake.pending_opens.push(entry);
  #|       } else if (fake.mode === "success" || fake.mode === "stale-transaction-once" ||
  #|           fake.mode === "abort-after-put" || fake.mode === "quota" ||
  #|           fake.mode === "request-success-only" ||
  #|           fake.mode === "commit-withheld" ||
  #|           fake.mode === "delete-failed-delayed-abort" ||
  #|           fake.mode === "cursor-continue-failed" ||
  #|           fake.mode === "cursor-error" ||
  #|           fake.mode === "cursor-value-getter-failed" ||
  #|           fake.mode === "cursor-result-getter-failed") {
  #|         request._deliver_upgrade = () => request._upgrade?.({ target: request });
  #|         request._deliver_success = () => request._success?.({ target: request });
  #|       } else if (fake.mode === "blocked" || fake.mode === "blocked-retained") {
  #|         request._deliver_blocked = () => request._blocked?.({ target: request });
  #|         if (fake.mode === "blocked-retained") {
  #|           fake.retained_request = request;
  #|           request._deliver_success = () => request._success?.({ target: request });
  #|         }
  #|       } else if (fake.mode === "open-error-security") {
  #|         request._deliver_error = () => {
  #|           request.error = { name: "SecurityError" };
  #|           request._error?.({ target: request });
  #|         };
  #|       } else if (fake.mode === "open-error-failed") {
  #|         request._deliver_error = () => {
  #|           request.error = { name: "UnknownError" };
  #|           request._error?.({ target: request });
  #|         };
  #|       }
  #|       return request;
  #|     },
  #|   };
  #| }

///|
extern "js" fn install_missing_indexed_db() -> Unit =
  #| () => {
  #|   delete globalThis.indexedDB;
  #|   delete globalThis.localStorage;
  #| }

///|
extern "js" fn set_fake_record(
  key : String,
  kind : String,
  value : String,
) -> Unit =
  #| (key, kind, value) => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   if (kind === "string") fake.records.set(key, value);
  #|   else if (kind === "undefined") fake.records.set(key, undefined);
  #|   else if (kind === "number") fake.records.set(key, 42);
  #| }

///|
extern "js" fn set_fake_unsupported_key_record(
  key : Int,
  value : String,
) -> Unit =
  #| (key, value) => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake != null) fake.records.set(key, value);
  #| }

///|
extern "js" fn fake_record_at(key : String) -> String =
  #| key => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null || !fake.records.has(key)) return "<missing>";
  #|   return String(fake.records.get(key));
  #| }

///|
extern "js" fn fake_open_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.open_count ?? 0

///|
extern "js" fn fake_transaction_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.transaction_count ?? 0

///|
extern "js" fn fake_abort_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.abort_count ?? 0

///|
extern "js" fn fake_get_key_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.get_key_count ?? 0

///|
extern "js" fn fake_keyed_cursor_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.keyed_cursor_count ?? 0

///|
extern "js" fn fake_value_read_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.value_read_count ?? 0

///|
extern "js" fn fake_closed_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.closed_count ?? 0

///|
extern "js" fn fake_stale_database_closed() -> Bool =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.stale")]?.database?.closed ?? false

///|
extern "js" fn flush_fake_transactions() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   const pending = fake.pending_transactions.splice(0);
  #|   for (const transaction of pending) transaction.complete();
  #| }

///|
extern "js" fn flush_fake_aborts() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   const pending = fake.pending_aborts.splice(0);
  #|   for (const transaction of pending) {
  #|     transaction.onerror?.({ target: transaction });
  #|     transaction.onabort?.({ target: transaction });
  #|   }
  #| }

///|
extern "js" fn deliver_fake_stale_open() -> Unit =
  #| () => {
  #|   const stale = globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.stale")];
  #|   stale?.retained_request?._success?.({ target: stale.retained_request });
  #| }

///|
extern "js" fn trigger_fake_versionchange() -> Unit =
  #| () => {
  #|   const fake = globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")];
  #|   fake?.database?.onversionchange?.({});
  #| }

///|
fn test_store() -> Store {
  Store::Store("loomark.local-repository", 1, "archives")
}

///|
fn read(store : Store, key : String) -> ReadOutcome {
  let mut result : ReadOutcome = Ok(Lookup::Missing)
  enqueue_get(store, key, next => result = next)
  result
}

///|
fn contains(store : Store, key : String) -> Result[Bool, ReadError] {
  let mut result : Result[Bool, ReadError] = Ok(false)
  enqueue_contains(store, key, next => result = next)
  result
}

///|
fn write(store : Store, mutations : Array[Mutation]) -> WriteOutcome {
  let mut result : WriteOutcome = Some(WriteError::Failed("pending", 1))
  enqueue_apply(store, mutations, next => result = next)
  result
}

///|
fn list(store : Store) -> EntriesOutcome {
  let mut result : EntriesOutcome = Err(ReadError::Failed("pending", 1))
  enqueue_entries(store, next => result = next)
  result
}

///|
test "structural stores share state and delimiters do not collide" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let first = Store::Store("loomark.local-repository", 1, "archives")
  let equal = Store::Store("loomark.local-repository", 1, "archives")
  let different = Store::Store("loomark.local-repository", 1, "archives|x")
  ignore(read(first, "x"))
  ignore(read(equal, "x"))
  ignore(read(different, "x"))
  assert_eq(fake_open_count(), 2)
}

///|
test "get reports missing found and unsupported" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let store = test_store()
  assert_eq(read(store, "missing"), Ok(Lookup::Missing))
  set_fake_record("found", "string", "value")
  assert_eq(read(store, "found"), Ok(Lookup::Found("value")))
  set_fake_record("bad", "number", "")
  assert_eq(read(store, "bad"), Ok(Lookup::Unsupported))
}

///|
test "contains uses getKey and never reads a value" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let store = test_store()
  set_fake_record("present", "string", "value")
  assert_eq(contains(store, "present"), Ok(true))
  assert_eq(contains(store, "missing"), Ok(false))
  assert_eq(fake_get_key_count(), 2)
  assert_eq(fake_keyed_cursor_count(), 0)
  assert_eq(fake_value_read_count(), 0)
}

///|
test "entries retains unsupported cursor entries and continues" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let store = test_store()
  set_fake_unsupported_key_record(7, "bad-key")
  set_fake_record("a", "number", "")
  set_fake_record("b", "string", "B")
  assert_eq(
    list(store),
    Ok([
      Entry::UnsupportedKey(0),
      Entry::UnsupportedValue("a"),
      Entry::StringRecord("b", "B"),
    ]),
  )
}

///|
test "set and delete commit in one transaction" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let store = test_store()
  assert_eq(
    write(store, [Mutation::Set("a", "A"), Mutation::Delete("b")]),
    None,
  )
  assert_eq(fake_transaction_count(), 1)
  assert_eq(fake_record_at("a"), "A")
}

///|
test "apply is atomic, snapshots inputs, and waits for commit" {
  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "missing", "")
  let store = test_store()
  let mutations = [Mutation::Set("a", "A")]
  let mut result : WriteOutcome = Some(WriteError::Failed("pending", 1))
  enqueue_apply(store, mutations, next => result = next)
  mutations.push(Mutation::Delete("b"))
  assert_eq(result, Some(WriteError::Failed("pending", 1)))
  flush_fake_transactions()
  assert_eq(result, None)
  assert_eq(fake_transaction_count(), 1)
}

///|
test "failed apply rolls back and empty apply does not open" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delete-failed-delayed-abort", "missing", "")
  let store = test_store()
  set_fake_record("old", "string", "old")
  let mut result : WriteOutcome = None
  enqueue_apply(store, [Mutation::Set("new", "new"), Mutation::Delete("old")], next => {
    result = next
  })
  assert_eq(fake_record_at("new"), "<missing>")
  assert_eq(fake_abort_count(), 1)
  flush_fake_aborts()
  assert_eq(result, Some(WriteError::Failed("UnknownError", 0)))
  assert_eq(fake_record_at("old"), "old")
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  assert_eq(write(test_store(), []), None)
  assert_eq(fake_open_count(), 0)
}

///|
test "quota and unavailable preserve typed diagnostics" {
  reset_provider_state_for_test()
  install_fake_indexed_db("quota", "string", "old")
  assert_eq(
    write(test_store(), [Mutation::Set("x", "new")]),
    Some(WriteError::QuotaExceeded),
  )
  reset_provider_state_for_test()
  install_missing_indexed_db()
  assert_eq(read(test_store(), "x"), Err(ReadError::Unavailable))
  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-failed", "missing", "")
  assert_eq(read(test_store(), "x"), Err(ReadError::Failed("UnknownError", 0)))
}

///|
test "blocked open fails once and a later operation recovers" {
  reset_provider_state_for_test()
  install_fake_indexed_db("blocked", "missing", "")
  let mut result : ReadOutcome = Ok(Lookup::Found("bad"))
  let mut count = 0
  enqueue_get(test_store(), "x", next => {
    result = next
    count += 1
  })
  assert_eq(result, Err(ReadError::Unavailable))
  assert_eq(count, 1)
  install_fake_indexed_db("success", "missing", "")
  let mut recovered_count = 0
  enqueue_get(test_store(), "x", _ => recovered_count += 1)
  assert_eq(recovered_count, 1)
  assert_eq(fake_open_count(), 1)
}

///|
test "stale open success closes its old database and never repeats callbacks" {
  reset_provider_state_for_test()
  install_fake_indexed_db("blocked-retained", "missing", "")
  let mut blocked_count = 0
  enqueue_get(test_store(), "old", _ => blocked_count += 1)
  assert_eq(blocked_count, 1)
  install_fake_indexed_db("success", "missing", "")
  let mut current_count = 0
  enqueue_get(test_store(), "current", _ => current_count += 1)
  assert_eq(current_count, 1)
  deliver_fake_stale_open()
  assert_eq(blocked_count, 1)
  assert_eq(current_count, 1)
  assert_eq(fake_stale_database_closed(), true)
}

///|
test "versionchange closes the cached database before reopening" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  assert_eq(read(test_store(), "before"), Ok(Lookup::Missing))
  assert_eq(fake_closed_count(), 0)
  trigger_fake_versionchange()
  assert_eq(fake_closed_count(), 1)
  assert_eq(read(test_store(), "after"), Ok(Lookup::Missing))
  assert_eq(fake_open_count(), 2)
}

///|
test "duplicate request and transaction events resume once" {
  reset_provider_state_for_test()
  install_fake_indexed_db("abort-after-put", "string", "old")
  let mut count = 0
  enqueue_apply(test_store(), [Mutation::Set("x", "new")], _ => count += 1)
  assert_eq(count, 1)
}

///|
test "debug output is complete and redacts operation arguments" {
  debug_inspect(
    test_store().get("secret", _ => @cmd.none),
    content="IndexedDBGet",
  )
  debug_inspect(
    test_store().contains("secret", _ => @cmd.none),
    content="IndexedDBContains",
  )
  debug_inspect(
    test_store().entries(_ => @cmd.none),
    content="IndexedDBEntries",
  )
  debug_inspect(
    test_store().apply([Mutation::Set("secret", "value")], _ => @cmd.none),
    content="IndexedDBApply(1)",
  )
}

///|
async test "public commands use the new API" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let store = test_store()
  let mut result : Result[Lookup, ReadError] = Ok(Lookup::Missing)
  @testing.run_cmd(
    store.get("x", next => {
      result = next
      @cmd.none
    }),
  )
  assert_eq(result, Ok(Lookup::Missing))
}
