///|
#cfg(not(target="js"))
#warnings("-alert_experimental")
async test "render appends injected head nodes before the transcript" {
  let app = @rabbita.new(() => {
    @rabbita.Val::constant(
      @html.html([
        @html.head([@html.title("Rabbita")]),
        @html.body([@html.div("content")]),
      ]),
    )
  })
  let rendered = app.render(url="https://example.com/docs", head=[
    @html.link(rel="stylesheet", href="/assets/app.css"),
    @html.script(src="/assets/app.js", type_="module", @html.nothing),
  ])
  inspect(
    rendered,
    content=(
      #|<!DOCTYPE html><html><head><title>Rabbita</title><link href="/assets/app.css" rel="stylesheet"><script src="/assets/app.js" type="module"></script><script id="__rabbita_transcript" type="application/json">{}</script></head><body><div>content</div></body></html>
    ),
  )
}

///|
#cfg(not(target="js"))
#warnings("-alert_experimental")
async test "setup runs once with non-Eq context and composed init commands" {
  let setups = Ref(0)
  let subscriptions = Ref([])
  let app = @rabbita.new(() => {
    let (model, _, context) = @rabbita.create_state_with_setup(
      setup=emit => {
        setups.val += 1
        let (child, child_emit) = @rabbita.create_state_with_init(
          init=_ => (0, @cmd.none),
          update=(model, msg, _) => (model + msg, @cmd.none),
        )
        (0, emit(1), (child, child_emit))
      },
      update=(model, context, msg, emit) => {
        let (_, child_emit) = context
        (
          model + msg,
          @cmd.batch([
            child_emit(msg),
            if msg == 1 {
              emit(2)
            } else {
              @cmd.none
            },
          ]),
        )
      },
      subscriptions=(model, context, _) => {
        let (_, child_emit) = context
        ignore(child_emit(0))
        subscriptions.val.push(model)
        @sub.none
      },
    )
    model.map2(context.0, (parent, child) => {
      @html.html([@html.head(@html.nothing), @html.body("\{parent}/\{child}")])
    })
  })
  let rendered = app.render(url="https://example.com/")
  assert_true(rendered.contains("<body>3/3</body>"))
  assert_eq(setups.val, 1)
  assert_eq(subscriptions.val, [0, 1, 3])
}
