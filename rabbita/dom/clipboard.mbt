///|
#cfg(target="js")
#external
pub type Clipboard

///|
#cfg(target="js")
pub impl IsEventTarget for Clipboard

///|
#cfg(target="js")
pub impl @js.Cast for Clipboard with fn into(value) {
  value |> ffi_to_clipboard |> clipboard => { clipboard.to_option() }
}

///|
#cfg(target="js")
pub impl @js.Cast for Clipboard with fn from(value) {
  value |> js_identity
}

// TODO: support ClipboardItem
//
// ///|
// pub extern type ClipboardItem

// ///|
// pub extern "js" fn Clipboard::write(
//   self : Clipboard,
//   data : FixedArray[ClipboardItem]
// ) =
//   #| (self,data) => self.write(data)

// ///|
// pub extern "js" fn Clipboard::read(self : Clipboard) -> @js.Promise =
//   #| (self) => self.read()

///|
#cfg(target="js")
pub extern "js" fn Clipboard::write_text(
  self : Clipboard,
  text : String,
) -> @js.Promise =
  #| (self, text) => {
  #|   const writeText = self && self.writeText
  #|   if (typeof writeText === 'function') {
  #|     return writeText.call(self, text)
  #|   }
  #|   return Promise.reject(
  #|     new Error(
  #|       "Clipboard.writeText is unavailable (requires browser support and secure context)."
  #|     )
  #|   )
  #| }

///|
#cfg(target="js")
pub extern "js" fn Clipboard::read_text(self : Clipboard) -> @js.Promise =
  #| (self) => {
  #|   const readText = self && self.readText
  #|   if (typeof readText === 'function') {
  #|     return readText.call(self)
  #|   }
  #|   return Promise.reject(
  #|     new Error(
  #|       "Clipboard.readText is unavailable (requires browser support and secure context)."
  #|     )
  #|   )
  #| }
