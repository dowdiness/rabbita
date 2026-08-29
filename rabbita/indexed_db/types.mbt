///|
/// One browser database and object store used by an IndexedDB binding.
pub struct Config {
  name : String
  version : Int
  store_name : String
} derive(Eq, Debug)

///|
/// Construct a database configuration. The version is passed unchanged to
/// `indexedDB.open` and store creation is performed by the binding's upgrade
/// handler.
pub fn Config::Config(
  name : String,
  version : Int,
  store_name : String,
) -> Config {
  { name, version, store_name }
}

///|
pub fn Config::name(self : Self) -> String {
  self.name
}

///|
pub fn Config::version(self : Self) -> Int {
  self.version
}

///|
pub fn Config::store_name(self : Self) -> String {
  self.store_name
}

///|
/// Result of a string read from one IndexedDB object-store key.
pub(all) enum ReadResult {
  Missing
  Loaded(String)
  Unavailable
  Failed
} derive(Eq, Debug)

///|
/// One string-store mutation executed as part of an atomic transaction.
pub(all) enum Mutation {
  Put(String, String)
  Delete(String)
} derive(Eq, Debug)

///|
/// Result of a complete string replacement in IndexedDB.
pub(all) enum WriteResult {
  Stored
  Unavailable
  QuotaExceeded
  Failed
} derive(Eq, Debug)

///|
/// One entry observed while scanning an IndexedDB object store.
pub(all) enum ScanEntry {
  StringRecord(String, String)
  UnsupportedValue(String)
  /// A non-string key at the given zero-based cursor position.
  UnsupportedKey(Int)
} derive(Eq, Debug)

///|
/// Result of scanning every record in one IndexedDB object store.
pub(all) enum ScanResult {
  Scanned(Array[ScanEntry])
  Unavailable
  Failed
} derive(Eq, Debug)
