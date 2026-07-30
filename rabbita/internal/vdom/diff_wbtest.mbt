///|
#cfg(target="js")
struct DiffTestScheduler {}

///|
#cfg(target="js")
impl @cmd.Scheduler for DiffTestScheduler with fn run_effect(self, kind, effect) {
  ignore(kind)
  effect(self)
}

///|
#cfg(target="js")
impl @cmd.Scheduler for DiffTestScheduler with fn queue_message(
  self,
  path,
  message,
) {
  ignore((self, path, message))
}

///|
#cfg(target="js")
impl @cmd.Scheduler for DiffTestScheduler with fn drain_message(self) {
  ignore(self)
}

///|
#cfg(target="js")
impl @cmd.Scheduler for DiffTestScheduler with fn hooks(self) {
  ignore(self)
  { url_request: None, url_changed: None }
}

///|
#cfg(target="js")
extern "js" fn diff_test_element() -> @dom.Element =
  #| () => {
  #|   let createdHTMLElement = null
  #|   if (typeof globalThis.HTMLElement === "undefined") {
  #|     createdHTMLElement = class HTMLElement {}
  #|     globalThis.HTMLElement = createdHTMLElement
  #|   }
  #|   const element = Object.create(globalThis.HTMLElement.prototype)
  #|   Object.defineProperty(element, "style", {
  #|     configurable: true,
  #|     value: {
  #|       removeProperty: () => "",
  #|       setProperty: () => {},
  #|     },
  #|   })
  #|   element.__diffTestCreatedHTMLElement = createdHTMLElement
  #|   return element
  #| }

///|
#cfg(target="js")
extern "js" fn diff_test_cleanup(element : @dom.Element) -> Unit =
  #| element => {
  #|   const created = element.__diffTestCreatedHTMLElement
  #|   if (created && globalThis.HTMLElement === created) {
  #|     delete globalThis.HTMLElement
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn diff_test_event() -> @dom.Event = "() => ({})"

///|
#cfg(target="js")
test "diff replaces a render's composed handler without accumulating stale handlers" {
  let trace : Array[String] = []
  let old_handler : (@dom.Event, &@cmd.Scheduler) -> Unit = (_, _) => {
    trace.push("A")
    trace.push("B")
  }
  let new_handler : (@dom.Event, &@cmd.Scheduler) -> Unit = (_, _) => {
    trace.push("C")
    trace.push("D")
  }
  let old_props = Props::new(Map([]), Map([]), Map([]), { "click": old_handler })
  let slot = @ref.new(old_handler)
  let old : MountedProps = { props: old_props, slots: { "click": slot } }
  let new_props = Props::new(Map([]), Map([]), Map([]), { "click": new_handler })
  let scheduler = DiffTestScheduler::{  }
  (slot.val)(diff_test_event(), scheduler)
  assert_eq(trace.join(","), "A,B")
  let element = diff_test_element()
  let updated = diff_props(old, new_props, scheduler, element)
  diff_test_cleanup(element)
  guard updated.slots.get("click") is Some(updated_slot) else {
    fail("expected the existing click handler slot to be retained")
  }
  assert_true(physical_equal(slot, updated_slot))
  (updated_slot.val)(diff_test_event(), scheduler)
  assert_eq(trace.join(","), "A,B,C,D")
}
