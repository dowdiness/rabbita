///|
#cfg(target="js")
type PointerEvent

///|
#cfg(target="js")
pub impl IsEvent for PointerEvent

///|
#cfg(target="js")
pub impl IsUIEvent for PointerEvent

///|
#cfg(target="js")
pub impl IsMouseEvent for PointerEvent

///|
#cfg(target="js")
pub impl @js.Cast for PointerEvent with fn into(value) {
  value |> ffi_to_pointer_event |> y => { y.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for PointerEvent with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_pointer_id(self : Self) -> Int = "(e) => e.pointerId"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_width(self : Self) -> Double = "(e) => e.width"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_height(self : Self) -> Double = "(e) => e.height"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_pressure(self : Self) -> Double = "(e) => e.pressure"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_tilt_x(self : Self) -> Int = "(e) => e.tiltX"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_tilt_y(self : Self) -> Int = "(e) => e.tiltY"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_pointer_type(self : Self) -> String = "(e) => e.pointerType"

///|
#cfg(target="js")
pub extern "js" fn PointerEvent::get_is_primary(self : Self) -> Bool = "(e) => e.isPrimary"
