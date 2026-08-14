///|
#cfg(not(target="js"))
test "failed HTTP results request hydration fallback" {
  let result : Result[String, HttpError] = Err(RequestError("offline"))
  try settle_result(result, _ => @cmd.none) catch {
    @cmd.HydrateExn::Fallback => ()
    _ => fail("unexpected hydration error")
  } noraise {
    _ => fail("expected hydration fallback")
  }
}
