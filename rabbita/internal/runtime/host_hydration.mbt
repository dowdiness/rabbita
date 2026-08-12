///|
struct HydrationHost {
  browser : BrowserHost
  transcript : Map[String, Array[Json]]
}

///|
priv suberror UnwrapNone

///|
pub fn HydrationHost::HydrationHost(builder : GraphBuilder) -> HydrationHost {
  let transcript = try {
    let element = @dom.document()
      .get_element_by_id(RABBITA_TRANSCRIPT_ID)
      .to_option()
      .unwrap_or_error(UnwrapNone)
    let text = element
      .get_property("textContent")
      .to_option()
      .unwrap_or_error(UnwrapNone)
    let json = @json.parse(text)
    guard json is Array(jsons) else { fail("") }
    let dict = Map([])
    for x in jsons {
      guard x is { "key": String(key), "value": Array(values), .. } else {
        fail("")
      }
      dict[key] = values.rev()
    }
    dict
  } catch {
    _ => Map([])
  }

  let host = HydrationHost::{
    browser: {
      task_queue: Queue([]),
      graph_output: None,
      document: None,
      url_request: _ => @cmd.none,
      url_changed: _ => @cmd.none,
      paint_scheduled: false,
      drain_scheduled: true,
      after_render_queue: Queue([]),
    },
    transcript,
  }

  let output = ambient_host.protect(Some(host), builder)
  host.browser.graph_output = Some(output)
  let url = @dom.window().current_url()
  let cmd = Context::inject_url_changed(host, url)
  Scheduler::queue_command(host, cmd)
  let root = output.read()
  host.browser.document = Some(
    @vdom.VDom::initialize_with_hydration(root, host),
  )
  host.browser.drain_scheduled = false
  host
}

///|
pub impl Host for HydrationHost with fn flush(self) {
  self.request_task()
}

///|
fn HydrationHost::request_task(host : Self) -> Unit {
  let self = host.browser
  guard !self.drain_scheduled else { return }
  self.drain_scheduled = true
  @dom.window().queue_microtask(() => {
    while self.task_queue.pop() is Some((op, extension)) {
      fn fallback() {
        try @cmd.invoke(@key.key, op, extension, self) catch {
          Unhandled => ()
        } noraise {
          None => ()
          Ready(cmd) => self.queue_command(cmd)
          Async(f) =>
            @js_async.Promise::from_async(() => {
              Scheduler::queue_command(self, f())
            })
            |> ignore
          AfterLayout(f) => self.after_render_queue.push(f)
          LegacyEffect(Immediately, f) => f(self)
          LegacyEffect(AfterRender, f) =>
            self.after_render_queue.push(() => {
              f(self)
              @cmd.none
            })
        }
      }
      try {
        let runner = @cmd.runner(host, op)
        let json = runner.describe(extension)
        let key = json.stringify()
        let values = host.transcript
          .get(key)
          .unwrap_or_error(@cmd.HydrateExn::Fallback)
        let json = values.pop().unwrap_or_error(@cmd.HydrateExn::Fallback)
        let cmd = runner.resume_(extension, json, host)
        self.queue_command(cmd)
      } catch {
        @cmd.Unhandled::Unhandled
        | @cmd.HydrateExn::Unhandled
        | @cmd.HydrateExn::Fallback => fallback()
        @cmd.HydrateExn::Skip | _ => ()
      }
    }
    self.drain_scheduled = false
    self.request_frame()
  })
}

///|
pub impl Host for HydrationHost with fn cleanup(self) {
  self.browser.cleanup()
}

///|
pub impl Scheduler for HydrationHost with fn queue_command(self, cmd) {
  self.browser.queue_command(cmd)
}

///|
pub impl Scheduler for HydrationHost with fn set_url_changed_injector(
  self,
  injector,
) {
  self.browser.set_url_changed_injector(injector)
}

///|
pub impl Scheduler for HydrationHost with fn set_url_request_injector(
  self,
  injector,
) {
  self.browser.set_url_request_injector(injector)
}

///|
pub impl Context for HydrationHost with fn get_origin(self) {
  self.browser.get_origin()
}

///|
pub impl Context for HydrationHost with fn inject_url_changed(self, url) {
  self.browser.inject_url_changed(url)
}

///|
pub impl Context for HydrationHost with fn inject_url_request(self, url) {
  self.browser.inject_url_request(url)
}
