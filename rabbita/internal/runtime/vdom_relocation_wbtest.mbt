///|
#cfg(target="js")
extern "js" fn relocation_test_document() -> @dom.Document =
  #| () => {
  #|   return {
  #|     createElement() {
  #|       return {
  #|         childNodes: [],
  #|         insertCount: 0,
  #|         appendChild(child) {
  #|           const previous = this.childNodes.at(-1)
  #|           if (previous) previous.nextSibling = child
  #|           child.nextSibling = null
  #|           this.childNodes.push(child)
  #|         },
  #|         insertBefore() {
  #|           this.insertCount += 1
  #|         },
  #|         getAttribute(name) {
  #|           return name === "data-insert-count" ? String(this.insertCount) : null
  #|         },
  #|       }
  #|     },
  #|     createTextNode(value) {
  #|       return { nodeValue: value, nextSibling: null }
  #|     },
  #|   }
  #| }

///|
#cfg(target="js")
test "diffing unchanged keyed children does not reinsert DOM nodes" {
  let document = relocation_test_document()
  let parent = document.create_element("div")
  let first = document.create_text_node("first")
  let second = document.create_text_node("second")
  parent..append_child(first.as_node()).append_child(second.as_node())
  let old : Children[INode] = Map(
    Map::from_array([
      ("first", INode::Text("first", first)),
      ("second", INode::Text("second", second)),
    ]),
  )
  let new : Children[VNode] = Map(
    Map::from_array([
      ("first", VNode::text("first")),
      ("second", VNode::text("second")),
    ]),
  )

  ignore(diff_children(old, new, Sandbox::new(), parent.as_node(), null()))

  assert_eq(parent.get_attribute("data-insert-count"), Some("0"))
}

///|
#cfg(target="js")
test "relocate inserts a DOM node when its position differs" {
  let document = relocation_test_document()
  let parent = document.create_element("div")
  let first = document.create_text_node("first")
  let second = document.create_text_node("second")
  parent..append_child(first.as_node()).append_child(second.as_node())

  INode::Text("first", first).relocate(parent.as_node(), null())

  assert_eq(parent.get_attribute("data-insert-count"), Some("1"))
}
