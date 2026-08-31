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
  #|     stale_thrown: false,
  #|     pending_opens: [],
  #|     pending_transactions: [],
  #|     pending_completions: [],
  #|     withheld_completion: false,
  #|     pending_aborts: [],
  #|     database: null,
  #|   };
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
  #|       if (name !== store_name || !fake.schema) throw { name: "NotFoundError" };
  #|       return {
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
  #|           const exists = fake.records.has(key);
  #|           const cursor = exists ? { key, value: fake.records.get(key) } : null;
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
extern "js" fn fake_record_at(key : String) -> String =
  #| key => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null || !fake.records.has(key)) return "<missing>";
  #|   return String(fake.records.get(key));
  #| }

///|
extern "js" fn fake_legacy_remove_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.legacy_remove_count ?? 0

///|
extern "js" fn fake_open_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.open_count ?? 0

///|
extern "js" fn fake_transaction_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.transaction_count ?? 0

///|
extern "js" fn fake_put_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.put_count ?? 0

///|
extern "js" fn fake_abort_count() -> Int =
  #| () => globalThis[Symbol.for("moonbit-community.rabbita.indexed-db.fake")]?.abort_count ?? 0

///|
extern "js" fn flush_fake_open() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   const pending = fake.pending_opens.splice(0);
  #|   for (const entry of pending) {
  #|     if (entry.request.error != null) {
  #|       entry.request._error?.({ target: entry.request });
  #|     } else {
  #|       entry.request._upgrade?.({ target: entry.request });
  #|       entry.request._success?.({ target: entry.request });
  #|     }
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
extern "js" fn flush_fake_completions() -> Unit =
  #| () => {
  #|   const fake_key = Symbol.for("moonbit-community.rabbita.indexed-db.fake");
  #|   const fake = globalThis[fake_key];
  #|   if (fake == null) return;
  #|   const pending = fake.pending_completions.splice(0);
  #|   for (const transaction of pending) {
  #|     transaction.oncomplete?.({ target: transaction });
  #|   }
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
fn scan_result() -> (ScanResult, Int) {
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut result = ScanResult::Failed
  let mut count = 0
  enqueue_scan(config, next => {
    result = next
    count += 1
  })
  (result, count)
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
test "one failed open fans out to every queued operation" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delayed-open-error", "missing", "")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut write = WriteResult::Stored
  let mut write_count = 0
  let mut scan = ScanResult::Scanned([])
  let mut scan_count = 0
  enqueue_mutate(config, [Mutation::Put("source/v1/a", "A")], result => {
    write = result
    write_count += 1
  })
  enqueue_scan(config, result => {
    scan = result
    scan_count += 1
  })
  assert_eq(write_count, 0)
  assert_eq(scan_count, 0)
  assert_eq(fake_open_count(), 1)
  flush_fake_open()
  assert_eq(write, WriteResult::Failed)
  assert_eq(write_count, 1)
  assert_eq(scan, ScanResult::Failed)
  assert_eq(scan_count, 1)
  assert_eq(fake_transaction_count(), 0)
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
test "provider admits a later transaction before an earlier acknowledgment" {
  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "string", "old")
  let mut first_count = 0
  let mut second_count = 0
  set_item("loomark.active-document-archive", "first", _ => first_count += 1)
  set_item("loomark.active-document-archive", "second", _ => second_count += 1)
  assert_eq(fake_transaction_count(), 2)
  assert_eq(first_count, 0)
  assert_eq(second_count, 0)
  flush_fake_transactions()
  assert_eq(first_count, 1)
  assert_eq(second_count, 1)
  assert_eq(fake_record_state(), "second")
}

///|
test "a completion callback may enqueue another transaction" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let mut first_count = 0
  let mut second_count = 0
  set_item("loomark.active-document-archive", "first", _ => {
    first_count += 1
    set_item("loomark.active-document-archive", "second", _ => second_count += 1)
  })
  assert_eq(first_count, 1)
  assert_eq(second_count, 1)
  assert_eq(fake_transaction_count(), 2)
  assert_eq(fake_record_state(), "second")
}

///|
test "committed mutation with a withheld acknowledgment does not block a probe" {
  reset_provider_state_for_test()
  install_fake_indexed_db("commit-withheld", "string", "old")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut delete_count = 0
  let mut probe = ReadResult::Failed
  let mut probe_count = 0
  enqueue_mutate(
    config,
    [Mutation::Delete("loomark.active-document-archive")],
    _ => delete_count += 1,
  )
  assert_eq(delete_count, 0)
  assert_eq(fake_record_state(), "missing")
  enqueue_get(config, "loomark.active-document-archive", false, result => {
    probe = result
    probe_count += 1
  })
  assert_eq(fake_transaction_count(), 2)
  assert_eq(probe, ReadResult::Missing)
  assert_eq(probe_count, 1)
  flush_fake_completions()
  assert_eq(delete_count, 1)
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

///|
test "indexeddb scan returns an empty committed store" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let (observed, count) = scan_result()
  assert_eq(observed, ScanResult::Scanned([]))
  assert_eq(count, 1)
  assert_eq(fake_transaction_count(), 1)
}

///|
test "indexeddb scan preserves order and isolates unsupported records" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_fake_unsupported_key_record(7, "unsupported-seven")
  set_fake_unsupported_key_record(8, "unsupported-eight")
  set_fake_record("source/v1/c", "string", "C")
  set_fake_record("source/v1/a", "number", "")
  set_fake_record("source/v1/b", "string", "B")
  let (observed, count) = scan_result()
  assert_eq(
    observed,
    ScanResult::Scanned([
      ScanEntry::UnsupportedKey(0),
      ScanEntry::UnsupportedKey(1),
      ScanEntry::UnsupportedValue("source/v1/a"),
      ScanEntry::StringRecord("source/v1/b", "B"),
      ScanEntry::StringRecord("source/v1/c", "C"),
    ]),
  )
  assert_eq(count, 1)
}

///|
test "indexeddb scan fails closed at every cursor boundary" {
  for
    mode in [
      "cursor-error", "cursor-result-getter-failed", "cursor-value-getter-failed",
      "cursor-continue-failed",
    ] {
    reset_provider_state_for_test()
    install_fake_indexed_db(mode, "missing", "")
    set_fake_record("source/v1/a", "string", "A")
    let (observed, count) = scan_result()
    assert_eq(observed, ScanResult::Failed)
    assert_eq(count, 1)
  }
}

///|
test "indexeddb scan waits for transaction completion" {
  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "missing", "")
  set_fake_record("source/v1/a", "string", "A")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut observed = ScanResult::Failed
  let mut count = 0
  enqueue_scan(config, result => {
    observed = result
    count += 1
  })
  assert_eq(count, 0)
  flush_fake_transactions()
  assert_eq(
    observed,
    ScanResult::Scanned([ScanEntry::StringRecord("source/v1/a", "A")]),
  )
  assert_eq(count, 1)
}

///|
test "indexeddb mutation atomically puts and deletes records" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_fake_record("active", "string", "old")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut observed = WriteResult::Failed
  let mut count = 0
  enqueue_mutate(
    config,
    [Mutation::Put("source/v1/document-1", "new"), Mutation::Delete("active")],
    result => {
      observed = result
      count += 1
    },
  )
  assert_eq(observed, WriteResult::Stored)
  assert_eq(count, 1)
  assert_eq(fake_record_at("source/v1/document-1"), "new")
  assert_eq(fake_record_at("active"), "<missing>")
  assert_eq(fake_transaction_count(), 1)
}

///|
test "indexeddb mutation failure waits for abort and rolls back" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delete-failed-delayed-abort", "missing", "")
  set_fake_record("active", "string", "old")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut observed = WriteResult::Stored
  let mut count = 0
  enqueue_mutate(
    config,
    [Mutation::Put("source/v1/document-1", "new"), Mutation::Delete("active")],
    result => {
      observed = result
      count += 1
    },
  )
  assert_eq(count, 0)
  assert_eq(fake_abort_count(), 1)
  flush_fake_aborts()
  assert_eq(observed, WriteResult::Failed)
  assert_eq(count, 1)
  assert_eq(fake_record_at("source/v1/document-1"), "<missing>")
  assert_eq(fake_record_at("active"), "old")
}

///|
test "empty indexeddb mutation is an immediate successful no-op" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut observed = WriteResult::Failed
  let mut count = 0
  enqueue_mutate(config, [], result => {
    observed = result
    count += 1
  })
  assert_eq(observed, WriteResult::Stored)
  assert_eq(count, 1)
  assert_eq(fake_open_count(), 0)
  assert_eq(fake_transaction_count(), 0)
}

///|
test "queued indexeddb mutation owns its mutation list" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delayed-open", "missing", "")
  set_fake_record("active", "string", "keep")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mutations = [Mutation::Put("source/v1/document-1", "new")]
  let mut observed = WriteResult::Failed
  enqueue_mutate(config, mutations, result => observed = result)
  mutations.push(Mutation::Delete("active"))
  flush_fake_open()
  assert_eq(observed, WriteResult::Stored)
  assert_eq(fake_record_at("source/v1/document-1"), "new")
  assert_eq(fake_record_at("active"), "keep")
}

///|
test "indexeddb mutation waits for transaction completion" {
  reset_provider_state_for_test()
  install_fake_indexed_db("request-success-only", "missing", "")
  set_fake_record("active", "string", "old")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut observed = WriteResult::Failed
  let mut count = 0
  enqueue_mutate(
    config,
    [Mutation::Put("source/v1/document-1", "new"), Mutation::Delete("active")],
    result => {
      observed = result
      count += 1
    },
  )
  assert_eq(count, 0)
  assert_eq(fake_record_at("source/v1/document-1"), "<missing>")
  assert_eq(fake_record_at("active"), "old")
  flush_fake_transactions()
  assert_eq(observed, WriteResult::Stored)
  assert_eq(count, 1)
  assert_eq(fake_record_at("source/v1/document-1"), "new")
  assert_eq(fake_record_at("active"), "<missing>")
}

///|
test "indexeddb provider preserves FIFO order across mutation and scan" {
  reset_provider_state_for_test()
  install_fake_indexed_db("delayed-open", "missing", "")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let order : Array[String] = []
  let mut scanned = ScanResult::Failed
  enqueue_mutate(config, [Mutation::Put("source/v1/document-1", "new")], _ => {
    order.push("mutate")
  })
  enqueue_scan(config, result => {
    scanned = result
    order.push("scan")
  })
  assert_eq(order, [])
  flush_fake_open()
  assert_eq(order, ["mutate", "scan"])
  assert_eq(
    scanned,
    ScanResult::Scanned([ScanEntry::StringRecord("source/v1/document-1", "new")]),
  )
}

///|
test "indexeddb scan classifies unavailable and failed opens" {
  reset_provider_state_for_test()
  install_missing_indexed_db()
  let (unavailable, unavailable_count) = scan_result()
  assert_eq(unavailable, ScanResult::Unavailable)
  assert_eq(unavailable_count, 1)

  reset_provider_state_for_test()
  install_fake_indexed_db("open-error-failed", "missing", "")
  let (failed, failed_count) = scan_result()
  assert_eq(failed, ScanResult::Failed)
  assert_eq(failed_count, 1)
}

///|
async test "public indexeddb commands preserve provider results" {
  reset_provider_state_for_test()
  install_fake_indexed_db("success", "missing", "")
  set_fake_record("active", "string", "old")
  set_fake_record("source/v1/a", "string", "A")
  set_fake_record("source/v1/b", "number", "")
  let config = Config::Config("loomark.local-repository", 1, "archives")
  let mut scanned = ScanResult::Failed
  @testing.run_cmd(
    scan(config, result=result => {
      scanned = result
      @cmd.none
    }),
  )
  assert_eq(
    scanned,
    ScanResult::Scanned([
      ScanEntry::StringRecord("active", "old"),
      ScanEntry::StringRecord("source/v1/a", "A"),
      ScanEntry::UnsupportedValue("source/v1/b"),
    ]),
  )
  let mut written = WriteResult::Failed
  @testing.run_cmd(
    mutate(
      config,
      [Mutation::Put("source/v1/document-1", "new"), Mutation::Delete("active")],
      result=result => {
        written = result
        @cmd.none
      },
    ),
  )
  assert_eq(written, WriteResult::Stored)
  assert_eq(fake_record_at("source/v1/document-1"), "new")
  assert_eq(fake_record_at("active"), "<missing>")
}
