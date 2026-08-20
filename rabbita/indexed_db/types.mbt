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
/// Result of a complete string replacement in IndexedDB.
pub(all) enum WriteResult {
  Stored
  Unavailable
  QuotaExceeded
  Failed
} derive(Eq, Debug)
