///|
struct Op {
  mut invoke : (Extension, &Context) -> OpCont[Cmd] raise Unhandled
  mut settle : (Extension, &Context) -> OpCont[(Json, Cmd)] raise Unhandled
  mut resume_ : (Extension, Json, &Context) -> Cmd raise HydrateExn
  mut describe : (Extension) -> Json raise Unhandled
  mut debug : (Extension) -> Repr raise Unhandled
}

///|
pub(all) enum OpCont[T] {
  None
  Ready(T)
  Async(async () -> T)
  AfterLayout(() -> T)
  LegacyEffect(EffectKind, (&Scheduler) -> Unit)
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
  settle: (_, _) => raise Unhandled,
  describe: _ => raise Unhandled,
  debug: _ => raise Unhandled,
  invoke: (_, _) => raise Unhandled,
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
  f : (Extension, Json, &Context) -> Cmd raise HydrateExn,
) -> Unit {
  self.resume_ = f
}

///|
pub fn Op::on_settle(
  self : Self,
  f : (Extension, &Context) -> OpCont[(Json, Cmd)] raise Unhandled,
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
  f : (Extension, &Context) -> OpCont[Cmd] raise Unhandled,
) -> Unit {
  let g = self.invoke
  self.invoke = (extension, context) => {
    f(extension, context) catch {
      Unhandled => g(extension, context)
    }
  }
}

///|
pub fn Op::request(self : Self, extension : Extension) -> Cmd {
  Invoke(self, extension)
}

///|
struct Runner(Op)

///|
pub fn Runner::invoke(
  runner : Self,
  extension : Extension,
  context : &Context,
) -> OpCont[Cmd] raise Unhandled {
  (runner.0.invoke)(extension, context)
}

///|
pub fn Runner::settle(
  runner : Runner,
  extension : Extension,
  context : &Context,
) -> OpCont[(Json, Cmd)] raise Unhandled {
  (runner.0.settle)(extension, context)
}

///|
pub fn Runner::resume_(
  runner : Runner,
  extension : Extension,
  value : Json,
  context : &Context,
) -> Cmd raise HydrateExn {
  (runner.0.resume_)(extension, value, context)
}

///|
pub fn Runner::describe(
  runner : Runner,
  extension : Extension,
) -> Json raise Unhandled {
  (runner.0.describe)(extension)
}

///|
#doc(hidden)
pub fn invoke(
  _ : @key.Key,
  op : Op,
  extension : Extension,
  context : &Context,
) -> OpCont[Cmd] raise Unhandled {
  (op.invoke)(extension, context)
}
