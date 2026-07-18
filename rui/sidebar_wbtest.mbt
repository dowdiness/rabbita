///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_focus_fixture(
  mode : Int,
) -> @dom.KeyboardEvent =
  #| mode => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiSidebarFocusFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     getComputedStyle: globalThis.getComputedStyle,
  #|     hadGetComputedStyle: own("getComputedStyle"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     focused: -1,
  #|   }
  #|   globalThis.HTMLElement = class FakeHTMLElement {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType === 1 }
  #|   }
  #|   const makeItem = index => ({
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     hasAttribute: () => false,
  #|     getAttribute: () => null,
  #|     closest: () => null,
  #|     getClientRects: () => [{}],
  #|     focus: () => { fixture.focused = index },
  #|   })
  #|   const disabledLink = makeItem(6)
  #|   const enabledLink = makeItem(7)
  #|   const excludedButton = makeItem(8)
  #|   const excludedInput = makeItem(9)
  #|   const excludedSelect = makeItem(10)
  #|   const excludedTextarea = makeItem(11)
  #|   const enabledNativeControl = makeItem(12)
  #|   const items = mode === 3 ? []
  #|     : mode === 6 ? [disabledLink, enabledLink]
  #|     : mode === 7
  #|       ? [
  #|           excludedButton,
  #|           excludedInput,
  #|           excludedSelect,
  #|           excludedTextarea,
  #|           enabledNativeControl,
  #|         ]
  #|     : [makeItem(0), makeItem(1)]
  #|   const root = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     hasAttribute: () => false,
  #|     getAttribute: name => name === "aria-hidden" && mode === 4 ? "true" : null,
  #|     querySelectorAll: selector => {
  #|       fixture.selector = selector
  #|       if (mode === 6
  #|         && selector.includes('a[href]:not([aria-disabled="true"]):not([tabindex="-1"])')) {
  #|         return [enabledLink]
  #|       }
  #|       if (mode === 7
  #|         && selector.includes('button:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('input:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('select:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('textarea:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')) {
  #|         return [enabledNativeControl]
  #|       }
  #|       return items
  #|     },
  #|     contains: node => items.includes(node),
  #|     focus: () => { fixture.focused = 2 },
  #|   }
  #|   fixture.root = root
  #|   fixture.items = items
  #|   globalThis.document = {
  #|     activeElement: mode === 0 || mode === 7
  #|       ? items[items.length - 1]
  #|       : mode === 1 || mode === 2 ? items[0] : null,
  #|   }
  #|   globalThis.getComputedStyle = () => ({ visibility: "visible" })
  #|   return {
  #|     key: mode === 5 ? "Escape" : "Tab",
  #|     shiftKey: mode === 1,
  #|     altKey: false,
  #|     ctrlKey: false,
  #|     metaKey: false,
  #|     currentTarget: root,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_focus_fixture_focused() -> Int =
  #| () => globalThis.__ruiSidebarFocusFixture?.focused ?? -1

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_focus_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarFocusFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadGetComputedStyle) globalThis.getComputedStyle = fixture.getComputedStyle
  #|   else delete globalThis.getComputedStyle
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiSidebarFocusFixture
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_restore_fixture(
  blocked : Bool,
) -> @dom.MouseEvent =
  #| blocked => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiSidebarRestoreFixture = {
  #|     previous: globalThis.__ruiSidebarRestoreTrigger,
  #|     hadPrevious: own("__ruiSidebarRestoreTrigger"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     focused: 0,
  #|   }
  #|   globalThis.HTMLElement = class FakeHTMLElement {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType === 1 }
  #|   }
  #|   const trigger = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     disabled: false,
  #|     hasAttribute: () => false,
  #|     getAttribute: () => null,
  #|     closest: () => blocked ? {} : null,
  #|     focus: () => { fixture.focused += 1 },
  #|   }
  #|   fixture.trigger = trigger
  #|   return { currentTarget: trigger }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_restore_fixture_focused() -> Int =
  #| () => globalThis.__ruiSidebarRestoreFixture?.focused ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_restore_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarRestoreFixture
  #|   if (!fixture) return
  #|   if (fixture.hadPrevious) globalThis.__ruiSidebarRestoreTrigger = fixture.previous
  #|   else delete globalThis.__ruiSidebarRestoreTrigger
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiSidebarRestoreFixture
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_open_focus_fixture(
  exclude_native_tabstops : Bool,
) -> Unit =
  #| excludeNativeTabstops => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const listeners = {}
  #|   let fixture
  #|   const oldNode = globalThis.Node
  #|   const oldHTMLElement = globalThis.HTMLElement
  #|   const oldKeyboardEvent = globalThis.KeyboardEvent
  #|   const oldMutationObserver = globalThis.MutationObserver
  #|   const hadMutationObserver = own("MutationObserver")
  #|   globalThis.Node = class FakeNode {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType != null }
  #|   }
  #|   globalThis.HTMLElement = class FakeHTMLElement {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType === 1 }
  #|   }
  #|   globalThis.KeyboardEvent = class FakeKeyboardEvent {
  #|     static [Symbol.hasInstance](value) { return typeof value?.key === "string" }
  #|   }
  #|   globalThis.MutationObserver = class FakeMutationObserver {
  #|     observe() {}
  #|     disconnect() {}
  #|   }
  #|   const outside = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     disabled: false,
  #|     hasAttribute: () => false,
  #|     getAttribute: () => null,
  #|     closest: () => null,
  #|     focus: () => {
  #|       fixture.focused = 3
  #|       globalThis.document.activeElement = outside
  #|     },
  #|   }
  #|   fixture = globalThis.__ruiSidebarOpenFocusFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     Node: oldNode,
  #|     hadNode: own("Node"),
  #|     HTMLElement: oldHTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     KeyboardEvent: oldKeyboardEvent,
  #|     hadKeyboardEvent: own("KeyboardEvent"),
  #|     MutationObserver: oldMutationObserver,
  #|     hadMutationObserver,
  #|     computed: globalThis.getComputedStyle,
  #|     hadComputed: own("getComputedStyle"),
  #|     listeners,
  #|     focused: -1,
  #|     outside,
  #|     restoreTrigger: globalThis.__ruiSidebarRestoreTrigger,
  #|     hadRestoreTrigger: own("__ruiSidebarRestoreTrigger"),
  #|   }
  #|   const makeItem = index => {
  #|     const item = {
  #|       nodeType: 1,
  #|       isConnected: true,
  #|       isSameNode(other) { return this === other },
  #|       hasAttribute: () => false,
  #|       getAttribute: () => null,
  #|       closest: () => null,
  #|       getClientRects: () => [{}],
  #|       focus: () => {
  #|         fixture.focused = index
  #|         globalThis.document.activeElement = item
  #|       },
  #|     }
  #|     return item
  #|   }
  #|   const enabledNativeControl = makeItem(7)
  #|   const excludedNativeControls = [
  #|     makeItem(3),
  #|     makeItem(4),
  #|     makeItem(5),
  #|     makeItem(6),
  #|   ]
  #|   const items = excludeNativeTabstops
  #|     ? [...excludedNativeControls, enabledNativeControl]
  #|     : [makeItem(0), makeItem(1)]
  #|   const root = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     hidden: false,
  #|     hasAttribute: () => false,
  #|     getAttribute: name => name === "data-mobile-state" ? "open" : null,
  #|     parentElement: null,
  #|     querySelectorAll: selector => {
  #|       if (excludeNativeTabstops
  #|         && selector.includes('button:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('input:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('select:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')
  #|         && selector.includes('textarea:not(:disabled):not([aria-disabled="true"]):not([tabindex="-1"])')) {
  #|         return [enabledNativeControl]
  #|       }
  #|       return items
  #|     },
  #|     contains: node => node === root || items.includes(node),
  #|     focus: () => {
  #|       fixture.focused = 2
  #|       globalThis.document.activeElement = root
  #|     },
  #|     dispatchEvent: () => true,
  #|   }
  #|   fixture.root = root
  #|   fixture.items = items
  #|   const body = {
  #|     nodeType: 1,
  #|     isSameNode(other) { return this === other },
  #|   }
  #|   const documentElement = {
  #|     nodeType: 1,
  #|     isSameNode(other) { return this === other },
  #|   }
  #|   const roots = [root]
  #|   roots.item = index => roots[index] ?? null
  #|   globalThis.document = {
  #|     nodeType: 9,
  #|     isSameNode(other) { return this === other },
  #|     activeElement: outside,
  #|     body,
  #|     documentElement,
  #|     querySelectorAll: () => roots,
  #|     addEventListener: (type, callback) => { listeners[type] = callback },
  #|   }
  #|   globalThis.getComputedStyle = () => ({ display: "block", visibility: "visible" })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_open_focus_fixture_focused() -> Int =
  #| () => globalThis.__ruiSidebarOpenFocusFixture?.focused ?? -1

///|
#cfg(target="js")
extern "js" fn ffi_fire_sidebar_outside_focus_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarOpenFocusFixture
  #|   globalThis.document.activeElement = fixture.outside
  #|   fixture.listeners.focusin?.({ target: fixture.outside })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_sidebar_outside_tab_fixture(shift : Bool) -> Bool =
  #| shift => {
  #|   const fixture = globalThis.__ruiSidebarOpenFocusFixture
  #|   globalThis.document.activeElement = fixture.outside
  #|   const event = {
  #|     key: "Tab",
  #|     shiftKey: shift,
  #|     defaultPrevented: false,
  #|     preventDefault() { this.defaultPrevented = true },
  #|   }
  #|   fixture.listeners.keydown?.(event)
  #|   return event.defaultPrevented
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_open_focus_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarOpenFocusFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadComputed) globalThis.getComputedStyle = fixture.computed
  #|   else delete globalThis.getComputedStyle
  #|   if (fixture.hadNode) globalThis.Node = fixture.Node
  #|   else delete globalThis.Node
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   if (fixture.hadKeyboardEvent) globalThis.KeyboardEvent = fixture.KeyboardEvent
  #|   else delete globalThis.KeyboardEvent
  #|   if (fixture.hadMutationObserver) {
  #|     globalThis.MutationObserver = fixture.MutationObserver
  #|   } else {
  #|     delete globalThis.MutationObserver
  #|   }
  #|   if (fixture.hadRestoreTrigger) {
  #|     globalThis.__ruiSidebarRestoreTrigger = fixture.restoreTrigger
  #|   } else {
  #|     delete globalThis.__ruiSidebarRestoreTrigger
  #|   }
  #|   delete globalThis.__ruiSidebarOpenFocusFixture
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_mobile_layer_fixture(mode : Int) -> Unit =
  #| mode => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiSidebarMobileLayerFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     setTimeout: globalThis.setTimeout,
  #|     hadSetTimeout: own("setTimeout"),
  #|     clearTimeout: globalThis.clearTimeout,
  #|     hadClearTimeout: own("clearTimeout"),
  #|     shows: 0,
  #|     hides: 0,
  #|     queries: 0,
  #|     layers: [],
  #|     nextTimer: 1,
  #|     timers: new Map(),
  #|   }
  #|   globalThis.window = globalThis
  #|   globalThis.HTMLElement = class FakeHTMLElement {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType === 1 }
  #|   }
  #|   globalThis.setTimeout = callback => {
  #|     const timer = fixture.nextTimer++
  #|     fixture.timers.set(timer, callback)
  #|     return timer
  #|   }
  #|   globalThis.clearTimeout = timer => { fixture.timers.delete(timer) }
  #|   const makeLayer = (requestedOpen, nativeOpen) => {
  #|     const layer = {
  #|       nodeType: 1,
  #|       isConnected: true,
  #|       isSameNode(other) { return this === other },
  #|       dataset: { state: requestedOpen ? "open" : "closed" },
  #|       getAttribute: name => name === "data-state" ? layer.dataset.state : null,
  #|       nativeOpen,
  #|       matches: selector => selector === ":popover-open" && layer.nativeOpen,
  #|       showPopover: () => {
  #|         fixture.shows += 1
  #|         layer.nativeOpen = true
  #|       },
  #|       hidePopover: () => {
  #|         fixture.hides += 1
  #|         layer.nativeOpen = false
  #|       },
  #|     }
  #|     return layer
  #|   }
  #|   fixture.layers = mode === 0
  #|     ? [makeLayer(true, false)]
  #|     : mode === 1
  #|       ? [makeLayer(false, true)]
  #|       : [
  #|           makeLayer(true, false),
  #|           makeLayer(false, true),
  #|           makeLayer(true, true),
  #|           makeLayer(false, false),
  #|         ]
  #|   fixture.layers.item = index => fixture.layers[index] ?? null
  #|   globalThis.document = {
  #|     querySelectorAll: selector => {
  #|       fixture.queries += 1
  #|       return selector === '[data-slot="sidebar-mobile-layer"][popover]'
  #|         ? fixture.layers
  #|         : []
  #|     },
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_mobile_layer_fixture_flush() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarMobileLayerFixture
  #|   const callbacks = [...fixture.timers.values()]
  #|   fixture.timers.clear()
  #|   for (const callback of callbacks) callback()
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_mobile_layer_fixture_request_open() -> Unit =
  #| () => {
  #|   globalThis.__ruiSidebarMobileLayerFixture.layers[0].dataset.state = "open"
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_mobile_layer_fixture_count(kind : Int) -> Int =
  #| kind => {
  #|   const fixture = globalThis.__ruiSidebarMobileLayerFixture
  #|   if (kind === 0) return fixture.shows
  #|   if (kind === 1) return fixture.hides
  #|   if (kind === 2) return fixture.layers.filter(layer => layer.nativeOpen).length
  #|   if (kind === 3) {
  #|     return fixture.layers.filter(layer => layer.__ruiSidebarLayerOpen).length
  #|   }
  #|   return fixture.queries
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_mobile_layer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarMobileLayerFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadSetTimeout) globalThis.setTimeout = fixture.setTimeout
  #|   else delete globalThis.setTimeout
  #|   if (fixture.hadClearTimeout) globalThis.clearTimeout = fixture.clearTimeout
  #|   else delete globalThis.clearTimeout
  #|   for (const layer of fixture.layers) layer.isConnected = false
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiSidebarMobileLayerFixture
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_desktop_collapse_fixture() -> Unit =
  #| () => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiSidebarDesktopCollapseFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     state: "expanded",
  #|     focused: 0,
  #|   }
  #|   delete globalThis.window
  #|   globalThis.HTMLElement = class FakeHTMLElement {
  #|     static [Symbol.hasInstance](value) { return value?.nodeType === 1 }
  #|   }
  #|   const trigger = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     focus: () => {
  #|       fixture.focused += 1
  #|       globalThis.document.activeElement = trigger
  #|     },
  #|   }
  #|   const wrapper = {
  #|     nodeType: 1,
  #|     querySelector: selector => selector.includes("sidebar-trigger")
  #|       ? trigger
  #|       : null,
  #|   }
  #|   const sidebar = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     getAttribute: name => name === "data-state"
  #|       ? fixture.state
  #|       : name === "data-collapsible" ? "icon" : null,
  #|     closest: selector => selector.includes("sidebar-wrapper")
  #|       ? wrapper
  #|       : null,
  #|     querySelector: () => null,
  #|   }
  #|   const active = {
  #|     nodeType: 1,
  #|     isConnected: true,
  #|     isSameNode(other) { return this === other },
  #|     getAttribute: name => name === "data-slot" ? "sidebar-menu-button" : null,
  #|     getClientRects: () => [],
  #|     closest: selector => selector.includes('data-mobile="false"')
  #|       ? sidebar
  #|       : null,
  #|   }
  #|   const body = {
  #|     nodeType: 1,
  #|     isSameNode(other) { return this === other },
  #|   }
  #|   fixture.sidebar = sidebar
  #|   fixture.active = active
  #|   globalThis.document = { activeElement: active, body }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_desktop_collapse_fixture_collapse() -> Unit =
  #| () => { globalThis.__ruiSidebarDesktopCollapseFixture.state = "collapsed" }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_desktop_collapse_fixture_replace_focus() -> Unit =
  #| () => {
  #|   globalThis.document.activeElement = {
  #|     nodeType: 1,
  #|     isSameNode(other) { return this === other },
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_desktop_collapse_fixture_focused() -> Int =
  #| () => globalThis.__ruiSidebarDesktopCollapseFixture?.focused ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_desktop_collapse_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarDesktopCollapseFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiSidebarDesktopCollapseFixture
  #| }

///|
#cfg(target="js")
test "mobile sidebar focus trap wraps both directions and ignores inactive paths" {
  let forward_event = ffi_install_sidebar_focus_fixture(0)
  let forward_handled = sidebar_trap_focus(forward_event)
  let forward_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(forward_handled)
  assert_eq(forward_focus, 0)

  let backward_event = ffi_install_sidebar_focus_fixture(1)
  let backward_handled = sidebar_trap_focus(backward_event)
  let backward_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(backward_handled)
  assert_eq(backward_focus, 1)

  let middle_event = ffi_install_sidebar_focus_fixture(2)
  let middle_handled = sidebar_trap_focus(middle_event)
  let middle_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(middle_handled)
  assert_eq(middle_focus, 1)

  let empty_event = ffi_install_sidebar_focus_fixture(3)
  let empty_handled = sidebar_trap_focus(empty_event)
  let empty_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(empty_handled)
  assert_eq(empty_focus, 2)

  let hidden_event = ffi_install_sidebar_focus_fixture(4)
  let hidden_handled = sidebar_trap_focus(hidden_event)
  ffi_restore_sidebar_focus_fixture()
  assert_true(!hidden_handled)

  let escape_event = ffi_install_sidebar_focus_fixture(5)
  let escape_handled = sidebar_trap_focus(escape_event)
  ffi_restore_sidebar_focus_fixture()
  assert_true(!escape_handled)

  let disabled_link_event = ffi_install_sidebar_focus_fixture(6)
  let disabled_link_handled = sidebar_trap_focus(disabled_link_event)
  let disabled_link_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(disabled_link_handled)
  assert_eq(disabled_link_focus, 7)

  let excluded_native_event = ffi_install_sidebar_focus_fixture(7)
  let excluded_native_handled = sidebar_trap_focus(excluded_native_event)
  let excluded_native_focus = ffi_sidebar_focus_fixture_focused()
  ffi_restore_sidebar_focus_fixture()
  assert_true(excluded_native_handled)
  assert_eq(excluded_native_focus, 12)
}

///|
#cfg(target="js")
test "mobile sidebar restores only a connected visible opener" {
  let visible_event = ffi_install_sidebar_restore_fixture(false)
  sidebar_capture_restore_trigger(visible_event)
  sidebar_restore_captured_trigger()
  let visible_focus = ffi_sidebar_restore_fixture_focused()
  ffi_restore_sidebar_restore_fixture()
  assert_eq(visible_focus, 1)

  let blocked_event = ffi_install_sidebar_restore_fixture(true)
  sidebar_capture_restore_trigger(blocked_event)
  sidebar_restore_captured_trigger()
  let blocked_focus = ffi_sidebar_restore_fixture_focused()
  ffi_restore_sidebar_restore_fixture()
  assert_eq(blocked_focus, 0)
}

///|
#cfg(target="js")
test "opening mobile sidebar moves focus in and contains outside focus" {
  ffi_install_sidebar_open_focus_fixture(false)
  assert_true(sidebar_focus_open())
  assert_eq(ffi_sidebar_open_focus_fixture_focused(), 0)
  ffi_fire_sidebar_outside_focus_fixture()
  assert_eq(ffi_sidebar_open_focus_fixture_focused(), 0)
  assert_true(ffi_fire_sidebar_outside_tab_fixture(true))
  assert_eq(ffi_sidebar_open_focus_fixture_focused(), 1)
  sidebar_restore_captured_trigger()
  assert_eq(ffi_sidebar_open_focus_fixture_focused(), 3)
  ffi_restore_sidebar_open_focus_fixture()
}

///|
#cfg(target="js")
test "opening mobile sidebar skips native controls removed from tab order" {
  ffi_install_sidebar_open_focus_fixture(true)
  assert_true(sidebar_focus_open())
  assert_eq(ffi_sidebar_open_focus_fixture_focused(), 7)
  ffi_restore_sidebar_open_focus_fixture()
}

///|
#cfg(target="js")
test "mobile sidebar promotes a requested open layer" {
  ffi_install_sidebar_mobile_layer_fixture(0)
  sidebar_sync_mobile_layers()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(0), 1)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 1)
  ffi_restore_sidebar_mobile_layer_fixture()
}

///|
#cfg(target="js")
test "mobile sidebar dismisses a native layer requested closed" {
  ffi_install_sidebar_mobile_layer_fixture(1)
  sidebar_sync_mobile_layers()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(0), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 1)
  ffi_sidebar_mobile_layer_fixture_flush()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 1)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 0)
  ffi_restore_sidebar_mobile_layer_fixture()
}

///|
#cfg(target="js")
test "mobile sidebar synchronizes every layer idempotently" {
  ffi_install_sidebar_mobile_layer_fixture(2)
  sidebar_sync_mobile_layers()
  sidebar_sync_mobile_layers()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(0), 1)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 3)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(4), 2)
  ffi_sidebar_mobile_layer_fixture_flush()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 1)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 2)
  ffi_restore_sidebar_mobile_layer_fixture()
}

///|
#cfg(target="js")
test "mobile sidebar cancels a pending native dismissal when reopened" {
  ffi_install_sidebar_mobile_layer_fixture(1)
  sidebar_sync_mobile_layers()
  ffi_sidebar_mobile_layer_fixture_request_open()
  sidebar_sync_mobile_layers()
  ffi_sidebar_mobile_layer_fixture_flush()
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(0), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(1), 0)
  assert_eq(ffi_sidebar_mobile_layer_fixture_count(2), 1)
  ffi_restore_sidebar_mobile_layer_fixture()
}

///|
#cfg(target="js")
test "desktop collapse moves focus only when the captured control becomes hidden" {
  ffi_install_sidebar_desktop_collapse_fixture()
  sidebar_capture_desktop_collapse_focus()
  ffi_sidebar_desktop_collapse_fixture_collapse()
  sidebar_restore_desktop_collapse_focus()
  let restored = ffi_sidebar_desktop_collapse_fixture_focused()
  ffi_restore_sidebar_desktop_collapse_fixture()
  assert_eq(restored, 1)

  ffi_install_sidebar_desktop_collapse_fixture()
  sidebar_capture_desktop_collapse_focus()
  ffi_sidebar_desktop_collapse_fixture_collapse()
  ffi_sidebar_desktop_collapse_fixture_replace_focus()
  sidebar_restore_desktop_collapse_focus()
  let preserved = ffi_sidebar_desktop_collapse_fixture_focused()
  ffi_restore_sidebar_desktop_collapse_fixture()
  assert_eq(preserved, 0)
}
