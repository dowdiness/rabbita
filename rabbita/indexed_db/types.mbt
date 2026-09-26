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

///|
pub extend Entry with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Entry with Eq::{equal, not_equal}

///|
pub extend Lookup with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Lookup with Eq::{equal, not_equal}

///|
pub extend Mutation with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Mutation with Eq::{equal, not_equal}

///|
pub extend ReadError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ReadError with Eq::{equal, not_equal}

///|
pub extend Store with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Store with Eq::{equal, not_equal}

///|
pub extend Store with Hash::{hash, hash_combine}

///|
pub extend WriteError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend WriteError with Eq::{equal, not_equal}
