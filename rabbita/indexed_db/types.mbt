///|
/// A handle to one IndexedDB database and object store.
pub struct Store {
  name : String
  version : Int
  store_name : String
} derive(Eq, Hash)

///|
/// Construct a store handle.
pub fn Store::Store(name : String, version : Int, store_name : String) -> Store {
  { name, version, store_name }
}

///|
pub impl @debug.Debug for Store with fn to_repr(_) {
  @debug.Repr::ctor("Store", [])
}

///|
/// Result of reading one record.
pub(all) enum Lookup {
  Missing
  Found(String)
  Unsupported
} derive(Eq, Debug)

///|
/// Read-side storage failure.
pub(all) suberror ReadError {
  Unavailable
  Failed(String, Int)
} derive(Eq, Debug)

///|
/// Write-side storage failure.
pub(all) suberror WriteError {
  Unavailable
  QuotaExceeded
  Failed(String, Int)
} derive(Eq, Debug)

///|
/// One cursor entry. Unsupported records are retained in their cursor position.
pub(all) enum Entry {
  StringRecord(String, String)
  UnsupportedValue(String)
  UnsupportedKey(Int)
} derive(Eq, Debug)

///|
/// An atomic string-store mutation.
pub(all) enum Mutation {
  Set(String, String)
  Delete(String)
} derive(Eq, Debug)
