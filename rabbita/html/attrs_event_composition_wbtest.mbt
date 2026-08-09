///|
#cfg(target="js")
struct EventCompositionScheduler {}

///|
#cfg(target="js")
impl @cmd.Scheduler for EventCompositionScheduler with fn run_effect(
  self,
  kind,
  effect,
) {
  ignore(kind)
  effect(self)
}

///|
#cfg(target="js")
impl @cmd.Scheduler for EventCompositionScheduler with fn queue_message(
  self,
  path,
  message,
) {
  ignore((self, path, message))
}

///|
#cfg(target="js")
impl @cmd.Scheduler for EventCompositionScheduler with fn drain_message(self) {
  ignore(self)
}

///|
#cfg(target="js")
impl @cmd.Scheduler for EventCompositionScheduler with fn hooks(self) {
  ignore(self)
  { url_request: None, url_changed: None }
}

///|
#cfg(target="js")
extern "js" fn with_event_composition_event(
  event_kind : String,
  value : String,
  run : (@dom.Event) -> Bool,
) -> Bool =
  #| (eventKind, value, run) => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const hadMouseEvent = own("MouseEvent")
  #|   const previousMouseEvent = globalThis.MouseEvent
  #|   const hadInputEvent = own("InputEvent")
  #|   const previousInputEvent = globalThis.InputEvent
  #|   const hadInputElement = own("HTMLInputElement")
  #|   const previousInputElement = globalThis.HTMLInputElement
  #|   class FakeMouseEvent {
  #|     constructor() {
  #|       this.defaultPrevented = false
  #|       this.target = null
  #|       this.currentTarget = null
  #|     }
  #|     preventDefault() { this.defaultPrevented = true }
  #|     stopPropagation() {}
  #|   }
  #|   class FakeInputElement {
  #|     constructor(inputValue) { this.value = inputValue }
  #|   }
  #|   class FakeInputEvent {
  #|     constructor(inputValue) {
  #|       this.defaultPrevented = false
  #|       this.target = new FakeInputElement(inputValue)
  #|       this.currentTarget = this.target
  #|     }
  #|     preventDefault() { this.defaultPrevented = true }
  #|     stopPropagation() {}
  #|   }
  #|   globalThis.MouseEvent = FakeMouseEvent
  #|   globalThis.InputEvent = FakeInputEvent
  #|   globalThis.HTMLInputElement = FakeInputElement
  #|   const event = eventKind === "mouse"
  #|     ? new FakeMouseEvent()
  #|     : eventKind === "input"
  #|       ? new FakeInputEvent(value)
  #|       : {
  #|           defaultPrevented: false,
  #|           target: null,
  #|           currentTarget: null,
  #|           preventDefault() { this.defaultPrevented = true },
  #|           stopPropagation() {},
  #|         }
  #|   try {
  #|     return run(event)
  #|   } finally {
  #|     if (hadMouseEvent) globalThis.MouseEvent = previousMouseEvent
  #|     else delete globalThis.MouseEvent
  #|     if (hadInputEvent) globalThis.InputEvent = previousInputEvent
  #|     else delete globalThis.InputEvent
  #|     if (hadInputElement) globalThis.HTMLInputElement = previousInputElement
  #|     else delete globalThis.HTMLInputElement
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn event_composition_default_prevented(event : @dom.Event) -> Bool = "event => event.defaultPrevented"

///|
#cfg(target="js")
fn event_composition_command(trace : Array[String], label : String) -> @cmd.Cmd {
  @cmd.custom_cmd(_ => trace.push(label))
}

///|
#cfg(target="js")
fn event_composition_props(html : Html) -> @runtime.Props raise {
  match html.to_virtual_dom() {
    Elem(_, props, _, namespace_uri=None) => props
    _ => fail("expected an HTML element")
  }
}

///|
#cfg(target="js")
fn dispatch_composed_event(
  props : @runtime.Props,
  event_name : String,
  event_kind : String,
  value : String,
) -> Bool raise {
  guard props.handlers.get(event_name) is Some(handler) else {
    fail("expected handler for event: \{event_name}")
  }
  let scheduler = EventCompositionScheduler::{  }
  with_event_composition_event(event_kind, value, event => {
    handler(event, scheduler)
    event_composition_default_prevented(event)
  })
}

///|
#cfg(target="js")
test "event families compose through one handler per event name" {
  let attrs = Attrs::build()
    .on_click(_ => @cmd.none)
    .on_click(_ => @cmd.none)
    .on_keydown(_ => @cmd.none)
    .on_keydown(_ => @cmd.none)
    .on_focus(_ => @cmd.none)
    .on_focus(_ => @cmd.none)
    .on_pointerdown(_ => @cmd.none)
    .on_pointerdown(_ => @cmd.none)
    .on_scroll(_ => @cmd.none)
    .on_scroll(_ => @cmd.none)
    .on_input(_ => @cmd.none)
    .on_input(_ => @cmd.none)
    .on_change(_ => @cmd.none)
    .on_change(_ => @cmd.none)
    .on_submit(_ => @cmd.none)
    .on_submit(_ => @cmd.none)
    .on_reset(_ => @cmd.none)
    .on_reset(_ => @cmd.none)
    .on_dragstart(_ => @cmd.none)
    .on_dragstart(_ => @cmd.none)
    .on_copy(_ => @cmd.none)
    .on_copy(_ => @cmd.none)
    .on_compositionstart(_ => @cmd.none)
    .on_compositionstart(_ => @cmd.none)
    .on_wheel(_ => @cmd.none)
    .on_wheel(_ => @cmd.none)
  assert_eq(attrs.0.handlers.length(), 13)
}

///|
#cfg(target="js")
test "beforeinput handlers compose as input events" {
  let trace : Array[String] = []
  let attrs = Attrs::build()
    .on_beforeinput(_ => event_composition_command(trace, "A"))
    .on_beforeinput(_ => event_composition_command(trace, "B"))
  assert_eq(attrs.0.handlers.length(), 1)
  assert_true(attrs.0.handlers.contains("beforeinput"))
  ignore(dispatch_composed_event(attrs.0, "beforeinput", "input", "typed"))
  assert_eq(trace.join(","), "A,B")
}

///|
#cfg(target="js")
test "same event handlers compose once in registration order" {
  let trace : Array[String] = []
  let attrs = Attrs::build()
    .on_click(_ => event_composition_command(trace, "A"))
    .on_click(_ => event_composition_command(trace, "B"))
    .on_click(_ => event_composition_command(trace, "C"))
  assert_eq(attrs.0.handlers.length(), 1)
  assert_true(attrs.0.handlers.contains("click"))
  ignore(dispatch_composed_event(attrs.0, "click", "mouse", ""))
  assert_eq(trace.join(","), "A,B,C")
}

///|
#cfg(target="js")
test "Attrs copy isolates later handler composition" {
  let trace : Array[String] = []
  let original = Attrs::build().on_click(_ => {
    event_composition_command(trace, "original")
  })
  let copied = original
    .copy()
    .on_click(_ => event_composition_command(trace, "copied"))
  ignore(dispatch_composed_event(original.0, "click", "mouse", ""))
  assert_eq(trace.join(","), "original")
  trace.clear()
  ignore(dispatch_composed_event(copied.0, "click", "mouse", ""))
  assert_eq(trace.join(","), "original,copied")
  trace.clear()
  ignore(dispatch_composed_event(original.0, "click", "mouse", ""))
  assert_eq(trace.join(","), "original")
}

///|
#cfg(target="js")
test "button named callback appends without mutating caller attrs" {
  let trace : Array[String] = []
  let caller_attrs = Attrs::build().on_click(_ => {
    event_composition_command(trace, "caller")
  })
  let html = button(
    attrs=caller_attrs,
    on_click=event_composition_command(trace, "internal"),
    nothing,
  )
  ignore(
    dispatch_composed_event(event_composition_props(html), "click", "mouse", ""),
  )
  assert_eq(trace.join(","), "caller,internal")
  trace.clear()
  ignore(dispatch_composed_event(caller_attrs.0, "click", "mouse", ""))
  assert_eq(trace.join(","), "caller")
}

///|
#cfg(target="js")
test "input and change named callbacks append to attrs handlers" {
  let trace : Array[String] = []
  let caller_attrs = Attrs::build()
    .on_input(_ => event_composition_command(trace, "input-caller"))
    .on_change(_ => event_composition_command(trace, "change-caller"))
  let html = input(
    attrs=caller_attrs,
    on_input=Emit(value => {
      event_composition_command(trace, "input-internal:\{value}")
    }),
    on_change=Emit(value => {
      event_composition_command(trace, "change-internal:\{value}")
    }),
  )
  let props = event_composition_props(html)
  ignore(dispatch_composed_event(props, "input", "input", "typed"))
  assert_eq(trace.join(","), "input-caller,input-internal:typed")
  trace.clear()
  ignore(dispatch_composed_event(props, "change", "input", "changed"))
  assert_eq(trace.join(","), "change-caller,change-internal:changed")
}

///|
#cfg(target="js")
test "form submit preserves caller order and prevention" {
  let trace : Array[String] = []
  let form_attrs = Attrs::build().on_submit(event => {
    trace.push("submit-caller:\{event_composition_default_prevented(event)}")
    @cmd.none
  })
  let form_html = form(
    attrs=form_attrs,
    on_submit=event_composition_command(trace, "submit-internal"),
    nothing,
  )
  assert_true(
    dispatch_composed_event(
      event_composition_props(form_html),
      "submit",
      "generic",
      "",
    ),
  )
  assert_eq(trace.join(","), "submit-caller:false,submit-internal")
}
