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
fn dom_exception_field(
  value : @js.Value,
  key : String,
  fallback : String,
) -> String {
  guard !value.is_null() && !value.is_undefined() else { return fallback }
  let field : @js.Value = @js.Error_::wrap(fn() -> @js.Value {
    value.get_with_string(key)
  }) catch {
    _ => return fallback
  }
  if field.is_string() {
    field.cast()
  } else {
    fallback
  }
}

///|
#cfg(target="js")
fn dom_exception_error(error : @js.Error_) -> DOMExceptionError {
  let @js.Error_::Error_(value) = error
  let name = dom_exception_field(value, "name", "UnknownError")
  let message = dom_exception_field(value, "message", "")
  DOMExceptionError(name~, message~)
}
