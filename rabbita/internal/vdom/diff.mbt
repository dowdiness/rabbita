///|
#cfg(target="js")
priv struct MountedProps {
  props : Props
  slots : Map[String, Ref[(@dom.Event, &Scheduler) -> Unit]]
}

///|
#cfg(target="js")
priv enum INode {
  Elem(
    String,
    MountedProps,
    Children[INode],
    namespace_uri~ : String?,
    @dom.Element
  )
  Text(String, @dom.Element)
  Frag(Array[INode], @dom.Comment, @dom.Comment)
  Thunk(Int, INode)
}

///|
#cfg(target="js")
struct Mounted {
  mut root : INode
  scheduler : &Scheduler
  captured_link_listener : @dom.Listener
}

///|
#cfg(not(target="js"))
#warnings("-unused_field")
struct Mounted {
  mut vnode : VNode
}

///|
#cfg(target="js")
fn INode::start(self : Self) -> @dom.Node {
  match self {
    Elem(_, _, _, element, ..) | Text(_, element) => element.as_node()
    Thunk(_, node) => node.start()
    Frag(_, start, _) => start.as_node()
  }
}

///|
#cfg(target="js")
fn INode::end(self : Self) -> @dom.Node {
  match self {
    Elem(_, _, _, element, ..) | Text(_, element) => element.as_node()
    Thunk(_, node) => node.end()
    Frag(_, _, end) => end.as_node()
  }
}

///|
#cfg(target="js")
fn INode::needs_relocation(
  self : Self,
  anchor : @js.Nullable[@dom.Node],
) -> Bool {
  match (self.end().get_next_sibling().to_option(), anchor.to_option()) {
    (None, None) => false
    (Some(actual), Some(expected)) => !actual.is_same_node(expected)
    _ => true
  }
}

///|
#cfg(target="js")
fn INode::remove(self : Self, parent : @dom.Node) -> Unit {
  match self {
    Elem(_, _, _, element, ..) | Text(_, element) =>
      parent.remove_child(element.as_node())
    Thunk(_, node) => node.remove(parent)
    Frag(_, start, end) => {
      let start = start.as_node()
      let end = end.as_node()
      while start.get_next_sibling().to_option() is Some(node) &&
            !node.is_same_node(end) {
        parent.remove_child(node)
      }
      parent.remove_child(start)
      parent.remove_child(end)
    }
  }
}

///|
#cfg(target="js")
fn INode::relocate(
  self : Self,
  parent : @dom.Node,
  before : @js.Nullable[@dom.Node],
) -> Unit {
  guard self.needs_relocation(before) else { return }
  match self {
    Elem(_, _, _, element, ..) | Text(_, element) =>
      parent.insert_before(element.as_node(), before)
    Thunk(_, node) => node.relocate(parent, before)
    Frag(_, start, end) => {
      {
        guard! start.get_parent_node().to_option() is Some(a)
        guard! end.get_parent_node().to_option() is Some(b)
        guard! a.is_same_node(b)
      }
      let start = start.as_node()
      let end = end.as_node()
      let mut anchor = before
      while end.get_previous_sibling().to_option() is Some(node) &&
            !node.is_same_node(start) {
        parent.insert_before(node, anchor)
        anchor = nullable(node)
      }
      parent.insert_before(end, before)
      parent.insert_before(start, anchor)
    }
  }
}

///|
#cfg(target="js")
fn VNode::insert(
  self : Self,
  scheduler : &Scheduler,
  captured_link_listener : @dom.Listener,
  parent : @dom.Node,
  before : @js.Nullable[@dom.Node],
) -> INode {
  match self {
    Text(text) => {
      let element = @dom.document().create_text_node(text)
      parent.insert_before(element.as_node(), before)
      Text(text, element)
    }
    Thunk(hash, render) => {
      let node = render().insert(
        scheduler, captured_link_listener, parent, before,
      )
      Thunk(hash, node)
    }
    Frag(children) => {
      let document = @dom.document()
      let fragment = document.create_document_fragment()
      let start = document.create_comment("start")
      let end = document.create_comment("end")
      fragment.append_child(start.as_node())
      let children = children.map(child => {
        child.insert(
          scheduler,
          captured_link_listener,
          fragment.as_node(),
          null(),
        )
      })
      fragment.append_child(end.as_node())
      parent.insert_before(fragment.as_node(), before)
      Frag(children, start, end)
    }
    Elem(tag, props, children, namespace_uri~) => {
      let rendered_tag = rendered_tag(tag)
      let document = @dom.document()
      let element = match namespace_uri {
        None => document.create_element(rendered_tag)
        Some(namespace_uri) =>
          document.create_element_ns(namespace_uri, rendered_tag)
      }
      let { handlers, attrs, props: properties, styles } = props
      let slots : Map[String, Ref[(@dom.Event, &Scheduler) -> Unit]] = Map([])
      for event, handler in handlers {
        let slot = @ref.new(handler)
        element.add_event_listener(event, event => (slot.val)(event, scheduler))
        slots[event] = slot
      }
      if is_captured_link_tag(tag) {
        element.add_event_listener("click", captured_link_listener)
      }
      for name, value in attrs {
        element.set_attribute(name, value)
      }
      for name, value in properties {
        element.set_property(name, variant_to_js_value(value))
      }
      let sheet = if element.to_html_element() is Some(html) {
        html.get_style()
      } else if element.to_svg_element() is Some(svg) {
        svg.get_style()
      } else {
        panic()
      }
      for name, value in styles {
        sheet.set_property(name, value)
      }
      let node = element.as_node()
      let children : Children[INode] = if is_html_void_element(tag) {
        Array([])
      } else {
        match children {
          RawHtml(html) => {
            node.to_element().unwrap().set_inner_html(html)
            RawHtml(html)
          }
          Array(children) =>
            Array(
              children.map(child => {
                child.insert(scheduler, captured_link_listener, node, null())
              }),
            )
          Map(children) => {
            let mounted : Map[String, INode] = Map([])
            for key, child in children {
              mounted[key] = child.insert(
                scheduler,
                captured_link_listener,
                node,
                null(),
              )
            }
            Map(mounted)
          }
        }
      }
      parent.insert_before(node, before)
      Elem(tag, { props, slots }, children, namespace_uri~, element)
    }
  }
}

///|
#cfg(target="js")
pub fn mount(
  element_id : String,
  vnode : VNode,
  scheduler : &Scheduler,
) -> Mounted {
  let parent = @dom.document().get_element_by_id(element_id).unwrap()
  parent.set_inner_html("<div></div>")
  let captured_link_listener : @dom.Listener = event => {
    if event.to_mouse_event() is Some(mouse_event) &&
      scheduler.hooks().url_request is Some(hook) &&
      !(mouse_event.get_meta_key() || mouse_event.get_ctrl_key()) {
      event.prevent_default()
      let href = event
        .current_target()
        .unwrap()
        .to_element()
        .unwrap()
        .get_property("href")
        .unwrap()
      hook(scheduler, href)
    }
  }
  {
    root: vnode.insert(
      scheduler,
      captured_link_listener,
      parent.as_node(),
      null(),
    ),
    scheduler,
    captured_link_listener,
  }
}

///|
#cfg(not(target="js"))
pub fn mount(
  element_id : String,
  vnode : VNode,
  scheduler : &Scheduler,
) -> Mounted {
  ignore((element_id, scheduler))
  { vnode, }
}

///|
#cfg(target="js")
pub fn Mounted::update(self : Self, vnode : VNode) -> Unit {
  let end = self.root.end()
  let parent = end.get_parent_node().unwrap()
  let next_sibling = end.get_next_sibling()
  self.root = diff_node(
    self.root,
    vnode,
    self.scheduler,
    self.captured_link_listener,
    parent,
    next_sibling,
  )
}

///|
#cfg(not(target="js"))
pub fn Mounted::update(self : Self, vnode : VNode) -> Unit {
  self.vnode = vnode
}

///|
#cfg(target="js")
fn[A] nullable(value : A) -> @js.Nullable[A] {
  @js.Nullable::from_option(Some(value))
}

///|
#cfg(target="js")
fn[A] null() -> @js.Nullable[A] {
  @js.Nullable::null()
}

///|
#cfg(target="js")
fn diff_node(
  old : INode,
  new : VNode,
  scheduler : &Scheduler,
  captured_link_listener : @dom.Listener,
  parent : @dom.Node,
  anchor : @js.Nullable[@dom.Node],
) -> INode {
  match (old, new) {
    (
      Elem(tag1, props1, children1, namespace_uri=ns1, element),
      Elem(tag2, props2, children2, namespace_uri=ns2),
    ) =>
      if tag1 != tag2 || ns1 != ns2 {
        old.remove(parent)
        new.insert(scheduler, captured_link_listener, parent, anchor)
      } else {
        let props = diff_props(props1, props2, scheduler, element)
        let children = diff_children(
          children1,
          children2,
          scheduler,
          captured_link_listener,
          element.as_node(),
          null(),
        )
        Elem(tag2, props, children, namespace_uri=ns2, element)
      }
    (Text(text1, element), Text(text2)) => {
      if text1 != text2 {
        element.set_node_value(@js.Nullable::from_option(Some(text2)))
      }
      Text(text2, element)
    }
    (Frag(children1, start, end), Frag(children2)) => {
      let children = diff_children(
        Array(children1),
        Array(children2),
        scheduler,
        captured_link_listener,
        parent,
        nullable(end.as_node()),
      )
      guard! children is Array(children)
      Frag(children, start, end)
    }
    (Thunk(hash1, node) as old, Thunk(hash2, render)) =>
      if hash1 == hash2 {
        old
      } else {
        let vnode = render()
        let node = diff_node(
          node, vnode, scheduler, captured_link_listener, parent, anchor,
        )
        Thunk(hash2, node)
      }
    (_, _) => {
      old.remove(parent)
      new.insert(scheduler, captured_link_listener, parent, anchor)
    }
  }
}

///|
#cfg(target="js")
fn diff_props(
  old : MountedProps,
  new : Props,
  scheduler : &Scheduler,
  parent : @dom.Element,
) -> MountedProps {
  let slots = old.slots
  for event, slot in slots {
    if !new.handlers.contains(event) {
      slot.val = fn(_, _) {  }
    }
  }
  for event, handler in new.handlers {
    if slots.get(event) is Some(slot) {
      slot.val = handler
    } else {
      let slot = @ref.new(handler)
      parent.add_event_listener(event, event => (slot.val)(event, scheduler))
      slots[event] = slot
    }
  }

  for key, _ in old.props.attrs {
    if !new.attrs.contains(key) {
      parent.remove_attribute(key)
    }
  }
  for key, value2 in new.attrs {
    if old.props.attrs.get(key) is Some(value1) {
      if value1 != value2 {
        parent.set_attribute(key, value2)
      }
    } else {
      parent.set_attribute(key, value2)
    }
  }
  for key, _ in old.props.props {
    if !new.props.contains(key) {
      parent.remove_property(key)
    }
  }
  for key, value2 in new.props {
    if old.props.props.get(key) is Some(value1) {
      if value1 != value2 {
        parent.set_property(key, variant_to_js_value(value2))
      }
    } else {
      parent.set_property(key, variant_to_js_value(value2))
    }
  }
  let stylesheet = if parent.to_html_element() is Some(html) {
    html.get_style()
  } else if parent.to_svg_element() is Some(svg) {
    svg.get_style()
  } else {
    panic()
  }
  for key, _ in old.props.styles {
    if !new.styles.contains(key) {
      stylesheet.remove_property(key) |> ignore
    }
  }
  for key, value2 in new.styles {
    if old.props.styles.get(key) is Some(value1) {
      if value1 != value2 {
        stylesheet.set_property(key, value2)
      }
    } else {
      stylesheet.set_property(key, value2)
    }
  }
  { props: new, slots }
}

///|
#cfg(target="js")
fn diff_children(
  old : Children[INode],
  new : Children[VNode],
  scheduler : &Scheduler,
  captured_link_listener : @dom.Listener,
  parent : @dom.Node,
  anchor : @js.Nullable[@dom.Node],
) -> Children[INode] {
  match (old, new) {
    (Array(old), Array(new)) => {
      let old_length = old.length()
      let new_length = new.length()
      let mut before = anchor
      let acc = []
      let length = if old_length > new_length {
        for index in old_length>..new_length {
          old[index].remove(parent)
        }
        new_length
      } else {
        for index in new_length>..old_length {
          let node = new[index].insert(
            scheduler, captured_link_listener, parent, before,
          )
          acc.push(node)
          before = nullable(node.start())
        }
        old_length
      }
      for index in length>..0 {
        let node = diff_node(
          old[index],
          new[index],
          scheduler,
          captured_link_listener,
          parent,
          before,
        )
        acc.push(node)
        before = nullable(node.start())
      }
      Array(acc.rev())
    }
    (Map(old), Map(new)) => {
      for key, node in old {
        if !new.contains(key) {
          node.remove(parent)
        }
      }
      let order = new.to_array()
      let mut before = null()
      let reversed = []
      for index in order.length()>..0 {
        let (key, vnode) = order[index]
        let node = if old.get(key) is Some(node) {
          let node = diff_node(
            node, vnode, scheduler, captured_link_listener, parent, before,
          )
          node.relocate(parent, before)
          node
        } else {
          vnode.insert(scheduler, captured_link_listener, parent, before)
        }
        reversed.push((key, node))
        before = nullable(node.start())
      }
      Map(Map::from_array(reversed))
    }
    (RawHtml(old), RawHtml(new)) => {
      if old != new {
        parent.to_element().unwrap().set_inner_html(new)
      }
      RawHtml(new)
    }
    (_, RawHtml(new)) => {
      parent.to_element().unwrap().set_inner_html(new)
      RawHtml(new)
    }
    (_, _) => {
      parent.to_element().unwrap().set_inner_html("")
      new.map(child => {
        child.insert(scheduler, captured_link_listener, parent, null())
      })
    }
  }
}

///|
#cfg(target="js")
fn[A, B] Children::map(self : Children[A], f : (A) -> B) -> Children[B] {
  match self {
    Array(children) => Array(children.map(f))
    Map(children) => Map(children.map((_, child) => f(child)))
    RawHtml(html) => RawHtml(html)
  }
}

///|
#cfg(target="js")
fn variant_to_js_value(value : @variant.Variant) -> @js.Value {
  match value {
    String(value) => @js.Value::cast_from(value)
    Floating(value) => @js.Value::cast_from(value)
    Integer(value) => @js.Value::cast_from(value)
    Boolean(value) => @js.Value::cast_from(value)
  }
}
