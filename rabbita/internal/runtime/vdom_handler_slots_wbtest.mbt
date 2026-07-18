///|
#cfg(target="js")
extern "js" fn vdom_handler_slot_test_element() -> @dom.Element =
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
  #|   element.__vdomHandlerSlotCreatedHTMLElement = createdHTMLElement
  #|   return element
  #| }

///|
#cfg(target="js")
extern "js" fn vdom_handler_slot_test_cleanup(element : @dom.Element) -> Unit =
  #| element => {
  #|   const created = element.__vdomHandlerSlotCreatedHTMLElement
  #|   if (created && globalThis.HTMLElement === created) {
  #|     delete globalThis.HTMLElement
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn vdom_handler_slot_test_event() -> @dom.Event = "() => ({})"

///|
#cfg(target="js")
test "vdom replaces a render's composed handler without accumulating stale handlers" {
  let trace : Array[String] = []
  let old_render_handler : (Event, &Scheduler) -> Unit = (_, _) => {
    trace.push("A")
    trace.push("B")
  }
  let new_render_handler : (Event, &Scheduler) -> Unit = (_, _) => {
    trace.push("C")
    trace.push("D")
  }
  let old = Props::new(Map([]), Map([]), Map([]), {
    "click": old_render_handler,
  })
  let slot = @ref.new(old_render_handler)
  old.slots["click"] = slot
  let new = Props::new(Map([]), Map([]), Map([]), {
    "click": new_render_handler,
  })
  let sandbox = Sandbox::new()
  (slot.val)(vdom_handler_slot_test_event(), sandbox)
  assert_eq(trace.join(","), "A,B")
  let element = vdom_handler_slot_test_element()
  diff_props(old, new, sandbox, element)
  vdom_handler_slot_test_cleanup(element)
  guard new.slots.get("click") is Some(updated_slot) else {
    fail("expected the existing click handler slot to be retained")
  }
  assert_true(physical_equal(slot, updated_slot))
  (updated_slot.val)(vdom_handler_slot_test_event(), sandbox)
  assert_eq(trace.join(","), "A,B,C,D")
}
