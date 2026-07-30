///|
pub using @vdom {type Children, type Props, type VNode}

///|
#cfg(target="js")
using @cmd {trait Scheduler}

///|
#cfg(target="js")
using @queue {type Queue}

///|
/// The rendering pipeline will do the following step:
///
/// 1. view(model) -> newView  
///      compute new vdom from model
///
/// 2. reconcile(oldView, newView)
///      compare with the mounted tree and update the real DOM
#cfg(target="js")
pub(all) struct Sandbox {
  priv after_render_queue : Queue[(&Scheduler) -> Unit]
  priv msg_queue : Queue[(@slotmap.Id, @any.Any)]
  priv mut root_view : @duplix.Node[VNode]?
  priv mut drain_scheduled : Bool
  priv mut paint_scheduled : Bool
  priv mut mounted : @vdom.Mounted?
  mut mount : String
  hooks : @cmd.Hooks
}

///|
#cfg(target="js")
pub fn Sandbox::new() -> Sandbox {
  {
    msg_queue: Queue([]),
    root_view: None,
    mounted: None,
    hooks: { url_request: None, url_changed: None },
    paint_scheduled: false,
    drain_scheduled: false,
    mount: "",
    after_render_queue: Queue([]),
  }
}

///|
#cfg(target="js")
pub fn Sandbox::initialize(self : Self, vnode : @duplix.Node[VNode]) -> Unit {
  let element = @dom.document().get_element_by_id(self.mount).unwrap() // TODO: handle error

  // trigger a url_changed message 
  if self.hooks().url_changed is Some(hook) {
    hook(self, @dom.window().current_url())
  }

  self.root_view = Some(vnode)
  let vnode = self.root_view.unwrap().read()
  self.mounted = Some(@vdom.mount(element.as_node(), vnode, self))
}

///|
/// Schedules a drawing frame to be rendered on the next animation frame.
#cfg(target="js")
pub fn Sandbox::flush(self : Self) -> Unit {
  if !self.paint_scheduled {
    self.paint_scheduled = true
    @dom.window().request_animation_frame(fn(_) {
      if self.mounted is Some(mounted) {
        let vnode = self.root_view.unwrap().read()
        mounted.update(vnode)
      }
      self.paint_scheduled = false
      while self.after_render_queue.pop() is Some(f) {
        f(self)
      }
    })
    |> ignore
  }
}

///|
#cfg(target="js")
pub impl Scheduler for Sandbox with fn run_effect(self, kind, f) {
  match kind {
    Immediately => f(self)
    AfterRender => self.after_render_queue.push(f)
  }
}

///|
#cfg(target="js")
pub impl Scheduler for Sandbox with fn queue_message(self, path, msg) {
  self.msg_queue.push((path, msg))
}

///|
/// Processing all pending messages FIFO to update all relevant models
#cfg(target="js")
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
#cfg(target="js")
pub impl Scheduler for Sandbox with fn hooks(self) {
  self.hooks
}
