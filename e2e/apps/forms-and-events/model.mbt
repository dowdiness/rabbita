///|
priv struct Model {
  text : String
  changed : String
  choice : String
  submits : Int
  focused : Bool
  keydowns : Int
  decorated : Bool
  locked : Bool
  checked : Bool
  handler_a : Int
  handler_b : Int
  file_name : String
  file_type : String
  file_size : Int
  file_count : Int
  file_modified : Bool
  file_selections : Int
  file_byte_count : Int
  file_first_byte : Int
  file_last_byte : Int
  file_read : String
} derive(Eq)

///|
priv enum Msg {
  InputChanged(String)
  ChangeCommitted(String)
  ChoiceChanged(String)
  Submitted
  Focused
  Blurred
  KeyDown
  ToggleDecoration
  ToggleLocked
  ToggleChecked
  ResetValue
  HandlerA
  HandlerB
  FilesSelected(FixedArray[@dom.File])
  FileRead(Result[Bytes, Error])
}

///|
fn update(
  model : Model,
  message : Msg,
  emit : @rabbita.Emit[Msg],
) -> (Model, @rabbita.Cmd) {
  match message {
    InputChanged(value) => ({ ..model, text: value }, @rabbita.none)
    ChangeCommitted(value) => ({ ..model, changed: value }, @rabbita.none)
    ChoiceChanged(value) => ({ ..model, choice: value }, @rabbita.none)
    Submitted => ({ ..model, submits: model.submits + 1 }, @rabbita.none)
    Focused => ({ ..model, focused: true }, @rabbita.none)
    Blurred => ({ ..model, focused: false }, @rabbita.none)
    KeyDown => ({ ..model, keydowns: model.keydowns + 1 }, @rabbita.none)
    ToggleDecoration =>
      ({ ..model, decorated: !model.decorated }, @rabbita.none)
    ToggleLocked => ({ ..model, locked: !model.locked }, @rabbita.none)
    ToggleChecked => ({ ..model, checked: !model.checked }, @rabbita.none)
    ResetValue => ({ ..model, text: "reset" }, @rabbita.none)
    HandlerA => ({ ..model, handler_a: model.handler_a + 1 }, @rabbita.none)
    HandlerB => ({ ..model, handler_b: model.handler_b + 1 }, @rabbita.none)
    FilesSelected(files) =>
      match files.get(0) {
        None => (model, @rabbita.none)
        Some(file) =>
          (
            {
              ..model,
              file_name: file.get_name(),
              file_type: file.as_blob().get_type(),
              file_size: file.as_blob().get_size(),
              file_count: files.length(),
              file_modified: file.get_last_modified() > 0.0,
              file_selections: model.file_selections + 1,
              file_read: "reading",
            },
            @rabbita.attempt(result => emit(FileRead(result)), async fn() {
              file.as_blob().bytes()
            }),
          )
      }
    FileRead(result) =>
      match result {
        Err(_) => ({ ..model, file_read: "failed" }, @rabbita.none)
        Ok(bytes) =>
          (
            {
              ..model,
              file_byte_count: bytes.length(),
              file_first_byte: bytes.get(0).map_or(-1, byte => byte.to_int()),
              file_last_byte: bytes
              .get(bytes.length() - 1)
              .map_or(-1, byte => byte.to_int()),
              file_read: "complete",
            },
            @rabbita.none,
          )
      }
  }
}
