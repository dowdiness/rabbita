///|
/// Browser IndexedDB primitives used by the higher-level `indexed_db` binding.
///
/// The types and methods in this file intentionally mirror the Web API. They
/// do not own queues, persistence policy, migration policy, or application
/// messages. See https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
///

///|
#cfg(target="js")
#external
pub type IDBFactory

///|
#cfg(target="js")
#external
pub type IDBOpenDBRequest

///|
#cfg(target="js")
#external
pub type IDBDatabase

///|
#cfg(target="js")
#external
pub type IDBTransaction

///|
#cfg(target="js")
#external
pub type IDBObjectStore

///|
#cfg(target="js")
#external
pub type IDBRequest

///|
#cfg(target="js")
#external
pub type IDBCursorWithValue

///|
#cfg(target="js")
#external
pub type Storage

///|
#cfg(target="js")
/// Return the browser's IndexedDB factory, or `None` when the API is absent.
pub fn indexed_db() -> IDBFactory? {
  ffi_indexed_db().to_option()
}

///|
#cfg(target="js")
extern "js" fn ffi_indexed_db() -> @js.Nullable[IDBFactory] =
  #| () => globalThis.indexedDB ?? null

///|
#cfg(target="js")
/// Return the browser's localStorage object.
///
/// Access errors deliberately escape so the caller can classify them as a
/// storage failure rather than treating them as an empty legacy store.
pub fn local_storage() -> Storage? {
  ffi_local_storage().to_option()
}

///|
#cfg(target="js")
extern "js" fn ffi_local_storage() -> @js.Nullable[Storage] =
  #| () => globalThis.localStorage ?? null

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBFactory/open

///|
#cfg(target="js")
pub extern "js" fn IDBFactory::open(
  self : Self,
  name : String,
  version : Int,
) -> IDBOpenDBRequest = "(factory, name, version) => factory.open(name, version)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBOpenDBRequest/onsuccess

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::set_on_success(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onsuccess = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBOpenDBRequest/onerror

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::set_on_error(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onerror = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBOpenDBRequest/onblocked

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::set_on_blocked(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onblocked = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBOpenDBRequest/onupgradeneeded

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::set_on_upgrade_needed(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onupgradeneeded = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBOpenDBRequest/result

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::get_result(self : Self) -> IDBDatabase = "(request) => request.result"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBRequest/error

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::get_error_name(self : Self) -> String = "(request) => request.error?.name ?? ''"

/// https://developer.mozilla.org/en-US/docs/Web/API/DOMException/code

///|
#cfg(target="js")
pub extern "js" fn IDBOpenDBRequest::get_error_code(self : Self) -> Int = "(request) => request.error?.code ?? 0"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBDatabase/createObjectStore

///|
#cfg(target="js")
pub extern "js" fn IDBDatabase::create_object_store(
  self : Self,
  name : String,
) -> IDBObjectStore = "(database, name) => database.createObjectStore(name)"

///|
#cfg(target="js")
pub extern "js" fn IDBDatabase::has_object_store(
  self : Self,
  name : String,
) -> Bool = "(database, name) => database.objectStoreNames.contains(name)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBDatabase/transaction

///|
#cfg(target="js")
pub extern "js" fn IDBDatabase::transaction(
  self : Self,
  store_name : String,
  mode : String,
) -> IDBTransaction = "(database, storeName, mode) => database.transaction(storeName, mode)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBDatabase/close

///|
#cfg(target="js")
pub extern "js" fn IDBDatabase::close(self : Self) -> Unit = "(database) => { try { database.close() } catch (_) {} }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBDatabase/onversionchange

///|
#cfg(target="js")
pub extern "js" fn IDBDatabase::set_on_version_change(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(database, callback) => { database.onversionchange = () => callback() }"

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::object_store(
  self : Self,
  name : String,
) -> IDBObjectStore = "(transaction, name) => transaction.objectStore(name)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/oncomplete

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::set_on_complete(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(transaction, callback) => { transaction.oncomplete = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/onerror

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::set_on_error(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(transaction, callback) => { transaction.onerror = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/onabort

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::set_on_abort(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(transaction, callback) => { transaction.onabort = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/abort

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::abort(self : Self) -> Unit = "(transaction) => { try { transaction.abort() } catch (_) {} }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/error

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::get_error_name(self : Self) -> String = "(transaction) => transaction.error?.name ?? ''"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBTransaction/error

///|
#cfg(target="js")
pub extern "js" fn IDBTransaction::get_error_code(self : Self) -> Int = "(transaction) => transaction.error?.code ?? 0"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBObjectStore/put

///|
#cfg(target="js")
pub extern "js" fn IDBObjectStore::put_string(
  self : Self,
  value : String,
  key : String,
) -> IDBRequest = "(store, value, key) => store.put(value, key)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBObjectStore/openCursor

///|
#cfg(target="js")
pub extern "js" fn IDBObjectStore::open_cursor(
  self : Self,
  key : String,
) -> IDBRequest = "(store, key) => store.openCursor(key)"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBRequest/onsuccess

///|
#cfg(target="js")
pub extern "js" fn IDBRequest::set_on_success(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onsuccess = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBRequest/onerror

///|
#cfg(target="js")
pub extern "js" fn IDBRequest::set_on_error(
  self : Self,
  callback : () -> Unit,
) -> Unit = "(request, callback) => { request.onerror = () => callback() }"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBRequest/result

///|
#cfg(target="js")
pub extern "js" fn IDBRequest::get_cursor(
  self : Self,
) -> @js.Nullable[IDBCursorWithValue] = "(request) => request.result ?? null"

///|
#cfg(target="js")
pub fn IDBRequest::cursor(self : Self) -> IDBCursorWithValue? {
  self.get_cursor().to_option()
}

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBRequest/error

///|
#cfg(target="js")
pub extern "js" fn IDBRequest::get_error_name(self : Self) -> String = "(request) => request.error?.name ?? ''"

/// https://developer.mozilla.org/en-US/docs/Web/API/DOMException/code

///|
#cfg(target="js")
pub extern "js" fn IDBRequest::get_error_code(self : Self) -> Int = "(request) => request.error?.code ?? 0"

/// https://developer.mozilla.org/en-US/docs/Web/API/IDBCursorWithValue/value

///|
#cfg(target="js")
pub extern "js" fn IDBCursorWithValue::get_string_value(
  self : Self,
) -> @js.Nullable[String] =
  #| (cursor) => typeof cursor.value === "string" ? cursor.value : null

///|
#cfg(target="js")
pub fn IDBCursorWithValue::string_value(self : Self) -> String? {
  self.get_string_value().to_option()
}

/// https://developer.mozilla.org/en-US/docs/Web/API/Storage/getItem

///|
#cfg(target="js")
pub extern "js" fn Storage::get_item(
  self : Self,
  key : String,
) -> @js.Nullable[String] = "(storage, key) => storage.getItem(key)"

///|
#cfg(target="js")
pub fn Storage::read_item(self : Self, key : String) -> String? {
  self.get_item(key).to_option()
}

/// https://developer.mozilla.org/en-US/docs/Web/API/Storage/removeItem

///|
#cfg(target="js")
pub extern "js" fn Storage::remove_item(self : Self, key : String) -> Unit = "(storage, key) => storage.removeItem(key)"
