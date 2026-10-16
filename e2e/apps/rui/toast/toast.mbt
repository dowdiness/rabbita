///|
fn toast_fixture() -> Val[Html] {
  let other = @rui.sonner_host(max_toasts=1, position="top-left", build=scope => {
    (
      @rabbita.Val::constant(
        @rui.button(on_click=scope.show(title="Other host"), "Show other host"),
      ),
      () => @cmd.none,
    )
  })
  let builds = Ref(0)
  let toaster = @rui.sonner_host(max_toasts=3, position="bottom-right", build=scope => {
    builds.val += 1
    let (alternate, emit) = @rabbita.create_state_with_init(
      init=_ => (false, @cmd.none),
      update=(alternate, msg, _) => {
        if msg {
          (true, @cmd.none)
        } else {
          let id = if alternate { "toast-alternate" } else { "toast-editor" }
          (
            alternate,
            @cmd.custom_cmd(kind=AfterRender, _ => {
              if @dom.document().get_element_by_id(id).to_option()
                is Some(element) {
                if element.to_html_element() is Some(editor) {
                  editor.focus()
                }
              }
            }),
          )
        }
      },
    )
    let content = alternate.view(_ => {
      div(style=["display:flex;flex-wrap:wrap;gap:0.5rem"], [
        @html.span("Host builds: \{builds.val}"),
        @html.input(
          id="toast-editor",
          attrs=@html.Attrs::build().aria_label("Editor"),
        ),
        @html.input(
          id="toast-alternate",
          attrs=@html.Attrs::build().aria_label("Alternate editor"),
        ),
        @rui.button(on_click=emit(true), "Use alternate editor"),
        @rui.button(
          size=Sm,
          on_click=scope.show(
            title="Saved",
            description="The draft is kept.",
            variant=ToastDefault,
          ),
          "Show toast",
        ),
        @rui.button(
          size=Sm,
          variant=Secondary,
          on_click=scope.show(
            title="Published",
            description="The preview is live.",
            variant=ToastSuccess,
          ),
          "Show success toast",
        ),
        @rui.button(
          size=Sm,
          variant=Ghost,
          on_click=scope.dismiss_all(),
          "Dismiss all toasts",
        ),
      ])
    })
    (content, () => emit(false))
  })
  toaster.map2(other, (toaster_html, other_html) => {
    @fixture.section("fixture-section-toast", "Toast", [
      toaster_html, other_html,
    ])
  })
}
