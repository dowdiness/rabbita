///|
priv struct Payload {
  value : String
} derive(FromJson)

///|
priv struct RequestPayload {
  name : String
} derive(ToJson)

///|
priv struct Model {
  get : String
  post : String
  put : String
  patch : String
  delete : String
  text : String
  json : String
  blob : String
  bytes : String
  failure : String
} derive(Eq)

///|
priv enum Msg {
  StartGet
  GetFinished(Result[String, Error])
  StartPost
  PostFinished(Result[String, Error])
  StartPut
  PutFinished(Result[String, Error])
  StartPatch
  PatchFinished(Result[String, Error])
  StartDelete
  DeleteFinished(Error?)
  StartText
  TextFinished(Result[String, Error])
  StartJson
  JsonFinished(Result[Payload, Error])
  StartBlob
  BlobFinished(Result[@dom.Blob, Error])
  StartBytes
  BytesFinished(Result[(String, Bytes), Error])
  StartFailure
  FailureFinished(Result[String, Error])
}

///|
fn result_text(result : Result[String, Error]) -> String {
  match result {
    Ok(value) => value
    Err(_) => "failed"
  }
}
