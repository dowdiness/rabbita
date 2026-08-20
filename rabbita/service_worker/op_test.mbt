///|
test "service worker commands have structural debug output" {
  debug_inspect(
    @service_worker.register("/sw.js", scope="/app/"),
    content=(
      #|ServiceWorkerRegister("/sw.js", Some("/app/"))
    ),
  )
  debug_inspect(
    @service_worker.get_registration("/app/"),
    content="ServiceWorkerGetRegistration(\"/app/\")",
  )
  debug_inspect(
    @service_worker.get_registrations(),
    content="ServiceWorkerGetRegistrations",
  )
  let id : @service_worker.RegistrationId = { scope: "/app/" }
  debug_inspect(
    @service_worker.update(id),
    content="ServiceWorkerUpdate(\"/app/\")",
  )
  debug_inspect(
    @service_worker.unregister(id),
    content="ServiceWorkerUnregister(\"/app/\")",
  )
  debug_inspect(
    @service_worker.post_message(id, Text("ping")),
    content="ServiceWorkerPostMessage(\"/app/\", Text(\"ping\"))",
  )
  debug_inspect(
    @service_worker.post_message(id, Json(@json.from_json({ "ping": true }))),
    content="ServiceWorkerPostMessage(\"/app/\", Json(Object({ \"ping\": True })))",
  )
}
