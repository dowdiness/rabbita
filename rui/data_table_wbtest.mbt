///|
#cfg(target="js")
test "data table columns close message is idempotent" {
  let initial = data_table_initial_model(None, false, [], [])
  let open = data_table_update(DataTableToggleColumns, initial)
  let closed = data_table_update(DataTableCloseColumns, open)
  let closed_again = data_table_update(DataTableCloseColumns, closed)
  assert_true(open.columns_open)
  assert_false(closed.columns_open)
  assert_false(closed_again.columns_open)
}
