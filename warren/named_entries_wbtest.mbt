///|
test "parse_named_entries resolves package paths and preserves order" {
  let root = SourcePath::new("/workspace/project")
  let parsed = parse_named_entries(
    ["capability-worker=worker", "inspector=tools/inspector"],
    root,
  )
  guard parsed is Ok([worker, inspector]) else {
    fail("expected two named entries")
  }
  assert_eq(worker.name, "capability-worker")
  assert_eq(
    source_path_to_string(worker.package_dir),
    "/workspace/project/worker",
  )
  assert_eq(inspector.name, "inspector")
  assert_eq(
    source_path_to_string(inspector.package_dir),
    "/workspace/project/tools/inspector",
  )
}

///|
test "parse_named_entries rejects unsafe and empty names" {
  let root = SourcePath::new("/workspace/project")
  for
    raw in [
      "=worker", "worker=", "worker/name=worker", "../worker=worker", "worker name=worker",
      "worker.js=worker", "index=worker",
    ] {
    guard parse_named_entries([raw], root) is Err(_) else {
      fail("expected invalid entry specification to be rejected")
    }
  }
}

///|
test "parse_named_entries rejects duplicate names" {
  let root = SourcePath::new("/workspace/project")
  guard parse_named_entries(["worker=one", "worker=two"], root) is Err(message) else {
    fail("expected duplicate entry names to be rejected")
  }
  assert_true(message.contains("duplicate"))
}

///|
test "parse_named_entries keeps legacy no-entry behavior" {
  let root = SourcePath::new("/workspace/project")
  guard parse_named_entries([], root) is Ok(entries) else {
    fail("expected no entries to be accepted")
  }
  assert_true(entries.is_empty())
  guard all_build_entries(root, []) is [page] else {
    fail("expected a single legacy page entry")
  }
  assert_eq(page.name, None)
  assert_eq(entry_output_filename(page.name), "index.js")
}

///|
test "entry_output_filename names auxiliary artifacts" {
  assert_eq(
    entry_output_filename(Some("capability-worker")),
    "capability-worker.js",
  )
  assert_eq(entry_output_filename(Some("inspector")), "inspector.js")
}
