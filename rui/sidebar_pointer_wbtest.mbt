///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_pointer_fixture(
  side : String,
  collapsed : Bool,
  start_width : Int,
  preferred_width : Int,
  root_width : Int,
) -> Unit =
  #| (side, collapsed, startWidth, preferredWidth, rootWidth) => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const style = entries => {
  #|     const values = new Map(entries)
  #|     return {
  #|       getPropertyValue: name => values.get(name) || "",
  #|       setProperty: (name, value) => { values.set(name, String(value)) },
  #|       removeProperty: name => {
  #|         const value = values.get(name) || ""
  #|         values.delete(name)
  #|         return value
  #|       },
  #|     }
  #|   }
  #|   const fixture = globalThis.__ruiSidebarPointerFixture = {
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
  #|     captures: 0,
  #|     releases: 0,
  #|     prevented: 0,
  #|     stopped: 0,
  #|     listeners: {},
  #|     clicks: 0,
  #|     timeouts: [],
  #|   }
  #|   class EventTarget {}
  #|   class Node extends EventTarget {
  #|     constructor() { super(); this.nodeType = 1 }
  #|   }
  #|   class HTMLElement extends Node {}
  #|   class PointerEvent {
  #|     constructor(init) {
  #|       Object.assign(this, init)
  #|       this.defaultPrevented = init.defaultPrevented ?? false
  #|     }
  #|     preventDefault() {
  #|       this.defaultPrevented = true
  #|       fixture.prevented += 1
  #|     }
  #|   }
  #|   Object.assign(globalThis, { EventTarget, Node, HTMLElement, PointerEvent })
  #|   const dataName = name => name.replace(/^data-/, "").replace(/-([a-z])/g, (_, c) => c.toUpperCase())
  #|   const dataMethods = element => Object.assign(element, {
  #|     getAttribute(name) { return this.dataset[dataName(name)] ?? "" },
  #|     setAttribute(name, value) { this.dataset[dataName(name)] = String(value) },
  #|     removeAttribute(name) { delete this.dataset[dataName(name)] },
  #|   })
  #|   const root = dataMethods(new HTMLElement())
  #|   Object.assign(root, {
  #|     dataset: { slot: "sidebar-wrapper" },
  #|     style: style([]),
  #|     getBoundingClientRect: () => ({ width: rootWidth }),
  #|   })
  #|   const sidebarStyle = style([[
  #|     "width",
  #|     collapsed
  #|       ? "var(--rui-sidebar-width-icon,3rem)"
  #|       : "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  #|   ], ["transition", "width 200ms ease,transform 200ms ease"]])
  #|   const shellStyle = style([
  #|     ["width", "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))"],
  #|     ["transition", "width 200ms linear"],
  #|   ])
  #|   const shell = dataMethods(new HTMLElement())
  #|   Object.assign(shell, {
  #|     dataset: { slot: "sidebar-shell", variant: "sidebar" },
  #|     style: shellStyle,
  #|   })
  #|   const sidebar = dataMethods(new HTMLElement())
  #|   Object.assign(sidebar, {
  #|     dataset: {
  #|       state: collapsed ? "collapsed" : "expanded",
  #|       mobile: "false",
  #|       side,
  #|     },
  #|     style: sidebarStyle,
  #|     getBoundingClientRect: () => {
  #|       const width = sidebarStyle.getPropertyValue("width")
  #|       if (/^-?\d+(?:\.\d+)?px$/.test(width)) return { width: Number.parseFloat(width) }
  #|       if (width.includes("--rui-sidebar-current-width")) return { width: preferredWidth }
  #|       return { width: startWidth }
  #|     },
  #|     closest: selector => selector.includes("sidebar-shell") ? shell : null,
  #|   })
  #|   const rail = dataMethods(new HTMLElement())
  #|   Object.assign(rail, {
  #|     dataset: {},
  #|     closest: selector => selector.includes("sidebar-wrapper")
  #|       ? root
  #|       : selector.includes("sidebar-shell") ? shell
  #|       : selector.includes('data-slot="sidebar"') ? sidebar : null,
  #|     addEventListener: (type, callback) => { fixture.listeners[type] = callback },
  #|     removeEventListener: (type, callback) => {
  #|       if (fixture.listeners[type] === callback) delete fixture.listeners[type]
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
  #|     click: () => { fixture.clicks += 1 },
  #|   })
  #|   fixture.root = root
  #|   fixture.sidebar = sidebar
  #|   fixture.shell = shell
  #|   fixture.rail = rail
  #|   globalThis.window = {
  #|     setTimeout(callback) {
  #|       fixture.timeouts.push(callback)
  #|       return fixture.timeouts.length
  #|     },
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_event(
  client_x : Int,
  pointer_id : Int,
) -> @dom.PointerEvent =
  #| (clientX, pointerId) => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   return new PointerEvent({
  #|     currentTarget: fixture.rail,
  #|     target: fixture.rail,
  #|     clientX,
  #|     clientY: 100,
  #|     pointerId,
  #|     pointerType: "mouse",
  #|     button: 0,
  #|     isPrimary: true,
  #|     defaultPrevented: false,
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_variant(variant : String) -> Unit =
  #| variant => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   if (fixture?.shell?.dataset) fixture.shell.dataset.variant = variant
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_property(kind : Int) -> String =
  #| kind => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   if (kind === 0) return fixture.root.style.getPropertyValue("--rui-sidebar-current-width")
  #|   if (kind === 1) return fixture.sidebar.style.getPropertyValue("width")
  #|   if (kind === 2) return fixture.sidebar.style.getPropertyValue("transition")
  #|   if (kind === 3) return fixture.root.style.getPropertyValue("user-select")
  #|   if (kind === 4) return fixture.shell.style.getPropertyValue("width")
  #|   if (kind === 5) return fixture.shell.style.getPropertyValue("transition")
  #|   return fixture.root.style.getPropertyValue("cursor")
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_count(kind : Int) -> Int =
  #| kind => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   if (kind === 0) return fixture.captures
  #|   if (kind === 1) return fixture.releases
  #|   if (kind === 2) return fixture.prevented
  #|   if (kind === 3) return fixture.stopped
  #|   if (kind === 4) return fixture.clicks
  #|   return 0
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_click() -> Bool =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   const listener = fixture.listeners.click
  #|   if (!listener) return false
  #|   const event = {
  #|     defaultPrevented: false,
  #|     preventDefault() { this.defaultPrevented = true },
  #|     stopImmediatePropagation() { fixture.stopped += 1 },
  #|     stopPropagation() { fixture.stopped += 1 },
  #|   }
  #|   listener(event)
  #|   return event.defaultPrevented
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_pointer_fixture_lost(pointer_id : Int) -> Unit =
  #| pointerId => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
  #|   delete fixture.rail.__capturedPointerId
  #|   fixture.listeners.lostpointercapture?.(new PointerEvent({
  #|     pointerId,
  #|     currentTarget: fixture.rail,
  #|     target: fixture.rail,
  #|   }))
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_pointer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarPointerFixture
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
  #|   delete globalThis.__ruiSidebarPointerFixture
  #|   delete globalThis.__ruiSidebarDispatchingCommitClick
  #| }

///|
#cfg(target="js")
test "sidebar rail resizes left and suppresses the synthetic toggle click" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  let down = ffi_sidebar_pointer_fixture_event(100, 7)
  let move_event = ffi_sidebar_pointer_fixture_event(160, 7)
  let up = ffi_sidebar_pointer_fixture_event(160, 7)
  assert_true(sidebar_pointer_start(down, 160, 512))
  assert_true(sidebar_pointer_move(move_event))
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "300px")
  assert_eq(ffi_sidebar_pointer_fixture_property(1), "300px")
  assert_eq(ffi_sidebar_pointer_fixture_property(4), "300px")
  assert_eq(ffi_sidebar_pointer_fixture_property(5), "none")
  assert_eq(ffi_sidebar_pointer_fixture_property(6), "col-resize")
  assert_eq(sidebar_pointer_end(up), 300)
  assert_eq(ffi_sidebar_pointer_fixture_count(0), 1)
  assert_eq(ffi_sidebar_pointer_fixture_count(1), 1)
  assert_true(ffi_sidebar_pointer_fixture_click())
  assert_eq(ffi_sidebar_pointer_fixture_count(3), 2)
  assert_eq(
    ffi_sidebar_pointer_fixture_property(4),
    "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar rail reverses right-side delta and clamps both bounds" {
  ffi_install_sidebar_pointer_fixture("right", false, 240, 240, 640)
  let down = ffi_sidebar_pointer_fixture_event(300, 11)
  assert_true(sidebar_pointer_start(down, 160, 400))
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(360, 11)))
  assert_eq(
    sidebar_pointer_end(ffi_sidebar_pointer_fixture_event(360, 11)),
    180,
  )
  ffi_restore_sidebar_pointer_fixture()
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 12), 160, 400),
  )
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(700, 12)))
  assert_eq(
    sidebar_pointer_end(ffi_sidebar_pointer_fixture_event(700, 12)),
    400,
  )
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar rail preserves clicks below threshold and restores cancellation" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 20), 160, 512),
  )
  assert_false(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(103, 20)))
  assert_eq(sidebar_pointer_end(ffi_sidebar_pointer_fixture_event(103, 20)), 0)
  assert_false(ffi_sidebar_pointer_fixture_click())
  ffi_restore_sidebar_pointer_fixture()
  ffi_install_sidebar_pointer_fixture("left", true, 48, 240, 640)
  assert_false(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 21), 160, 512),
  )
  assert_false(ffi_sidebar_pointer_fixture_click())
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar rail lost pointer capture cancels an in-flight preview" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 31), 160, 512),
  )
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(180, 31)))
  ffi_sidebar_pointer_fixture_lost(31)
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "")
  assert_eq(
    ffi_sidebar_pointer_fixture_property(1),
    "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  assert_eq(ffi_sidebar_pointer_fixture_count(1), 0)
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar pointer cancel rolls back an active preview" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 37), 160, 512),
  )
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(180, 37)))
  sidebar_pointer_cancel(ffi_sidebar_pointer_fixture_event(180, 37))
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "")
  assert_eq(
    ffi_sidebar_pointer_fixture_property(1),
    "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  assert_eq(ffi_sidebar_pointer_fixture_count(1), 1)
  assert_false(ffi_sidebar_pointer_fixture_click())
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar pointer capture commits a drag that ends outside the rail" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 640)
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 41), 160, 512),
  )
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(900, 41)))
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "512px")
  assert_eq(
    sidebar_pointer_end(ffi_sidebar_pointer_fixture_event(900, 41)),
    512,
  )
  assert_eq(ffi_sidebar_pointer_fixture_count(4), 0)
  assert_eq(ffi_sidebar_pointer_fixture_count(0), 1)
  assert_eq(ffi_sidebar_pointer_fixture_count(1), 1)
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "floating sidebar resizes one total-width token without double-counting its gutter" {
  ffi_install_sidebar_pointer_fixture("left", false, 224, 224, 640)
  ffi_sidebar_pointer_fixture_variant("floating")
  assert_true(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 47), 160, 512),
  )
  assert_true(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(160, 47)))
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "300px")
  assert_eq(ffi_sidebar_pointer_fixture_property(1), "284px")
  assert_eq(ffi_sidebar_pointer_fixture_property(4), "300px")
  assert_eq(
    sidebar_pointer_end(ffi_sidebar_pointer_fixture_event(160, 47)),
    300,
  )
  ffi_restore_sidebar_pointer_fixture()
}

///|
#cfg(target="js")
test "sidebar rail refuses resize when the root cannot honor its minimum" {
  ffi_install_sidebar_pointer_fixture("left", false, 240, 240, 40)
  assert_false(
    sidebar_pointer_start(ffi_sidebar_pointer_fixture_event(100, 51), 160, 512),
  )
  assert_false(sidebar_pointer_move(ffi_sidebar_pointer_fixture_event(180, 51)))
  assert_eq(ffi_sidebar_pointer_fixture_property(0), "")
  assert_eq(
    ffi_sidebar_pointer_fixture_property(1),
    "var(--rui-sidebar-current-width,var(--rui-sidebar-width,16rem))",
  )
  assert_eq(ffi_sidebar_pointer_fixture_count(0), 0)
  ffi_restore_sidebar_pointer_fixture()
}
