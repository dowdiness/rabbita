///|
pub(open) trait Context {
  fn get_current_url(Self) -> String
  fn inject_url_changed(Self, String) -> Cmd
  fn inject_url_request(Self, String) -> Cmd
}

///|
pub(open) trait Scheduler: Context {
  fn add(Self, Cmd) -> Unit = _
  fn queue_command(Self, Cmd) -> Unit
  fn set_url_changed_injector(Self, Injector[String]) -> Unit
  fn set_url_request_injector(Self, Injector[String]) -> Unit
}

///|
pub(open) trait Host: Scheduler {
  fn flush(Self) -> Unit
  fn cleanup(Self) -> Unit
}

///|
pub extend &Scheduler with Context::{
  get_current_url,
  inject_url_changed,
  inject_url_request,
}

///|
impl Scheduler with fn add(self, cmd) {
  self.queue_command(cmd)
}

///|
pub fn runner(_ : &Host, op : Op) -> Runner {
  Runner(op)
}

///|
pub(all) struct Injector[Arg]((Arg) -> Cmd)
