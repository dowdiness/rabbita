///|
#cfg(target="js")
test "svg edge paths expose accessibility and stable data attributes" {
  let edge_path = path(
    class="edge selected",
    d="M 0 0 C 40 0, 40 10, 80 10",
    attrs=Attrs::build()
      .role("button")
      .tabindex("0")
      .aria_label("Disconnect source.out → target.in")
      .data_set("edge-id", "edge-1"),
  )
  match edge_path.to_virtual_dom() {
    @runtime.VNode::Elem(
      "path",
      props,
      @runtime.Children::Array(children),
      namespace_uri=Some(svg_namespace)
    ) => {
      assert_eq(svg_namespace, @dom.namespace_svg)
      assert_eq(children.length(), 0)
      assert_eq(props.attrs.get("class"), Some("edge selected"))
      assert_eq(props.attrs.get("d"), Some("M 0 0 C 40 0, 40 10, 80 10"))
      assert_eq(props.attrs.get("role"), Some("button"))
      assert_eq(props.attrs.get("tabindex"), Some("0"))
      assert_eq(
        props.attrs.get("aria-label"),
        Some("Disconnect source.out → target.in"),
      )
      assert_eq(props.attrs.get("data-edge-id"), Some("edge-1"))
    }
    _ => fail("expected an SVG path VNode")
  }
}

///|
#cfg(target="js")
test "svg keyed node retains EdgeId child keys for VDOM reconciliation" {
  let children : Map[String, Svg] = Map::from_array([
    (
      "edge-a",
      path(d="M 0 0", attrs=Attrs::build().data_set("edge-id", "edge-a")),
    ),
    (
      "edge-b",
      path(d="M 1 1", attrs=Attrs::build().data_set("edge-id", "edge-b")),
    ),
  ])
  let svg = keyed_node("svg", Attrs::build(), children)
  match svg.to_virtual_dom() {
    @runtime.VNode::Elem(
      "svg",
      _,
      @runtime.Children::Map(actual),
      namespace_uri=Some(svg_namespace)
    ) => {
      assert_eq(svg_namespace, @dom.namespace_svg)
      assert_true(actual.get("edge-a") is Some(_))
      assert_true(actual.get("edge-b") is Some(_))
    }
    _ => fail("expected keyed SVG children")
  }
}
