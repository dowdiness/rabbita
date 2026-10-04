///|
// SSR's native renderer cannot import this JS-only package. This regression
// exercises the separate JS/server guard, including a server Worker polyfill.
extern "js" fn with_server_worker(probe : () -> Unit) -> Int =
  #| probe => {
  #|   const previous = Object.getOwnPropertyDescriptor(globalThis, "Worker");
  #|   let constructions = 0;
  #|   Object.defineProperty(globalThis, "Worker", {
  #|     configurable: true,
  #|     value: class { constructor() { constructions++; throw new Error("server Worker must not run"); } }
  #|   });
  #|   try { probe(); return constructions; }
  #|   finally {
  #|     if (previous) Object.defineProperty(globalThis, "Worker", previous);
  #|     else delete globalThis.Worker;
  #|   }
  #| }

///|
test "server Worker polyfill cannot start a subscription incarnation" {
  let result : Ref[Result[Entry, Failure]?] = Ref(None)
  let events = Ref(0)
  let constructions = with_server_worker(() => {
    result.val = Some(install_worker("/never-start.js", _ => events.val += 1))
  })
  assert_true(result.val is Some(Err(Unavailable)))
  assert_eq(constructions, 0)
  assert_eq(events.val, 0)
}

///|
async test "managed request rejects outside the browser before connection lookup" {
  let reply : Ref[Result[Json, Failure]?] = Ref(None)
  // Private construction is test setup for a stale identity; consumers cannot
  // construct connections. The environment gate must precede registry lookup.
  let connection : Connection = { id: 42, }
  @testing.run_cmd(
    request(connection, { "increment": 3 }, reply=result => {
      reply.val = Some(result)
      @cmd.none
    }),
  )
  assert_true(reply.val is Some(Err(Unavailable)))
}
