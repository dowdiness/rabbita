///|
#external
type Fetch

///|
extern "js" fn install_mock_fetch() -> Fetch =
  #| () => {
  #|   const originalFetch = globalThis.fetch;
  #|   globalThis.fetch = (url) => {
  #|     const responses = {
  #|       "/not-found": {
  #|         ok: false,
  #|         status: 404,
  #|         statusText: "Not Found",
  #|         body: "missing",
  #|       },
  #|       "/server-error": {
  #|         ok: false,
  #|         status: 500,
  #|         statusText: "Internal Server Error",
  #|         body: "failed",
  #|       },
  #|       "/ok": {
  #|         ok: true,
  #|         status: 200,
  #|         statusText: "OK",
  #|         body: "success",
  #|       },
  #|     };
  #|     const response = responses[url];
  #|     return Promise.resolve({
  #|       ok: response.ok,
  #|       status: response.status,
  #|       statusText: response.statusText,
  #|       text: () => Promise.resolve(response.body),
  #|       blob: () => Promise.resolve(new Blob([response.body])),
  #|       headers: {
  #|         get: (name) => name === "Content-Type" ? "text/plain" : null,
  #|       },
  #|       arrayBuffer: () => Promise.resolve(
  #|         new TextEncoder().encode(response.body).buffer
  #|       ),
  #|     });
  #|   };
  #|   return originalFetch;
  #| }

///|
extern "js" fn restore_fetch(fetch : Fetch) -> Unit =
  #| (fetch) => {
  #|   globalThis.fetch = fetch;
  #| }

///|
async fn invoke_js_request(url : String, response_kind : String) -> String {
  @js.suspend(fn(resolve, reject) {
    js_request(
      url,
      "GET",
      content_type="",
      body_kind="empty",
      response_kind~,
      text_body="",
      bytes_body=Default::default(),
      blob_body=@js.Nullable::from_option(None),
      succeed_text=text => resolve("text:\{text}"),
      succeed_blob=_ => resolve("blob"),
      succeed_bytes=(content_type, bytes) => {
        resolve("bytes:\{content_type}:\{bytes.length()}")
      },
      failed=detail => reject(RequestError(detail)),
    )
  })
}

///|
test "js_request rejects non-2xx responses before reading the body" {
  @js.async_test(() => {
    let original_fetch = install_mock_fetch()
    try {
      try invoke_js_request("/not-found", "text") catch {
        RequestError(detail) => assert_eq(detail, "HTTP 404 Not Found")
        error => raise error
      } noraise {
        _ => fail("expected 404 response to fail")
      }
      try invoke_js_request("/server-error", "bytes") catch {
        RequestError(detail) =>
          assert_eq(detail, "HTTP 500 Internal Server Error")
        error => raise error
      } noraise {
        _ => fail("expected 500 response to fail")
      }
      assert_eq(invoke_js_request("/ok", "text"), "text:success")
    } catch {
      error => {
        restore_fetch(original_fetch)
        raise error
      }
    } noraise {
      _ => restore_fetch(original_fetch)
    }
  })
}
