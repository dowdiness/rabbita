///|
#cfg(target="js")
pub using @cmd {perform, attempt, effect}

///|
pub using @cmd {delay}

///|
pub using @cmd {none, batch}

///|
pub type Cmd = @cmd.Cmd

///|
pub using @html {type Html}

///|
/// A running Rabbita application.
struct App {
  builder : () -> Val[Html]
}

///|
/// Creates an application from a root component builder.
///
/// The builder runs when the app is mounted and must return its root
/// incremental HTML value. Use `Val::map`, `Val::switch`, and `Val::assoc` to
/// express subsequent changes, then call `App::mount` to start the app.
pub fn new(builder : () -> Val[Html]) -> App {
  { builder, }
}

///|
/// Creates an application using an Elm-style model, update, and view.
///
/// This is a convenience wrapper around `create_state` and `new`. Each emitted
/// message updates the model, schedules the returned command, and refreshes the
/// optional subscriptions.
pub fn[Model : Eq, Msg] elmish(
  model~ : Model,
  view~ : (Model, Emit[Msg]) -> Html,
  update~ : (Model, Msg, Emit[Msg]) -> (Model, Cmd),
  subscriptions? : (Model, Emit[Msg]) -> @sub.Sub,
) -> App {
  fn builder() {
    let (model, emit) = create_state(model, update~, subscriptions?)
    model.map(model => view(model, emit))
  }
  { builder, }
}

///|
/// Mount the app.
///
/// This initializes the runtime and schedules the first render flush.
/// On JavaScript targets, `element_id` identifies the DOM mount point. If
/// routing is configured, the current URL is also emitted on mount.
#cfg(target="js")
pub fn App::mount(self : Self, element_id : String) -> Unit {
  let sandbox = @runtime.Sandbox::new()
  sandbox.spawn_bg = fn(task) { @js_async.Promise::from_async(task) |> ignore }

  let output = ambient_graph.protect(Some(Graph(sandbox)), self.builder)
  let vnode = output.map(html => html.0)
  sandbox.initialize(vnode.0, target_element_id=element_id, url="")
  sandbox.drain_task()
  sandbox.flush()
}

///|
#cfg(not(target="js"))
pub async fn App::render(self : Self, url~ : String) -> String {
  let sandbox = @runtime.Sandbox::new()
  let output = ambient_graph.protect(Some(Graph(sandbox)), self.builder)
  @async.with_task_group(group => {
    sandbox.spawn_bg = fn(task) { group.spawn_bg(task) }
    sandbox.initialize(output.0.map(html => html.0), url~)
    sandbox.drain_task()
  })
  sandbox.render_hydrate_html().unwrap()
}

///|
#cfg(target="js")
pub fn App::hydrate(self : Self) -> Unit {
  let sandbox = @runtime.Sandbox::new()
  let output = ambient_graph.protect(Some(Graph(sandbox)), self.builder)
  sandbox.spawn_bg = fn(task) { @js_async.Promise::from_async(task) |> ignore }
  sandbox.initialize_with_hydration(
    output.0.map(x => x.to_virtual_dom()),
    url="",
  )
  sandbox.drain_task()
  sandbox.flush()
}
