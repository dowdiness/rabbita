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
  priv after_render_queue : Queue[(&Scheduler) -> Unit]
  priv msg_queue : Queue[(@slotmap.Id, @any.Any)]
  priv mut root_view : @duplix.Node[VNode]?
  priv mut drain_scheduled : Bool
  priv mut paint_scheduled : Bool
  priv mut mounted : @vdom.Mounted?
  hooks : @cmd.Hooks
}

///|
pub fn Sandbox::new() -> Sandbox {
  {
    msg_queue: Queue([]),
    root_view: None,
    mounted: None,
    hooks: { url_request: None, url_changed: None },
    paint_scheduled: false,
    drain_scheduled: false,
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
  if self.hooks().url_changed is Some(hook) {
    hook(self, current_url())
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
      f(self)
    }
  })
}

///|
#cfg(target="js")
fn current_url() -> String {
  @dom.window().current_url()
}

///|
#cfg(not(target="js"))
fn current_url() -> String {
  ""
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
pub impl Scheduler for Sandbox with fn run_effect(self, kind, f) {
  match kind {
    Immediately => f(self)
    AfterRender => self.after_render_queue.push(f)
  }
}

///|
pub impl Scheduler for Sandbox with fn queue_message(self, path, msg) {
  self.msg_queue.push((path, msg))
}

///|
/// Processing all pending messages FIFO to update all relevant models
pub impl Scheduler for Sandbox with fn drain_message(self) {
  if !self.drain_scheduled {
    self.drain_scheduled = true
    while self.msg_queue.pop() is Some((id, erased_msg)) {
      guard global_stores.get(id) is Some(store) else { continue }
      (store.on_update)(self, erased_msg)
    }
    self.drain_scheduled = false
    self.flush()
  }
}

///|
pub impl Scheduler for Sandbox with fn hooks(self) {
  self.hooks
}
