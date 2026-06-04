///|
extern "js" fn sync_editor_js(
  host_id : String,
  key : String,
  value : String,
  lang : String,
  on_change : (String) -> Unit,
) -> Unit =
  #| (hostId, key, value, lang, onChange) => {
  #|   import('./support/editor.js?v=cm-25')
  #|     .then(({ syncEditor }) =>
  #|       syncEditor({ hostId, key, value, lang, onChange })
  #|     )
  #|     .catch(error => {
  #|       console.error('[playground editor] failed to load CodeMirror', error)
  #|     })
  #| }

///|
pub fn sync_code_editor(
  host_id : String,
  key : String,
  value : String,
  lang : String,
  on_change : (String) -> @cmd.Cmd,
) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=AfterRender, scheduler => {
    sync_editor_js(host_id, key, value, lang, value => {
      scheduler.add(on_change(value))
    })
  })
}

///|
extern "js" fn focus_editor_range_js(
  host_id : String,
  key : String,
  value : String,
  lang : String,
  on_change : (String) -> Unit,
  line : Int,
  column : Int,
  end_line : Int,
  end_column : Int,
) -> Unit =
  #| (hostId, key, value, lang, onChange, line, column, endLine, endColumn) => {
  #|   import('./support/editor.js?v=cm-25')
  #|     .then(async ({ syncEditor, selectEditorRange }) => {
  #|       if (await syncEditor({ hostId, key, value, lang, onChange })) {
  #|         selectEditorRange({ key, line, column, endLine, endColumn })
  #|       }
  #|     })
  #|     .catch(error => {
  #|       console.error('[playground editor] failed to focus diagnostic', error)
  #|     })
  #| }

///|
pub fn focus_code_editor_range(
  host_id : String,
  key : String,
  value : String,
  lang : String,
  on_change : (String) -> @cmd.Cmd,
  line : Int,
  column : Int,
  end_line : Int,
  end_column : Int,
) -> @cmd.Cmd {
  @cmd.custom_cmd(kind=AfterRender, scheduler => {
    focus_editor_range_js(
      host_id,
      key,
      value,
      lang,
      value => scheduler.add(on_change(value)),
      line,
      column,
      end_line,
      end_column,
    )
  })
}
