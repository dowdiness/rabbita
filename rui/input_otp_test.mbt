///|
#cfg(target="js")
extern "js" fn install_input_otp_test_window() =
  #| () => {
  #|   if (typeof globalThis.window === "undefined") {
  #|     globalThis.window = { requestAnimationFrame: () => 0 }
  #|   }
  #| }

///|
#warnings("-alert_unstable")
#cfg(target="js")
fn render_input_otp_test(builder : () -> @rabbita.Val[@html.Html]) -> String {
  install_input_otp_test_window()
  ignore(@rabbita.new(builder))
  @rabbita.render_to_string(builder)
}

///|
#warnings("-alert_unstable")
#cfg(not(target="js"))
fn render_input_otp_test(builder : () -> @rabbita.Val[@html.Html]) -> String {
  @rabbita.render_to_string(builder)
}

///|
fn input_otp_assert_contains(actual : String, expected : String) -> Unit raise {
  if !actual.contains(expected) {
    fail("expected Input OTP HTML to contain `\{expected}`; got `\{actual}`")
  }
}

///|
test "input otp defaults to a numeric virtual keyboard" {
  let html = render_input_otp_test(() => {
    @rui.input_otp(id="numeric-otp", max_length=4)
  })
  input_otp_assert_contains(html, "inputmode=\"numeric\"")
}

///|
test "input otp exposes native alphanumeric input constraints" {
  let html = render_input_otp_test(() => {
    @rui.input_otp(
      id="alphanumeric-otp",
      max_length=6,
      default_value="A1B2",
      inputmode="text",
      pattern="[A-Za-z0-9]*",
      input_attrs=@html.Attrs::build().inputmode("numeric"),
    )
  })
  input_otp_assert_contains(html, "inputmode=\"text\"")
  if html.contains("inputmode=\"numeric\"") {
    fail("the public inputmode must replace a conflicting low-level attribute")
  }
  input_otp_assert_contains(html, "pattern=\"[A-Za-z0-9]*\"")
  input_otp_assert_contains(html, "value=\"A1B2\"")
  input_otp_assert_contains(html, ">A</span>")
}
