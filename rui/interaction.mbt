///|
#cfg(target="js")
priv struct DialogLayerBinding {
  element : @dom.Element
  dialog : @dom.HTMLDialogElement
  request_close : Ref[() -> Unit]
  return_focus : Ref[@dom.HTMLElement?]
}

///|
#cfg(target="js")
let dialog_layers : Map[String, DialogLayerBinding] = Map([])

///|
#cfg(target="js")
let dialog_stack : Ref[Array[String]] = Ref([])

///|
#cfg(target="js")
let dialog_bound_document : Ref[@dom.Document?] = Ref(None)

///|
#cfg(target="js")
let dialog_outside_press_had_floating : Ref[Bool] = Ref(false)

///|
#cfg(target="js")
fn dialog_update_stack(id : String, open : Bool) -> Unit {
  let next : Array[String] = []
  for current in dialog_stack.val {
    if current != id {
      next.push(current)
    }
  }
  if open {
    next.push(id)
  }
  dialog_stack.val = next
}

///|
#cfg(target="js")
fn dialog_live_layer(id : String) -> DialogLayerBinding? {
  guard dialog_layers.get(id) is Some(layer) else { return None }
  guard ui_element_by_id(id) is Some(element) else {
    dialog_update_stack(id, false)
    return None
  }
  if !element.get_is_connected() ||
    !layer.element.is_same_node(element.as_node()) ||
    !layer.dialog.open() {
    dialog_update_stack(id, false)
    return None
  }
  Some(layer)
}

///|
#cfg(target="js")
fn dialog_top_layer() -> DialogLayerBinding? {
  let stack = dialog_stack.val
  for index = stack.length() - 1; index >= 0; index = index - 1 {
    let id = stack[index]
    if dialog_live_layer(id) is Some(layer) {
      return Some(layer)
    }
  }
  None
}

///|
#cfg(target="js")
fn dialog_restore_focus(layer : DialogLayerBinding) -> Unit {
  if layer.element.get_attribute("data-modal").unwrap_or("") != "false" ||
    layer.element.get_attribute("data-restore-focus").unwrap_or("") == "false" {
    return
  }
  let document = @dom.document()
  if document.get_active_element() is Some(active) {
    let active_is_body = if document.get_body() is Some(body) {
      active.is_same_node(body.as_node())
    } else {
      false
    }
    if !active_is_body && !layer.element.contains(active.as_node()) {
      return
    }
  }
  let final_id = layer.element
    .get_attribute("data-final-focus-id")
    .unwrap_or("")
  let target = if ui_element_by_id(final_id) is Some(element) &&
    element.to_html_element() is Some(html) {
    Some(html)
  } else {
    layer.return_focus.val
  }
  if target is Some(html) && html.get_is_connected() {
    html.focus_with_options(prevent_scroll=true)
  }
}

///|
#cfg(target="js")
fn dialog_bind_document_events() -> Unit {
  let document = @dom.document()
  if dialog_bound_document.val is Some(bound) &&
    bound.to_node().is_same_node(document.to_node()) {
    return
  }
  dialog_bound_document.val = Some(document)
  document.add_event_listener_with_options(
    "pointerdown",
    _ => dialog_outside_press_had_floating.val = floating_top_layer() is Some(_),
    capture=true,
  )
  document.add_event_listener("keydown", event => {
    guard event.to_keyboard_event() is Some(keyboard) else { return }
    if keyboard.key() != "Escape" ||
      event.get_default_prevented() ||
      floating_top_layer() is Some(_) {
      return
    }
    guard dialog_top_layer() is Some(layer) else { return }
    if layer.element.get_attribute("data-close-on-escape").unwrap_or("") !=
      "true" {
      return
    }
    event.prevent_default()
    event.stop_propagation()
    (layer.request_close.val)()
  })
  document.add_event_listener("click", event => {
    if event.get_default_prevented() {
      return
    }
    let had_floating = dialog_outside_press_had_floating.val
    dialog_outside_press_had_floating.val = false
    if had_floating || floating_top_layer() is Some(_) {
      return
    }
    guard dialog_top_layer() is Some(layer) else { return }
    if layer.element.get_attribute("data-modal").unwrap_or("") != "false" {
      return
    }
    let selector = "[data-slot=\"dialog-content\"],[data-slot=\"sheet-content\"],[data-slot=\"drawer-content\"]"
    if layer.element.query_selector(selector) is Some(content) &&
      floating_event_inside(event, content) {
      return
    }
    if layer.element.get_attribute("data-close-on-outside").unwrap_or("") ==
      "true" {
      (layer.request_close.val)()
    }
  })
}

///|
#cfg(target="js")
fn bind_dialog_layer(id : String, request_close : () -> Unit) -> Unit {
  guard ui_element_by_id(id) is Some(element) else { return }
  guard element.to_html_dialog_element() is Some(dialog) else { return }
  if dialog_layers.get(id) is Some(layer) &&
    layer.element.is_same_node(element.as_node()) {
    layer.request_close.val = request_close
    return
  }
  let layer : DialogLayerBinding = {
    element,
    dialog,
    request_close: Ref(request_close),
    return_focus: Ref(None),
  }
  dialog_layers[id] = layer
  dialog_bind_document_events()
  dialog.add_event_listener("close", _ => {
    dialog_update_stack(id, false)
    if ui_has_window() {
      @dom.window().queue_microtask(() => dialog_restore_focus(layer))
    } else {
      dialog_restore_focus(layer)
    }
  })
}

///|
#cfg(target="js")
fn should_close_dialog_outside() -> Bool {
  let had_floating = dialog_outside_press_had_floating.val
  dialog_outside_press_had_floating.val = false
  !had_floating && floating_top_layer() is None
}

///|
#cfg(target="js")
fn ui_dialog_should_close_outside() -> Bool {
  should_close_dialog_outside()
}

///|
#cfg(not(target="js"))
fn ui_dialog_should_close_outside() -> Bool {
  true
}

///|
#cfg(target="js")
fn mark_dialog_layer(id : String, open : Bool) -> Unit {
  dialog_update_stack(id, open)
  if !open {
    return
  }
  guard dialog_layers.get(id) is Some(layer) else { return }
  if @dom.document().get_active_element() is Some(active) &&
    !layer.element.contains(active.as_node()) &&
    active.to_html_element() is Some(html) {
    layer.return_focus.val = Some(html)
  }
  if layer.element.get_attribute("data-modal").unwrap_or("") != "false" ||
    layer.element.get_attribute("data-initial-focus").unwrap_or("") == "false" {
    return
  }
  fn focus_initial() -> Unit {
    if !layer.dialog.open() {
      return
    }
    let requested_id = layer.element
      .get_attribute("data-initial-focus-id")
      .unwrap_or("")
    let requested = ui_element_by_id(requested_id)
    let selector = "button:not([disabled]),a[href],input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex=\"-1\"])"
    let target = if requested is Some(element) &&
      layer.element.contains(element.as_node()) {
      Some(element)
    } else {
      match layer.element.query_selector(selector) {
        Some(element) => Some(element)
        None => Some(layer.element)
      }
    }
    if target is Some(element) {
      ui_focus_element_without_scroll(element)
    }
  }

  if ui_has_window() {
    ignore(@dom.window().request_animation_frame(_ => focus_initial()))
  } else {
    focus_initial()
  }
}

///|
#cfg(target="js")
fn ui_dialog_bind(id : String, request_close : @cmd.Cmd) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=@cmd.AfterRender, scheduler => {
    ui_after_mount(
      id,
      () => bind_dialog_layer(id, () => scheduler.add(request_close)),
      purpose="dialog-bind",
    )
  })
}

///|
#cfg(not(target="js"))
fn ui_dialog_bind(id : String, request_close : @cmd.Cmd) -> @cmd.Cmd {
  ignore((id, request_close))
  @cmd.none
}

///|
#cfg(target="js")
fn ui_dialog_show(id : String, modal : Bool) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=@cmd.after_render, _ => {
    ui_after_mount(
      id,
      () => {
        if @dom.document().get_element_by_id(id).to_option() is Some(element) &&
          element.to_html_element() is Some(html_element) &&
          html_element.to_html_dialog_element() is Some(dialog) {
          mark_dialog_layer(id, true)
          if !dialog.open() {
            if modal {
              dialog.show_modal()
            } else {
              dialog.show()
            }
          }
        }
      },
      purpose="dialog-show",
    )
  })
}

///|
#cfg(not(target="js"))
fn ui_dialog_show(id : String, modal : Bool) -> @cmd.Cmd {
  ignore((id, modal))
  @cmd.none
}

///|
#cfg(target="js")
fn ui_dialog_close(id : String) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=@cmd.after_render, _ => {
    if @dom.document().get_element_by_id(id).to_option() is Some(element) &&
      element.to_html_element() is Some(html_element) &&
      html_element.to_html_dialog_element() is Some(dialog) {
      if dialog.open() {
        dialog.close()
      }
      mark_dialog_layer(id, false)
    }
  })
}

///|
#cfg(not(target="js"))
fn ui_dialog_close(id : String) -> @cmd.Cmd {
  ignore(id)
  @cmd.none
}

///|
#cfg(target="js")
fn ui_focus_id(id : String) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=@cmd.after_render, _ => {
    if @dom.document().get_element_by_id(id).to_option() is Some(element) &&
      element.to_html_element() is Some(html_element) {
      html_element.focus()
    }
  })
}

///|
#cfg(not(target="js"))
fn ui_focus_id(id : String) -> @cmd.Cmd {
  ignore(id)
  @cmd.none
}

///|
#cfg(target="js")
fn ui_scroll_id(id : String, end_ : Bool) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=@cmd.after_render, _ => {
    if @dom.document().get_element_by_id(id).to_option() is Some(element) {
      if end_ {
        element.set_scroll_top(element.get_scroll_height())
      } else {
        element.set_scroll_top(0.0)
      }
    }
  })
}

///|
#cfg(not(target="js"))
fn ui_scroll_id(id : String, end_ : Bool) -> @cmd.Cmd {
  ignore((id, end_))
  @cmd.none
}
