///|
struct Op {
  mut inovke : (Extension, &Scheduler) -> Unit raise Unhandled
  mut describe : (Extension) -> Json raise Unhandled
  mut settle : (Extension, Settle, &Scheduler) -> Unit raise Unhandled
  mut resume_ : (Extension, Json, &Scheduler) -> Unit raise HydrateExn
  mut debug : (Extension) -> Repr raise Unhandled
}

///|
pub(all) suberror Unhandled

///|
pub(all) suberror HydrateExn {
  Unhandled
  Fallback
  Skip
}

///|
pub(all) extenum Extension {}

///|
let default_handler : Op = {
  resume_: (_, _, _) => raise Unhandled,
  settle: (_, _, _) => raise Unhandled,
  describe: _ => raise Unhandled,
  debug: _ => raise Unhandled,
  inovke: (_, _) => raise Unhandled,
}

///|
pub fn Op::Op() -> Self {
  // copy the handler
  { ..default_handler }
}

///|
pub impl Debug for Cmd with fn to_repr(cmd) {
  match cmd {
    Batch(cmds) => Repr::array(cmds.map(Debug::to_repr))
    Invoke(op, extension) =>
      (op.debug)(extension) catch {
        Unhandled => Repr::omitted()
      }
    Effect(_, _) | Message(_, _) | LegacyMessage(_) => Repr::omitted()
  }
}

///|
fn[A, B] wrap_hook(
  f : (A) -> B raise Unhandled,
  g : (A) -> B raise Unhandled,
) -> (A) -> B raise Unhandled {
  a => f(a) catch { Unhandled => g(a) }
}

///|
pub type Settle = (Json) -> Unit

///|
pub fn Op::on_resume(
  self : Self,
  f : (Extension, Json, &Scheduler) -> Unit raise HydrateExn,
) -> Unit {
  self.resume_ = f
}

///|
pub fn Op::on_settle(
  self : Self,
  f : (Extension, Settle, &Scheduler) -> Unit raise Unhandled,
) -> Unit {
  self.settle = f
}

///|
pub fn Op::on_describe(
  self : Self,
  describe : (Extension) -> Json raise Unhandled,
) -> Unit {
  self.describe = describe
}

///|
pub fn Op::on_debug(
  self : Self,
  f : (Extension) -> Repr raise Unhandled,
) -> Unit {
  self.debug = wrap_hook(f, self.debug)
}

///|
pub fn Op::on_invoke(
  self : Self,
  f : (Extension, &Scheduler) -> Unit raise Unhandled,
) -> Unit {
  let g = self.inovke
  self.inovke = (a, b) => f(a, b) catch { Unhandled => g(a, b) }
}

///|
pub fn Op::request(self : Self, extension : Extension) -> Cmd {
  Invoke(self, extension)
}
