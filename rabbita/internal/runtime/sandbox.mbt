///|
pub using @vdom {type Children, type Props, type VNode}

///|
using @cmd {trait Scheduler}

///|
using @queue {type Queue}

///|
/// The rendering pipeline will do the following step:
///
/// 1. view(model) -> newView  
///      compute new vdom from model
///
/// 2. reconcile(oldView, newView)
///      update the mounted render state
pub(all) struct Sandbox {
  priv mut root_view : @duplix.Node[VNode]?
  priv after_render_queue : Queue[() -> Cmd]
  priv task_queue : Queue[(@cmd.Op, @cmd.Extension)]
  mut spawn_bg : (async () -> Unit) -> Unit
  priv mut drain_scheduled : Bool
  priv mut paint_scheduled : Bool
  priv mut mounted : @vdom.Mounted?
  priv current_url : String
  hooks : @cmd.Hooks
}

///|
extenum @cmd.Extension += {
  Message(@slotmap.Id, @any.Any)
}

///|
let op : @cmd.Op = @cmd.Op()..on_invoke(extension => {
  match extension {
    Message(id, erased_msg) => {
      guard global_stores.get(id) is Some(store) else { None }
      LegacyEffect(Immediately, scheduler => {
        let cmd = (store.on_update)(scheduler, erased_msg)
        scheduler.queue_command(cmd)
      })
    }
    _ => raise Unhandled
  }
})

///|
pub fn Sandbox::new() -> Sandbox {
  {
    root_view: None,
    mounted: None,
    task_queue: Queue([]),
    spawn_bg: _ => (),
    current_url: "",
    hooks: { url_request: None, url_changed: None },
    paint_scheduled: false,
    drain_scheduled: true,
    after_render_queue: Queue([]),
  }
}

///|
pub fn Sandbox::initialize(
  self : Self,
  element_id : String,
  vnode : @duplix.Node[VNode],
) -> Unit {
  // Trigger a url_changed message after subscriptions have installed hooks.
  self.drain_scheduled = false
  if self.hooks().url_changed is Some(inject) {
    self.queue_command(inject(self.current_url()))
  }
  self.root_view = Some(vnode)
  let vnode = self.root_view.unwrap().read()
  self.mounted = Some(@vdom.mount(element_id, vnode, self))
}

///|
/// Schedules a drawing frame to be rendered on the next animation frame.
pub fn Sandbox::flush(self : Self) -> Unit {
  guard !self.paint_scheduled else { return }
  self.paint_scheduled = true
  request_frame(fn() {
    if self.mounted is Some(mounted) {
      let vnode = self.root_view.unwrap().read()
      mounted.update(vnode)
    }
    self.paint_scheduled = false
    while self.after_render_queue.pop() is Some(f) {
      let cmd = f()
      self.queue_command(cmd)
    }
  })
}

///|
pub fn Sandbox::drain_task(self : Self) -> Unit {
  guard !self.drain_scheduled else { return }
  self.drain_scheduled = true
  self.request_task(() => {
    while self.task_queue.pop() is Some((op, extension)) {
      try @cmd.invoke(@key.key, op, extension) catch {
        Unhandled => ()
      } noraise {
        None => ()
        Ready(cmd) => self.queue_command(cmd)
        Async(f) => (self.spawn_bg)(() => self.queue_command(f()))
        AfterLayout(f) => self.after_render_queue.push(f)
        LegacyEffect(Immediately, f) => f(self)
        LegacyEffect(AfterRender, f) =>
          self.after_render_queue.push(() => {
            f(self)
            @cmd.none
          })
      }
    }
    self.drain_scheduled = false
    self.flush()
  })
}

///|
#cfg(target="js")
fn request_frame(callback : () -> Unit) -> Unit {
  @dom.window().request_animation_frame(_ => callback()) |> ignore
}

///|
#cfg(not(target="js"))
fn request_frame(callback : () -> Unit) -> Unit {
  callback()
}

///|
#cfg(target="js")
fn Sandbox::request_task(_self : Sandbox, callback : () -> Unit) -> Unit {
  @dom.window().queue_microtask(callback)
}

///|
#cfg(not(target="js"))
fn Sandbox::request_task(_self : Sandbox, callback : () -> Unit) -> Unit {
  callback()
}

///|
/// Processing all pending messages FIFO to update all relevant models
// pub impl Scheduler for Sandbox with fn drain_message(self) {
// if !self.drain_scheduled {
//   self.drain_scheduled = true
//   while self.msg_queue.pop() is Some((id, erased_msg)) {

//   }
//   self.drain_scheduled = false
//   self.flush()
// }
// }

///|
pub impl Scheduler for Sandbox with fn queue_command(self, cmd) {
  let tasks = @cmd.flatten(@key.key, cmd)
  for task in tasks {
    self.task_queue.push(task)
  }
  self.drain_task()
}

///|
#cfg(not(target="js"))
pub impl Scheduler for Sandbox with fn current_url(self) {
  self.current_url
}

///|
#cfg(target="js")
pub impl Scheduler for Sandbox with fn current_url(self) {
  ignore(self.current_url)
  @dom.window().current_url()
}

///|
pub impl Scheduler for Sandbox with fn hooks(self) {
  self.hooks
}
