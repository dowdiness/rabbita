///|
#cfg(target="js")
using @queue {type Queue}

///|
/// The rendering pipeline will do the following step:
///
/// 1. view(model) -> newView  
///      compute new vdom from model
///
/// 2. diff(oldView, newView) -> patch
///      generate patches by comparing to old vdom
///
/// 3. mount(patch)
///      apply patches to real DOM
#cfg(target="js")
pub(all) struct Sandbox {
  priv after_render_queue : Queue[(&Scheduler) -> Unit]
  // priv msg_queue : Queue[(@common.Path, @cmd.Cmd)]
  // priv dirty_set : Queue[Id]
  priv root : @incremental.Dyn[VNode]
  priv mut drain_scheduled : Bool
  priv mut paint_scheduled : Bool
  priv mut inode : INode?
  priv captured_link_listener : @dom.Listener
  mut mount : String
  hooks : @cmd.Hooks
}

///|
pub fn[Model : Eq, Msg, Input] create_state_with_input(
  init : Model,
  input : @incremental.Dyn[Input],
  update : (Msg, Model, Input, @cmd.Emit[Msg]) -> (Model, @cmd.Cmd),
) -> (@incremental.Dyn[Model], @cmd.Emit[Msg]) {
  let model = @incremental.input(init)
  let mut emit = @cmd.make_emitter(@key.key, (_, _) => ())
  emit = @cmd.make_emitter(@key.key, (msg, scheduler) => {
    let input_val = @incremental.read(@key.key, input)
    let (new_model, cmd) = update(msg, model.get(), input_val, emit)
    model.set(new_model)
    scheduler.add(cmd)
  })
  (model.to_dyn(), emit)
}

///|
pub fn[Model : Eq, Msg] create_state(
  init : Model,
  update : (Msg, Model, @cmd.Emit[Msg]) -> (Model, @cmd.Cmd),
) -> (@incremental.Dyn[Model], @cmd.Emit[Msg]) {
  let model = @incremental.input(init)
  let mut emit = @cmd.make_emitter(@key.key, (_, _) => ())
  emit = @cmd.make_emitter(@key.key, (msg, scheduler) => {
    let (new_model, cmd) = update(msg, model.get(), emit)
    model.set(new_model)
    scheduler.add(cmd)
  })
  (model.to_dyn(), emit)
}

///|
#cfg(target="js")
pub fn Sandbox::new(root : @incremental.Dyn[VNode]) -> Sandbox {
  let mut sandbox : Sandbox? = None
  let captured_link_listener = fn(event : @dom.Event) {
    if event.to_mouse_event() is Some(mouse_event) &&
      sandbox is Some(sandbox) &&
      sandbox.hooks.url_request is Some(hook) &&
      !(mouse_event.get_meta_key() || mouse_event.get_ctrl_key()) {
      event.prevent_default()
      let href = event
        .current_target()
        .unwrap()
        .to_element()
        .unwrap()
        .get_property("href")
        .unwrap()

      hook(sandbox, href)
    }
  }
  sandbox = Some({
    // msg_queue: Queue([]),
    root,
    inode: None,
    hooks: { url_request: None, url_changed: None },
    paint_scheduled: false,
    drain_scheduled: false,
    mount: "",
    captured_link_listener,
    after_render_queue: Queue([]),
  })
  sandbox.unwrap()
}

///|
#cfg(target="js")
pub fn Sandbox::initialize(self : Self) -> Unit {
  let element = @dom.document().get_element_by_id(self.mount).unwrap() // TODO: handle error

  // trigger a url_changed message 
  if self.hooks().url_changed is Some(hook) {
    hook(self, @dom.window().current_url())
  }

  let vnode = @incremental.read(@key.key, self.root)
  let inode = vnode.insert(self, element.as_node(), null())
  self.inode = Some(inode)
}

///|
/// Schedules a drawing frame to be rendered on the next animation frame.
#cfg(target="js")
pub fn Sandbox::flush(self : Self) -> Unit {
  if !self.paint_scheduled {
    self.paint_scheduled = true
    @dom.window().request_animation_frame(fn(_) {
      if self.inode is Some(inode) {
        let end = inode.end()
        let parent = end.get_parent_node().unwrap()
        let next_sibling = end.get_next_sibling()
        let vnode = @incremental.read(@key.key, self.root)
        let inode = diff_node(inode, vnode, self, parent, next_sibling)
        self.inode = Some(inode)
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
pub impl Scheduler for Sandbox with fn queue_message(self, msg) {
  msg(self)
  // self.msg_queue.push((id, msg))
}

///|
/// Processing all pending messages FIFO to update all relevant models
#cfg(target="js")
pub impl Scheduler for Sandbox with fn drain_message(self) {
  if !self.drain_scheduled {
    self.drain_scheduled = true
    // while self.msg_queue.pop() is Some((path, _)) {
    //   let store = context.find(path)
    //   (store.step)()
    // }
    self.drain_scheduled = false
    self.flush()
  }
}

///|
#cfg(target="js")
pub impl Scheduler for Sandbox with fn hooks(self) {
  self.hooks
}
