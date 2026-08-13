///|
/// DO NOT USE THIS FUNCTION.
/// NOTE: There is a bug in the unused analyzer, so make this function public to avoid the warning.
#cfg(target="js")
pub fn[E, R] default_exception_handler(exception : E) -> R {
  console_log(@js.Value::cast_from(exception))
  panic()
}

///|
#cfg(target="js")
extern "js" fn console_log(x : @js.Value) = "(x) => console.log(x)"

///|
#cfg(target="js")
pub(all) suberror DOMExceptionError {
  DOMExceptionError(name~ : String, message~ : String)
}

///|
#cfg(target="js")
fn dom_exception_error(error : @js.Error_) -> DOMExceptionError {
  let @js.Error_::Error_(value) = error
  let exception : DOMException = value.cast()
  let name = exception.get_name()
  let message = exception.get_message()
  DOMExceptionError(name~, message~)
}
