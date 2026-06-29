///|
pub(open) trait Scheduler {
  fn run_effect(Self, EffectKind, OnExecute) -> Unit
  fn queue_message(Self, OnExecute) -> Unit
  fn drain_message(Self) -> Unit
  fn add(Self, Cmd) -> Unit = _
  fn hooks(Self) -> Hooks
}

///|
pub(all) struct Hooks {
  mut url_request : Hook[String]?
  mut url_changed : Hook[String]?
}

///|
pub type Hook[Arg] = (&Scheduler, Arg) -> Unit

///|
impl Scheduler with fn add(self, cmd) {
  fn go(cmd) {
    match cmd {
      Batch(xs) => xs.each(x => go(x))
      Effect(k, f) => self.run_effect(k, f)
      Message(f) => self.queue_message(f)
    }
  }
  go(cmd)
  self.drain_message()
}
