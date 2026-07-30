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
  ..on_resume((extension, json, scheduler) => {
    let cmd = match extension {
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
    scheduler.add(cmd)
  })
  ..on_invoke((_, _) => ())

///|
#cfg(target="js")
fn init {
  op.on_invoke((extension, scheduler) => {
    guard extension is Request(url~, http_method~, body~, expect~) else {
      raise Unhandled
    }
    let (content_type, body_kind, text_body, bytes_body, blob_body) = match
      body {
      Json(json) =>
        ("application/json", "text", json.stringify(), Default::default(), None)
      Text(text) => ("text/plain", "text", text, Default::default(), None)
      BytesBody(content_type, bytes) => (content_type, "bytes", "", bytes, None)
      BlobBody(content_type, blob) =>
        (content_type, "blob", "", Default::default(), Some(blob))
      Empty => ("", "empty", "", Default::default(), None)
    }
    let (response_kind, succeed_text, succeed_blob, succeed_bytes, failed) = match
      expect {
      Text(f) =>
        (
          "text",
          text => {
            let result = Ok(text)
            scheduler.add(f(result))
          },
          ignore,
          fn(_, _) { () },
          error => {
            let result = Err(RequestError(error))
            scheduler.add(f(result))
          },
        )
      Json(f) =>
        (
          "text",
          text => {
            let result : Result[Json, HttpError] = try @json.parse(text) catch {
              error => Err(RequestError("\{error}"))
            } noraise {
              json => Ok(json)
            }
            scheduler.add(f(result))
          },
          ignore,
          fn(_, _) { () },
          error => {
            let result = Err(RequestError(error))
            scheduler.add(f(result))
          },
        )
      Bytes(f) =>
        (
          "bytes",
          ignore,
          ignore,
          fn(content_type, bytes) {
            let result = Ok((content_type, bytes))
            scheduler.add(f(result))
          },
          error => {
            let result = Err(RequestError(error))
            scheduler.add(f(result))
          },
        )
      Blob(f) =>
        (
          "blob",
          ignore,
          blob => scheduler.add(f(Ok(blob))),
          fn(_, _) { () },
          error => scheduler.add(f(Err(RequestError(error)))),
        )
    }
    js_request(
      url,
      http_method,
      content_type~,
      body_kind~,
      response_kind~,
      text_body~,
      bytes_body~,
      blob_body=@js.Nullable::from_option(blob_body),
      succeed_text~,
      succeed_blob~,
      succeed_bytes~,
      failed~,
    )
  })
}

///|
#cfg(target="js")
extern "js" fn js_request(
  url : String,
  http_method : String,
  content_type~ : String,
  body_kind~ : String,
  response_kind~ : String,
  text_body~ : String,
  bytes_body~ : Bytes,
  blob_body~ : @js.Nullable[Blob],
  succeed_text~ : (String) -> Unit,
  succeed_blob~ : (Blob) -> Unit,
  succeed_bytes~ : (ContentType, Bytes) -> Unit,
  failed~ : (String) -> Unit,
) =
  #| (url, method, contentType, bodyKind, responseKind, textBody, bytesBody, blobBody, succeedText, succeedBlob, succeedBytes, failed) => {
  #|   const config = { method };
  #|   if (contentType !== "") {
  #|     config.headers = { "Content-Type": contentType };
  #|   }
  #|   switch (bodyKind) {
  #|     case "text":
  #|       config.body = textBody;
  #|       break;
  #|     case "bytes":
  #|       config.body = bytesBody;
  #|       break;
  #|     case "blob":
  #|       config.body = blobBody;
  #|       break;
  #|   }
  #|   fetch(url, config)
  #|     .then((response) => {
  #|       if (!response.ok) {
  #|         const statusText = response.statusText ? ` ${response.statusText}` : "";
  #|         failed(`HTTP ${response.status}${statusText}`);
  #|         return;
  #|       }
  #|       switch (responseKind) {
  #|         case "text":
  #|           return response.text().then((text) => succeedText(text));
  #|         case "blob":
  #|           return response.blob().then((blob) => succeedBlob(blob));
  #|         case "bytes": {
  #|           const responseContentType = response.headers.get("Content-Type");
  #|           if (!responseContentType) {
  #|             throw new Error("Missing Content-Type header");
  #|           }
  #|           return response
  #|             .arrayBuffer()
  #|             .then((buffer) => succeedBytes(responseContentType, new Uint8Array(buffer)));
  #|         }
  #|         default:
  #|           throw new Error(`Unknown response kind: ${responseKind}`);
  #|       }
  #|     })
  #|     .catch((error) => failed(error.toString()));
  #| }

///|
#cfg(not(target="js"))
fn init {
  op.on_settle((extension, settle, scheduler) => {
    guard extension is Request(url~, http_method~, body~, expect~) else {
      raise Unhandled
    }
    let request_method = match http_method {
      "GET" => GET
      "DELETE" => DELETE
      "POST" => POST
      "PATCH" => PATCH
      "PUT" => PUT
      _ => raise Unhandled
    }
    guard handler.val is Some(request_handler) else { raise Unhandled }
    if expect is Blob(f) {
      ignore(f)
      raise Unhandled
    }
    request_handler(request_method, url, body, response => {
      match (expect, response) {
        (Json(f), Json(json)) => {
          let result = Ok(json)
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Text(f), Text(text)) => {
          let result = Ok(text)
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Text(f), Empty) => {
          let result = Ok("")
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Bytes(f), Bytes(content_type, bytes)) => {
          let result = Ok((content_type, bytes))
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Json(f), Error(error)) => {
          let result : Result[Json, HttpError] = Err(error)
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Text(f), Error(error)) => {
          let result : Result[String, HttpError] = Err(error)
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Bytes(f), Error(error)) => {
          let result : Result[(ContentType, Bytes), HttpError] = Err(error)
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Json(f), _) => {
          let result : Result[Json, HttpError] = Err(
            RequestError("unexpected HTTP response kind"),
          )
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Text(f), _) => {
          let result : Result[String, HttpError] = Err(
            RequestError("unexpected HTTP response kind"),
          )
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Bytes(f), _) => {
          let result : Result[(ContentType, Bytes), HttpError] = Err(
            RequestError("unexpected HTTP response kind"),
          )
          settle(ToJson::to_json(result))
          scheduler.add(f(result))
        }
        (Blob(_), _) => ()
      }
    })
  })
}

///|
pub(all) enum Method {
  GET
  DELETE
  POST
  PATCH
  PUT
}

///|
pub(all) enum Response {
  Json(Json)
  Text(String)
  Bytes(ContentType, Bytes)
  Empty
  Error(HttpError)
}

///|
let handler : Ref[((Method, String, Body, (Response) -> Unit) -> Unit)?] = Ref(
  None,
)

///|
pub fn handle(
  callback : (Method, String, Body, (Response) -> Unit) -> Unit,
) -> Unit {
  handler.val = Some(callback)
}
