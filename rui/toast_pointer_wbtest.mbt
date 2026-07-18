///|
#cfg(target="js")
extern "js" fn ffi_install_toast_pointer_fixture(rtl : Bool) -> Unit =
  #| rtl => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const saved = {
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
  #|   const props = {
  #|     transition: "opacity 150ms ease,transform 150ms ease",
  #|   }
  #|   const style = {
  #|     getPropertyValue: key => props[key] || "",
  #|     setProperty: (key, value) => { props[key] = value },
  #|     removeProperty: key => {
  #|       const value = props[key] || ""
  #|       delete props[key]
  #|       return value
  #|     },
  #|   }
  #|   const plain = new HTMLElement()
  #|   plain.closest = () => null
  #|   const interactive = new HTMLElement()
  #|   interactive.closest = selector => selector.includes("button") ? interactive : null
  #|   const surface = new HTMLElement()
  #|   Object.assign(surface, {
  #|     clientWidth: 300,
  #|     style,
  #|     dataset: {},
  #|     __direction: rtl ? "rtl" : "ltr",
  #|     captures: 0,
  #|     releases: 0,
  #|     setAttribute(name, value) {
  #|       if (name === "data-swipe") this.dataset.swipe = value
  #|     },
  #|     removeAttribute(name) {
  #|       if (name === "data-swipe") delete this.dataset.swipe
  #|     },
  #|     setPointerCapture(pointerId) {
  #|       this.__capturedPointerId = pointerId
  #|       this.captures += 1
  #|     },
  #|     releasePointerCapture(pointerId) {
  #|       if (this.__capturedPointerId !== pointerId) return
  #|       delete this.__capturedPointerId
  #|       this.releases += 1
  #|     },
  #|     hasPointerCapture(pointerId) { return this.__capturedPointerId === pointerId },
  #|   })
  #|   globalThis.window = {
  #|     getComputedStyle: element => ({
  #|       getPropertyValue: name => name === "direction"
  #|         ? element.__direction || "ltr"
  #|         : "",
  #|     }),
  #|   }
  #|   globalThis.__ruiToastPointerFixture = {
  #|     ...saved,
  #|     props,
  #|     plain,
  #|     interactive,
  #|     surface,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_toast_pointer_fixture_event(
  x : Int,
  y : Int,
  time : Int,
  interactive : Bool,
) -> @dom.MouseEvent =
  #| (x, y, time, interactive) => {
  #|   const fixture = globalThis.__ruiToastPointerFixture
  #|   return new PointerEvent({
  #|     currentTarget: fixture.surface,
  #|     target: interactive ? fixture.interactive : fixture.plain,
  #|     pointerId: 5,
  #|     pointerType: "touch",
  #|     isPrimary: true,
  #|     button: 0,
  #|     clientX: x,
  #|     clientY: y,
  #|     timeStamp: time,
  #|     defaultPrevented: false,
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_toast_fixture_value(key : String) -> String =
  #| key => globalThis.__ruiToastPointerFixture?.props?.[key] || ""

///|
#cfg(target="js")
extern "js" fn ffi_toast_fixture_swiping() -> Bool =
  #| () => globalThis.__ruiToastPointerFixture?.surface?.dataset?.swipe === "move"

///|
#cfg(target="js")
extern "js" fn ffi_toast_fixture_releases() -> Int =
  #| () => globalThis.__ruiToastPointerFixture?.surface?.releases ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_restore_toast_pointer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiToastPointerFixture
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
  #|   delete globalThis.__ruiToastPointerFixture
  #| }

///|
#cfg(target="js")
test "toast swipe dismisses toward logical inline end in LTR and RTL" {
  ffi_install_toast_pointer_fixture(false)
  let start = ffi_toast_pointer_fixture_event(20, 20, 0, false)
  let drag_move = ffi_toast_pointer_fixture_event(145, 22, 200, false)
  let finish = ffi_toast_pointer_fixture_event(145, 22, 350, false)
  assert_true(toast_pointer_start(start))
  assert_true(toast_pointer_move(drag_move))
  assert_true(ffi_toast_fixture_swiping())
  assert_eq(ffi_toast_fixture_value("--rui-toast-swipe-x"), "125px")
  assert_eq(toast_pointer_end(finish), 2)
  assert_eq(ffi_toast_fixture_value("--rui-toast-swipe-x"), "")
  assert_eq(
    ffi_toast_fixture_value("transition"),
    "opacity 150ms ease,transform 150ms ease",
  )
  assert_eq(ffi_toast_fixture_releases(), 1)
  ffi_restore_toast_pointer_fixture()

  ffi_install_toast_pointer_fixture(true)
  let rtl_start = ffi_toast_pointer_fixture_event(260, 20, 0, false)
  let rtl_drag = ffi_toast_pointer_fixture_event(130, 20, 200, false)
  let rtl_finish = ffi_toast_pointer_fixture_event(130, 20, 350, false)
  assert_true(toast_pointer_start(rtl_start))
  assert_true(toast_pointer_move(rtl_drag))
  assert_eq(ffi_toast_fixture_value("--rui-toast-swipe-x"), "-130px")
  assert_eq(toast_pointer_end(rtl_finish), -2)
  ffi_restore_toast_pointer_fixture()
}

///|
#cfg(target="js")
test "toast swipe preserves vertical scrolling and interactive controls" {
  ffi_install_toast_pointer_fixture(false)
  let interactive = ffi_toast_pointer_fixture_event(20, 20, 0, true)
  assert_true(!toast_pointer_start(interactive))
  let start = ffi_toast_pointer_fixture_event(20, 20, 0, false)
  let vertical = ffi_toast_pointer_fixture_event(24, 90, 100, false)
  assert_true(toast_pointer_start(start))
  assert_true(!toast_pointer_move(vertical))
  assert_true(!ffi_toast_fixture_swiping())
  assert_eq(ffi_toast_fixture_releases(), 1)
  ffi_restore_toast_pointer_fixture()
}
