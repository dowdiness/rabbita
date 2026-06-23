///|
test "basic_url" {
  let a = "http://localhost:5173/abcd"
  @debug.debug_inspect(
    try {
      let v = @url.parse(a)
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Http, host: "localhost", port: Some(5173), path: "abcd", query: None, fragment: None})
    ),
  )
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: None, path: "", query: None, fragment: None})
    ),
  )
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com/")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: None, path: "", query: None, fragment: None})
    ),
  )
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com/path1/path2")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: None, path: "path1/path2", query: None, fragment: None})
    ),
  )
  @debug.debug_inspect(
    try {
      let v = @url.parse(
        "https://example.com:8080/path/to/somewhere?query#fragment",
      )
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: Some(8080), path: "path/to/somewhere", query: Some("query"), fragment: Some("fragment")})
    ),
  )
  @debug.debug_inspect(
    try {
      let v = @url.parse(
        "https://example.com:8080/path/to/somewhere?key=value&key2=value2#fragment",
      )
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: Some(8080), path: "path/to/somewhere", query: Some("key=value&key2=value2"), fragment: Some("fragment")})
    ),
  )
}

///|
test "special url" {
  @debug.debug_inspect(
    try {
      let v = @url.parse("localhost:8080/abcd")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Other(""), host: "localhost", port: Some(8080), path: "abcd", query: None, fragment: None})
    ),
  )
}

///|
test "no_port" {
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com/path/to/somewhere?query#fragment")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: None, path: "path/to/somewhere", query: Some("query"), fragment: Some("fragment")})
    ),
  )
}

///|
test "no_query" {
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com:8080/path/to/somewhere#fragment")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: Some(8080), path: "path/to/somewhere", query: None, fragment: Some("fragment")})
    ),
  )
}

///|
test "no_fragment" {
  @debug.debug_inspect(
    try {
      let v = @url.parse("https://example.com:8080/path/to/somewhere?query")
      Ok(v)
    } catch {
      e => Err(e)
    },
    content=(
      #|Ok({protocol: Https, host: "example.com", port: Some(8080), path: "path/to/somewhere", query: Some("query"), fragment: None})
    ),
  )
}
