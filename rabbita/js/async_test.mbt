///|
#cfg(target="js")
fn op1() -> String? noraise {
  Some("Hello")
}

///|
#cfg(target="js")
fn op2() -> String? noraise {
  guard! op1() is Some(prefix)
  Some(prefix + ", World")
}

///|
#cfg(target="js")
fn op3() -> String? noraise {
  None
}

///|
#cfg(target="js")
test "Promise::wait" {
  @js.async_test(() => {
    // Promise::unsafe_new + Promise::wait is a noop.
    let res = @js.Promise::unsafe_new(fn() { op1() }).wait()
    @debug.assert_eq(res.cast(), Some("Hello"))
  })
}

///|
#cfg(target="js")
test "async_all" {
  @js.async_test(() => {
    let results = @js.async_all([fn() { op2() }, fn() { op1() }, fn() { op3() }])
    @debug.assert_eq(results.length(), 3)
    @debug.assert_eq(results.unsafe_get(0), Some("Hello, World"))
    @debug.assert_eq(results.unsafe_get(1), Some("Hello"))
    @debug.assert_eq(results.unsafe_get(2), None)
  })
}
