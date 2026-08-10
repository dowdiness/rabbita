///|
test "HTTP commands have structural debug output" {
  debug_inspect(
    @http.get("/api/v0/modules").expect_text(_ => @cmd.none),
    content=(
      #|Request(
      #|  url="/api/v0/modules",
      #|  http_method="GET",
      #|  body=Empty,
      #|  expect=Text,
      #|)
    ),
  )
}
