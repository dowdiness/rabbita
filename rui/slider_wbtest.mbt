///|
test "slider keyboard handles every arrow independent of orientation" {
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "ArrowUp"),
    Some(40),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "ArrowRight"),
    Some(40),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "ArrowDown"),
    Some(34),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "ArrowLeft"),
    Some(34),
  )
}

///|
test "slider keyboard supports large movement Home End and RTL" {
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, true, false, "ArrowRight"),
    Some(48),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "PageUp"),
    Some(48),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, false, "PageDown"),
    Some(26),
  )
  assert_eq(slider_key_value(37, 1, 97, 3, 11, false, false, "Home"), Some(1))
  assert_eq(slider_key_value(37, 1, 97, 3, 11, false, false, "End"), Some(97))
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, true, "ArrowRight"),
    Some(34),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, true, "ArrowLeft"),
    Some(40),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, true, "ArrowUp"),
    Some(40),
  )
  assert_eq(
    slider_key_value(37, 1, 97, 3, 11, false, true, "ArrowDown"),
    Some(34),
  )
  assert_eq(slider_key_value(37, 1, 97, 3, 11, false, false, "Escape"), None)
}

///|
test "slider large step preserves its own grid" {
  assert_eq(
    slider_key_value(20, 0, 100, 2, 5, false, false, "PageUp"),
    Some(25),
  )
  assert_eq(
    slider_key_value(25, 0, 100, 2, 5, false, false, "ArrowUp"),
    Some(28),
  )
  assert_eq(
    slider_key_value(96, 0, 97, 2, 13, true, false, "ArrowRight"),
    Some(97),
  )
  assert_eq(
    slider_key_value(1, 1, 97, 0, 11, false, false, "ArrowRight"),
    Some(2),
  )
}

///|
test "slider values normalize two and three thumbs" {
  assert_eq(slider_normalize_values([83, 24], 10, 90, 5, 2), [25, 85])
  assert_eq(slider_normalize_values([-9, 44, 113], 10, 90, 5, 1), [10, 45, 90])
  assert_eq(slider_normalize_values([], 10, 90, 5, 0), [10])
}

///|
test "slider thumb updates align and stop at constrained neighbours" {
  let values = [20, 50, 80]
  assert_eq(slider_set_thumb_value(values, 1, 76, 10, 90, 5, 2), [20, 70, 80])
  assert_eq(slider_set_thumb_value(values, 1, 24, 10, 90, 5, 2), [20, 30, 80])
  assert_eq(slider_set_thumb_value(values, 0, 87, 10, 90, 5, 2), [40, 50, 80])
  assert_eq(
    slider_thumb_key_value(values, 1, 10, 90, 5, 2, 13, false, false, "End"),
    Some(70),
  )
  assert_eq(
    slider_thumb_key_value(values, 1, 10, 90, 5, 2, 13, false, false, "Home"),
    Some(30),
  )
  assert_eq(
    slider_thumb_key_value(
      values, 2, 10, 90, 5, 2, 13, false, false, "ArrowDown",
    ),
    Some(75),
  )
  // Reject a large move that would violate a positive neighbour gap.
  assert_eq(
    slider_thumb_key_value(
      values, 1, 10, 90, 5, 2, 27, true, false, "ArrowRight",
    ),
    Some(50),
  )
  // With no requested gap, the same move clamps to the adjacent thumb.
  assert_eq(
    slider_thumb_key_value(
      values, 1, 10, 90, 5, 0, 47, true, false, "ArrowRight",
    ),
    Some(80),
  )
}

///|
#cfg(target="js")
extern "js" fn ffi_install_slider_pointer_fixture() -> Unit =
  #| () => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const listeners = {}
  #|   const fixture = globalThis.__ruiSliderPointerFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     EventTarget: globalThis.EventTarget,
  #|     hadEventTarget: own("EventTarget"),
  #|     Node: globalThis.Node,
  #|     hadNode: own("Node"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     HTMLInputElement: globalThis.HTMLInputElement,
  #|     hadHTMLInputElement: own("HTMLInputElement"),
  #|     Event: globalThis.Event,
  #|     hadEvent: own("Event"),
  #|     PointerEvent: globalThis.PointerEvent,
  #|     hadPointerEvent: own("PointerEvent"),
  #|     focused: -1,
  #|     inputIndex: -1,
  #|     commitIndex: -1,
  #|     listeners,
  #|   }
  #|   class EventTarget {}
  #|   class Node extends EventTarget {
  #|     constructor() { super(); this.nodeType = 1 }
  #|   }
  #|   class HTMLElement extends Node {}
  #|   class HTMLInputElement extends HTMLElement {}
  #|   class Event {
  #|     constructor(type, init = {}) {
  #|       this.type = type
  #|       this.bubbles = !!init.bubbles
  #|       this.defaultPrevented = false
  #|     }
  #|     preventDefault() { this.defaultPrevented = true }
  #|   }
  #|   class PointerEvent extends Event {
  #|     constructor(type, init = {}) {
  #|       super(type, init)
  #|       Object.assign(this, init)
  #|       this.button = init.button ?? 0
  #|       this.pointerId = init.pointerId ?? 0
  #|       this.clientX = init.clientX ?? 0
  #|       this.clientY = init.clientY ?? 0
  #|     }
  #|   }
  #|   Object.assign(globalThis, {
  #|     EventTarget, Node, HTMLElement, HTMLInputElement, Event, PointerEvent,
  #|   })
  #|   const style = () => ({
  #|     values: {},
  #|     setProperty(name, value) { this.values[name] = value },
  #|     getPropertyValue(name) { return this.values[name] || "" },
  #|     removeProperty(name) {
  #|       const value = this.values[name] || ""
  #|       delete this.values[name]
  #|       return value
  #|     },
  #|   })
  #|   const inputs = [20, 50, 80].map((value, index) => {
  #|     const input = new HTMLInputElement()
  #|     Object.assign(input, {
  #|       value: String(value),
  #|       style: style(),
  #|       focus: () => { fixture.focused = index },
  #|       hasAttribute: name => name === "disabled" ? false : false,
  #|       getAttribute: name => name === "aria-disabled" ? "" : "",
  #|       dispatchEvent: event => {
  #|         if (event.type === "input") fixture.inputIndex = index
  #|         if (event.type === "change") fixture.commitIndex = index
  #|         return true
  #|       },
  #|     })
  #|     return input
  #|   })
  #|   const root = new HTMLElement()
  #|   const attributes = {
  #|     "data-min": "10",
  #|     "data-max": "90",
  #|     "data-step": "5",
  #|     "data-min-steps-between-values": "2",
  #|     "data-orientation": "horizontal",
  #|     "data-disabled": "false",
  #|   }
  #|   Object.assign(root, {
  #|     getAttribute: name => attributes[name] || "",
  #|     hasAttribute: name => Object.prototype.hasOwnProperty.call(attributes, name),
  #|     querySelectorAll: selector => selector === '[data-slot="slider-control"]'
  #|       ? inputs
  #|       : [],
  #|     getBoundingClientRect: () => ({
  #|       left: 0, right: 100, top: 0, bottom: 20, width: 100, height: 20,
  #|     }),
  #|     addEventListener: (type, callback) => { listeners[type] = callback },
  #|     setPointerCapture(pointerId) { this.__capturedPointerId = pointerId },
  #|     releasePointerCapture(pointerId) {
  #|       if (this.__capturedPointerId === pointerId) delete this.__capturedPointerId
  #|     },
  #|     hasPointerCapture(pointerId) { return this.__capturedPointerId === pointerId },
  #|   })
  #|   fixture.inputs = inputs
  #|   fixture.root = root
  #|   globalThis.window = {
  #|     getComputedStyle: () => ({ getPropertyValue: () => "ltr" }),
  #|   }
  #|   globalThis.document = {
  #|     getElementById: id => id === "pointer-band-root" ? root : null,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_slider_pointer_fixture(client_x : Int) -> Unit =
  #| clientX => {
  #|   const fixture = globalThis.__ruiSliderPointerFixture
  #|   const event = new PointerEvent("pointerdown", {
  #|     button: 0,
  #|     pointerId: 7,
  #|     clientX,
  #|     clientY: 10,
  #|   })
  #|   fixture.listeners.pointerdown(event)
  #|   fixture.listeners.pointerup(event)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_lose_slider_pointer_fixture(client_x : Int) -> Unit =
  #| clientX => {
  #|   const fixture = globalThis.__ruiSliderPointerFixture
  #|   const event = new PointerEvent("pointerdown", {
  #|     button: 0,
  #|     pointerId: 8,
  #|     clientX,
  #|     clientY: 10,
  #|   })
  #|   fixture.listeners.pointerdown(event)
  #|   delete fixture.root.__capturedPointerId
  #|   fixture.listeners.lostpointercapture(event)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_slider_pointer_fixture_result(kind : Int) -> Int =
  #| kind => {
  #|   const fixture = globalThis.__ruiSliderPointerFixture
  #|   if (kind === 0) return fixture.focused
  #|   if (kind === 1) return fixture.inputIndex
  #|   if (kind === 2) return fixture.commitIndex
  #|   return -2
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_slider_pointer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSliderPointerFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadEventTarget) globalThis.EventTarget = fixture.EventTarget
  #|   else delete globalThis.EventTarget
  #|   if (fixture.hadNode) globalThis.Node = fixture.Node
  #|   else delete globalThis.Node
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   if (fixture.hadHTMLInputElement) {
  #|     globalThis.HTMLInputElement = fixture.HTMLInputElement
  #|   } else delete globalThis.HTMLInputElement
  #|   if (fixture.hadEvent) globalThis.Event = fixture.Event
  #|   else delete globalThis.Event
  #|   if (fixture.hadPointerEvent) globalThis.PointerEvent = fixture.PointerEvent
  #|   else delete globalThis.PointerEvent
  #|   delete globalThis.__ruiSliderPointerFixture
  #| }

///|
#cfg(target="js")
test "slider pointer selection targets the nearest first and middle thumbs" {
  ffi_install_slider_pointer_fixture()
  bind_slider_pointer("pointer-band")
  ffi_fire_slider_pointer_fixture(18)
  let first_focus = ffi_slider_pointer_fixture_result(0)
  let first_input = ffi_slider_pointer_fixture_result(1)
  let first_commit = ffi_slider_pointer_fixture_result(2)
  ffi_fire_slider_pointer_fixture(58)
  let middle_focus = ffi_slider_pointer_fixture_result(0)
  let middle_input = ffi_slider_pointer_fixture_result(1)
  let middle_commit = ffi_slider_pointer_fixture_result(2)
  ffi_lose_slider_pointer_fixture(31)
  let active_after_capture_loss = match ui_element_by_id("pointer-band-root") {
    Some(root) =>
      match slider_pointer_binding(root) {
        Some(binding) => binding.active_index
        None => -1
      }
    None => -2
  }
  ffi_restore_slider_pointer_fixture()
  assert_eq(first_focus, 0)
  assert_eq(first_input, 0)
  assert_eq(first_commit, 0)
  assert_eq(middle_focus, 1)
  assert_eq(middle_input, 1)
  assert_eq(middle_commit, 1)
  assert_eq(active_after_capture_loss, -1)
}
