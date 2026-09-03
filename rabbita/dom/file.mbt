///|
/// A file selected through the browser File API.
///
/// [MDN](https://developer.mozilla.org/en-US/docs/Web/API/File)
#warnings("-unused_type_declaration")
#external
type File

///|
/// [MDN](https://developer.mozilla.org/en-US/docs/Web/API/File/name)
#cfg(target="js")
pub extern "js" fn File::get_name(self : Self) -> String = "(file) => file.name"

///|
/// [MDN](https://developer.mozilla.org/en-US/docs/Web/API/File/lastModified)
#cfg(target="js")
pub extern "js" fn File::get_last_modified(self : Self) -> Double =
  "(file) => file.lastModified"

///|
/// Upcast this file to the Blob interface it extends.
///
/// [MDN](https://developer.mozilla.org/en-US/docs/Web/API/File)
#cfg(target="js")
pub extern "js" fn File::as_blob(self : Self) -> Blob = "(file) => file"
