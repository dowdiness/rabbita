///|
test "service worker commands have structural debug output" {
  debug_inspect(
    @service_worker.register(
      "/sw.js",
      options=@service_worker.RegistrationOptions(scope="/app/"),
    ),
    content=(
      #|ServiceWorkerRegister(
      #|  "/sw.js",
      #|  Some({ scope: Some("/app/"), worker_type: None, update_via_cache: None }),
      #|)
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
  let id = @service_worker.RegistrationId("http://localhost/app/")
  debug_inspect(
    @service_worker.update(id),
    content="ServiceWorkerUpdate(\"http://localhost/app/\")",
  )
  debug_inspect(
    @service_worker.unregister(id),
    content="ServiceWorkerUnregister(\"http://localhost/app/\")",
  )
  debug_inspect(
    @service_worker.post_message(id, Text("ping")),
    content="ServiceWorkerPostMessage(\"http://localhost/app/\", Text(\"ping\"))",
  )
  debug_inspect(
    @service_worker.post_message(id, Json(@json.from_json({ "ping": true }))),
    content=(
      #|ServiceWorkerPostMessage(
      #|  "http://localhost/app/",
      #|  Json(Object({ "ping": True })),
      #|)
    ),
  )
}
