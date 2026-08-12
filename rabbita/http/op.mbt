///|
extenum @cmd.Extension += {
  Request(
    url~ : String,
    http_method~ : String,
    body~ : Body,
    expect~ : Expecting
  )
}

///|
priv enum Expecting {
  Json((Result[Json, HttpError]) -> Cmd)
  Text((Result[String, HttpError]) -> Cmd)
  Bytes((Result[(ContentType, Bytes), HttpError]) -> Cmd)
  Blob((Result[Blob, HttpError]) -> Cmd)
}

///|
let op : @cmd.Op = @cmd.Op()
  ..on_describe(data => {
    match data {
      Request(url~, http_method~, body~, expect~) => {
        let response_kind = match expect {
          Json(_) => "json"
          Text(_) => "text"
          Bytes(_) => "bytes"
          Blob(_) => raise Unhandled
        }
        let body : Json = match body {
          Json(json) => { "kind": "json", "value": json }
          Text(text) => { "kind": "text", "value": text }
          BytesBody(content_type, bytes) =>
            {
              "kind": "bytes",
              "content_type": content_type,
              "value": ToJson::to_json(bytes),
            }
          BlobBody(_, _) => raise Unhandled
          Empty => { "kind": "empty" }
        }
        {
          "url": url,
          "method": http_method,
          "body": body,
          "response_kind": response_kind,
        }
      }
      _ => raise Unhandled
    }
  })
  ..on_resume((extension, json, _context) => {
    match extension {
      Request(expect=Json(f), ..) =>
        f(@json.from_json(json)) catch {
          _ => raise Fallback
        }
      Request(expect=Text(f), ..) =>
        f(@json.from_json(json)) catch {
          _ => raise Fallback
        }
      Request(expect=Bytes(f), ..) =>
        f(@json.from_json(json)) catch {
          _ => raise Fallback
        }
      _ => raise Fallback
    }
  })
  ..on_debug(extension => {
    match extension {
      Request(url~, http_method~, body~, expect~) => {
        let body = match body {
          Json(_) => Repr::ctor("Json", [])
          Text(_) => Repr::ctor("Text", [])
          BytesBody(_, _) => Repr::ctor("Bytes", [])
          BlobBody(_, _) => Repr::ctor("Blob", [])
          Empty => Repr::ctor("Empty", [])
        }
        let expect = match expect {
          Json(_) => Repr::ctor("Json", [])
          Text(_) => Repr::ctor("Text", [])
          Bytes(_) => Repr::ctor("Bytes", [])
          Blob(_) => Repr::ctor("Blob", [])
        }
        Repr::ctor("Request", [
          (Some("url"), Repr(url)),
          (Some("http_method"), Repr(http_method)),
          (Some("body"), body),
          (Some("expect"), expect),
        ])
      }
      _ => raise Unhandled
    }
  })
  ..on_invoke((_, _) => None)

///|
fn init {
  op.on_invoke((extension, context) => {
    guard extension is Request(url~, http_method~, body~, expect~) else {
      raise Unhandled
    }
    fn fail_request(error : HttpError) -> Cmd {
      match expect {
        Json(f) => f(Err(error))
        Text(f) => f(Err(error))
        Bytes(f) => f(Err(error))
        Blob(f) => f(Err(error))
      }
    }

    if !url.contains("://") {
      let cmd = try {
        let current_url = context.get_current_url()
        let current = @url.parse(current_url)
        let protocol = match current.protocol {
          @url.Http => "http"
          Https => "https"
          Other(protocol) => fail("unsupported HTTP protocol: \{protocol}")
        }
        let port = if current.port is Some(port) { ":\{port}" } else { "" }
        let origin = "\{protocol}://\{current.host}\{port}"
        let resolved_url = if url.is_empty() {
          current_url
        } else if url.has_prefix("//") {
          "\{protocol}:\{url}"
        } else if url.has_prefix("/") {
          "\{origin}\{url}"
        } else if url.has_prefix("?") || url.has_prefix("#") {
          "\{origin}/\{current.path}\{url}"
        } else {
          let directory = if current.path.rev_split_once("/")
            is Some((directory, _)) {
            if directory.is_empty() {
              "/"
            } else {
              "/\{directory}/"
            }
          } else {
            "/"
          }
          "\{origin}\{directory}\{url}"
        }
        op.request(Request(url=resolved_url, http_method~, body~, expect~))
      } catch {
        error => fail_request(RequestError(error.to_string()))
      }
      Ready(cmd)
    } else {
      Async(() => {
        fn request_method() -> @async_http.RequestMethod raise @cmd.Unhandled {
          match http_method {
            "GET" => @async_http.Get
            "DELETE" => Delete
            "POST" => Post
            "PATCH" => Patch
            "PUT" => Put
            _ => raise @cmd.Unhandled
          }
        }

        fn request_target() -> (String, String) raise {
          let parsed = @url.parse(url)
          let protocol = match parsed.protocol {
            @url.Http => "http"
            Https => "https"
            Other(protocol) => fail("unsupported HTTP protocol: \{protocol}")
          }
          let port = if parsed.port is Some(port) { ":\{port}" } else { "" }
          let query = if parsed.query is Some(query) { "?\{query}" } else { "" }
          ("\{protocol}://\{parsed.host}\{port}", "/\{parsed.path}\{query}")
        }

        async fn write_request_body(client : @async_http.Client) -> Unit {
          match body {
            Json(json) => client.write(json)
            Text(text) => client.write(text)
            BytesBody(_, bytes) => client.write(bytes)
            BlobBody(_, blob) => client.write(blob.bytes())
            Empty => ()
          }
        }

        async fn read_response(
          client : @async_http.Client,
          response : @async_http.Response,
        ) -> Cmd {
          match expect {
            Json(f) => {
              let text = client.read_all().text()
              let result : Result[Json, HttpError] = try
                @json.parse(text)
              catch {
                error => Err(RequestError(error.to_string()))
              } noraise {
                json => Ok(json)
              }
              f(result)
            }
            Text(f) => f(Ok(client.read_all().text()))
            Bytes(f) =>
              if response.headers.get("content-type") is Some(content_type) {
                f(Ok((content_type, client.read_all().binary())))
              } else {
                f(Err(RequestError("Missing Content-Type header")))
              }
            Blob(f) => {
              let content_type = response.headers
                .get("content-type")
                .unwrap_or("")
              let blob = @dom.Blob::from_bytes(
                client.read_all().binary(),
                content_type,
              )
              f(Ok(blob))
            }
          }
        }

        try {
          let (base_url, path) = request_target()
          let headers : Map[String, String] = Map([])
          match body {
            Json(_) => headers["Content-Type"] = "application/json"
            Text(_) => headers["Content-Type"] = "text/plain"
            BytesBody(content_type, _) | BlobBody(content_type, _) =>
              if !content_type.is_empty() {
                headers["Content-Type"] = content_type
              }
            Empty => ()
          }
          let client = @async_http.Client(base_url)
          defer client.close()
          client.request(request_method(), path, extra_headers=headers)
          write_request_body(client)
          let response = client.end_request()
          if response.code is (200..<300) {
            read_response(client, response)
          } else {
            let reason = if response.reason.is_empty() {
              ""
            } else {
              " \{response.reason}"
            }
            fail_request(RequestError("HTTP \{response.code}\{reason}"))
          }
        } catch {
          error if @async.is_cancellation_error(error) => raise error
          RequestError(_) as error => fail_request(error)
          error => fail_request(RequestError(error.to_string()))
        }
      })
    }
  })
}

///|
#cfg(not(target="js"))
fn[T : ToJson] settle_result(
  result : Result[T, HttpError],
  on_result : (Result[T, HttpError]) -> Cmd,
) -> (Json, Cmd) raise @cmd.HydrateExn {
  match result {
    Err(_) => raise @cmd.HydrateExn::Fallback
    Ok(_) => (ToJson::to_json(result), on_result(result))
  }
}

///|
#cfg(not(target="js"))
fn settle_resolve_request_url(
  url : String,
  current_url : String,
) -> String raise {
  if url.contains("://") {
    return url
  }
  let current = @url.parse(current_url)
  let protocol = match current.protocol {
    Http => "http"
    Https => "https"
    Other(protocol) => fail("unsupported HTTP protocol: \{protocol}")
  }
  let port = if current.port is Some(port) { ":\{port}" } else { "" }
  let origin = "\{protocol}://\{current.host}\{port}"
  if url.is_empty() {
    current_url
  } else if url.has_prefix("//") {
    "\{protocol}:\{url}"
  } else if url.has_prefix("/") {
    "\{origin}\{url}"
  } else if url.has_prefix("?") || url.has_prefix("#") {
    "\{origin}/\{current.path}\{url}"
  } else {
    let directory = if current.path.rev_split_once("/") is Some((directory, _)) {
      if directory.is_empty() {
        "/"
      } else {
        "/\{directory}/"
      }
    } else {
      "/"
    }
    "\{origin}\{directory}\{url}"
  }
}

///|
#cfg(not(target="js"))
fn settle_request_method(
  http_method : String,
) -> @async_http.RequestMethod raise @cmd.HydrateExn {
  match http_method {
    "GET" => @async_http.Get
    "DELETE" => Delete
    "POST" => Post
    "PATCH" => Patch
    "PUT" => Put
    _ => raise @cmd.HydrateExn::Fallback
  }
}

///|
#cfg(not(target="js"))
fn settle_request_target(url : String) -> (String, String) raise {
  let parsed = @url.parse(url)
  let protocol = match parsed.protocol {
    Http => "http"
    Https => "https"
    Other(protocol) => fail("unsupported HTTP protocol: \{protocol}")
  }
  let port = if parsed.port is Some(port) { ":\{port}" } else { "" }
  let query = if parsed.query is Some(query) { "?\{query}" } else { "" }
  ("\{protocol}://\{parsed.host}\{port}", "/\{parsed.path}\{query}")
}

///|
#cfg(not(target="js"))
async fn settle_write_request_body(
  client : @async_http.Client,
  body : Body,
) -> Unit {
  match body {
    Json(json) => client.write(json)
    Text(text) => client.write(text)
    BytesBody(_, bytes) => client.write(bytes)
    BlobBody(_, blob) => client.write(blob.bytes())
    Empty => ()
  }
}

///|
#cfg(not(target="js"))
async fn settle_http_request(
  url : String,
  http_method : String,
  body : Body,
  expect : Expecting,
  current_url : String,
) -> (Json, Cmd) {
  try {
    if expect is Blob(_) {
      raise @cmd.HydrateExn::Fallback
    }
    let url = settle_resolve_request_url(url, current_url)
    let (base_url, path) = settle_request_target(url)
    let headers : Map[String, String] = Map([])
    match body {
      Json(_) => headers["Content-Type"] = "application/json"
      Text(_) => headers["Content-Type"] = "text/plain"
      BytesBody(content_type, _) | BlobBody(content_type, _) =>
        if !content_type.is_empty() {
          headers["Content-Type"] = content_type
        }
      Empty => ()
    }
    let client = @async_http.Client(base_url)
    defer client.close()
    client.request(
      settle_request_method(http_method),
      path,
      extra_headers=headers,
    )
    settle_write_request_body(client, body)
    let response = client.end_request()
    if response.code < 200 || response.code >= 300 {
      raise @cmd.HydrateExn::Fallback
    }
    match expect {
      Json(f) => {
        let result : Result[Json, HttpError] = Ok(
          @json.parse(client.read_all().text()),
        )
        settle_result(result, f)
      }
      Text(f) => {
        let result : Result[String, HttpError] = Ok(client.read_all().text())
        settle_result(result, f)
      }
      Bytes(f) => {
        guard response.headers.get("content-type") is Some(content_type) else {
          raise @cmd.HydrateExn::Fallback
        }
        let result : Result[(ContentType, Bytes), HttpError] = Ok(
          (content_type, client.read_all().binary()),
        )
        settle_result(result, f)
      }
      Blob(_) => raise @cmd.HydrateExn::Fallback
    }
  } catch {
    error if @async.is_cancellation_error(error) => raise error
    @cmd.HydrateExn::Fallback => raise @cmd.HydrateExn::Fallback
    _ => raise @cmd.HydrateExn::Fallback
  }
}

///|
#cfg(not(target="js"))
fn init {
  op.on_settle((extension, context) => {
    guard extension is Request(url~, http_method~, body~, expect~) else {
      raise Unhandled
    }
    Async(() => {
      settle_http_request(
        url,
        http_method,
        body,
        expect,
        context.get_current_url(),
      )
    })
  })
}
