///|
#cfg(target="js")
fn command_test_update(
  message : CommandMessage,
  current : CommandModel,
) -> CommandModel {
  let (next, _) = command_update(
    Emit(_ => @cmd.none),
    "command-root",
    Some("command-dialog"),
    true,
    true,
    None,
    None,
    None,
    None,
    message,
    current,
  )
  next
}

///|
#cfg(target="js")
test "command dialog close state survives its exit window and stale finalize" {
  let open : CommandModel = {
    query: "set",
    active: 2,
    open: true,
    generation: 4,
  }
  let closing = command_test_update(CommandRequestClose, open)
  assert_true(!closing.open)
  assert_eq(closing.query, "set")
  assert_eq(closing.active, 2)
  assert_eq(closing.generation, 5)
  let reopened = command_test_update(CommandOpen, closing)
  assert_true(reopened.open)
  assert_eq(reopened.query, "")
  assert_eq(reopened.active, -1)
  assert_eq(reopened.generation, 6)
  let after_stale_finalize = command_test_update(
    CommandFinalizeClose(5),
    reopened,
  )
  assert_true(after_stale_finalize.open)
  assert_eq(after_stale_finalize.generation, 6)
}

///|
#cfg(target="js")
test "command selection enters closed state before native removal" {
  let open : CommandModel = {
    query: "dash",
    active: 0,
    open: true,
    generation: 8,
  }
  let closing = command_test_update(CommandSelect("Dashboard", @cmd.none), open)
  assert_true(!closing.open)
  assert_eq(closing.query, "")
  assert_eq(closing.active, -1)
  assert_eq(closing.generation, 9)
  let idempotent = command_test_update(CommandRequestClose, closing)
  assert_eq(idempotent.generation, 9)
  assert_true(!idempotent.open)
}
