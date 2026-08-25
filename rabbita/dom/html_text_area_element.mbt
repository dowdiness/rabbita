///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement
#cfg(target="js")
#external
type HTMLTextAreaElement

///|
#cfg(target="js")
pub impl IsEventTarget for HTMLTextAreaElement

///|
#cfg(target="js")
pub impl @js.Cast for HTMLTextAreaElement with fn into(value) {
  value |> ffi_to_html_text_area_element |> nullable => { nullable.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for HTMLTextAreaElement with fn from(value) {
  value |> js_identity
}

///|
#cfg(target="js")
pub impl IsNode for HTMLTextAreaElement

///|
#cfg(target="js")
pub impl IsElement for HTMLTextAreaElement

///|
#cfg(target="js")
pub impl IsHtmlElement for HTMLTextAreaElement

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/value
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_value(self : Self) -> String = "(self) => self.value"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/value
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_value(
  self : Self,
  value : String,
) -> Unit = "(self, value) => self.value = value"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/defaultValue
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_default_value(
  self : Self,
) -> String = "(self) => self.defaultValue"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/defaultValue
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_default_value(
  self : Self,
  value : String,
) -> Unit = "(self, value) => self.defaultValue = value"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/textLength
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_text_length(self : Self) -> Int = "(self) => self.textLength"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionStart
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_selection_start(self : Self) -> Int = "(self) => self.selectionStart"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionStart
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_selection_start(
  self : Self,
  value : Int,
) -> Unit = "(self, value) => self.selectionStart = value"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionEnd
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_selection_end(self : Self) -> Int = "(self) => self.selectionEnd"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionEnd
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_selection_end(
  self : Self,
  value : Int,
) -> Unit = "(self, value) => self.selectionEnd = value"

///|
/// Browser values are "forward", "backward", and "none".
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionDirection
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::get_selection_direction(
  self : Self,
) -> String = "(self) => self.selectionDirection"

///|
/// Browser values are "forward", "backward", and "none".
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/selectionDirection
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_selection_direction(
  self : Self,
  value : String,
) -> Unit = "(self, value) => self.selectionDirection = value"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/select
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::select(self : Self) -> Unit = "(self) => self.select()"

///|
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/setSelectionRange
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_selection_range(
  self : Self,
  start : Int,
  end : Int,
  direction? : @js.Optional[String] = @js.Optional::undefined(),
) -> Unit = "(self, start, end, direction) => self.setSelectionRange(start, end, direction)"

///|
/// Replace the currently selected text.
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/setRangeText
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_range_text(
  self : Self,
  replacement : String,
) -> Unit = "(self, replacement) => self.setRangeText(replacement)"

///|
/// Browser selection modes are "select", "start", "end", and "preserve".
/// https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement/setRangeText
#cfg(target="js")
pub extern "js" fn HTMLTextAreaElement::set_range_text_with_range(
  self : Self,
  replacement : String,
  start : Int,
  end : Int,
  selection_mode? : @js.Optional[String] = @js.Optional::undefined(),
) -> Unit =
  #| (self, replacement, start, end, selectionMode) =>
  #|   self.setRangeText(replacement, start, end, selectionMode)
