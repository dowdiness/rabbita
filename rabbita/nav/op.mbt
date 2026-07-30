///|
extenum @cmd.Extension += {
  NavBack
  NavForward
  NavLoad(String)
  NavReload
  NavPushUrl(String)
  NavReplaceUrl(String)
  NavScrollToPos(Int, Int, ScrollBehavior)
  NavScrollByPos(Int, Int, ScrollBehavior)
  NavScrollTo(String, ScrollBehavior)
  NavScrollToTop(ScrollBehavior)
  NavScrollToBottom(ScrollBehavior)
}

///|
fn scroll_behavior_repr(behavior : ScrollBehavior) -> Repr {
  match behavior {
    Auto => Repr::ctor("Auto", [])
    Instant => Repr::ctor("Instant", [])
    Smooth => Repr::ctor("Smooth", [])
  }
}

///|
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(op_invoke)
  ..on_debug(extension => {
    match extension {
      NavBack => Repr::ctor("NavBack", [])
      NavForward => Repr::ctor("NavForward", [])
      NavLoad(url) => Repr::ctor("NavLoad", [(None, Repr(url))])
      NavReload => Repr::ctor("NavReload", [])
      NavPushUrl(url) => Repr::ctor("NavPushUrl", [(None, Repr(url))])
      NavReplaceUrl(url) => Repr::ctor("NavReplaceUrl", [(None, Repr(url))])
      NavScrollToPos(x, y, behavior) =>
        Repr::ctor("NavScrollToPos", [
          (None, Repr(x)),
          (None, Repr(y)),
          (None, scroll_behavior_repr(behavior)),
        ])
      NavScrollByPos(x, y, behavior) =>
        Repr::ctor("NavScrollByPos", [
          (None, Repr(x)),
          (None, Repr(y)),
          (None, scroll_behavior_repr(behavior)),
        ])
      NavScrollTo(element, behavior) =>
        Repr::ctor("NavScrollTo", [
          (None, Repr(element)),
          (None, scroll_behavior_repr(behavior)),
        ])
      NavScrollToTop(behavior) =>
        Repr::ctor("NavScrollToTop", [(None, scroll_behavior_repr(behavior))])
      NavScrollToBottom(behavior) =>
        Repr::ctor("NavScrollToBottom", [(None, scroll_behavior_repr(behavior))])
      _ => raise Unhandled
    }
  })

///|
#cfg(target="js")
fn op_invoke(
  extension : @cmd.Extension,
  scheduler : &@cmd.Scheduler,
) -> Unit raise @cmd.Unhandled {
  match extension {
    NavBack => @dom.window().history_go_back()
    NavForward => @dom.window().history_go_forward()
    NavLoad(url) => @dom.window().load_url(url)
    NavReload => @dom.window().reload_url()
    NavPushUrl(url) => {
      @dom.window().push_url(url)
      if scheduler.hooks().url_changed is Some(hook) {
        let normalized_url = @dom.window().current_url()
        hook(scheduler, normalized_url)
      }
    }
    NavReplaceUrl(url) => {
      @dom.window().replace_url(url)
      if scheduler.hooks().url_changed is Some(hook) {
        let normalized_url = @dom.window().current_url()
        hook(scheduler, normalized_url)
      }
    }
    NavScrollToPos(x, y, behavior) =>
      @dom.window().scroll_to(x, y, behavior=behavior.to_string())
    NavScrollByPos(x, y, behavior) =>
      @dom.window().scroll_by(x, y, behavior=behavior.to_string())
    NavScrollTo(element, behavior) =>
      if @dom.document().get_element_by_id(element).to_option() is Some(node) {
        node.scroll_into_view(behavior=behavior.to_string())
      }
    NavScrollToTop(behavior) =>
      @dom.window().scroll_to_top(behavior=behavior.to_string())
    NavScrollToBottom(behavior) =>
      @dom.window().scroll_to_bottom(behavior=behavior.to_string())
    _ => raise Unhandled
  }
}

///|
#cfg(not(target="js"))
#warnings("-unused_error_type")
fn op_invoke(
  _ : @cmd.Extension,
  _ : &@cmd.Scheduler,
) -> Unit raise @cmd.Unhandled {
  ()
}
