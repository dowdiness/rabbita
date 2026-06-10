///|
fn log(tag : String, msg : String) -> Unit {
  @log.log(tag, msg)
}

///|
pub fn debug_log(tag : String, msg : String) -> Unit {
  log(tag, msg)
}
