///|
using @rabbita {type Html, type Val}

///|
using @html {button, div, form, h1, input, label, option, p, select}

///|
fn app() -> Val[Html] {
  let initial : Model = {
    text: "initial",
    changed: "",
    choice: "red",
    submits: 0,
    focused: false,
    keydowns: 0,
    decorated: false,
    locked: false,
    checked: false,
    handler_a: 0,
    handler_b: 0,
    file_name: "",
    file_type: "",
    file_size: 0,
    file_count: 0,
    file_modified: false,
    file_selections: 0,
    file_byte_count: 0,
    file_first_byte: -1,
    file_last_byte: -1,
    file_read: "idle",
  }
  let (model, emit) = @rabbita.create_state(initial, update~)
  model.view(model => {
    let field_attrs = @html.Attrs::build()
      .on_focus(_ => emit(Focused))
      .on_blur(_ => emit(Blurred))
      .on_keydown(_ => emit(KeyDown))
    let composed_attrs = @html.Attrs::build()
      .on_click(_ => emit(HandlerA))
      .on_click(_ => emit(HandlerB))
    div <| [
      h1("Forms and events"),
      form(on_submit=emit(Submitted), [
        label(for_="name-input", "Name"),
        input(
          id="name-input",
          value=model.text,
          on_input=emit.map(value => InputChanged(value)),
          on_change=emit.map(value => ChangeCommitted(value)),
          attrs=field_attrs,
        ),
        label(for_="color-select", "Color"),
        select(
          id="color-select",
          on_change=emit.map(value => ChoiceChanged(value)),
          [
            option(value="red", selected=model.choice == "red", "Red"),
            option(value="blue", selected=model.choice == "blue", "Blue"),
          ],
        ),
        button(type_="submit", "Submit form"),
      ]),
      p(id="input-value", "input: \{model.text}"),
      p(id="change-value", "change: \{model.changed}"),
      p(id="choice-value", "choice: \{model.choice}"),
      p(id="submit-count", "submits: \{model.submits}"),
      p(id="focus-state", if model.focused { "focused" } else { "blurred" }),
      p(id="keydown-count", "keydowns: \{model.keydowns}"),
      button(on_click=emit(ResetValue), "Reset controlled value"),
      button(on_click=emit(ToggleDecoration), "Toggle title attribute"),
      button(
        id="decorated-button",
        title?=if model.decorated { Some("decorated") } else { None },
        "Decorated target",
      ),
      button(on_click=emit(ToggleLocked), "Toggle disabled"),
      button(id="controlled-button", disabled=model.locked, "Controlled button"),
      button(on_click=emit(ToggleChecked), "Toggle checked"),
      label(for_="controlled-checkbox", "Controlled checkbox"),
      input(
        id="controlled-checkbox",
        input_type=Checkbox,
        checked=model.checked,
      ),
      button(attrs=composed_attrs, "Run composed handlers"),
      p(id="handler-a", "handler a: \{model.handler_a}"),
      p(id="handler-b", "handler b: \{model.handler_b}"),
      label(for_="file-input", "Choose files"),
      input(
        id="file-input",
        input_type=File,
        accept="text/markdown,.md",
        multiple=true,
        on_files=emit.map(files => FilesSelected(files)),
      ),
      p(id="file-name", "file name: \{model.file_name}"),
      p(id="file-type", "file type: \{model.file_type}"),
      p(id="file-size", "file size: \{model.file_size}"),
      p(id="file-count", "file count: \{model.file_count}"),
      p(id="file-modified", "file modified: \{model.file_modified}"),
      p(id="file-selections", "file selections: \{model.file_selections}"),
      p(
        id="file-bytes",
        "file bytes: \{model.file_byte_count}, first: \{model.file_first_byte}, last: \{model.file_last_byte}",
      ),
      p(id="file-read", "file read: \{model.file_read}"),
    ]
  })
}
