///|
using @rabbita {type Html, type MountedApp, type Val}

///|
using @html {button, div, h1, nothing, p}

///|
let current_mount : @ref.Ref[MountedApp?] = @ref.Ref(None)

///|
let stale_mount : @ref.Ref[MountedApp?] = @ref.Ref(None)

///|
let unload_count : @ref.Ref[Int] = @ref.Ref(0)

///|
let delayed_delivery_count : @ref.Ref[Int] = @ref.Ref(0)

///|
let frame_delivery_count : @ref.Ref[Int] = @ref.Ref(0)

///|
priv suberror LifecycleSubscription {
  LifecycleSubscription
}

///|
priv enum ChildMessage {
  StartDelayedUpdate
  FinishDelayedUpdate
  QueueFrameUpdate
}

///|
fn set_text(id : String, text : String) -> Unit {
  guard @dom.document().get_element_by_id(id).to_option() is Some(element) else {
    return
  }
  guard element.to_html_element() is Some(output) else { return }
  output.set_inner_text(text)
}

///|
fn publish_unload_count() -> Unit {
  set_text("unload-count", "unloads: \{unload_count.val}")
}

///|
fn record_delayed_delivery() -> Unit {
  delayed_delivery_count.val += 1
  set_text(
    "delayed-delivery-count",
    "delayed deliveries: \{delayed_delivery_count.val}",
  )
}

///|
fn record_frame_delivery() -> Unit {
  frame_delivery_count.val += 1
  set_text(
    "frame-delivery-count",
    "frame deliveries: \{frame_delivery_count.val}",
  )
}

///|
fn lifecycle_subscription() -> @sub.Sub {
  @sub.custom_sub(
    "mount-lifecycle",
    @sub.Local,
    LifecycleSubscription,
    @sub.SubLoader((_, _) => {
      Some({
        unload: _ => {
          unload_count.val += 1
          publish_unload_count()
        },
        update_tagger: _ => (),
      })
    }),
  )
}

///|
fn child_a() -> Val[Html] {
  let (status, emit) = @rabbita.create_state(
    "A ready",
    update=(_status, message, emit) => {
      match message {
        StartDelayedUpdate =>
          ("A waiting", @rabbita.delay(emit(FinishDelayedUpdate), 1000))
        FinishDelayedUpdate =>
          ("A delayed update", @cmd.custom_cmd(_ => record_delayed_delivery()))
        QueueFrameUpdate =>
          (
            "A queued frame",
            @cmd.custom_cmd(
              _ => record_frame_delivery(),
              kind=@cmd.after_render,
            ),
          )
      }
    },
    subscriptions=(_status, _emit) => lifecycle_subscription(),
  )
  status.view(status => {
    div <| [
      p(id="child-status", status),
      button(on_click=emit(StartDelayedUpdate), "Schedule delayed A update"),
      button(
        id="queue-frame-update",
        on_click=emit(QueueFrameUpdate),
        "Queue A frame update",
      ),
    ]
  })
}

///|
fn child_b() -> Val[Html] {
  Val::constant(
    div <| [
      p(id="child-status", "B mounted"),
    ],
  )
}

///|
fn unmount_current() -> Unit {
  if current_mount.val is Some(mounted) {
    mounted.unmount()
  }
}

///|
fn mount_a() -> Unit {
  unmount_current()
  current_mount.val = Some(@rabbita.new(child_a).mount("mount-target"))
}

///|
fn mount_b() -> Unit {
  unmount_current()
  current_mount.val = Some(@rabbita.new(child_b).mount("mount-target"))
}

///|
fn replace_with_b() -> Unit {
  stale_mount.val = current_mount.val
  current_mount.val = Some(@rabbita.new(child_b).mount("mount-target"))
}

///|
fn unmount_stale() -> Unit {
  if stale_mount.val is Some(mounted) {
    mounted.unmount()
  }
  set_text("shell-status", "stale A unmount completed")
}

///|
fn queue_frame_then_unmount() -> Unit {
  guard @dom.document().get_element_by_id("queue-frame-update").to_option()
    is Some(element) else {
    return
  }
  guard element.to_html_element() is Some(button) else { return }
  button.click()
  @dom.window().queue_microtask(() => {
    unmount_current()
    set_text("shell-status", "queued frame unmounted")
  })
}

///|
fn controller() -> Val[Html] {
  Val::constant(
    div <| [
      h1("Mount lifecycle"),
      button(on_click=@cmd.custom_cmd(_ => mount_a()), "Mount A"),
      button(
        on_click=@cmd.custom_cmd(_ => unmount_current()),
        "Unmount current",
      ),
      button(on_click=@cmd.custom_cmd(_ => mount_b()), "Mount B"),
      button(
        on_click=@cmd.custom_cmd(_ => replace_with_b()),
        "Replace A with B",
      ),
      button(on_click=@cmd.custom_cmd(_ => unmount_stale()), "Unmount stale A"),
      button(
        on_click=@cmd.custom_cmd(_ => queue_frame_then_unmount()),
        "Queue A frame then unmount",
      ),
      p(id="shell-status", "idle"),
      p(id="unload-count", "unloads: 0"),
      p(id="delayed-delivery-count", "delayed deliveries: 0"),
      p(id="frame-delivery-count", "frame deliveries: 0"),
      div(id="mount-target", nothing),
    ],
  )
}

///|
fn main {
  ignore(@rabbita.new(controller).mount("app"))
}
