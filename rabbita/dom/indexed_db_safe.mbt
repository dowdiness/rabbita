///|
/// Error raised synchronously while invoking an IndexedDB Web API method.
#cfg(target="js")
pub(all) struct IDBError {
  name : String
  code : Int
} derive(Eq)

///|
#cfg(target="js")
pub fn IDBError::name(self : Self) -> String {
  self.name
}

///|
#cfg(target="js")
pub fn IDBError::code(self : Self) -> Int {
  self.code
}

///|
#cfg(target="js")
pub fn indexed_db_safe() -> Result[IDBFactory?, IDBError] {
  let mut result : Result[IDBFactory?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_indexed_db_safe(factory => result = Ok(factory.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_indexed_db_safe(
  on_success : (@js.Nullable[IDBFactory]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (onSuccess, onError) => {
  #|   try {
  #|     onSuccess(globalThis.indexedDB ?? null);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn local_storage_safe() -> Result[Storage?, IDBError] {
  let mut result : Result[Storage?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_local_storage_safe(storage => result = Ok(storage.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_local_storage_safe(
  on_success : (@js.Nullable[Storage]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (onSuccess, onError) => {
  #|   try {
  #|     onSuccess(globalThis.localStorage ?? null);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBFactory::open_safe(
  self : Self,
  name : String,
  version : Int,
) -> Result[IDBOpenDBRequest, IDBError] {
  let mut result : Result[IDBOpenDBRequest, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_open_safe(self, name, version, request => result = Ok(request), (
    name,
    code,
  ) => result = Err({ name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_open_safe(
  factory : IDBFactory,
  name : String,
  version : Int,
  on_success : (IDBOpenDBRequest) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (factory, name, version, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(factory.open(name, version));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBOpenDBRequest::get_result_safe(
  self : Self,
) -> Result[IDBDatabase, IDBError] {
  let mut result : Result[IDBDatabase, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_open_result_safe(self, database => result = Ok(database), (name, code) => {
    result = Err({ name, code })
  })
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_open_result_safe(
  request : IDBOpenDBRequest,
  on_success : (IDBDatabase) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (request, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(request.result);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBDatabase::has_object_store_safe(
  self : Self,
  name : String,
) -> Result[Bool, IDBError] {
  let mut result : Result[Bool, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_has_object_store_safe(self, name, value => result = Ok(value), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_has_object_store_safe(
  database : IDBDatabase,
  name : String,
  on_success : (Bool) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (database, name, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(database.objectStoreNames.contains(name));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBDatabase::create_object_store_safe(
  self : Self,
  name : String,
) -> Result[IDBObjectStore, IDBError] {
  let mut result : Result[IDBObjectStore, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_create_object_store_safe(self, name, store => result = Ok(store), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_create_object_store_safe(
  database : IDBDatabase,
  name : String,
  on_success : (IDBObjectStore) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (database, name, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(database.createObjectStore(name));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBDatabase::transaction_safe(
  self : Self,
  store_name : String,
  mode : String,
) -> Result[IDBTransaction, IDBError] {
  let mut result : Result[IDBTransaction, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_transaction_safe(
    self,
    store_name,
    mode,
    transaction => result = Ok(transaction),
    (error_name, code) => result = Err({ name: error_name, code }),
  )
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_transaction_safe(
  database : IDBDatabase,
  store_name : String,
  mode : String,
  on_success : (IDBTransaction) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (database, storeName, mode, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(database.transaction(storeName, mode));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBTransaction::abort_safe(self : Self) -> Result[Unit, IDBError] {
  let mut result : Result[Unit, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_transaction_abort_safe(self, () => result = Ok(()), (error_name, code) => {
    result = Err({ name: error_name, code })
  })
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_transaction_abort_safe(
  transaction : IDBTransaction,
  on_success : () -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (transaction, onSuccess, onError) => {
  #|   try {
  #|     transaction.abort();
  #|     onSuccess();
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBTransaction::object_store_safe(
  self : Self,
  name : String,
) -> Result[IDBObjectStore, IDBError] {
  let mut result : Result[IDBObjectStore, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_object_store_safe(self, name, store => result = Ok(store), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_object_store_safe(
  transaction : IDBTransaction,
  name : String,
  on_success : (IDBObjectStore) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (transaction, name, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(transaction.objectStore(name));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBObjectStore::put_string_safe(
  self : Self,
  value : String,
  key : String,
) -> Result[IDBRequest, IDBError] {
  let mut result : Result[IDBRequest, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_put_string_safe(self, value, key, request => result = Ok(request), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_put_string_safe(
  store : IDBObjectStore,
  value : String,
  key : String,
  on_success : (IDBRequest) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (store, value, key, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(store.put(value, key));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBObjectStore::delete_safe(
  self : Self,
  key : String,
) -> Result[IDBRequest, IDBError] {
  let mut result : Result[IDBRequest, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_delete_safe(self, key, request => result = Ok(request), (error_name, code) => {
    result = Err({ name: error_name, code })
  })
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_delete_safe(
  store : IDBObjectStore,
  key : String,
  on_success : (IDBRequest) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (store, key, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(store.delete(key));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBObjectStore::open_cursor_safe(
  self : Self,
  key : String,
) -> Result[IDBRequest, IDBError] {
  let mut result : Result[IDBRequest, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_open_cursor_safe(self, key, request => result = Ok(request), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_open_cursor_safe(
  store : IDBObjectStore,
  key : String,
  on_success : (IDBRequest) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (store, key, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(store.openCursor(key));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBObjectStore::open_cursor_all_safe(
  self : Self,
) -> Result[IDBRequest, IDBError] {
  let mut result : Result[IDBRequest, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_open_cursor_all_safe(self, request => result = Ok(request), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_open_cursor_all_safe(
  store : IDBObjectStore,
  on_success : (IDBRequest) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (store, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(store.openCursor());
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBRequest::cursor_safe(
  self : Self,
) -> Result[IDBCursorWithValue?, IDBError] {
  let mut result : Result[IDBCursorWithValue?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_request_cursor_safe(self, cursor => result = Ok(cursor.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_request_cursor_safe(
  request : IDBRequest,
  on_success : (@js.Nullable[IDBCursorWithValue]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (request, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(request.result ?? null);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBCursorWithValue::string_value_safe(
  self : Self,
) -> Result[String?, IDBError] {
  let mut result : Result[String?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_cursor_string_value_safe(self, value => result = Ok(value.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_cursor_string_value_safe(
  cursor : IDBCursorWithValue,
  on_success : (@js.Nullable[String]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (cursor, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(typeof cursor.value === "string" ? cursor.value : null);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBCursorWithValue::string_key_safe(
  self : Self,
) -> Result[String?, IDBError] {
  let mut result : Result[String?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_cursor_string_key_safe(self, key => result = Ok(key.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_cursor_string_key_safe(
  cursor : IDBCursorWithValue,
  on_success : (@js.Nullable[String]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (cursor, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(typeof cursor.key === "string" ? cursor.key : null);
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn IDBCursorWithValue::continue_safe(self : Self) -> Result[Unit, IDBError] {
  let mut result : Result[Unit, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_cursor_continue_safe(self, () => result = Ok(()), (error_name, code) => {
    result = Err({ name: error_name, code })
  })
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_cursor_continue_safe(
  cursor : IDBCursorWithValue,
  on_success : () -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (cursor, onSuccess, onError) => {
  #|   try {
  #|     cursor.continue();
  #|     onSuccess();
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn Storage::read_item_safe(
  self : Self,
  key : String,
) -> Result[String?, IDBError] {
  let mut result : Result[String?, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_storage_read_safe(self, key, value => result = Ok(value.to_option()), (
    error_name,
    code,
  ) => result = Err({ name: error_name, code }))
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_storage_read_safe(
  storage : Storage,
  key : String,
  on_success : (@js.Nullable[String]) -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (storage, key, onSuccess, onError) => {
  #|   try {
  #|     onSuccess(storage.getItem(key));
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }

///|
#cfg(target="js")
pub fn Storage::remove_item_safe(
  self : Self,
  key : String,
) -> Result[Unit, IDBError] {
  let mut result : Result[Unit, IDBError] = Err({
    name: "UnknownError",
    code: 0,
  })
  ffi_storage_remove_safe(self, key, () => result = Ok(()), (error_name, code) => {
    result = Err({ name: error_name, code })
  })
  result
}

///|
#cfg(target="js")
extern "js" fn ffi_storage_remove_safe(
  storage : Storage,
  key : String,
  on_success : () -> Unit,
  on_error : (String, Int) -> Unit,
) -> Unit =
  #| (storage, key, onSuccess, onError) => {
  #|   try {
  #|     storage.removeItem(key);
  #|     onSuccess();
  #|   } catch (error) {
  #|     onError(error?.name ?? "UnknownError", error?.code ?? 0);
  #|   }
  #| }
