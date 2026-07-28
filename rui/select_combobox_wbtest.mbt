///|
test "select typeahead skips disabled options and cycles enabled matches" {
  let options = [
    select_option(value="aaron", label="Aaron", disabled=true),
    select_option(value="apple", label="Apple"),
    select_option(value="avocado", label="Avocado"),
  ]
  assert_eq(select_typeahead_index(options, -1, "a"), 1)
  assert_eq(select_typeahead_index(options, 1, "a"), 2)
  assert_eq(select_typeahead_index(options, 2, "z"), -1)
  assert_eq(select_typeahead_search("", "A"), "a")
  assert_eq(select_typeahead_search("a", "A"), "a")
  assert_eq(select_typeahead_search("a", "p"), "ap")
}

///|
test "combobox derives selected input and treats that label as an unfiltered query" {
  let options = [
    combobox_option(value="apple", label="Apple"),
    combobox_option(value="banana", label="Banana"),
  ]
  assert_eq(combobox_selected_input_value(options, ["banana"], false), "Banana")
  assert_eq(combobox_filter_query(options, ["banana"], false, "Banana"), "")
  assert_eq(
    combobox_filter_query(options, ["banana"], false, "Bananax"),
    "Bananax",
  )
  assert_eq(combobox_selected_input_value(options, ["banana"], true), "")
}

///|
test "combobox virtual navigation starts at an edge and skips disabled matches" {
  let options = [
    combobox_option(value="disabled", label="Disabled", disabled=true),
    combobox_option(value="apple", label="Apple"),
    combobox_option(value="banana", label="Banana"),
  ]
  assert_eq(combobox_next_match(options, "", -1, 1), 1)
  assert_eq(combobox_next_match(options, "", -1, -1), 2)
  assert_eq(combobox_next_match(options, "app", -1, 1), 1)
  assert_eq(combobox_next_match(options, "missing", -1, 1), -1)
}

///|
test "listbox native layer changes before focus restoration" {
  let calls : Array[String] = []
  ui_listbox_run_open_sequence(
    () => calls.push("show-popover"),
    Some(() => calls.push("focus-control")),
  )
  assert_eq(calls.length(), 2)
  assert_eq(calls[0], "show-popover")
  assert_eq(calls[1], "focus-control")

  calls.clear()
  ui_listbox_run_open_sequence(() => calls.push("hide-popover"), None)
  assert_eq(calls.length(), 1)
  assert_eq(calls[0], "hide-popover")
}

///|
#cfg(target="js")
extern "js" fn ffi_install_select_trigger_fixture(root_id : String) -> Unit =
  #| rootId => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const trigger = {
  #|     id: "caller-owned-trigger",
  #|     dataset: { slot: "select-trigger" },
  #|     getAttribute(name) {
  #|       if (name === "id") return this.id
  #|       if (name === "data-slot") return this.dataset.slot || ""
  #|       return ""
  #|     },
  #|   }
  #|   const content = {
  #|     id: "caller-owned-content",
  #|     dataset: {},
  #|     setAttribute(name, value) {
  #|       if (name === "data-trigger-id") this.dataset.triggerId = value
  #|     },
  #|   }
  #|   const root = { querySelectorAll: () => [trigger, content] }
  #|   globalThis.__ruiSelectTriggerFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     content,
  #|   }
  #|   globalThis.document = {
  #|     getElementById: id => id === `${rootId}-root`
  #|       ? root
  #|       : id === content.id ? content : null,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_select_trigger_fixture_id() -> String =
  #| () => globalThis.__ruiSelectTriggerFixture.content.dataset.triggerId || ""

///|
#cfg(target="js")
extern "js" fn ffi_restore_select_trigger_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiSelectTriggerFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   delete globalThis.__ruiSelectTriggerFixture
  #| }

///|
#cfg(target="js")
test "select resolves a caller-owned trigger id from its component root" {
  let root_id = "independent-select"
  ffi_install_select_trigger_fixture(root_id)
  sync_select_trigger_id(root_id, "caller-owned-content")
  let trigger_id = ffi_select_trigger_fixture_id()
  ffi_restore_select_trigger_fixture()
  assert_eq(trigger_id, "caller-owned-trigger")
}

///|
#cfg(target="js")
extern "js" fn ffi_install_combobox_press_fixture(root_id : String) -> Unit =
  #| rootId => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiComboboxPressFixture = {
  #|     document: globalThis.document,
  #|     hadDocument: own("document"),
  #|     FocusEvent: globalThis.FocusEvent,
  #|     hadFocusEvent: own("FocusEvent"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     listeners: {},
  #|     dispatches: [],
  #|     focuses: 0,
  #|   }
  #|   class FixtureFocusEvent {
  #|     constructor() { this.relatedTarget = null }
  #|   }
  #|   class FixtureHTMLElement {
  #|     constructor() { this.nodeType = 1 }
  #|   }
  #|   globalThis.FocusEvent = FixtureFocusEvent
  #|   globalThis.HTMLElement = FixtureHTMLElement
  #|   const root = new FixtureHTMLElement()
  #|   root.dataset = { state: "open", slot: "combobox" }
  #|   root.getAttribute = name => name === "data-state"
  #|     ? root.dataset.state
  #|     : name === "data-slot" ? root.dataset.slot : ""
  #|   root.addEventListener = (type, listener) => {
  #|     fixture.listeners[type] = listener
  #|   }
  #|   root.contains = target => target?.root === root
  #|   const elements = {}
  #|   const makeElement = slot => {
  #|     const element = new FixtureHTMLElement()
  #|     element.dataset = { slot }
  #|     element.root = root
  #|     element.getAttribute = name => name === "data-slot" ? slot : ""
  #|     element.hasAttribute = () => false
  #|     element.closest = selector => selector === '[data-slot="combobox"]'
  #|       ? root
  #|       : selector.includes(`[data-slot="${slot}"]`) ? element : null
  #|     elements[slot] = element
  #|     return element
  #|   }
  #|   const input = makeElement("combobox-input")
  #|   makeElement("combobox-item")
  #|   makeElement("combobox-trigger")
  #|   makeElement("combobox-clear")
  #|   input.focus = options => {
  #|     if (options?.preventScroll) fixture.focuses += 1
  #|   }
  #|   root.querySelector = selector => selector.includes("combobox-input")
  #|     ? input
  #|     : null
  #|   fixture.root = root
  #|   fixture.elements = elements
  #|   globalThis.document = {
  #|     getElementById: id => id === `${rootId}-root` ? root : null,
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_fire_combobox_press_fixture(event_type : String) -> Unit =
  #| eventType => {
  #|   const fixture = globalThis.__ruiComboboxPressFixture
  #|   fixture.listeners[eventType]?.(new FocusEvent())
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_event(slot : String) -> @dom.MouseEvent =
  #| slot => {
  #|   const fixture = globalThis.__ruiComboboxPressFixture
  #|   return {
  #|     currentTarget: fixture.root,
  #|     target: fixture.elements[slot],
  #|     defaultPrevented: false,
  #|     preventDefault() { this.defaultPrevented = true },
  #|   }
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_prevented(event : @dom.MouseEvent) -> Bool =
  #| event => event.defaultPrevented

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_focuses() -> Int =
  #| () => globalThis.__ruiComboboxPressFixture.focuses

///|
#cfg(target="js")
extern "js" fn ffi_combobox_keyboard_event(
  key : String,
  alt_key : Bool,
  ctrl_key : Bool,
  meta_key : Bool,
  composing : Bool,
) -> @dom.KeyboardEvent =
  #| (key, altKey, ctrlKey, metaKey, isComposing) => ({
  #|   key,
  #|   altKey,
  #|   ctrlKey,
  #|   metaKey,
  #|   isComposing,
  #|   defaultPrevented: false,
  #|   preventDefault() { this.defaultPrevented = true },
  #| })

///|
#cfg(target="js")
extern "js" fn ffi_combobox_default_prevented(
  event : @dom.KeyboardEvent,
) -> Bool = "event => event.defaultPrevented"

///|
#cfg(target="js")
fn combobox_key_test_result(
  key : String,
  multiple : Bool,
  disabled : Bool,
  query : String,
  values : Array[String],
  alt_key : Bool,
  ctrl_key : Bool,
  meta_key : Bool,
  composing : Bool,
) -> (Bool, Array[ComboboxMsg]) {
  let messages : Array[ComboboxMsg] = []
  let scope : ComboboxScope = {
    id: "keyboard-combobox",
    options: [],
    model: { open: false, query, values, active: -1 },
    multiple,
    placeholder: "",
    empty_text: "",
    disabled,
    invalid: false,
    required: false,
    name: None,
    side: Bottom,
    align: Start,
    side_offset: 4,
    align_offset: 0,
    emit: Emit(message => {
      messages.push(message)
      @cmd.none
    }),
    content_id: Ref("keyboard-combobox-content"),
    anchor_id: Ref("keyboard-combobox-input"),
    has_input: Ref(true),
  }
  let event = ffi_combobox_keyboard_event(
    key, alt_key, ctrl_key, meta_key, composing,
  )
  ignore(combobox_input_keydown(scope, event))
  (ffi_combobox_default_prevented(event), messages)
}

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_fixture_dispatches() -> Int =
  #| () => globalThis.__ruiComboboxPressFixture.dispatches.length

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_fixture_last_dispatch() -> Int =
  #| () => globalThis.__ruiComboboxPressFixture.dispatches.at(-1) ?? -1

///|
#cfg(target="js")
extern "js" fn ffi_combobox_press_fixture_record_dispatch(kind : Int) -> Unit =
  #| kind => { globalThis.__ruiComboboxPressFixture.dispatches.push(kind) }

///|
#cfg(target="js")
extern "js" fn ffi_restore_combobox_press_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiComboboxPressFixture
  #|   if (!fixture) return
  #|   if (fixture.hadDocument) globalThis.document = fixture.document
  #|   else delete globalThis.document
  #|   if (fixture.hadFocusEvent) globalThis.FocusEvent = fixture.FocusEvent
  #|   else delete globalThis.FocusEvent
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiComboboxPressFixture
  #| }

///|
#cfg(target="js")
test "combobox focusout binding dismisses an open root" {
  let root_id = "press-combobox"
  ffi_install_combobox_press_fixture(root_id)
  bind_combobox_events(root_id, kind => {
    ffi_combobox_press_fixture_record_dispatch(kind)
  })
  ffi_fire_combobox_press_fixture("focusout")
  let dispatches = ffi_combobox_press_fixture_dispatches()
  let last_dispatch = ffi_combobox_press_fixture_last_dispatch()
  ffi_restore_combobox_press_fixture()

  assert_eq(dispatches, 1)
  assert_eq(last_dispatch, 7)
}

///|
#cfg(target="js")
test "combobox root handlers open after input release and preserve item press focus" {
  let root_id = "press-combobox"
  ffi_install_combobox_press_fixture(root_id)
  let messages : Array[ComboboxMsg] = []
  let scope : ComboboxScope = {
    id: root_id,
    options: [],
    model: { open: false, query: "", values: [], active: -1 },
    multiple: false,
    placeholder: "",
    empty_text: "",
    disabled: false,
    invalid: false,
    required: false,
    name: None,
    side: Bottom,
    align: Start,
    side_offset: 4,
    align_offset: 0,
    emit: Emit(message => {
      messages.push(message)
      @cmd.none
    }),
    content_id: Ref("press-combobox-content"),
    anchor_id: Ref("press-combobox-input"),
    has_input: Ref(true),
  }
  let input_click = ffi_combobox_press_event("combobox-input")
  ignore(combobox_root_click(scope, input_click))
  let input_click_prevented = ffi_combobox_press_prevented(input_click)
  let item_press = ffi_combobox_press_event("combobox-item")
  ignore(combobox_root_mousedown(item_press))
  let item_press_prevented = ffi_combobox_press_prevented(item_press)
  let trigger_press = ffi_combobox_press_event("combobox-trigger")
  ignore(combobox_root_mousedown(trigger_press))
  let trigger_press_prevented = ffi_combobox_press_prevented(trigger_press)
  let focuses = ffi_combobox_press_focuses()
  ffi_restore_combobox_press_fixture()

  assert_false(input_click_prevented)
  assert_eq(messages.length(), 1)
  guard messages[0] is ComboboxOpen else {
    fail("input release should request an open combobox")
  }
  assert_true(item_press_prevented)
  assert_true(trigger_press_prevented)
  assert_eq(focuses, 1)
}

///|
#cfg(target="js")
test "multiple combobox deletes the previous value only from an empty input" {
  let (backspace_prevented, backspace_messages) = combobox_key_test_result(
    "Backspace",
    true,
    false,
    "",
    ["alpha", "beta"],
    false,
    false,
    false,
    false,
  )
  assert_true(backspace_prevented)
  guard backspace_messages.get(0) is Some(ComboboxRemove(value)) else {
    fail("Backspace should remove the final selected value")
  }
  assert_eq(value, "beta")

  let (delete_prevented, delete_messages) = combobox_key_test_result(
    "Delete",
    true,
    false,
    "",
    ["alpha", "beta"],
    false,
    false,
    false,
    false,
  )
  assert_true(delete_prevented)
  guard delete_messages.get(0) is Some(ComboboxRemove(value)) else {
    fail("Delete should remove the final selected value")
  }
  assert_eq(value, "beta")

  let rejected : Array[(Bool, Array[ComboboxMsg])] = [
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "query",
      ["alpha"],
      false,
      false,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      false,
      false,
      "",
      ["alpha"],
      false,
      false,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "",
      [],
      false,
      false,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      true,
      "",
      ["alpha"],
      false,
      false,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "",
      ["alpha"],
      true,
      false,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "",
      ["alpha"],
      false,
      true,
      false,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "",
      ["alpha"],
      false,
      false,
      true,
      false,
    ),
    combobox_key_test_result(
      "Backspace",
      true,
      false,
      "",
      ["alpha"],
      false,
      false,
      false,
      true,
    ),
  ]
  for result in rejected {
    let (prevented, messages) = result
    assert_false(prevented)
    assert_eq(messages.length(), 0)
  }
}
