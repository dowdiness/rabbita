///|
#cfg(target="js")
extern "js" fn ffi_install_radio_group_fixture(rtl : Bool) -> Unit =
  #| rtl => {
  #|   const own = key => Object.prototype.hasOwnProperty.call(globalThis, key)
  #|   const fixture = globalThis.__ruiRadioGroupFixture = {
  #|     getComputedStyle: globalThis.getComputedStyle,
  #|     hadGetComputedStyle: own("getComputedStyle"),
  #|     window: globalThis.window,
  #|     hadWindow: own("window"),
  #|     HTMLElement: globalThis.HTMLElement,
  #|     hadHTMLElement: own("HTMLElement"),
  #|     focused: -1,
  #|     selected: -1,
  #|   }
  #|   class FixtureHTMLElement {
  #|     constructor() { this.nodeType = 1 }
  #|   }
  #|   globalThis.HTMLElement = FixtureHTMLElement
  #|   globalThis.window = globalThis
  #|   const group = {
  #|     nodeType: 1,
  #|     dataset: { orientation: "horizontal" },
  #|     querySelectorAll: selector => selector === '[data-slot="radio-group-item"]'
  #|       ? fixture.items
  #|       : [],
  #|   }
  #|   const makeItem = (index, disabled = false) => {
  #|     const item = new FixtureHTMLElement()
  #|     item.disabled = disabled
  #|     item.getAttribute = name => name === "aria-disabled" && disabled ? "true" : ""
  #|     item.hasAttribute = name => name === "disabled" && disabled
  #|     item.closest = selector => selector === '[data-slot="radio-group-item"]'
  #|       ? fixture.items[index]
  #|       : selector === '[data-slot="radio-group"]' ? group : null
  #|     item.focus = () => { fixture.focused = index }
  #|     item.click = () => { fixture.selected = index }
  #|     return item
  #|   }
  #|   fixture.group = group
  #|   fixture.items = [makeItem(0), makeItem(1, true), makeItem(2)]
  #|   globalThis.getComputedStyle = node => ({
  #|     getPropertyValue: name => name === "direction" && node === group && rtl
  #|       ? "rtl"
  #|       : "ltr",
  #|   })
  #| }

///|
#cfg(target="js")
extern "js" fn ffi_radio_group_fixture_event(
  index : Int,
  key : String,
  modified : Bool,
) -> @dom.KeyboardEvent =
  #| (index, key, modified) => ({
  #|   target: globalThis.__ruiRadioGroupFixture.items[index],
  #|   key,
  #|   altKey: modified,
  #|   ctrlKey: false,
  #|   metaKey: false,
  #|   shiftKey: false,
  #| })

///|
#cfg(target="js")
extern "js" fn ffi_radio_group_fixture_focused() -> Int =
  #| () => globalThis.__ruiRadioGroupFixture.focused

///|
#cfg(target="js")
extern "js" fn ffi_radio_group_fixture_selected() -> Int =
  #| () => globalThis.__ruiRadioGroupFixture.selected

///|
#cfg(target="js")
extern "js" fn ffi_restore_radio_group_fixture() -> Unit =
  #| () => {
  #|   const fixture = globalThis.__ruiRadioGroupFixture
  #|   if (!fixture) return
  #|   if (fixture.hadGetComputedStyle) globalThis.getComputedStyle = fixture.getComputedStyle
  #|   else delete globalThis.getComputedStyle
  #|   if (fixture.hadWindow) globalThis.window = fixture.window
  #|   else delete globalThis.window
  #|   if (fixture.hadHTMLElement) globalThis.HTMLElement = fixture.HTMLElement
  #|   else delete globalThis.HTMLElement
  #|   delete globalThis.__ruiRadioGroupFixture
  #| }

///|
#cfg(target="js")
test "radio group arrows select, focus, skip disabled items, and honor RTL" {
  ffi_install_radio_group_fixture(false)
  let moved = radio_group_move_and_select(
    ffi_radio_group_fixture_event(0, "ArrowRight", false),
  )
  let ltr_focus = ffi_radio_group_fixture_focused()
  let ltr_selected = ffi_radio_group_fixture_selected()
  ffi_restore_radio_group_fixture()

  ffi_install_radio_group_fixture(true)
  let rtl_moved = radio_group_move_and_select(
    ffi_radio_group_fixture_event(0, "ArrowLeft", false),
  )
  let rtl_focus = ffi_radio_group_fixture_focused()
  let rtl_selected = ffi_radio_group_fixture_selected()
  ffi_restore_radio_group_fixture()

  assert_true(moved)
  assert_eq(ltr_focus, 2)
  assert_eq(ltr_selected, 2)
  assert_true(rtl_moved)
  assert_eq(rtl_focus, 2)
  assert_eq(rtl_selected, 2)
}

///|
#cfg(target="js")
test "radio group Home and End select endpoints while modifiers pass through" {
  ffi_install_radio_group_fixture(false)
  let end_moved = radio_group_move_and_select(
    ffi_radio_group_fixture_event(0, "End", false),
  )
  let end_selected = ffi_radio_group_fixture_selected()
  let home_moved = radio_group_move_and_select(
    ffi_radio_group_fixture_event(2, "Home", false),
  )
  let home_selected = ffi_radio_group_fixture_selected()
  let modified = radio_group_move_and_select(
    ffi_radio_group_fixture_event(0, "ArrowRight", true),
  )
  ffi_restore_radio_group_fixture()

  assert_true(end_moved)
  assert_eq(end_selected, 2)
  assert_true(home_moved)
  assert_eq(home_selected, 0)
  assert_false(modified)
}
