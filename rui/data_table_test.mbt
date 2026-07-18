///|
priv struct DataTableTestRow {
  id : String
  status : String
  email : String
  amount : Int
}

///|
fn data_table_test_rows() -> Array[DataTableTestRow] {
  [
    { id: "inv-001", status: "success", email: "ada@example.com", amount: 316 },
    {
      id: "inv-002",
      status: "processing",
      email: "grace@example.com",
      amount: 242,
    },
    { id: "inv-003", status: "failed", email: "linus@example.com", amount: 837 },
  ]
}

///|
fn data_table_test_columns() -> Array[@rui.DataTableColumn[DataTableTestRow]] {
  [
    @rui.data_table_column(key="status", label="Status", value=row => row.status),
    @rui.data_table_column(key="email", label="Email", value=row => row.email),
    @rui.data_table_column(
      key="amount",
      label="Amount",
      value=row => "\{row.amount}",
      numeric=true,
      render=row => @html.strong("$\{row.amount}"),
    ),
  ]
}

///|
test "data table renders typed cells and black-box controls" {
  let html = render_incremental(() => {
    @rui.data_table(
      id="payments",
      rows=data_table_test_rows(),
      columns=data_table_test_columns(),
      row_key=row => row.id,
      page_size=2,
      default_sort_key="amount",
      default_selected=["inv-002", "missing-row"],
      style=["max-width:64rem"],
    )
  })
  assert_contains(html, "data-slot=\"data-table\"")
  assert_contains(html, "data-page=\"1\"")
  assert_contains(html, "data-page-count=\"2\"")
  assert_contains(html, "data-row-count=\"3\"")
  assert_contains(html, "data-slot=\"data-table-search\"")
  assert_contains(html, "data-slot=\"data-table-columns-trigger\"")
  assert_contains(html, "id=\"payments-columns\"")
  assert_contains(html, "data-slot=\"data-table-columns-wrap\"")
  assert_contains(html, "data-state=\"closed\"")
  assert_contains(html, "aria-haspopup=\"menu\"")
  assert_contains(html, "aria-sort=\"ascending\"")
  assert_contains(html, "data-table-row=\"\"")
  assert_contains(html, "role=\"checkbox\"")
  assert_contains(html, "1 of 3 row(s) selected.")
  assert_contains(html, "Page 1 of 2")
  assert_contains(html, "<strong>$242</strong>")
  assert_contains(html, "max-width:64rem")
  assert_contains(
    html, "height:2rem;margin-inline-start:-0.25rem;padding-inline:0.5rem",
  )
  assert_not_contains(html, "margin-inline-start:-0.5rem")
}

///|
test "data table honors hidden columns and caller style order" {
  let html = render_incremental(() => {
    @rui.data_table(
      id="compact-payments",
      rows=data_table_test_rows(),
      columns=data_table_test_columns(),
      row_key=row => row.id,
      default_hidden_columns=["email"],
      selectable=false,
      searchable=false,
      show_columns=false,
      style=["gap:3rem"],
    )
  })
  assert_contains(html, "data-slot=\"data-table\"")
  assert_not_contains(html, "data-slot=\"data-table-search\"")
  assert_not_contains(html, "data-slot=\"data-table-columns-trigger\"")
  assert_not_contains(html, ">Email</")
  assert_contains(html, "3 row(s).")
  assert_contains(html, "gap:1rem")
  assert_contains(html, "gap:3rem")
}
