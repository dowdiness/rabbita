///|
#warnings("-alert_unstable")
test "static code keeps an escaped fallback before preload" {
  let html = @rabbita.render_to_string(() => {
    @rabbita.Val::constant(
      static_code(
        "fn main { println(\"<ready>\") }",
        lang="moonbit",
        light_theme="github-light",
        dark_theme="github-dark-default",
      ),
    )
  })
  for
    expected in [
      "<yoorkin-shiki-code", "data-lang=\"moonbit\"", "data-light-theme=\"github-light\"",
      "data-dark-theme=\"github-dark-default\"", "&lt;ready&gt;",
    ] {
    if !html.contains(expected) {
      fail(
        "expected static Shiki fallback to contain `\{expected}`; got `\{html}`",
      )
    }
  }
}
