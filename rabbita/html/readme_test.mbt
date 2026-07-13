///|
using @rabbita {type Emit}

///|
using @html {type Html, type Mouse, div, h1, button, node}

///|
#warnings("-struct_never_constructed-unused_field")
struct Model {
  count : Int
  records : Array[String]
}

///|
#warnings("-unused_constructor")
enum Msg {
  Inc
  Dec
}

///|
#warnings("-unused_constructor")
enum Msg2 {
  StartDraw(Mouse)
  EndDraw(Mouse)
}

///|
test {
  ignore(view)
  ignore(view2)
  ignore(html)
  ignore(html1)
  ignore(html2)
}

///|
#cfg(target="js")
test {
  ignore(update2)
}

///|
test "dialog closedby argument emits attribute" {
  let html = @html.dialog(closedby="any", @html.nothing)
  match html.to_virtual_dom() {
    @runtime.VNode::Elem("dialog", props, _, namespace_uri=None) =>
      match props.attrs.get("closedby") {
        Some("any") => ()
        _ => fail("expected closedby=any")
      }
    _ => fail("expected dialog element")
  }
}

///|
test "dialog accepts closedby through attrs builder" {
  let html = @html.dialog(
    attrs=@html.Attrs::build().closedby("closerequest"),
    @html.nothing,
  )
  match html.to_virtual_dom() {
    @runtime.VNode::Elem("dialog", props, _, namespace_uri=None) =>
      match props.attrs.get("closedby") {
        Some("closerequest") => ()
        _ => fail("expected closedby=closerequest")
      }
    _ => fail("expected dialog element")
  }
}

///|
type Model2 = Unit
