///|
#cfg(target="js")
extern "js" fn ffi_install_carousel_pointer_fixture(rtl : Bool) -> Unit =
  #| rtl => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const values = new Map([
  #|     ["transform", "original-transform"],
  #|     ["transition", "original-transition"],
  #|   ])
  #|   const style = {
  #|     getPropertyValue: key => values.get(key) ?? "",
  #|     setProperty: (key, value) => { values.set(key, String(value)) },
  #|     removeProperty: key => {
  #|       const value = values.get(key) ?? ""
  #|       values.delete(key)
  #|       return value
  #|     },
  #|   }
  #|   const listeners = {}
  #|   const fixture = globalThis.__ruiCarouselPointerFixture = {
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     EventTarget: globalThis.EventTarget,
  #|     hadEventTarget: own("EventTarget"),
  #|     Node: globalThis.Node,
  #|     hadNode: own("Node"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     PointerEvent: globalThis.PointerEvent,
  #|     hadPointerEvent: own("PointerEvent"),
  #|     values,
  #|     listeners,
  #|     timeouts: [],
  #|     captures: 0,
  #|     releases: 0,
  #|   }
  #|   class EventTarget {}
  #|   class Node extends EventTarget {
  #|     constructor() { super(); this.nodeType = 1 }
  #|   }
  #|   class HTMLElement extends Node {}
  #|   class PointerEvent {
  #|     constructor(init) { Object.assign(this, init) }
  #|   }
  #|   Object.assign(globalThis, { EventTarget, Node, HTMLElement, PointerEvent })
  #|   const track = new HTMLElement()
  #|   track.style = style
  #|   const root = new HTMLElement()
  #|   Object.assign(root, {
  #|     dataset: {
  #|       slot: "carousel",
  #|       count: "3",
  #|       loop: "false",
  #|       maxSnapIndex: "2",
  #|     },
  #|     getAttribute(name) {
  #|       const key = name.replace(/^data-/, "").replace(/-([a-z])/g, (_, c) => c.toUpperCase())
  #|       return this.dataset[key] ?? ""
  #|     },
  #|   })
  #|   const viewport = new HTMLElement()
  #|   Object.assign(viewport, {
  #|     style: {
  #|       getPropertyValue: key => values.get(`viewport:${key}`) ?? "",
  #|       setProperty: (key, value) => { values.set(`viewport:${key}`, String(value)) },
  #|       removeProperty: key => {
  #|         const name = `viewport:${key}`
  #|         const value = values.get(name) ?? ""
  #|         values.delete(name)
  #|         return value
  #|       },
  #|     },
  #|     dataset: {},
  #|     clientWidth: 300,
  #|     clientHeight: 240,
  #|     querySelector: selector => selector === '[data-slot="carousel-track"]' ? track : null,
  #|     closest: selector => selector === '[data-slot="carousel"]' ? root : null,
  #|     setAttribute(name, value) {
  #|       if (name === "data-dragging") this.dataset.dragging = value
  #|     },
  #|     removeAttribute(name) {
  #|       if (name === "data-dragging") delete this.dataset.dragging
  #|     },
  #|     setPointerCapture(pointerId) {
  #|       this.__capturedPointerId = pointerId
  #|       fixture.captures += 1
  #|     },
  #|     releasePointerCapture(pointerId) {
  #|       if (this.__capturedPointerId !== pointerId) return
  #|       delete this.__capturedPointerId
  #|       fixture.releases += 1
  #|     },
  #|     hasPointerCapture(pointerId) { return this.__capturedPointerId === pointerId },
  #|     addEventListener: (type, callback, options) => {
  #|       const capture = typeof options === "boolean" ? options : !!options?.capture
  #|       listeners[`${type}:${capture}`] = callback
  #|     },
  #|     removeEventListener: (type, callback, options) => {
  #|       const capture = typeof options === "boolean" ? options : !!options?.capture
  #|       const key = `${type}:${capture}`
  #|       if (listeners[key] === callback) delete listeners[key]
  #|     },
  #|   })
  #|   fixture.viewport = viewport
  #|   fixture.track = track
  #|   fixture.root = root
  #|   globalThis.window = {
  #|     getComputedStyle: () => ({
  #|       getPropertyValue: name => name === "direction" ? (rtl ? "rtl" : "ltr") : "",
  #|     }),
  #|     setTimeout(callback) {
  #|       fixture.timeouts.push(callback)
  #|       return fixture.timeouts.length
  #|     },
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_event(
  x : Int,
  y : Int,
  time : Int,
  button : Int,
  interactive : Bool,
) -> @dom.MouseEvent =
  #| (x, y, time, button, interactive) => {
  #|   const fixture = globalThis.__ruiCarouselPointerFixture
  #|   const target = new HTMLElement()
  #|   target.closest = () => interactive ? target : null
  #|   return new PointerEvent({
  #|     currentTarget: fixture.viewport,
  #|     target,
  #|     clientX: x,
  #|     clientY: y,
  #|     timeStamp: time,
  #|     pointerId: 7,
  #|     pointerType: "touch",
  #|     isPrimary: true,
  #|     button,
  #|     defaultPrevented: false,
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_carousel_keyboard_fixture_event(
  key : String,
  rtl : Bool,
  modified : Bool,
  interactive : Bool,
) -> @dom.KeyboardEvent =
  #| (key, rtl, modified, interactive) => {
  #|   globalThis.window.getComputedStyle = () => ({
  #|     getPropertyValue: name => name === "direction" ? (rtl ? "rtl" : "ltr") : "",
  #|   })
  #|   const currentTarget = new HTMLElement()
  #|   const target = new HTMLElement()
  #|   target.closest = () => interactive ? target : null
  #|   return {
  #|     key,
  #|     altKey: modified,
  #|     ctrlKey: false,
  #|     metaKey: false,
  #|     shiftKey: false,
  #|     currentTarget,
  #|     target,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_transform() -> String =
  #| () => globalThis.__ruiCarouselPointerFixture.values.get("transform") ?? ""

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_dragging() -> Bool =
  #| () => globalThis.__ruiCarouselPointerFixture.viewport.dataset.dragging === "true"

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_captures() -> Int =
  #| () => globalThis.__ruiCarouselPointerFixture.captures

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_releases() -> Int =
  #| () => globalThis.__ruiCarouselPointerFixture.releases

///|
#cfg(target="js")
extern "js" fn ffi_carousel_pointer_fixture_element(kind : Int) -> @dom.Element =
  #| kind => {
  #|   const fixture = globalThis.__ruiCarouselPointerFixture
  #|   if (kind === 0) return fixture.root
  #|   if (kind === 1) return fixture.viewport
  #|   return fixture.track
  #| }

///|
#cfg(target="js")
fn carousel_pointer_fixture_has_state() -> Bool {
  carousel_pointer_state(ffi_carousel_pointer_fixture_element(1)) is Some(_)
}

///|
#cfg(target="js")
extern "js" fn ffi_configure_carousel_pointer_root(
  loop_ : Bool,
  max_index : Int,
) -> Unit =
  #| (loop, maxIndex) => {
  #|   const fixture = globalThis.__ruiCarouselPointerFixture
  #|   fixture.root.dataset.loop = String(loop)
  #|   fixture.root.dataset.maxSnapIndex = String(maxIndex)
  #| }

///|
#cfg(target="js")
fn configure_carousel_pointer_measurement(
  offset : Int,
  loop_ : Bool,
  max_index : Int,
) -> Unit {
  ffi_configure_carousel_pointer_root(loop_, max_index)
  let root = ffi_carousel_pointer_fixture_element(0)
  let viewport = ffi_carousel_pointer_fixture_element(1)
  let track = ffi_carousel_pointer_fixture_element(2)
  carousel_layout_states.push({
    root,
    viewport,
    track,
    items: [],
    notify: _ => (),
    previous_index: None,
    offset: Some(offset.to_double()),
    reported_max: None,
    observer: None,
    transition_generation: 0,
  })
}

///|
#cfg(target="js")
extern "js" fn ffi_fire_carousel_suppressed_click() -> Bool =
  #| () => {
  #|   const fixture = globalThis.__ruiCarouselPointerFixture
  #|   const listener = fixture.listeners["click:true"]
  #|   if (!listener) return false
  #|   const event = {
  #|     prevented: false,
  #|     stopped: false,
  #|     preventDefault() { this.prevented = true },
  #|     stopPropagation() { this.stopped = true },
  #|   }
  #|   listener(event)
  #|   return event.prevented && event.stopped
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_carousel_pointer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiCarouselPointerFixture
  #|   if (!fixture) return
  #|   for (const callback of fixture.timeouts) callback()
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadEventTarget) globalThis.EventTarget = fixture.EventTarget
  #|   else delete globalThis.EventTarget
  #|   if (fixture.hadNode) globalThis.Node = fixture.Node
  #|   else delete globalThis.Node
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   if (fixture.hadPointerEvent) globalThis.PointerEvent = fixture.PointerEvent
  #|   else delete globalThis.PointerEvent
  #|   delete globalThis.__ruiCarouselPointerFixture
  #| }

///|
#cfg(target="js")
test "carousel pointer drag advances LTR and suppresses the release click" {
  ffi_install_carousel_pointer_fixture(false)
  let start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let drag_move = ffi_carousel_pointer_fixture_event(60, 103, 100, 0, false)
  let finish = ffi_carousel_pointer_fixture_event(60, 103, 300, 0, false)
  assert_true(carousel_pointer_start(start, "horizontal", 1, true, true))
  assert_eq(ffi_carousel_pointer_fixture_captures(), 1)
  assert_true(carousel_pointer_move(drag_move))
  assert_true(ffi_carousel_pointer_fixture_dragging())
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(calc(-100% + -90px),0,0)",
  )
  assert_eq(carousel_pointer_end(finish), 1)
  assert_eq(ffi_carousel_pointer_fixture_transform(), "original-transform")
  assert_eq(ffi_carousel_pointer_fixture_releases(), 1)
  assert_true(!carousel_pointer_fixture_has_state())
  assert_true(ffi_fire_carousel_suppressed_click())
  ffi_restore_carousel_pointer_fixture()
}

///|
#cfg(target="js")
test "carousel pointer drag follows RTL and vertical logical direction" {
  ffi_install_carousel_pointer_fixture(true)
  let rtl_start = ffi_carousel_pointer_fixture_event(100, 100, 0, 0, false)
  let rtl_move = ffi_carousel_pointer_fixture_event(190, 100, 100, 0, false)
  let rtl_finish = ffi_carousel_pointer_fixture_event(190, 100, 300, 0, false)
  assert_true(carousel_pointer_start(rtl_start, "horizontal", 1, true, true))
  assert_true(carousel_pointer_move(rtl_move))
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(calc(100% + 90px),0,0)",
  )
  assert_eq(carousel_pointer_end(rtl_finish), 1)
  ffi_restore_carousel_pointer_fixture()

  ffi_install_carousel_pointer_fixture(false)
  let vertical_start = ffi_carousel_pointer_fixture_event(100, 150, 0, 0, false)
  let vertical_move = ffi_carousel_pointer_fixture_event(102, 70, 100, 0, false)
  let vertical_finish = ffi_carousel_pointer_fixture_event(
    102, 70, 300, 0, false,
  )
  assert_true(carousel_pointer_start(vertical_start, "vertical", 1, true, true))
  assert_true(carousel_pointer_move(vertical_move))
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(0,calc(-100% + -80px),0)",
  )
  assert_eq(carousel_pointer_end(vertical_finish), 1)
  ffi_restore_carousel_pointer_fixture()
}

///|
#cfg(target="js")
test "carousel pointer drag respects threshold boundaries cancellation and inputs" {
  ffi_install_carousel_pointer_fixture(false)
  let small_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let small_move = ffi_carousel_pointer_fixture_event(147, 100, 100, 0, false)
  let small_finish = ffi_carousel_pointer_fixture_event(147, 100, 300, 0, false)
  assert_true(carousel_pointer_start(small_start, "horizontal", 1, true, true))
  assert_true(!carousel_pointer_move(small_move))
  assert_eq(carousel_pointer_end(small_finish), 0)
  ffi_restore_carousel_pointer_fixture()

  ffi_install_carousel_pointer_fixture(false)
  let edge_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let edge_move = ffi_carousel_pointer_fixture_event(50, 100, 100, 0, false)
  let edge_finish = ffi_carousel_pointer_fixture_event(50, 100, 300, 0, false)
  assert_true(carousel_pointer_start(edge_start, "horizontal", 2, true, false))
  assert_true(carousel_pointer_move(edge_move))
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(calc(-200% + -35px),0,0)",
  )
  assert_eq(carousel_pointer_end(edge_finish), 2)
  ffi_restore_carousel_pointer_fixture()

  ffi_install_carousel_pointer_fixture(false)
  let cancel_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let cancel_move = ffi_carousel_pointer_fixture_event(50, 100, 100, 0, false)
  assert_true(carousel_pointer_start(cancel_start, "horizontal", 1, true, true))
  assert_true(carousel_pointer_move(cancel_move))
  carousel_pointer_cancel(cancel_move)
  assert_true(!carousel_pointer_fixture_has_state())
  assert_eq(ffi_carousel_pointer_fixture_transform(), "original-transform")
  ffi_restore_carousel_pointer_fixture()

  ffi_install_carousel_pointer_fixture(false)
  let input_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, true)
  assert_true(!carousel_pointer_start(input_start, "horizontal", 1, true, true))
  ffi_restore_carousel_pointer_fixture()
}

///|
#cfg(target="js")
test "carousel pointer drag uses measured offsets and resists an uncloned loop edge" {
  ffi_install_carousel_pointer_fixture(false)
  configure_carousel_pointer_measurement(-105, false, 2)
  let measured_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let measured_move = ffi_carousel_pointer_fixture_event(
    100, 100, 100, 0, false,
  )
  let measured_finish = ffi_carousel_pointer_fixture_event(
    100, 100, 300, 0, false,
  )
  assert_true(
    carousel_pointer_start(measured_start, "horizontal", 1, true, true),
  )
  assert_true(carousel_pointer_move(measured_move))
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(calc(-105px + -50px),0,0)",
  )
  assert_eq(carousel_pointer_end(measured_finish), 1)
  ffi_restore_carousel_pointer_fixture()

  ffi_install_carousel_pointer_fixture(false)
  configure_carousel_pointer_measurement(-210, true, 2)
  let loop_start = ffi_carousel_pointer_fixture_event(150, 100, 0, 0, false)
  let loop_move = ffi_carousel_pointer_fixture_event(50, 100, 100, 0, false)
  let loop_finish = ffi_carousel_pointer_fixture_event(50, 100, 300, 0, false)
  assert_true(carousel_pointer_start(loop_start, "horizontal", 2, true, true))
  assert_true(carousel_pointer_move(loop_move))
  assert_eq(
    ffi_carousel_pointer_fixture_transform(),
    "translate3d(calc(-210px + -35px),0,0)",
  )
  assert_eq(carousel_pointer_end(loop_finish), 1)
  ffi_restore_carousel_pointer_fixture()
}

///|
#cfg(target="js")
test "carousel keyboard stepping preserves orientation RTL and editable guards" {
  ffi_install_carousel_pointer_fixture(false)
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowRight", false, false, false),
      "horizontal",
    ),
    1,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowLeft", false, false, false),
      "horizontal",
    ),
    -1,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowRight", true, false, false),
      "horizontal",
    ),
    -1,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowUp", false, false, false),
      "vertical",
    ),
    -1,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowDown", false, false, false),
      "vertical",
    ),
    1,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowRight", false, true, false),
      "horizontal",
    ),
    0,
  )
  assert_eq(
    carousel_key_step(
      ffi_carousel_keyboard_fixture_event("ArrowRight", false, false, true),
      "horizontal",
    ),
    0,
  )
  ffi_restore_carousel_pointer_fixture()
}
