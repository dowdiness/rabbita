///|
#cfg(target="js")
extern "js" fn ffi_install_late_mount_fixture(id : String) -> Unit =
  #| id => {
  #|   const keys = [
  #|     "window", "document", "CSS", "EventTarget", "Node", "Element",
  #|     "HTMLElement", "HTMLDialogElement", "Document", "Window", "Event",
  #|     "MouseEvent", "KeyboardEvent", "FocusEvent", "ToggleEvent",
  #|     "TransitionEvent",
  #|   ]
  #|   const globals = new Map(keys.map(key => [key, {
  #|     had: Object.prototype.hasOwnProperty.call(globalThis, key),
  #|     value: globalThis[key],
  #|   }]))
  #|   const frameQueue = []
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
  #|     constructor() {
  #|       this.values = new Map([
  #|         ["position-area", "bottom center"],
  #|         ["position-try-fallbacks", "--rui-flip-block"],
  #|       ])
  #|     }
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
  #|       this.clientWidth = 0
  #|       this.clientHeight = 0
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
  #|     getBoundingClientRect() {
  #|       return this.rect ?? {
  #|         left: 0, right: 0, top: 0, bottom: 0, width: 0, height: 0,
  #|       }
  #|     }
  #|   }
  #|   class FakeHTMLElement extends FakeElement {
  #|     constructor(id, attributes = {}) {
  #|       super(id, attributes)
  #|       this.popover = null
  #|       this.popoverOpen = false
  #|       this.offsetWidth = 0
  #|       this.offsetHeight = 0
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
  #|       this.bubbles = Boolean(init.bubbles)
  #|       this.cancelable = Boolean(init.cancelable)
  #|       this.composed = Boolean(init.composed)
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
  #|   class FakeTransitionEvent extends FakeEvent {}
  #|   class FakeDocument extends FakeNode {
  #|     constructor() {
  #|       super(9)
  #|       this.body = new FakeHTMLElement("body")
  #|       this.documentElement = new FakeHTMLElement("html")
  #|       this.documentElement.clientWidth = 1024
  #|       this.documentElement.clientHeight = 768
  #|       this.activeElement = this.body
  #|     }
  #|     getElementById(value) {
  #|       if (value === id + "-root") return fixture.phase >= 1 ? root : null
  #|       if (value === id + "-trigger") return fixture.phase >= 2 ? trigger : null
  #|       if (value === id) return fixture.phase >= 2 ? popup : null
  #|       return null
  #|     }
  #|   }
  #|   class FakeWindow extends FakeEventTarget {
  #|     constructor() {
  #|       super()
  #|       this.performance = { now: () => 0 }
  #|       this.visualViewport = null
  #|     }
  #|     requestAnimationFrame(callback) {
  #|       frameQueue.push(callback)
  #|       return frameQueue.length
  #|     }
  #|     cancelAnimationFrame() {}
  #|     queueMicrotask(callback) { callback() }
  #|     getComputedStyle(element) { return element.style }
  #|   }
  #|   const root = new FakeHTMLElement(id + "-root", {
  #|     "data-delay": "17",
  #|     "data-close-delay": "7",
  #|     "data-close-on-click": "true",
  #|     "data-hoverable": "true",
  #|     "data-open-delay": "23",
  #|   })
  #|   const trigger = new FakeHTMLElement(id + "-trigger", {
  #|     "data-delay": "23", "data-close-delay": "11",
  #|   })
  #|   trigger.rect = {
  #|     left: 20, right: 100, top: 20, bottom: 44, width: 80, height: 24,
  #|   }
  #|   const popup = new FakeHTMLElement(id, {
  #|     "data-slot": "tooltip-content",
  #|     "data-restore-focus": "false",
  #|     "data-trigger-id": id + "-trigger",
  #|   })
  #|   popup.popover = "manual"
  #|   popup.rect = {
  #|     left: 0, right: 120, top: 0, bottom: 48, width: 120, height: 48,
  #|   }
  #|   root.append(trigger)
  #|   root.append(popup)
  #|   let fixture
  #|   const document = new FakeDocument()
  #|   const window = new FakeWindow()
  #|   window.document = document
  #|   fixture = globalThis.__ruiLateMountFixture = {
  #|     globals, phase: 0, root, trigger, popup, frameQueue, window,
  #|   }
  #|   Object.assign(globalThis, {
  #|     window, document, CSS: { supports: () => true },
  #|     EventTarget: FakeEventTarget, Node: FakeNode, Element: FakeElement,
  #|     HTMLElement: FakeHTMLElement, HTMLDialogElement: FakeHTMLDialogElement,
  #|     Document: FakeDocument, Window: FakeWindow, Event: FakeEvent,
  #|     MouseEvent: FakeMouseEvent, KeyboardEvent: FakeKeyboardEvent,
  #|     FocusEvent: FakeFocusEvent, ToggleEvent: FakeToggleEvent,
  #|     TransitionEvent: FakeTransitionEvent,
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_mount_late_root_and_advance_frame() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiLateMountFixture
  #|   fixture.phase = 1
  #|   fixture.frameQueue.shift()?.(0)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_flush_late_mount_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiLateMountFixture
  #|   fixture.phase = 2
  #|   while (fixture.frameQueue.length) fixture.frameQueue.shift()(0)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_late_mount_mouseenter() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiLateMountFixture
  #|   fixture.trigger.dispatchEvent(new MouseEvent("mouseenter"))
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_restore_late_mount_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiLateMountFixture
  #|   if (!fixture) return
  #|   fixture.root.isConnected = false
  #|   fixture.trigger.isConnected = false
  #|   fixture.popup.isConnected = false
  #|   for (const [key, saved] of fixture.globals) {
  #|     if (saved.had) globalThis[key] = saved.value
  #|     else delete globalThis[key]
  #|   }
  #|   delete globalThis.__ruiLateMountFixture
  #| }

///|
#cfg(target="js")
fn late_tooltip_bound(id : String) -> Bool {
  tooltip_live_binding(id) is Some(_)
}

///|
#cfg(target="js")
fn late_hover_card_bound(id : String) -> Bool {
  hover_card_event_bindings.get(id) is Some(_)
}

///|
#cfg(target="js")
fn late_floating_bound(id : String) -> Bool {
  floating_live_layer(id) is Some(_)
}

///|
#cfg(target="js")
fn late_floating_open(id : String) -> Bool {
  if floating_live_layer(id) is Some(layer) {
    floating_layer_is_open(layer)
  } else {
    false
  }
}

///|
#cfg(target="js")
fn reset_late_mount_bindings(id : String) -> Unit {
  if tooltip_event_bindings.get(id) is Some(binding) &&
    binding.sidebar_observer.val is Some(observer) {
    observer.disconnect()
  }
  ignore(tooltip_event_bindings.remove(id))
  ignore(hover_card_event_bindings.remove(id))
  if floating_live_layer(id) is Some(_) {
    ignore(set_floating_open(id, false))
  }
  floating_stop(id)
  ignore(floating_layers.remove(id))
  floating_update_stack(id, false)
}

///|
#cfg(target="js")
test "tooltip events and native sync bind after delayed mount" {
  let kind = Ref(-1)
  let wait = Ref(-1)
  ffi_install_late_mount_fixture("late-tooltip")
  ui_after_ready("tooltip-events:late-tooltip", () => {
    bind_tooltip_events("late-tooltip", (next_kind, next_wait) => {
      kind.val = next_kind
      wait.val = next_wait
    })
  })
  ui_after_mount("late-tooltip", () => {
    bind_floating_sync("late-tooltip", _ => ())
  })
  let bound_before_mount = late_tooltip_bound("late-tooltip")
  ffi_mount_late_root_and_advance_frame()
  let bound_with_only_root = late_tooltip_bound("late-tooltip")
  ffi_flush_late_mount_fixture()
  ffi_fire_late_mount_mouseenter()
  let bound = late_tooltip_bound("late-tooltip")
  let floating_bound = late_floating_bound("late-tooltip")
  reset_late_mount_bindings("late-tooltip")
  ffi_restore_late_mount_fixture()
  assert_true(!bound_before_mount)
  assert_true(!bound_with_only_root)
  assert_true(bound)
  assert_true(floating_bound)
  assert_eq(kind.val, 0)
  assert_eq(wait.val, 17)
}

///|
#cfg(target="js")
test "hover card events bind after delayed mount" {
  let kind = Ref(-1)
  let wait = Ref(-1)
  ffi_install_late_mount_fixture("late-hover-card")
  ui_after_ready("hover-card-events:late-hover-card", () => {
    bind_hover_card_events("late-hover-card", (next_kind, next_wait) => {
      kind.val = next_kind
      wait.val = next_wait
    })
  })
  let bound_before_mount = late_hover_card_bound("late-hover-card")
  ffi_mount_late_root_and_advance_frame()
  let bound_with_only_root = late_hover_card_bound("late-hover-card")
  ffi_flush_late_mount_fixture()
  ffi_fire_late_mount_mouseenter()
  let bound = late_hover_card_bound("late-hover-card")
  reset_late_mount_bindings("late-hover-card")
  ffi_restore_late_mount_fixture()
  assert_true(!bound_before_mount)
  assert_true(!bound_with_only_root)
  assert_true(bound)
  assert_eq(kind.val, 0)
  assert_eq(wait.val, 23)
}

///|
#cfg(target="js")
test "floating default-open waits for its delayed popup mount" {
  ffi_install_late_mount_fixture("late-default-open")
  floating_set_open_when_ready("late-default-open", true)
  let open_before_mount = late_floating_open("late-default-open")
  ffi_mount_late_root_and_advance_frame()
  let open_with_only_root = late_floating_open("late-default-open")
  ffi_flush_late_mount_fixture()
  let open = late_floating_open("late-default-open")
  reset_late_mount_bindings("late-default-open")
  ffi_restore_late_mount_fixture()
  assert_true(!open_before_mount)
  assert_true(!open_with_only_root)
  assert_true(open)
}
