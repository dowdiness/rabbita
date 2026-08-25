///|
#cfg(target="js")
#external
type InputEvent

///|
#cfg(target="js")
pub impl IsEvent for InputEvent

///|
#cfg(target="js")
pub impl IsUIEvent for InputEvent

///|
#cfg(target="js")
pub impl @js.Cast for InputEvent with fn into(value) {
  value |> ffi_to_input_event |> y => { y.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for InputEvent with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
pub extern "js" fn InputEvent::get_data(self : Self) -> @js.Nullable[String] = "(event) => event.data"

///|
#cfg(target="js")
pub extern "js" fn InputEvent::is_composing(self : Self) -> Bool = "(e) => e.isComposing"

///|
#cfg(target="js")
pub extern "js" fn InputEvent::input_type(self : Self) -> String = "(e) => e.inputType"
