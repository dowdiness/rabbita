///|
pub(open) trait Scheduler {
  fn add(Self, Cmd) -> Unit = _
  fn queue_command(Self, Cmd) -> Unit
  fn current_url(Self) -> String
  fn hooks(Self) -> Hooks
}

///|
pub(all) struct Hooks {
  mut url_request : Hook[String]?
  mut url_changed : Hook[String]?
}

///|
pub type Hook[Arg] = (Arg) -> Cmd

///|
impl Scheduler with fn add(self, cmd) {
  self.queue_command(cmd)
}
