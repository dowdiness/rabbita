///|
extenum @cmd.Extension += {
  ClipboardCopy(Item, Cmd?, ((String) -> Cmd)?)
  ClipboardPaste((Item) -> Cmd, ((String) -> Cmd)?)
}

///|
let op : @cmd.Op = @cmd.Op()
  ..on_invoke(op_invoke)
  ..on_debug(extension => {
    match extension {
      ClipboardCopy(Text(text), _, _) =>
        Repr::ctor("ClipboardCopy", [
          (None, Repr::ctor("Text", [(None, Repr(text))])),
        ])
      ClipboardPaste(_, _) => Repr::ctor("ClipboardPaste", [])
      _ => raise Unhandled
    }
  })

///|
#cfg(target="js")
fn op_invoke(
  extension : @cmd.Extension,
  scheduler : &@cmd.Scheduler,
) -> Unit raise @cmd.Unhandled {
  match extension {
    ClipboardCopy(item, copied, failed) =>
      @js.async_run(() => {
        try {
          match item {
            Text(text) =>
              @dom.window().navigator().clipboard().write_text(text).wait()
              |> ignore
          }
          if copied is Some(message) {
            scheduler.add(message)
          }
        } catch {
          error =>
            if failed is Some(to_message) {
              scheduler.add(to_message(error.to_string()))
            }
        }
      })
    ClipboardPaste(pasted, failed) =>
      @js.async_run(() => {
        try {
          let text : String = @dom.window()
            .navigator()
            .clipboard()
            .read_text()
            .wait()
            |> @js.Value::cast()
          scheduler.add(pasted(Text(text)))
        } catch {
          error =>
            if failed is Some(to_message) {
              scheduler.add(to_message(error.to_string()))
            }
        }
      })
    _ => raise Unhandled
  }
}

///|
#cfg(not(target="js"))
#warnings("-unused_error_type")
fn op_invoke(
  extension : @cmd.Extension,
  _ : &@cmd.Scheduler,
) -> Unit raise @cmd.Unhandled {
  match extension {
    ClipboardCopy(item, copied, failed) => {
      ignore(item)
      ignore(copied)
      ignore(failed)
    }
    ClipboardPaste(pasted, failed) => {
      ignore(pasted)
      ignore(failed)
    }
    _ => ()
  }
}
