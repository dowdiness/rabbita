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
  #|     stale_thrown: false,
  #|     pending_opens: [],
  #|     pending_transactions: [],
  #|     database: null,
  #|   };
  #|   globalThis[fake_key] = fake;
  #|   if (record_kind === "string") fake.records.set(archive_key, record_value);
  #|   else if (record_kind === "undefined") fake.records.set(archive_key, undefined);
  #|   else if (record_kind === "number") fake.records.set(archive_key, 42);
  #|
  #|   const install_local_storage = () => {
  #|     globalThis.localStorage = {
  #|       getItem(key) {
  #|         if (fake.legacy_error != null) throw { name: fake.legacy_error };
  #|         return key === archive_key ? fake.legacy_value : null;
  #|       },
  #|       setItem(key, value) {
  #|         if (key === archive_key) fake.legacy_value = String(value);
  #|       },
  #|       removeItem(key) {
  #|         if (key === archive_key) {
  #|           fake.legacy_remove_count += 1;
  #|           fake.legacy_value = null;
  #|         }
  #|       },
  #|     };
  #|   };
  #|   install_local_storage();
  #|
  #|   const make_request = (result, error) => {
  #|     const request = { result, error, _success: null, _error: null, _upgrade: null, _blocked: null };
  #|     Object.defineProperty(request, "onsuccess", {
  #|       get() { return request._success; },
  #|       set(handler) {
  #|         request._success = handler;
  #|         if (handler && request._deliver_success != null) request._deliver_success();
  #|       },
  #|     });
  #|     Object.defineProperty(request, "onerror", {
  #|       get() { return request._error; },
  #|       set(handler) {
  #|         request._error = handler;
  #|         if (handler && request._deliver_error != null && request.error != null) {
  #|           request._deliver_error();
  #|         };
  #|       },
  #|     });
  #|     Object.defineProperty(request, "onupgradeneeded", {
  #|       get() { return request._upgrade; },
  #|       set(handler) {
  #|         request._upgrade = handler;
  #|         if (handler && request._deliver_upgrade != null) request._deliver_upgrade();
  #|       },
  #|     });
  #|     Object.defineProperty(request, "onblocked", {
  #|       get() { return request._blocked; },
  #|       set(handler) {
  #|         request._blocked = handler;
  #|         if (handler && request._deliver_blocked != null) request._deliver_blocked();
  #|       },
  #|     });
  #|     return request;
  #|   };
  #|
  #|   const make_transaction = () => {
  #|     const transaction = {
  #|       error: null,
  #|       finished: false,
  #|       writes: [],
  #|       oncomplete: null,
  #|       onerror: null,
  #|       onabort: null,
  #|     };
  #|     transaction.objectStore = name => {
  #|       if (name !== store_name || !fake.schema) throw { name: "NotFoundError" };
  #|       return {
  #|         openCursor(key) {
  #|           const exists = fake.records.has(key);
  #|           const cursor = exists ? { key, value: fake.records.get(key) } : null;
  #|           const request = make_request(cursor, null);
  #|           request._deliver_success = () => {
  #|             request._success?.({ target: request });
  #|             if (!transaction.finished && fake.mode !== "request-success-only") transaction.complete();
  #|           };
  #|           request._deliver_error = () => {
  #|             request._error?.({ target: request });
  #|           };
  #|           return request;
  #|         },
  #|         put(value, key) {
  #|           fake.put_count += 1;
  #|           const request = make_request(undefined, null);
  #|           transaction.writes.push({ key, value });
  #|           request._deliver_success = () => {
  #|             if (fake.mode === "quota") {
  #|               request.error = { name: "QuotaExceededError", code: 22 };
  #|               request._error?.({ target: request });
  #|               return;
  #|             }
  #|             request._success?.({ target: request });
  #|             if (fake.mode === "abort-after-put") {
  #|               transaction.abort({ name: "AbortError" });
  #|             } else if (fake.mode === "transaction-failed") {
  #|               transaction.abort({ name: "UnknownError" });
  #|             } else if (fake.mode === "request-success-only") {
  #|               fake.pending_transactions.push(transaction);
  #|             } else {
  #|               transaction.complete();
  #|             }
  #|           };
  #|           request._deliver_error = () => {
  #|             request._error?.({ target: request });
  #|           };
  #|           return request;
  #|         },
  #|       };
  #|     };
  #|     transaction.complete = () => {
  #|       if (transaction.finished) return;
  #|       transaction.finished = true;
  #|       for (const write of transaction.writes) fake.records.set(write.key, write.value);
  #|       transaction.oncomplete?.({ target: transaction });
  #|     };
  #|     transaction.abort = error => {
  #|       if (transaction.finished) return;
  #|       transaction.finished = true;
  #|       transaction.error = error ?? { name: "AbortError" };
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
  #|         contains(name) { return fake.schema && name === store_name; },
  #|       },
  #|       createObjectStore(name) {
  #|         if (name !== store_name) throw { name: "InvalidStateError" };
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
  #|       close() { database.closed = true; },
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
  #|         : fake.mode === "open-error-failed" ? { name: "UnknownError" } : null;
  #|       const request = make_request(null, open_error);
  #|       const database = make_database();
  #|       request.result = database;
  #|       const entry = { request, database };
  #|       if (fake.mode === "delayed-open") {
  #|         fake.pending_opens.push(entry);
  #|       } else if (fake.mode === "success" || fake.mode === "stale-transaction-once" ||
  #|           fake.mode === "abort-after-put" || fake.mode === "quota" ||
  #|           fake.mode === "request-success-only" || fake.mode === "transaction-failed") {
  #|         request._deliver_upgrade = () => request._upgrade?.({ target: request });
  #|         request._deliver_success = () => request._success?.({ target: request });
  #|       } else if (fake.mode === "blocked") {
  #|         request._deliver_blocked = () => request._blocked?.({ target: request });
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
extern "js" fn set_legacy_value(value : String?) -> Unit =
  #| value => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake != null) fake.legacy_value = value;
  #| }

///|
extern "js" fn throw_legacy_get(name : String) -> Unit =
  #| name => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake != null) fake.legacy_error = name;
  #| }

///|
extern "js" fn clear_legacy_storage() -> Unit =
  #| () => { delete globalThis.localStorage; }

///|
extern "js" fn fake_record_state() -> String =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   const key = "loomark.active-document-archive";
  #|   if (fake == null || !fake.records.has(key)) return "missing";
  #|   const value = fake.records.get(key);
  #|   if (value === undefined) return "undefined";
  #|   return String(value);
  #| }

///|
extern "js" fn fake_legacy_state() -> String =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   const value = fake == null ? null : fake.legacy_value;
  #|   return value == null ? "<missing>" : String(value);
  #| }

///|
extern "js" fn fake_legacy_remove_count() -> Int =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   return globalThis[fake_key]?.legacy_remove_count ?? 0;
  #| }

///|
extern "js" fn fake_open_count() -> Int =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   return globalThis[fake_key]?.open_count ?? 0;
  #| }

///|
extern "js" fn fake_transaction_count() -> Int =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   return globalThis[fake_key]?.transaction_count ?? 0;
  #| }

///|
extern "js" fn fake_put_count() -> Int =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   return globalThis[fake_key]?.put_count ?? 0;
  #| }

///|
extern "js" fn flush_fake_open() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   const pending = fake.pending_opens.splice(0);
  #|   for (const entry of pending) {
  #|     entry.request._upgrade?.({ target: entry.request });
  #|     entry.request._success?.({ target: entry.request });
  #|   }
  #| }

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
extern "js" fn trigger_fake_versionchange() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   fake?.database?.onversionchange?.({});
  #| }

///|
fn read_result() -> (Int, String, Int) {
  let mut kind = -1
  let mut value = ""
  let mut count = 0
  get_item("loomark.active-document-archive", (next_kind, next_value) => {
    kind = next_kind
    value = next_value
    count += 1
  })
  (kind, value, count)
}

///|
test "indexeddb provider distinguishes missing records and authoritative loaded values" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  clear_legacy_storage()
  let (missing_kind, missing_value, missing_count) = read_result()
  assert_eq(missing_kind, 0)
  assert_eq(missing_value, "")
  assert_eq(missing_count, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("success", "string", "indexeddb")
  set_legacy_value(Some("legacy"))
  let (loaded_kind, loaded_value, loaded_count) = read_result()
  assert_eq(loaded_kind, 1)
  assert_eq(loaded_value, "indexeddb")
  assert_eq(loaded_count, 1)
  assert_eq(fake_record_state(), "indexeddb")
  assert_eq(fake_legacy_state(), "legacy")
  assert_eq(fake_legacy_remove_count(), 0)
}

///|
test "indexeddb open failures preserve the existing unavailable and failed codes" {
  reset_provider_state_for_test()
  install_missing_indexed_db()
  let (missing_kind, _, missing_count) = read_result()
  assert_eq(missing_kind, 2)
  assert_eq(missing_count, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("blocked", "missing", "")
  let (blocked_kind, _, blocked_count) = read_result()
  assert_eq(blocked_kind, 2)
  assert_eq(blocked_count, 1)
  let (blocked_again_kind, _, blocked_again_count) = read_result()
  assert_eq(blocked_again_kind, 2)
  assert_eq(blocked_again_count, 1)
  assert_eq(fake_open_count(), 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-security", "missing", "")
  let (security_kind, _, security_count) = read_result()
  assert_eq(security_kind, 2)
  assert_eq(security_count, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-failed", "missing", "")
  let (failed_kind, _, failed_count) = read_result()
  assert_eq(failed_kind, 3)
  assert_eq(failed_count, 1)

  reset_provider_state_for_test()
  install_missing_indexed_db()
  let mut unavailable_write_kind = -1
  set_item("loomark.active-document-archive", "new", kind => {
    unavailable_write_kind = kind
  })
  assert_eq(unavailable_write_kind, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-security", "missing", "")
  let mut security_write_kind = -1
  set_item("loomark.active-document-archive", "new", kind => {
    security_write_kind = kind
  })
  assert_eq(security_write_kind, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-failed", "missing", "")
  let mut failed_write_kind = -1
  set_item("loomark.active-document-archive", "new", kind => {
    failed_write_kind = kind
  })
  assert_eq(failed_write_kind, 3)
}

///|
test "successful writes wait for transaction completion and preserve FIFO invocation order" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delayed-open", "missing", "")
  let mut first_kind = -1
  let mut second_kind = -1
  set_item("loomark.active-document-archive", "first", kind => first_kind = kind)
  set_item("loomark.active-document-archive", "second", kind => {
    second_kind = kind
  })
  assert_eq(first_kind, -1)
  assert_eq(second_kind, -1)
  assert_eq(fake_transaction_count(), 0)
  flush_fake_open()
  assert_eq(first_kind, 0)
  assert_eq(second_kind, 0)
  assert_eq(fake_record_state(), "second")
  assert_eq(fake_transaction_count(), 2)
  assert_eq(fake_put_count(), 2)

  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "string", "old")
  let mut completion_kind = -1
  let mut completion_count = 0
  set_item("loomark.active-document-archive", "new", kind => {
    completion_kind = kind
    completion_count += 1
  })
  assert_eq(completion_kind, -1)
  assert_eq(completion_count, 0)
  assert_eq(fake_record_state(), "old")
  flush_fake_transactions()
  assert_eq(completion_kind, 0)
  assert_eq(completion_count, 1)
  assert_eq(fake_record_state(), "new")
}

///|
test "aborted and quota writes complete once and preserve the old record" {
  reset_provider_state_for_test()
  install_fake_indexed_db("abort-after-put", "string", "old")
  let mut abort_kind = -1
  let mut abort_count = 0
  set_item("loomark.active-document-archive", "new", kind => {
    abort_kind = kind
    abort_count += 1
  })
  assert_eq(abort_kind, 3)
  assert_eq(abort_count, 1)
  assert_eq(fake_record_state(), "old")

  reset_provider_state_for_test()
  install_fake_indexed_db("quota", "string", "old")
  let mut quota_kind = -1
  set_item("loomark.active-document-archive", "new", kind => quota_kind = kind)
  assert_eq(quota_kind, 2)
  assert_eq(fake_record_state(), "old")
}

///|
test "legacy strings migrate only after commit and never override an idb record" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_legacy_value(Some("legacy"))
  let (migrated_kind, migrated_value, migrated_count) = read_result()
  assert_eq(migrated_kind, 1)
  assert_eq(migrated_value, "legacy")
  assert_eq(migrated_count, 1)
  assert_eq(fake_record_state(), "legacy")
  assert_eq(fake_legacy_state(), "<missing>")
  assert_eq(fake_legacy_remove_count(), 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "missing", "")
  set_legacy_value(Some("old"))
  let mut race_kind = -1
  let mut race_value = ""
  let mut race_count = 0
  get_item("loomark.active-document-archive", (kind, value) => {
    race_kind = kind
    race_value = value
    race_count += 1
  })
  assert_eq(race_kind, -1)
  assert_eq(fake_record_state(), "missing")
  set_legacy_value(Some("new"))
  flush_fake_transactions()
  assert_eq(race_kind, 1)
  assert_eq(race_value, "old")
  assert_eq(race_count, 1)
  assert_eq(fake_record_state(), "old")
  assert_eq(fake_legacy_state(), "new")
  assert_eq(fake_legacy_remove_count(), 0)

  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_legacy_value(Some("preserve"))
  throw_legacy_get("SecurityError")
  let (unavailable_kind, _, unavailable_count) = read_result()
  assert_eq(unavailable_kind, 2)
  assert_eq(unavailable_count, 1)
  assert_eq(fake_legacy_state(), "preserve")

  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_legacy_value(Some("preserve"))
  throw_legacy_get("UnknownError")
  let (failed_kind, _, failed_count) = read_result()
  assert_eq(failed_kind, 3)
  assert_eq(failed_count, 1)
  assert_eq(fake_legacy_state(), "preserve")

  reset_provider_state_for_test()
  install_fake_indexed_db("abort-after-put", "missing", "")
  set_legacy_value(Some("preserve"))
  let (migration_failure_kind, _, migration_failure_count) = read_result()
  assert_eq(migration_failure_kind, 3)
  assert_eq(migration_failure_count, 1)
  assert_eq(fake_record_state(), "missing")
  assert_eq(fake_legacy_state(), "preserve")
  assert_eq(fake_legacy_remove_count(), 0)

  reset_provider_state_for_test()
  install_fake_indexed_db("success", "undefined", "")
  set_legacy_value(Some("must-not-win"))
  let (undefined_kind, undefined_value, undefined_count) = read_result()
  assert_eq(undefined_kind, 3)
  assert_eq(undefined_value, "")
  assert_eq(undefined_count, 1)
  assert_eq(fake_record_state(), "undefined")
  assert_eq(fake_legacy_state(), "must-not-win")
  assert_eq(fake_legacy_remove_count(), 0)

  reset_provider_state_for_test()
  install_fake_indexed_db("success", "number", "")
  set_legacy_value(Some("also-must-not-win"))
  let (number_kind, number_value, number_count) = read_result()
  assert_eq(number_kind, 3)
  assert_eq(number_value, "")
  assert_eq(number_count, 1)
  assert_eq(fake_record_state(), "42")
  assert_eq(fake_legacy_state(), "also-must-not-win")
  assert_eq(fake_legacy_remove_count(), 0)
}

///|
test "stale transaction creation reports unavailable without retrying" {
  reset_provider_state_for_test()
  install_fake_indexed_db("stale-transaction-once", "missing", "")
  let mut observed_kind = -1
  let mut observed_count = 0
  set_item("loomark.active-document-archive", "not-retried", kind => {
    observed_kind = kind
    observed_count += 1
  })
  assert_eq(observed_kind, 1)
  assert_eq(observed_count, 1)
  assert_eq(fake_open_count(), 1)
  assert_eq(fake_record_state(), "missing")
}

///|
test "versionchange invalidates the cached connection before the next operation" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let mut first_kind = -1
  set_item("loomark.active-document-archive", "before", kind => {
    first_kind = kind
  })
  assert_eq(first_kind, 0)
  trigger_fake_versionchange()

  let mut second_kind = -1
  set_item("loomark.active-document-archive", "after", kind => {
    second_kind = kind
  })
  assert_eq(second_kind, 0)
  assert_eq(fake_open_count(), 2)
  assert_eq(fake_record_state(), "after")
}
