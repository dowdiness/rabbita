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
struct RelocationTestScheduler {}

///|
#cfg(target="js")
impl @cmd.Scheduler for RelocationTestScheduler with fn queue_command(self, cmd) {
  ignore((self, cmd))
}

///|
#cfg(target="js")
impl @cmd.Scheduler for RelocationTestScheduler with fn set_url_changed_injector(
  self,
  injector,
) {
  ignore((self, injector))
}

///|
#cfg(target="js")
impl @cmd.Scheduler for RelocationTestScheduler with fn set_url_request_injector(
  self,
  injector,
) {
  ignore((self, injector))
}

///|
#cfg(target="js")
impl @cmd.Context for RelocationTestScheduler with fn get_origin(_self) {
  ""
}

///|
#cfg(target="js")
impl @cmd.Context for RelocationTestScheduler with fn inject_url_changed(
  _self,
  _url,
) {
  @cmd.none
}

///|
#cfg(target="js")
impl @cmd.Context for RelocationTestScheduler with fn inject_url_request(
  _self,
  _url,
) {
  @cmd.none
}

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

  let scheduler = RelocationTestScheduler::{  }
  let captured_link_listener : @dom.Listener = _ => ()
  ignore(
    diff_children(
      old,
      new,
      scheduler,
      captured_link_listener,
      parent.as_node(),
      null(),
    ),
  )

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

///|
#cfg(target="js")
extern "js" fn keyed_focus_reorder_test_document() -> @dom.Document =
  #| () => {
  #|   const doc = { activeElement: null };
  #|   const sync = (parent) => {
  #|     for (let i = 0; i < parent.childNodes.length; i += 1) {
  #|       parent.childNodes[i].nextSibling = parent.childNodes[i + 1] ?? null;
  #|       parent.childNodes[i].parentNode = parent;
  #|     }
  #|   };
  #|   const makeNode = () => {
  #|     const node = {
  #|       childNodes: [],
  #|       nextSibling: null,
  #|       parentNode: null,
  #|       appendChild(child) {
  #|         if (child.parentNode) {
  #|           const old = child.parentNode.childNodes.indexOf(child);
  #|           if (old >= 0) child.parentNode.childNodes.splice(old, 1);
  #|           sync(child.parentNode);
  #|         }
  #|         this.childNodes.push(child);
  #|         sync(this);
  #|       },
  #|       insertBefore(child, before) {
  #|         if (child.parentNode) {
  #|           const old = child.parentNode.childNodes.indexOf(child);
  #|           if (old >= 0) child.parentNode.childNodes.splice(old, 1);
  #|           sync(child.parentNode);
  #|         }
  #|         const index = before == null ? this.childNodes.length : this.childNodes.indexOf(before);
  #|         this.childNodes.splice(index < 0 ? this.childNodes.length : index, 0, child);
  #|         sync(this);
  #|       },
  #|       removeChild(child) {
  #|         const index = this.childNodes.indexOf(child);
  #|         if (index >= 0) this.childNodes.splice(index, 1);
  #|         child.parentNode = null;
  #|         child.nextSibling = null;
  #|         sync(this);
  #|       },
  #|       focus() { doc.activeElement = this; },
  #|       setAttribute() {},
  #|       getAttribute() { return null; },
  #|       removeAttribute() {},
  #|     };
  #|     return node;
  #|   };
  #|   doc.createElement = makeNode;
  #|   doc.createTextNode = makeNode;
  #|   return doc;
  #| }

///|
#cfg(target="js")
test "reordering keyed children preserves focused DOM identity" {
  let document = keyed_focus_reorder_test_document()
  let parent = document.create_element("div")
  let first = document.create_element("path")
  let second = document.create_element("path")
  parent..append_child(first.as_node()).append_child(second.as_node())
  let props = Props::new(Map([]), Map([]), Map([]), Map([]))
  let old : Children[INode] = Map(
    Map::from_array([
      ("edge-a", INode::Text("a", first)),
      ("edge-b", INode::Text("b", second)),
    ]),
  )
  let new : Children[VNode] = Map(
    Map::from_array([("edge-b", VNode::text("b")), ("edge-a", VNode::text("a"))]),
  )
  ignore(props)

  keyed_focus_reorder_test_focus(second)
  let scheduler = RelocationTestScheduler::{  }
  let captured_link_listener : @dom.Listener = _ => ()
  ignore(
    diff_children(
      old,
      new,
      scheduler,
      captured_link_listener,
      parent.as_node(),
      null(),
    ),
  )

  guard document.get_active_element() is Some(active) else {
    fail("expected a focused keyed child")
  }
  assert_true(active.is_same_node(second.as_node()))
}

///|
#cfg(target="js")
extern "js" fn keyed_focus_reorder_test_focus(element : @dom.Element) -> Unit = "(element) => element.focus()"
