///|
async test "HTML fallback serves application routes but not missing assets" {
  let vfs = @vfs.new({ "/index.html": FileContent("<main>app</main>") })
  let hub = @devhub.Devhub(0U, vfs, html_fallback_path="/index.html")
  @async.with_task_group <| group => {
    group.spawn_bg(no_wait=true, allow_failure=true, () => hub.run_forever())
    let address = "http://127.0.0.1:\{hub.port()}"
    let (route_response, route_body) = @http.get(address + "/settings", headers={
      "Accept": "text/html",
    })
    assert_eq(route_response.code, 200)
    assert_eq(route_response.headers.get("content-type"), Some("text/html"))
    assert_eq(route_body.text(), "<main>app</main>")

    let (asset_response, _) = @http.get(address + "/missing.js", headers={
      "Accept": "text/javascript",
    })
    assert_eq(asset_response.code, 404)
  }
}

///|
async test "HTML fallback stays disabled when it is not configured" {
  let vfs = @vfs.new({ "/index.html": FileContent("<main>app</main>") })
  let hub = @devhub.Devhub(0U, vfs)
  @async.with_task_group <| group => {
    group.spawn_bg(no_wait=true, allow_failure=true, () => hub.run_forever())
    let (response, _) = @http.get("http://127.0.0.1:\{hub.port()}/settings", headers={
      "Accept": "text/html",
    })
    assert_eq(response.code, 404)
  }
}
