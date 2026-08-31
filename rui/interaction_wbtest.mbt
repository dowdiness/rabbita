///|
#cfg(target="js")
extern "js" fn ffi_install_escape_fixture(
  kind : String,
  id : String,
  popup_id : String,
) -> Unit =
  #| (kind, id, popupId) => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const documentListeners = {}
  #|   const addDocumentListener = (type, callback) => {
  #|     const callbacks = documentListeners[type] ||= []
  #|     callbacks.push(callback)
  #|   }
  #|   class FakeNode {
  #|     constructor(nodeType = 0) {
  #|       this.nodeType = nodeType
  #|       this.parentNode = null
  #|     }
  #|     isSameNode(other) { return this === other }
  #|   }
  #|   class FakeElement extends FakeNode {
  #|     constructor() {
  #|       super(1)
  #|       this.isConnected = true
  #|       this.dataset = {}
  #|       this.listeners = {}
  #|     }
  #|     getAttribute(name) {
  #|       if (!name.startsWith("data-")) return this[name] ?? ""
  #|       const key = name.slice(5).replace(/-([a-z])/g, (_, char) => char.toUpperCase())
  #|       return this.dataset[key] ?? ""
  #|     }
  #|     setAttribute(name, value) {
  #|       if (!name.startsWith("data-")) {
  #|         this[name] = String(value)
  #|         return
  #|       }
  #|       const key = name.slice(5).replace(/-([a-z])/g, (_, char) => char.toUpperCase())
  #|       this.dataset[key] = String(value)
  #|     }
  #|     removeAttribute(name) {
  #|       if (!name.startsWith("data-")) {
  #|         delete this[name]
  #|         return
  #|       }
  #|       const key = name.slice(5).replace(/-([a-z])/g, (_, char) => char.toUpperCase())
  #|       delete this.dataset[key]
  #|     }
  #|     hasAttribute(name) { return this.getAttribute(name) !== "" }
  #|     addEventListener(type, callback) {
  #|       const callbacks = this.listeners[type] ||= []
  #|       callbacks.push(callback)
  #|     }
  #|     removeEventListener(type, callback) {
  #|       this.listeners[type] = (this.listeners[type] || [])
  #|         .filter(current => current !== callback)
  #|     }
  #|     emit(type, event) {
  #|       for (const callback of this.listeners[type] || []) callback(event)
  #|     }
  #|     closest() { return null }
  #|     contains(target) { return target === this }
  #|     querySelector() { return null }
  #|     querySelectorAll() { return [] }
  #|     getBoundingClientRect() {
  #|       return { left: 0, right: 100, top: 0, bottom: 100, width: 100, height: 100 }
  #|     }
  #|   }
  #|   class FakeHTMLElement extends FakeElement {
  #|     constructor() {
  #|       super()
  #|       this.popover = null
  #|       this.style = {
  #|         getPropertyValue: () => "",
  #|         setProperty() {},
  #|         removeProperty() { return "" },
  #|       }
  #|     }
  #|     focus() {}
  #|   }
  #|   class FakeHTMLDialogElement extends FakeHTMLElement {
  #|     constructor(dialogId) {
  #|       super()
  #|       this.id = dialogId
  #|       this.open = true
  #|       this.dataset = {
  #|         modal: "true",
  #|         closeOnEscape: "true",
  #|         restoreFocus: "true",
  #|       }
  #|     }
  #|     close() {
  #|       if (!this.open) return
  #|       this.open = false
  #|       this.emit("close", new FakeEvent(this))
  #|     }
  #|     show() { this.open = true }
  #|     showModal() { this.open = true }
  #|   }
  #|   class FakeEvent {
  #|     constructor(target) {
  #|       this.target = target
  #|       this.currentTarget = null
  #|       this.defaultPrevented = false
  #|       this.timeStamp = 0
  #|     }
  #|     preventDefault() { this.defaultPrevented = true }
  #|     stopPropagation() {}
  #|     stopImmediatePropagation() {}
  #|     composedPath() { return [this.target] }
  #|   }
  #|   class FakeKeyboardEvent extends FakeEvent {
  #|     constructor(target, key) {
  #|       super(target)
  #|       this.key = key
  #|     }
  #|   }
  #|   class FakeMouseEvent extends FakeEvent {
  #|     constructor(target) {
  #|       super(target)
  #|       this.clientX = 0
  #|       this.clientY = 0
  #|     }
  #|   }
  #|   class FakeToggleEvent extends FakeEvent {
  #|     constructor(target, newState) {
  #|       super(target)
  #|       this.newState = newState
  #|       this.oldState = newState === "open" ? "closed" : "open"
  #|     }
  #|   }
  #|   let dialog = null
  #|   let popup = null
  #|   const makePopup = (popupId, popover, dataset, open) =>
  #|     Object.assign(new FakeHTMLElement(), {
  #|       id: popupId,
  #|       popover,
  #|       dataset,
  #|       __open: open,
  #|       matches(selector) {
  #|         return selector === ":popover-open" && this.__open
  #|       },
  #|       showPopover() {
  #|         if (this.__open) return
  #|         this.__open = true
  #|         this.emit("toggle", new FakeToggleEvent(this, "open"))
  #|       },
  #|       hidePopover() {
  #|         if (!this.__open) return
  #|         this.__open = false
  #|         globalThis.__ruiEscapeFixture.hidden += 1
  #|         this.emit("toggle", new FakeToggleEvent(this, "closed"))
  #|       },
  #|     })
  #|   if (kind === "dialog" || kind === "layered") {
  #|     dialog = new FakeHTMLDialogElement(id)
  #|   }
  #|   if (kind === "floating" || kind === "fallback" || kind === "layered") {
  #|     const resolvedPopupId = kind === "layered" ? popupId : id
  #|     popup = makePopup(
  #|       resolvedPopupId,
  #|       kind === "fallback" ? null : "manual",
  #|       {
  #|         restoreFocus: "false",
  #|         slot: "popover-content",
  #|       },
  #|       kind === "floating" || kind === "layered",
  #|     )
  #|   }
  #|   const body = new FakeHTMLElement()
  #|   const document = Object.assign(new FakeNode(9), {
  #|     activeElement: null,
  #|     body,
  #|     documentElement: Object.assign(new FakeElement(), {
  #|       clientWidth: 1024,
  #|       clientHeight: 768,
  #|     }),
  #|     getElementById: value => {
  #|       if (dialog && value === id) return dialog
  #|       if (popup && value === (kind === "layered" ? popupId : id)) return popup
  #|       return null
  #|     },
  #|     querySelector: () => null,
  #|     addEventListener: addDocumentListener,
  #|     removeEventListener() {},
  #|   })
  #|   const fixture = globalThis.__ruiEscapeFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     Node: globalThis.Node,
  #|     hadNode: own("Node"),
  #|     Element: globalThis.Element,
  #|     hadElement: own("Element"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     HTMLDialogElement: globalThis.HTMLDialogElement,
  #|     hadHTMLDialogElement: own("HTMLDialogElement"),
  #|     Event: globalThis.Event,
  #|     hadEvent: own("Event"),
  #|     KeyboardEvent: globalThis.KeyboardEvent,
  #|     hadKeyboardEvent: own("KeyboardEvent"),
  #|     MouseEvent: globalThis.MouseEvent,
  #|     hadMouseEvent: own("MouseEvent"),
  #|     ToggleEvent: globalThis.ToggleEvent,
  #|     hadToggleEvent: own("ToggleEvent"),
  #|     documentListeners,
  #|     document,
  #|     dialog,
  #|     popup,
  #|     requested: 0,
  #|     hidden: 0,
  #|     stopped: 0,
  #|     prevented: false,
  #|     FakeEvent,
  #|     FakeKeyboardEvent,
  #|     setPopupOpen: value => { popup.__open = value },
  #|     replacePopup: () => {
  #|       const previous = popup
  #|       previous.isConnected = false
  #|       fixture.previousPopup = previous
  #|       popup = makePopup(
  #|         previous.id,
  #|         previous.popover,
  #|         { ...previous.dataset, lightDismiss: "true" },
  #|         true,
  #|       )
  #|       fixture.popup = popup
  #|     },
  #|   }
  #|   globalThis.Node = FakeNode
  #|   globalThis.Element = FakeElement
  #|   globalThis.HTMLElement = FakeHTMLElement
  #|   globalThis.HTMLDialogElement = FakeHTMLDialogElement
  #|   globalThis.Event = FakeEvent
  #|   globalThis.KeyboardEvent = FakeKeyboardEvent
  #|   globalThis.MouseEvent = FakeMouseEvent
  #|   globalThis.ToggleEvent = FakeToggleEvent
  #|   globalThis.document = document
  #|   globalThis.window = {
  #|     queueMicrotask: callback => callback(),
  #|     requestAnimationFrame: callback => { callback(0); return 1 },
  #|     cancelAnimationFrame() {},
  #|     performance: { now: () => 0 },
  #|     addEventListener() {},
  #|     removeEventListener() {},
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_escape_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiEscapeFixture
  #|   const event = new fixture.FakeKeyboardEvent(fixture.document, "Escape")
  #|   const original = event.preventDefault.bind(event)
  #|   event.preventDefault = () => {
  #|     original()
  #|     fixture.prevented = true
  #|   }
  #|   for (const callback of fixture.documentListeners.keydown || []) callback(event)
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_plain_closed_toggle_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiEscapeFixture
  #|   fixture.setPopupOpen(false)
  #|   fixture.popup.emit("toggle", new fixture.FakeEvent(fixture.popup))
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_replace_popup_fixture() -> Unit =
  #| () => globalThis.__ruiEscapeFixture.replacePopup()

///|
#cfg(target="js")
extern "js" fn ffi_fire_previous_closed_toggle_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiEscapeFixture
  #|   fixture.previousPopup.__open = false
  #|   fixture.previousPopup.emit(
  #|     "toggle",
  #|     new fixture.FakeEvent(fixture.previousPopup),
  #|   )
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_outside_pointer_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiEscapeFixture
  #|   const event = new fixture.FakeEvent(fixture.document.body)
  #|   for (const callback of fixture.documentListeners.pointerdown || []) {
  #|     callback(event)
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_escape_fixture_requested() -> Int =
  #| () => globalThis.__ruiEscapeFixture?.requested ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_escape_fixture_hidden() -> Int =
  #| () => globalThis.__ruiEscapeFixture?.hidden ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_escape_fixture_stopped() -> Int =
  #| () => globalThis.__ruiEscapeFixture?.stopped ?? 0

///|
#cfg(target="js")
extern "js" fn ffi_escape_fixture_prevented() -> Bool =
  #| () => Boolean(globalThis.__ruiEscapeFixture?.prevented)

///|
#cfg(target="js")
extern "js" fn ffi_mark_dialog_escape_fixture_requested() -> Unit =
  #| () => { globalThis.__ruiEscapeFixture.requested += 1 }

///|
#cfg(target="js")
extern "js" fn ffi_mark_floating_positioning_stopped() -> Unit =
  #| () => { globalThis.__ruiEscapeFixture.stopped += 1 }

///|
#cfg(target="js")
extern "js" fn ffi_restore_escape_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiEscapeFixture
  #|   if (!fixture) return
  #|   const restore = (key, had, value) => {
  #|     if (had) globalThis[key] = value
  #|     else delete globalThis[key]
  #|   }
  #|   restore("document", fixture.hadDocument, fixture.document)
  #|   restore("window", fixture.hadWindow, fixture.window)
  #|   restore("Node", fixture.hadNode, fixture.Node)
  #|   restore("Element", fixture.hadElement, fixture.Element)
  #|   restore("HTMLElement", fixture.hadHTMLElement, fixture.HTMLElement)
  #|   restore(
  #|     "HTMLDialogElement",
  #|     fixture.hadHTMLDialogElement,
  #|     fixture.HTMLDialogElement,
  #|   )
  #|   restore("Event", fixture.hadEvent, fixture.Event)
  #|   restore("KeyboardEvent", fixture.hadKeyboardEvent, fixture.KeyboardEvent)
  #|   restore("MouseEvent", fixture.hadMouseEvent, fixture.MouseEvent)
  #|   restore("ToggleEvent", fixture.hadToggleEvent, fixture.ToggleEvent)
  #|   delete globalThis.__ruiEscapeFixture
  #| }

///|
#cfg(target="js")
test "Escape explicitly requests closing the top modal dialog" {
  ffi_install_escape_fixture("dialog", "escape-dialog", "")
  bind_dialog_layer("escape-dialog", ffi_mark_dialog_escape_fixture_requested)
  mark_dialog_layer("escape-dialog", true)
  ffi_fire_escape_fixture()
  let requested = ffi_escape_fixture_requested()
  let prevented = ffi_escape_fixture_prevented()
  ffi_restore_escape_fixture()
  assert_eq(requested, 1)
  assert_true(prevented)
}

///|
#cfg(target="js")
test "Escape explicitly hides the top native popover" {
  ffi_install_escape_fixture("floating", "escape-popover", "")
  bind_floating_sync("escape-popover", _ => ())
  ffi_fire_escape_fixture()
  let hidden = ffi_escape_fixture_hidden()
  let prevented = ffi_escape_fixture_prevented()
  ffi_restore_escape_fixture()
  assert_eq(hidden, 1)
  assert_true(prevented)
}

///|
#cfg(target="js")
test "native light dismiss synchronizes from actual popover state" {
  ffi_install_escape_fixture("floating", "plain-toggle-popover", "")
  let mut closed = 0
  bind_floating_sync("plain-toggle-popover", open => if !open { closed += 1 })
  ffi_fire_plain_closed_toggle_fixture()
  let stack_size = floating_stack.val.length()
  ffi_restore_escape_fixture()
  assert_eq(closed, 1)
  assert_eq(stack_size, 0)
}

///|
#cfg(target="js")
test "floating dismissal rebinds a replaced physical element" {
  ffi_install_escape_fixture("floating", "replaced-floating-popover", "")
  let mut closed = 0
  bind_floating_sync("replaced-floating-popover", open => {
    if !open {
      closed += 1
    }
  })
  ffi_replace_popup_fixture()
  ffi_fire_previous_closed_toggle_fixture()
  assert_eq(closed, 0)
  assert_eq(floating_stack.val.length(), 1)
  ffi_fire_outside_pointer_fixture()
  let hidden = ffi_escape_fixture_hidden()
  let stack_size = floating_stack.val.length()
  ffi_restore_escape_fixture()
  assert_eq(hidden, 1)
  assert_eq(closed, 1)
  assert_eq(stack_size, 0)
}

///|
#cfg(target="js")
test "fallback floating layer stays in the stack and closes through one lifecycle" {
  ffi_install_escape_fixture("fallback", "fallback-popover", "")
  let mut closed = 0
  bind_floating_sync("fallback-popover", open => if !open { closed += 1 })
  floating_set_stop_positioning(
    "fallback-popover", ffi_mark_floating_positioning_stopped,
  )
  ignore(set_floating_open("fallback-popover", true))
  let open_stack = floating_stack.val.length()
  ffi_fire_escape_fixture()
  let closed_stack = floating_stack.val.length()
  let stopped = ffi_escape_fixture_stopped()
  let prevented = ffi_escape_fixture_prevented()
  ffi_restore_escape_fixture()
  assert_eq(open_stack, 1)
  assert_eq(closed_stack, 0)
  assert_eq(closed, 1)
  assert_eq(stopped, 1)
  assert_true(prevented)
}

///|
#cfg(target="js")
test "Escape closes only the floating layer above a modal dialog" {
  ffi_install_escape_fixture("layered", "layered-dialog", "layered-popover")
  bind_dialog_layer("layered-dialog", ffi_mark_dialog_escape_fixture_requested)
  mark_dialog_layer("layered-dialog", true)
  bind_floating_sync("layered-popover", _ => ())
  ffi_fire_escape_fixture()
  let requested = ffi_escape_fixture_requested()
  let hidden = ffi_escape_fixture_hidden()
  ffi_restore_escape_fixture()
  assert_eq(requested, 0)
  assert_eq(hidden, 1)
}

///|
test "modal dialog restores focus only when an explicit final target is set" {
  assert_false(dialog_should_restore_focus(true, true, ""))
  assert_true(dialog_should_restore_focus(true, true, "document-actions"))
  assert_false(dialog_should_restore_focus(true, false, "document-actions"))
  assert_true(dialog_should_restore_focus(false, true, ""))
}
