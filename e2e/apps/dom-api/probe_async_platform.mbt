///|
fn probe_observers() -> Unit {
  let document = @dom.document()
  if document.get_body() is Some(body) {
    let target = document.create_element("div")
    @dom.IsElement::set_attribute(
      target, "style", "width: 20px; height: 20px; background: black",
    )
    @dom.IsNode::append_child(body, @dom.IsNode::as_node(target))
    let resize_done = [false]
    let mutation_done = [false]
    let intersection_done = [false]
    let failures : Array[String] = []
    fn update_result() {
      if resize_done[0] && mutation_done[0] && intersection_done[0] {
        set_result("observers-result", finish_probe(failures))
      }
    }
    let resize = @dom.ResizeObserver::new((entries, observer) => {
      record(failures, !entries.is_empty(), "resize_entries")
      observer.unobserve(target)
      observer.disconnect()
      resize_done[0] = true
      update_result()
    })
    let mutation = @dom.MutationObserver::new((records, observer) => {
      record(failures, !records.is_empty(), "mutation_records")
      if records.get(0) is Some(mutation_record) {
        record(
          failures,
          mutation_record.get_attribute_name() == Some("data-observed"),
          "mutation_attribute_name",
        )
      }
      observer.disconnect()
      mutation_done[0] = true
      update_result()
    })
    let intersection = @dom.IntersectionObserver::new(
      (entries, observer) => {
        record(failures, !entries.is_empty(), "intersection_entries")
        observer.unobserve(target)
        observer.disconnect()
        intersection_done[0] = true
        update_result()
      },
      threshold=[0.0, 0.5, 1.0],
    )
    resize.observe(target)
    mutation.observe(
      @dom.IsNode::as_node(target),
      attributes=true,
      child_list=true,
      subtree=true,
      attribute_old_value=true,
      character_data=true,
      character_data_old_value=true,
      attribute_filter=["data-observed"],
    )
    intersection.observe(target)
    @dom.IsElement::set_attribute(target, "data-observed", "yes")
    @dom.IsElement::set_attribute(
      target, "style", "width: 30px; height: 30px; background: black",
    )
  } else {
    set_result("observers-result", "failed: missing_body")
  }
}

///|
fn probe_timers() -> Unit {
  let window = @dom.window()
  let microtask_done = [false]
  let timeout_done = [false]
  let interval_done = [false]
  let animation_done = [false]
  let cancelled_timeout_fired = [false]
  let cancelled_animation_fired = [false]
  let interval_id = [0]
  window.queue_microtask(() => microtask_done[0] = true)
  ignore(window.set_timeout(() => timeout_done[0] = true, 1))
  interval_id[0] = window.set_interval(
    () => {
      interval_done[0] = true
      window.clear_interval(interval_id[0])
    },
    1,
  )
  ignore(window.request_animation_frame(_ => animation_done[0] = true))
  let cancelled_timeout = window.set_timeout(
    () => cancelled_timeout_fired[0] = true,
    1,
  )
  window.clear_timeout(cancelled_timeout)
  let cancelled_animation = window.request_animation_frame(_ => {
    cancelled_animation_fired[0] = true
  })
  window.cancel_animation_frame(cancelled_animation)
  ignore(
    window.set_timeout(
      () => {
        let failures : Array[String] = []
        record(failures, microtask_done[0], "queue_microtask")
        record(failures, timeout_done[0], "set_timeout")
        record(failures, interval_done[0], "set_interval")
        record(failures, animation_done[0], "request_animation_frame")
        record(failures, !cancelled_timeout_fired[0], "clear_timeout")
        record(
          failures,
          !cancelled_animation_fired[0],
          "cancel_animation_frame",
        )
        set_result("timers-result", finish_probe(failures))
      },
      50,
    ),
  )
}
