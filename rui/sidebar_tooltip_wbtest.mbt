///|
#cfg(target="js")
extern "js" fn ffi_install_sidebar_tooltip_fixture(
  content_id : String,
  trigger_id : String,
) -> Unit =
  #| (contentId, triggerId) => {
  #|   const keys = [
  #|     "window", "document", "EventTarget", "Node", "Element",
  #|     "HTMLElement", "HTMLDialogElement", "Document", "Window", "Event",
  #|     "MouseEvent", "KeyboardEvent", "FocusEvent", "ToggleEvent",
  #|     "MutationObserver",
  #|   ]
  #|   const globals = new Map(keys.map(key => [key, {
  #|     had: Object.prototype.hasOwnProperty.call(globalThis, key),
  #|     value: globalThis[key],
  #|   }]))
  #|   class FakeEventTarget {
  #|     constructor() { this.listeners = new Map() }
  #|     addEventListener(type, callback, options = {}) {
  #|       const listeners = this.listeners.get(type) ?? []
  #|       listeners.push({ callback, once: Boolean(options?.once) })
  #|       this.listeners.set(type, listeners)
  #|     }
  #|     removeEventListener(type, callback) {
  #|       this.listeners.set(
  #|         type,
  #|         (this.listeners.get(type) ?? []).filter(item => item.callback !== callback),
  #|       )
  #|     }
  #|     dispatchEvent(event) {
  #|       if (!(event instanceof FakeEvent)) throw new TypeError("Event required")
  #|       if (!event.target) event.target = this
  #|       event.currentTarget = this
  #|       const listeners = [...(this.listeners.get(event.type) ?? [])]
  #|       for (const item of listeners) {
  #|         item.callback(event)
  #|         if (item.once) this.removeEventListener(event.type, item.callback)
  #|         if (event.immediatePropagationStopped) break
  #|       }
  #|       event.currentTarget = null
  #|       return !event.defaultPrevented
  #|     }
  #|   }
  #|   class FakeNode extends FakeEventTarget {
  #|     constructor(nodeType) {
  #|       super()
  #|       this.nodeType = nodeType
  #|       this.parentNode = null
  #|       this.isConnected = true
  #|     }
  #|     contains(node) {
  #|       for (let current = node; current; current = current.parentNode) {
  #|         if (current === this) return true
  #|       }
  #|       return false
  #|     }
  #|   }
  #|   class FakeStyle {
  #|     constructor() { this.values = new Map() }
  #|     getPropertyValue(name) { return this.values.get(name) ?? "" }
  #|     setProperty(name, value) { this.values.set(name, String(value)) }
  #|     removeProperty(name) {
  #|       const previous = this.getPropertyValue(name)
  #|       this.values.delete(name)
  #|       return previous
  #|     }
  #|   }
  #|   class FakeElement extends FakeNode {
  #|     constructor(id, attributes = {}) {
  #|       super(1)
  #|       this.id = id
  #|       this.attributes = new Map()
  #|       this.children = []
  #|       this.parentElement = null
  #|       this.style = new FakeStyle()
  #|       this.focusVisible = true
  #|       for (const [name, value] of Object.entries(attributes)) {
  #|         this.setAttribute(name, value)
  #|       }
  #|     }
  #|     setAttribute(name, value) { this.attributes.set(name, String(value)) }
  #|     getAttribute(name) {
  #|       if (name === "id") return this.id
  #|       return this.attributes.get(name) ?? ""
  #|     }
  #|     hasAttribute(name) { return this.attributes.has(name) }
  #|     removeAttribute(name) { this.attributes.delete(name) }
  #|     append(child) {
  #|       child.parentNode = this
  #|       child.parentElement = this
  #|       this.children.push(child)
  #|     }
  #|     matches(selector) {
  #|       if (selector === ":focus-visible") return this.focusVisible
  #|       if (selector === ":popover-open") return Boolean(this.popoverOpen)
  #|       const slot = selector.match(/^\[data-slot="([^"]+)"\]$/)?.[1]
  #|       return slot ? this.getAttribute("data-slot") === slot : false
  #|     }
  #|     closest(selector) {
  #|       for (let current = this; current; current = current.parentElement) {
  #|         if (current.matches(selector)) return current
  #|       }
  #|       return null
  #|     }
  #|     querySelectorAll(selector) {
  #|       const result = []
  #|       const visit = element => {
  #|         for (const child of element.children) {
  #|           if (child.matches(selector)) result.push(child)
  #|           visit(child)
  #|         }
  #|       }
  #|       visit(this)
  #|       return result
  #|     }
  #|     querySelector(selector) { return this.querySelectorAll(selector)[0] ?? null }
  #|   }
  #|   class FakeHTMLElement extends FakeElement {
  #|     constructor(id, attributes = {}) {
  #|       super(id, attributes)
  #|       this.popover = null
  #|       this.popoverOpen = false
  #|     }
  #|     focus() {}
  #|     showPopover() {
  #|       if (this.popoverOpen) return
  #|       this.popoverOpen = true
  #|       this.dispatchEvent(new FakeToggleEvent("toggle", {
  #|         oldState: "closed", newState: "open",
  #|       }))
  #|     }
  #|     hidePopover() {
  #|       if (!this.popoverOpen) return
  #|       this.popoverOpen = false
  #|       this.dispatchEvent(new FakeToggleEvent("toggle", {
  #|         oldState: "open", newState: "closed",
  #|       }))
  #|     }
  #|   }
  #|   class FakeHTMLDialogElement extends FakeHTMLElement {}
  #|   class FakeEvent {
  #|     constructor(type, init = {}) {
  #|       this.type = type
  #|       this.cancelable = Boolean(init.cancelable)
  #|       this.defaultPrevented = false
  #|       this.propagationStopped = false
  #|       this.immediatePropagationStopped = false
  #|       this.target = init.target ?? null
  #|       this.currentTarget = null
  #|       this.timeStamp = 0
  #|     }
  #|     preventDefault() { if (this.cancelable) this.defaultPrevented = true }
  #|     stopPropagation() { this.propagationStopped = true }
  #|     stopImmediatePropagation() {
  #|       this.immediatePropagationStopped = true
  #|       this.propagationStopped = true
  #|     }
  #|     composedPath() { return this.target ? [this.target] : [] }
  #|   }
  #|   class FakeMouseEvent extends FakeEvent {}
  #|   class FakeKeyboardEvent extends FakeEvent {
  #|     constructor(type, init = {}) { super(type, init); this.key = init.key ?? "" }
  #|   }
  #|   class FakeFocusEvent extends FakeEvent {
  #|     constructor(type, init = {}) {
  #|       super(type, init)
  #|       this.relatedTarget = init.relatedTarget ?? null
  #|     }
  #|   }
  #|   class FakeToggleEvent extends FakeEvent {
  #|     constructor(type, init = {}) {
  #|       super(type, init)
  #|       this.oldState = init.oldState ?? "closed"
  #|       this.newState = init.newState ?? "closed"
  #|     }
  #|   }
  #|   class FakeDocument extends FakeNode {
  #|     constructor() {
  #|       super(9)
  #|       this.body = new FakeHTMLElement("body")
  #|       this.documentElement = new FakeHTMLElement("html")
  #|       this.activeElement = this.body
  #|     }
  #|     getElementById(value) {
  #|       if (value === contentId) return popup
  #|       if (value === triggerId) return trigger
  #|       if (value === "sidebar") return sidebar
  #|       return null
  #|     }
  #|   }
  #|   class FakeWindow extends FakeEventTarget {
  #|     constructor() { super(); this.performance = { now: () => 0 } }
  #|     requestAnimationFrame(callback) { callback(0); return 1 }
  #|     queueMicrotask(callback) { callback() }
  #|     getComputedStyle(element) { return element.style }
  #|   }
  #|   let fixture
  #|   class FakeMutationObserver {
  #|     constructor(callback) { fixture.observer = callback }
  #|     observe() {}
  #|     disconnect() {}
  #|   }
  #|   const sidebar = new FakeHTMLElement("sidebar", {
  #|     "data-slot": "sidebar",
  #|     "data-collapsible": "icon",
  #|     "data-state": "expanded",
  #|     "data-mobile": "false",
  #|   })
  #|   const trigger = new FakeHTMLElement(triggerId, {
  #|     "data-sidebar-collapsed-only": "true",
  #|     "data-close-on-click": "true",
  #|     "data-hoverable": "true",
  #|   })
  #|   const popup = new FakeHTMLElement(contentId, {
  #|     "data-slot": "tooltip-content",
  #|     "data-trigger-id": triggerId,
  #|     "data-tooltip-owner-id": triggerId,
  #|     "data-restore-focus": "false",
  #|   })
  #|   popup.popover = "manual"
  #|   sidebar.append(trigger)
  #|   const document = new FakeDocument()
  #|   const window = new FakeWindow()
  #|   window.document = document
  #|   fixture = globalThis.__ruiSidebarTooltipFixture = {
  #|     globals, contentId, triggerId, sidebar, trigger, popup,
  #|     observer: null, escapeEvent: null,
  #|   }
  #|   Object.assign(globalThis, {
  #|     window, document, EventTarget: FakeEventTarget, Node: FakeNode,
  #|     Element: FakeElement, HTMLElement: FakeHTMLElement,
  #|     HTMLDialogElement: FakeHTMLDialogElement, Document: FakeDocument,
  #|     Window: FakeWindow, Event: FakeEvent, MouseEvent: FakeMouseEvent,
  #|     KeyboardEvent: FakeKeyboardEvent, FocusEvent: FakeFocusEvent,
  #|     ToggleEvent: FakeToggleEvent, MutationObserver: FakeMutationObserver,
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_set_context(
  collapsed : Bool,
  mobile : Bool,
  icon : Bool,
) -> Unit =
  #| (collapsed, mobile, icon) => {
  #|   const sidebar = globalThis.__ruiSidebarTooltipFixture.sidebar
  #|   sidebar.setAttribute("data-state", collapsed ? "collapsed" : "expanded")
  #|   sidebar.setAttribute("data-mobile", mobile ? "true" : "false")
  #|   sidebar.setAttribute("data-collapsible", icon ? "icon" : "offcanvas")
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_set_disabled(
  disabled : Bool,
) -> Unit =
  #| disabled => {
  #|   const trigger = globalThis.__ruiSidebarTooltipFixture.trigger
  #|   if (disabled) trigger.setAttribute("aria-disabled", "true")
  #|   else trigger.removeAttribute("aria-disabled")
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_fire(type_ : String) -> Unit =
  #| type => {
  #|   const fixture = globalThis.__ruiSidebarTooltipFixture
  #|   const event = type === "focus"
  #|     ? new FocusEvent(type)
  #|     : new MouseEvent(type)
  #|   fixture.trigger.dispatchEvent(event)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_fire_observer() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarTooltipFixture
  #|   fixture.observer?.([], null)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_fire_escape() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarTooltipFixture
  #|   fixture.escapeEvent = new KeyboardEvent("keydown", {
  #|     key: "Escape", cancelable: true,
  #|   })
  #|   document.dispatchEvent(fixture.escapeEvent)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_sidebar_tooltip_fixture_escape_handled() -> Bool =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarTooltipFixture
  #|   return Boolean(
  #|     fixture.escapeEvent?.defaultPrevented &&
  #|     fixture.escapeEvent?.propagationStopped,
  #|   )
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_sidebar_tooltip_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSidebarTooltipFixture
  #|   if (!fixture) return
  #|   fixture.sidebar.isConnected = false
  #|   fixture.trigger.isConnected = false
  #|   fixture.popup.isConnected = false
  #|   for (const [key, saved] of fixture.globals) {
  #|     if (saved.had) globalThis[key] = saved.value
  #|     else delete globalThis[key]
  #|   }
  #|   delete globalThis.__ruiSidebarTooltipFixture
  #| }

///|
#cfg(target="js")
fn reset_sidebar_tooltip_bindings(id : String) -> Unit {
  if tooltip_event_bindings.get(id) is Some(binding) &&
    binding.sidebar_observer.val is Some(observer) {
    observer.disconnect()
  }
  ignore(tooltip_event_bindings.remove(id))
  if floating_live_layer(id) is Some(_) {
    ignore(set_floating_open(id, false))
  }
  floating_stop(id)
  ignore(floating_layers.remove(id))
  floating_update_stack(id, false)
}

///|
#cfg(target="js")
test "sidebar tooltip opens only for collapsed desktop icons and handles Escape" {
  let kind = Ref(-1)
  let wait = Ref(-1)
  ffi_install_sidebar_tooltip_fixture(
    "sidebar-projects-tooltip", "sidebar-projects",
  )
  assert_true(
    bind_tooltip_events_for_trigger(
      "sidebar-projects-tooltip",
      "sidebar-projects",
      "sidebar-projects",
      (next_kind, next_wait) => {
        kind.val = next_kind
        wait.val = next_wait
      },
    ),
  )
  assert_eq(kind.val, 9)

  ffi_sidebar_tooltip_fixture_set_context(true, false, true)
  kind.val = -1
  ffi_sidebar_tooltip_fixture_fire("mouseenter")
  assert_eq(kind.val, 0)
  assert_eq(wait.val, 0)
  kind.val = -1
  ffi_sidebar_tooltip_fixture_fire("focus")
  assert_eq(kind.val, 2)

  ffi_sidebar_tooltip_fixture_set_context(false, false, true)
  kind.val = -1
  ffi_sidebar_tooltip_fixture_fire("mouseenter")
  ffi_sidebar_tooltip_fixture_fire("focus")
  assert_eq(kind.val, -1)
  ffi_sidebar_tooltip_fixture_set_context(true, true, true)
  ffi_sidebar_tooltip_fixture_fire("mouseenter")
  ffi_sidebar_tooltip_fixture_fire("focus")
  assert_eq(kind.val, -1)
  ffi_sidebar_tooltip_fixture_set_context(true, false, false)
  ffi_sidebar_tooltip_fixture_fire("mouseenter")
  ffi_sidebar_tooltip_fixture_fire("focus")
  assert_eq(kind.val, -1)

  ffi_sidebar_tooltip_fixture_set_context(true, false, true)
  ffi_sidebar_tooltip_fixture_set_disabled(true)
  ffi_sidebar_tooltip_fixture_fire("mouseenter")
  ffi_sidebar_tooltip_fixture_fire("focus")
  assert_eq(kind.val, -1)
  ffi_sidebar_tooltip_fixture_set_disabled(false)

  bind_floating_sync("sidebar-projects-tooltip", _ => ())
  assert_true(set_floating_open("sidebar-projects-tooltip", true))
  ffi_sidebar_tooltip_fixture_fire_escape()
  assert_eq(kind.val, 7)
  assert_true(ffi_sidebar_tooltip_fixture_escape_handled())

  ffi_sidebar_tooltip_fixture_set_context(false, false, true)
  kind.val = -1
  ffi_sidebar_tooltip_fixture_fire_observer()
  let closed_kind = kind.val
  reset_sidebar_tooltip_bindings("sidebar-projects-tooltip")
  ffi_restore_sidebar_tooltip_fixture()
  assert_eq(closed_kind, 9)
}

///|
test "sidebar outline variant keeps its shadcn hover and active ring" {
  assert_true(
    UiInteractionCss.contains(
      "[data-slot=\"sidebar-menu-button\"][data-variant=\"outline\"]:not(:disabled):not([aria-disabled=\"true\"]):hover",
    ),
  )
  assert_true(
    UiInteractionCss.contains(
      "[data-slot=\"sidebar-menu-button\"][data-variant=\"outline\"]:where(:active,[data-active=\"true\"])",
    ),
  )
  assert_true(
    UiInteractionCss.contains(
      "--rui-sidebar-item-shadow:0 0 0 1px var(--rui-sidebar-accent",
    ),
  )
}
