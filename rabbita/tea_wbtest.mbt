///|
priv suberror DiffSubsTestPayload {
  DiffSubsTestPayload((String) -> Unit)
}

///|
struct DiffSubsTestScheduler {
  hooks : @cmd.Hooks
}

///|
impl @cmd.Scheduler for DiffSubsTestScheduler with run_effect(self, _kind, _f) {
  ignore(self)
}

///|
impl @cmd.Scheduler for DiffSubsTestScheduler with queue_message(
  self,
  _id,
  _send_message,
) {
  ignore(self)
}

///|
impl @cmd.Scheduler for DiffSubsTestScheduler with drain_message(self) {
  ignore(self)
}

///|
impl @cmd.Scheduler for DiffSubsTestScheduler with hooks(self) {
  self.hooks
}

///|
test "diff_subs updates tagger for preserved subscription keys" {
  let old_events = []
  let new_events = []
  let mut current_tagger : (String) -> Unit = _ => ()
  let loader = @sub.SubLoader(fn(payload, _scheduler) {
    match payload {
      DiffSubsTestPayload(tagger) => {
        current_tagger = tagger
        Some({
          unload: _ => (),
          update_tagger: payload => {
            match payload {
              DiffSubsTestPayload(new_tagger) => current_tagger = new_tagger
              _ => ()
            }
          },
        })
      }
      _ => None
    }
  })
  let scheduler : DiffSubsTestScheduler = {
    hooks: { url_request: None, url_changed: None },
  }
  let old_payload : Error = DiffSubsTestPayload(event => old_events.push(event))
  let new_payload : Error = DiffSubsTestPayload(event => new_events.push(event))
  let old_subs : Map[String, @sub.RunningSub] = {}
  let new_subs : Map[String, (Error, @sub.SubLoader)] = {}
  let running = loader(old_payload, scheduler).unwrap()
  old_subs["stable"] = running
  new_subs["stable"] = (new_payload, loader)
  let updated = diff_subs(old_subs, new_subs, scheduler)
  if updated.contains("stable") {
    current_tagger("event")
  }
  assert_eq(old_events.length(), 0)
  assert_eq(new_events.length(), 1)
}
