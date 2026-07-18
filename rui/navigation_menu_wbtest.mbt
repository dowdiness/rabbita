///|
#cfg(target="js")
extern "js" fn ffi_install_navigation_menu_fixture(rtl : Bool) -> Unit =
  #| rtl => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const listeners = {}
  #|   const fixture = globalThis.__ruiNavigationMenuFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     KeyboardEvent: globalThis.KeyboardEvent,
  #|     hadKeyboardEvent: own("KeyboardEvent"),
  #|     getComputedStyle: globalThis.getComputedStyle,
  #|     hadGetComputedStyle: own("getComputedStyle"),
  #|     requestAnimationFrame: globalThis.requestAnimationFrame,
  #|     hadRequestAnimationFrame: own("requestAnimationFrame"),
  #|     queueMicrotask: globalThis.queueMicrotask,
  #|     hadQueueMicrotask: own("queueMicrotask"),
  #|     listeners,
  #|     focused: -1,
  #|     contentFocused: false,
  #|     rafCount: 0,
  #|     prevented: false,
  #|   }
  #|   globalThis.HTMLElement = function HTMLElement() {}
  #|   globalThis.KeyboardEvent = function KeyboardEvent() {}
  #|   const makeElement = properties => Object.assign(new globalThis.HTMLElement(), {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     tabIndex: -1,
  #|     getAttribute: () => "",
  #|     setAttribute: () => {},
  #|     hasAttribute: () => false,
  #|     closest: () => null,
  #|     matches: () => false,
  #|     getClientRects: () => [{}],
  #|     querySelectorAll: () => [],
  #|     addEventListener: () => {},
  #|     focus() { fixture.documentValue.activeElement = this },
  #|   }, properties)
  #|   const root = makeElement({
  #|     dataset: { state: "open" },
  #|     isConnected: true,
  #|     addEventListener: (type, callback) => { listeners[type] = callback },
  #|     querySelectorAll: selector => selector === '[data-slot="navigation-menu-trigger"]'
  #|       ? fixture.triggers
  #|       : selector === '[data-slot="navigation-menu-content"]' ? [fixture.content] : [],
  #|     querySelector: () => null,
  #|     getAttribute: name => name === "data-state" ? "open" : "",
  #|     contains: node => node === root || fixture.triggers.includes(node)
  #|       || node === fixture.content || node === fixture.contentTarget,
  #|     matches: () => false,
  #|   })
  #|   const makeTrigger = (index, expanded, disabled = false) => makeElement({
  #|     disabled,
  #|     tabIndex: index === 0 ? 0 : -1,
  #|     dataset: {
  #|       navigationIndex: String(index),
  #|       navigationValue: `value-${index}`,
  #|     },
  #|     hasAttribute: name => name === "disabled" && disabled,
  #|     getAttribute: name => name === "aria-disabled"
  #|       ? disabled ? "true" : "false"
  #|       : name === "aria-expanded" ? expanded ? "true" : "false"
  #|       : name === "data-navigation-index" ? String(index)
  #|       : name === "data-navigation-value" ? `value-${index}` : "",
  #|     closest: selector => selector === '[data-slot="navigation-menu-trigger"]'
  #|       ? fixture.triggers[index]
  #|       : null,
  #|     focus: () => {
  #|       fixture.focused = index
  #|       fixture.documentValue.activeElement = fixture.triggers[index]
  #|     },
  #|   })
  #|   fixture.root = root
  #|   fixture.triggers = [
  #|     makeTrigger(0, false),
  #|     makeTrigger(1, true),
  #|     makeTrigger(2, false, true),
  #|   ]
  #|   fixture.contentTarget = makeElement({
  #|     disabled: false,
  #|     hidden: false,
  #|     getAttribute: () => "",
  #|     closest: () => null,
  #|     getClientRects: () => fixture.rafCount >= 2 ? [{}] : [],
  #|     focus: () => {
  #|       fixture.contentFocused = true
  #|       fixture.documentValue.activeElement = fixture.contentTarget
  #|     },
  #|   })
  #|   fixture.content = makeElement({
  #|     dataset: { navigationIndex: "1", navigationValue: "value-1" },
  #|     disabled: false,
  #|     hidden: false,
  #|     addEventListener: () => {},
  #|     getAttribute: name => name === "data-navigation-index" ? "1"
  #|       : name === "data-navigation-value" ? "value-1" : "",
  #|     closest: () => null,
  #|     getClientRects: () => fixture.rafCount >= 2 ? [{}] : [],
  #|     matches: () => false,
  #|     querySelectorAll: () => [fixture.contentTarget],
  #|     focus: () => {
  #|       fixture.contentFocused = true
  #|       fixture.documentValue.activeElement = fixture.content
  #|     },
  #|   })
  #|   fixture.documentValue = {
  #|     activeElement: null,
  #|     getElementById: id => id === "navigation-fixture" ? root : null,
  #|     addEventListener: (type, callback) => { listeners[`document:${type}`] = callback },
  #|     removeEventListener: (type, callback) => {
  #|       if (listeners[`document:${type}`] === callback) delete listeners[`document:${type}`]
  #|     },
  #|   }
  #|   globalThis.document = fixture.documentValue
  #|   const getComputedStyle = node => ({
  #|     getPropertyValue: name => name === "direction"
  #|       ? node === root && rtl ? "rtl" : "ltr"
  #|       : name === "display" ? "block"
  #|       : name === "visibility" ? "visible" : "",
  #|   })
  #|   const requestAnimationFrame = callback => {
  #|     fixture.rafCount += 1
  #|     callback(fixture.rafCount)
  #|     return fixture.rafCount
  #|   }
  #|   const windowValue = {
  #|     document: fixture.documentValue,
  #|     getComputedStyle,
  #|     requestAnimationFrame,
  #|     queueMicrotask: callback => callback(),
  #|     setTimeout: callback => { callback(); return 1 },
  #|     clearTimeout: () => {},
  #|     performance: { now: () => fixture.rafCount },
  #|   }
  #|   globalThis.window = windowValue
  #|   globalThis.getComputedStyle = getComputedStyle
  #|   globalThis.requestAnimationFrame = requestAnimationFrame
  #|   globalThis.queueMicrotask = callback => callback()
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_navigation_menu_fixture_tab_index(index : Int) -> Int =
  #| index => globalThis.__ruiNavigationMenuFixture.triggers[index].tabIndex

///|
#cfg(target="js")
extern "js" fn ffi_fire_navigation_menu_key(index : Int, key : String) -> Bool =
  #| (index, key) => {
  #|   const fixture = globalThis.__ruiNavigationMenuFixture
  #|   fixture.prevented = false
  #|   const event = Object.assign(new globalThis.KeyboardEvent(), {
  #|     target: fixture.triggers[index],
  #|     key,
  #|     defaultPrevented: false,
  #|     preventDefault: () => {
  #|       fixture.prevented = true
  #|       event.defaultPrevented = true
  #|     },
  #|   })
  #|   fixture.listeners.keydown(event)
  #|   return fixture.prevented
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_navigation_menu_fixture_focused() -> Int =
  #| () => globalThis.__ruiNavigationMenuFixture.focused

///|
#cfg(target="js")
extern "js" fn ffi_navigation_menu_fixture_content_focused() -> Bool =
  #| () => globalThis.__ruiNavigationMenuFixture.contentFocused

///|
#cfg(target="js")
extern "js" fn ffi_fire_navigation_menu_outside_press() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiNavigationMenuFixture
  #|   fixture.listeners["document:pointerdown"]({ target: {} })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_navigation_menu_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiNavigationMenuFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   if (fixture.hadKeyboardEvent) globalThis.KeyboardEvent = fixture.KeyboardEvent
  #|   else delete globalThis.KeyboardEvent
  #|   if (fixture.hadGetComputedStyle) globalThis.getComputedStyle = fixture.getComputedStyle
  #|   else delete globalThis.getComputedStyle
  #|   if (fixture.hadRequestAnimationFrame) {
  #|     globalThis.requestAnimationFrame = fixture.requestAnimationFrame
  #|   } else delete globalThis.requestAnimationFrame
  #|   if (fixture.hadQueueMicrotask) globalThis.queueMicrotask = fixture.queueMicrotask
  #|   else delete globalThis.queueMicrotask
  #|   delete globalThis.__ruiNavigationMenuFixture
  #| }

///|
#cfg(target="js")
test "navigation menu normalizes one enabled tab stop and follows RTL arrows" {
  ffi_install_navigation_menu_fixture(true)
  let activated = Ref(-1)
  let closed = Ref(0)
  bind_navigation_menu(
    "navigation-fixture",
    (_, index) => activated.val = index,
    (_, _, _) => (),
    () => closed.val += 1,
    _ => (),
  )
  let first_tab_index = ffi_navigation_menu_fixture_tab_index(0)
  let active_tab_index = ffi_navigation_menu_fixture_tab_index(1)
  let disabled_tab_index = ffi_navigation_menu_fixture_tab_index(2)
  let prevented = ffi_fire_navigation_menu_key(1, "ArrowRight")
  let focused = ffi_navigation_menu_fixture_focused()
  ffi_fire_navigation_menu_outside_press()
  let close_count = closed.val
  ffi_restore_navigation_menu_fixture()
  assert_eq(first_tab_index, -1)
  assert_eq(active_tab_index, 0)
  assert_eq(disabled_tab_index, -1)
  assert_true(prevented)
  assert_eq(focused, 0)
  assert_eq(activated.val, 0)
  assert_eq(close_count, 1)
}

///|
#cfg(target="js")
test "navigation menu retries content focus across incremental frames" {
  ffi_install_navigation_menu_fixture(false)
  let activated = Ref(-1)
  bind_navigation_menu(
    "navigation-fixture",
    (_, index) => activated.val = index,
    (_, _, _) => (),
    () => (),
    _ => (),
  )
  let prevented = ffi_fire_navigation_menu_key(1, "ArrowDown")
  let focused = ffi_navigation_menu_fixture_content_focused()
  ffi_restore_navigation_menu_fixture()
  assert_true(prevented)
  assert_eq(activated.val, 1)
  assert_true(focused)
}
