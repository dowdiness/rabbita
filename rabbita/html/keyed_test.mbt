///|
test "keyed children preserve insertion order" {
  let html = @html.div(
    @html.keyed([
      ("second", @html.span("second")),
      ("first", @html.span("first")),
    ]),
  )
  inspect(
    @vdom.server_side_render(() => html.to_virtual_dom()),
    content="<!DOCTYPE html><div><span>second</span><span>first</span></div>",
  )
}
