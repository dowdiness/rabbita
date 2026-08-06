///|
test "direct dev assets keep the app in the top-level document" {
  let html =
    $|<!doctype html>
    $|<html>
    $|<head></head>
    $|<body><div id="app"></div></body>
    $|</html>
  let output = inject_direct_assets(html)
  assert_true(
    output.contains("<script src=\"/index.js\" type=\"module\"></script>"),
  )
  assert_true(
    output.contains(
      "<script src=\"/__warren/direct.js\" type=\"module\"></script>",
    ),
  )
  assert_true(
    output.contains(
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"/styles.css\"></link>",
    ),
  )
  assert_true(output.contains("<base href=\"/\">"))
}

///|
test "direct dev assets do not duplicate existing entries" {
  let html =
    $|<!doctype html>
    $|<html>
    $|<head>
    $|<base href="/">
    $|<script src="/index.js" type="module"></script>
    $|<script src="/__warren/direct.js" type="module"></script>
    $|<link rel="stylesheet" type="text/css" href="/styles.css"></link>
    $|</head>
    $|<body><div id="app"></div></body>
    $|</html>
  assert_eq(inject_direct_assets(html), html)
}
