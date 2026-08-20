///|
test "WorkerState follows the spec transition graph" {
  let parsed = @service_worker.WorkerState::Parsed
  let installing = @service_worker.WorkerState::Installing
  let installed = @service_worker.WorkerState::Installed
  let activating = @service_worker.WorkerState::Activating
  let activated = @service_worker.WorkerState::Activated
  let redundant = @service_worker.WorkerState::Redundant

  inspect(parsed, content="parsed")
  inspect(installing, content="installing")
  inspect(activating.is_active(), content="true")
  inspect(activated.is_terminal(), content="true")
  inspect(installing.is_settling(), content="true")
  inspect(installed.is_settling(), content="false")

  inspect(installing.can_transition_to(installed), content="true")
  inspect(installing.can_transition_to(redundant), content="true")
  inspect(installing.can_transition_to(activated), content="false")
  inspect(installed.can_transition_to(activating), content="true")
  inspect(activating.can_transition_to(activated), content="true")
}

///|
test "Message show output distinguishes text and json payloads" {
  inspect(@service_worker.Message::Text("ping"), content="Text(ping)")
  inspect(
    @service_worker.Message::Json(@json.from_json({ "ok": true })),
    content="Json({\"ok\":true})",
  )
}
