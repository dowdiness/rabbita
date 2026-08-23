///|
#cfg(target="js")
pub using @cmd {perform, attempt, effect}

///|
pub using @cmd {none, batch, delay, type Cmd}

///|
pub using @html {type Html}

///|
/// A running Rabbita application.
struct App {
  builder : () -> Val[Html]
}

///|
/// A handle that owns one mounted browser application.
///
/// Keep this value when the host has a shorter lifetime than the page. Calling
/// `unmount` synchronously stops Rabbita-managed subscriptions and queued
/// rendering, releases the mounted runtime, and removes its DOM while that DOM
/// still belongs to this mount.
pub struct MountedApp {
  priv cleanup : () -> Unit
}

///|
/// Unmounts this application. Repeated calls are no-ops.
///
/// If another application has already replaced this mount's DOM in the same
/// container, unmounting the stale handle still cleans its runtime but leaves
/// the replacement DOM unchanged. Effects already running outside Rabbita may
/// finish, but their returned commands are ignored after unmount.
#cfg(target="js")
pub fn MountedApp::unmount(self : Self) -> Unit {
  (self.cleanup)()
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
/// This initializes the runtime, schedules the first render flush, and returns
/// the handle that owns this particular mount. On JavaScript targets,
/// `element_id` identifies the DOM mount point. If routing is configured, the
/// current URL is also emitted on mount.
///
/// A later mount may replace the DOM in the same container. Retain each handle
/// until its runtime should stop, then call `MountedApp::unmount`. Page-lifetime
/// applications may explicitly ignore the returned handle.
#cfg(target="js")
pub fn App::mount(self : Self, element_id : String) -> MountedApp {
  let host = @runtime.BrowserHost(element_id~, () => {
    let output = (self.builder)()
    output.map(html => html.to_virtual_dom()).0
  })
  @runtime.Host::flush(host)
  { cleanup: () => @runtime.Host::cleanup(host) }
}

///|
#cfg(not(target="js"))
fn split_url(url : String) -> (String, String) raise {
  let { protocol, host, path, port, query, fragment } = @url.parse(url)
  let protocol = match protocol {
    Http => "http"
    Https => "https"
    Other(p) => p
  }
  let port = if port is Some(p) { ":\{p}" } else { "" }
  let query = if query is Some(q) { "?\{q}" } else { "" }
  let fragment = if fragment is Some(f) { "#\{f}" } else { "" }
  let origin = "\{protocol}://\{host}\{port}"
  let path = "/\{path}\{query}\{fragment}"
  (origin, path)
}

///|
/// Renders the application to an HTML string for the given URL.
///
/// The nodes in `head` are appended to the application's existing `<head>`
/// before the hydration transcript.
///
/// Throws `@async.TimeoutError` if rendering does not complete within `timeout`
/// milliseconds.
#cfg(not(target="js"))
#internal(experimental, "This API is unstable and may change in the future.")
pub async fn App::render(
  self : Self,
  url~ : String,
  head? : Array[Html] = [],
  timeout? : Int = 10_000,
) -> String {
  let (origin, path) = split_url(url)
  let host = @runtime.SSRHost(origin~, path~, () => {
    let output = (self.builder)()
    output.0.map(html => html.0)
  })
  let html = @async.with_timeout(timeout, () => {
    host.render_to_string(head.map(html => html.to_virtual_dom()))
  })
  defer host.cleanup()
  html
}

///|
#cfg(target="js")
#internal(experimental, "This API is unstable and may change in the future.")
pub fn App::hydrate(self : Self) -> Unit {
  let host = @runtime.HydrationHost(() => {
    let output = (self.builder)()
    output.0.map(x => x.to_virtual_dom())
  })
  @runtime.Host::flush(host)
}
